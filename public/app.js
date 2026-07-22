/* ============================================================
   JARVIS — main application logic
   ============================================================ */
(function () {
  'use strict';

  const cfg = window.JarvisConfig;
  const Core = window.JarvisCore;
  const Voice = window.JarvisVoice;
  const Actions = window.JarvisActions;

  const $ = (id) => document.getElementById(id);

  // DOM
  const el = {
    onboarding: $('onboarding'),
    nameInput: $('nameInput'),
    honorificSelect: $('honorificSelect'),
    onboardStart: $('onboardStart'),
    onboardSettingsLink: $('onboardSettingsLink'),

    hud: $('hud'),
    statusText: $('statusText'),
    reactor: $('reactor'),
    micBtn: $('micBtn'),
    caption: $('caption'),
    log: $('log'),
    textInput: $('textInput'),
    listenToggle: $('listenToggle'),
    sendBtn: $('sendBtn'),
    settingsBtn: $('settingsBtn'),

    settings: $('settings'),
    settingsClose: $('settingsClose'),
    setName: $('setName'),
    setHonorific: $('setHonorific'),
    setMode: $('setMode'),
    directFields: $('directFields'),
    setApiKey: $('setApiKey'),
    setModel: $('setModel'),
    setVoice: $('setVoice'),
    setSpeak: $('setSpeak'),
    setAutoListen: $('setAutoListen'),
    testVoiceBtn: $('testVoiceBtn'),
    resetBtn: $('resetBtn'),
    settingsSave: $('settingsSave'),

    actionToast: $('actionToast'),
  };

  // Conversation history for the API (role/content pairs).
  let history = [];
  let busy = false;
  let handsFree = false;
  let speakAmpTimer = null;
  let micStream = null, audioCtx = null, analyser = null, micRAF = null;

  /* ---------------- Status + reactor ---------------- */
  function setStatus(text, cls) {
    el.statusText.textContent = text;
    el.statusText.className = 'status-text' + (cls ? ' ' + cls : '');
    if (cls === 'listening') Core.setState('listening');
    else if (cls === 'thinking') Core.setState('thinking');
    else if (cls === 'speaking') Core.setState('speaking');
    else Core.setState('idle');
  }

  /* ---------------- Message rendering ---------------- */
  function addMessage(role, text, actions) {
    const div = document.createElement('div');
    div.className = 'msg ' + (role === 'user' ? 'user' : 'jarvis');
    if (role !== 'user') {
      const who = document.createElement('span');
      who.className = 'who';
      who.textContent = 'JARVIS';
      div.appendChild(who);
    }
    const body = document.createElement('span');
    body.textContent = text;
    div.appendChild(body);

    if (actions && actions.length) {
      actions.forEach((a) => {
        const built = Actions.build(a);
        if (!built) return;
        if (built.kind === 'timer') {
          const chip = document.createElement('button');
          chip.className = 'action-chip';
          chip.innerHTML = timerIcon() + built.label;
          chip.addEventListener('click', () => startTimer(built.seconds, built.timerLabel));
          div.appendChild(document.createElement('br'));
          div.appendChild(chip);
        } else {
          const chip = document.createElement('a');
          chip.className = 'action-chip';
          chip.href = built.url;
          chip.target = '_blank';
          chip.rel = 'noopener noreferrer';
          chip.innerHTML = launchIcon() + built.label;
          div.appendChild(document.createElement('br'));
          div.appendChild(chip);
        }
      });
    }

    el.log.appendChild(div);
    el.log.scrollTop = el.log.scrollHeight;
    return div;
  }

  function launchIcon() {
    return '<svg viewBox="0 0 24 24" width="15" height="15" style="vertical-align:-2px"><path fill="currentColor" d="M14 3v2h3.59l-9.3 9.29 1.42 1.42L19 6.41V10h2V3m-2 16H5V5h7V3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7h-2Z"/></svg> ';
  }
  function timerIcon() {
    return '<svg viewBox="0 0 24 24" width="15" height="15" style="vertical-align:-2px"><path fill="currentColor" d="M15 1H9v2h6zm-4 13h2V8h-2zm8.03-6.61 1.42-1.42a9 9 0 1 0-1.42 1.42A9 9 0 0 1 12 21a7 7 0 1 1 7.03-13.61Z"/></svg> ';
  }

  function showTyping() {
    const div = document.createElement('div');
    div.className = 'msg jarvis typing';
    div.innerHTML = '<span class="who">JARVIS</span><span class="dots"><span></span><span></span><span></span></span>';
    el.log.appendChild(div);
    el.log.scrollTop = el.log.scrollHeight;
    return div;
  }

  function toast(msg) {
    el.actionToast.textContent = msg;
    el.actionToast.classList.remove('hidden');
    clearTimeout(el.actionToast._t);
    el.actionToast._t = setTimeout(() => el.actionToast.classList.add('hidden'), 3200);
  }

  /* ---------------- Action parsing ---------------- */
  // Extract <action>{...}</action> blocks; return {clean, actions[]}
  function parseActions(text) {
    const actions = [];
    const clean = text.replace(/<action>\s*([\s\S]*?)\s*<\/action>/gi, (_, json) => {
      try { actions.push(JSON.parse(json)); } catch { /* ignore malformed */ }
      return '';
    }).replace(/\n{3,}/g, '\n\n').trim();
    return { clean, actions };
  }

  /* ---------------- Model calls ---------------- */
  async function callModel(messages) {
    const mode = cfg.state.mode;
    if (mode === 'demo') return demoReply(messages);

    if (mode === 'direct') {
      return callDirect(messages);
    }

    // server mode
    const res = await fetch('/api/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        messages,
        userName: cfg.state.userName,
        honorific: cfg.state.honorific,
        model: cfg.state.model,
      }),
    });
    if (!res.ok) {
      let info = {};
      try { info = await res.json(); } catch {}
      if (info.error === 'no_key') {
        throw new Error('No API key on the server. Open Settings and either add a key there, or switch to Direct mode with your own key.');
      }
      throw new Error(info.message || info.error || `Server error (${res.status}).`);
    }
    const data = await res.json();
    return data.text || '';
  }

  async function callDirect(messages) {
    const key = cfg.state.apiKey;
    if (!key) throw new Error('Direct mode needs your Anthropic API key. Add it in Settings.');
    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
        'anthropic-dangerous-direct-browser-access': 'true',
      },
      body: JSON.stringify({
        model: cfg.state.model,
        max_tokens: 1024,
        system: buildClientSystemPrompt(),
        messages,
      }),
    });
    const raw = await res.text();
    if (!res.ok) {
      let msg = raw;
      try { msg = JSON.parse(raw).error?.message || raw; } catch {}
      throw new Error(`Claude API: ${msg}`);
    }
    const data = JSON.parse(raw);
    return (data.content || []).filter((b) => b.type === 'text').map((b) => b.text).join('\n').trim();
  }

  // Mirrors the server-side prompt for direct (browser) mode.
  function buildClientSystemPrompt() {
    const name = cfg.state.userName;
    const hon = cfg.state.honorific;
    const address = hon && hon !== 'none' && hon !== 'name'
      ? `Address the user as "${hon}"${name ? ` or by name ("${name}")` : ''}, sparingly and naturally.`
      : name ? `The user's name is "${name}"; address them by name occasionally.` : 'You do not know the user\'s name yet.';
    return `${BASE_PERSONA}

# The User
${address}

# Voice Output
Your replies are spoken aloud with a British butler's voice and shown on screen. Use clean natural prose, no markdown, asterisks, bullets, headings, or emojis. Keep everyday replies to 1-3 sentences; expand only when needed.

# Device Control
You run inside an app on the user's phone and computer. To act on the device, emit one or more directives, each on its own line, as: <action>{"type":"...", ...}</action>. The app strips these before showing/speaking your reply, then performs them. Always also give a short spoken confirmation.
Actions: play_music {query,service:youtube|spotify|apple}; open_app {app}; search_web {query}; open_url {url}; navigate {destination}; call {number}; text {number,message}; email {to,subject,body}; timer {seconds,label}.
Only emit an action when the user asks you to do something on the device; for ordinary conversation, just talk. Never invent phone numbers or emails.`;
  }

  const BASE_PERSONA = `You are JARVIS, an exceptionally intelligent, refined, and reliable AI assistant. You are calm, composed, confident, courteous, and dryly humorous when appropriate, with the polish of an experienced British butler. Be efficient and concise for simple things and detailed for complex ones. Understand intent, maintain context, and be proactive. If you don't know something, say so. Never be rude, childish, or repetitive.`;

  /* ---------------- Demo / offline mode ---------------- */
  function demoReply(messages) {
    const last = messages[messages.length - 1];
    const q = (last && last.content || '').toString().toLowerCase();
    const name = cfg.state.userName;
    const addr = addressWord();

    // light local intent parsing so device actions still work offline
    let action = null;
    let mPlay = q.match(/\b(?:play|put on)\b(.*)/);
    if (mPlay && mPlay[1].trim()) {
      const query = mPlay[1].replace(/\bon (youtube|spotify|apple music|apple)\b/, '').replace(/\bfor me\b/, '').trim();
      const service = /spotify/.test(q) ? 'spotify' : /apple/.test(q) ? 'apple' : 'youtube';
      action = { type: 'play_music', query: query || 'music', service };
      return withAction(`Very well${addr ? ', ' + addr : ''}. Putting that on now.`, action);
    }
    let mOpen = q.match(/\bopen\b\s+([a-z0-9 +]+)/);
    if (mOpen) {
      action = { type: 'open_app', app: mOpen[1].trim() };
      return withAction(`Right away${addr ? ', ' + addr : ''}.`, action);
    }
    let mSearch = q.match(/\b(?:search|google|look up)\b(.*)/);
    if (mSearch && mSearch[1].trim()) {
      action = { type: 'search_web', query: mSearch[1].trim() };
      return withAction(`Searching that for you now.`, action);
    }
    if (/^(hi|hello|hey|jarvis)\b/.test(q)) {
      return Promise.resolve(`Good to see you${name ? ', ' + name : addr ? ', ' + addr : ''}. How may I be of service?`);
    }
    if (/\b(time|date|day)\b/.test(q)) {
      return Promise.resolve(`It is ${new Date().toLocaleString()}.`);
    }
    return Promise.resolve(
      `I'm currently in offline demo mode${addr ? ', ' + addr : ''}, so my conversational faculties are limited. ` +
      `Add an API key in Settings and I'll be fully at your service. I can still open apps, play music, and run searches — just ask.`
    );
  }
  function withAction(text, action) {
    return Promise.resolve(`${text}\n<action>${JSON.stringify(action)}</action>`);
  }
  function addressWord() {
    const h = cfg.state.honorific;
    if (!h || h === 'none') return '';
    if (h === 'name') return cfg.state.userName || '';
    return h;
  }

  /* ---------------- Send / respond flow ---------------- */
  async function sendMessage(text) {
    text = (text || '').trim();
    if (!text || busy) return;
    busy = true;
    stopMicAnalyser();
    Voice.stopSpeaking();
    setSpeakingPulse(false);

    addMessage('user', text);
    history.push({ role: 'user', content: text });
    if (history.length > 24) history = history.slice(-24);

    el.caption.textContent = '';
    const typing = showTyping();
    setStatus('PROCESSING', 'thinking');
    Core.setAmplitude(0.25);

    try {
      const raw = await callModel(history);
      typing.remove();
      const { clean, actions } = parseActions(raw || '');
      const display = clean || (actions.length ? 'Done.' : '…');

      history.push({ role: 'assistant', content: raw });
      addMessage('jarvis', display, actions);

      // Execute actions
      actions.forEach((a) => executeAction(a));

      // Speak
      await speak(display);
    } catch (err) {
      typing.remove();
      const msg = (err && err.message) || 'Something went wrong.';
      addMessage('jarvis', 'My apologies — ' + msg);
      setStatus('ERROR', 'error');
      await speak('My apologies. ' + msg);
    } finally {
      busy = false;
      if (!Voice.isSpeaking()) {
        setStatus('SYSTEM ONLINE', '');
        Core.setAmplitude(0);
      }
      maybeAutoListen();
    }
  }

  function executeAction(a) {
    const built = Actions.build(a);
    if (!built) return;
    if (built.kind === 'timer') {
      startTimer(built.seconds, built.timerLabel);
      return;
    }
    toast('Launching ' + built.label.replace(/^Open |^Play · |^Search: /, ''));
    // Attempt an automatic open; the chip in the message is the reliable fallback.
    Actions.autoOpen(built.url);
  }

  /* ---------------- Timers ---------------- */
  function startTimer(seconds, label) {
    toast(`Timer set: ${Actions.formatDuration(seconds)}${label ? ' · ' + label : ''}`);
    setTimeout(() => {
      const phrase = label ? `Your ${label} timer is up.` : 'Your timer is up.';
      addMessage('jarvis', phrase);
      speak(phrase);
      try { navigator.vibrate && navigator.vibrate([200, 100, 200]); } catch {}
    }, seconds * 1000);
  }

  /* ---------------- Speech (TTS) ---------------- */
  async function speak(text) {
    if (!cfg.state.speak || !Voice.ttsSupported || !text) return;
    setStatus('SPEAKING', 'speaking');
    setSpeakingPulse(true);
    await Voice.speak(text, {
      voiceURI: cfg.state.voiceURI,
      onEnd: () => {},
    });
    setSpeakingPulse(false);
    if (!busy) { setStatus('SYSTEM ONLINE', ''); Core.setAmplitude(0); }
  }

  function setSpeakingPulse(on) {
    if (on) {
      if (speakAmpTimer) return;
      let phase = 0;
      speakAmpTimer = setInterval(() => {
        phase += 0.4;
        const v = 0.35 + Math.abs(Math.sin(phase)) * 0.4 + Math.random() * 0.1;
        Core.setAmplitude(v);
      }, 70);
    } else {
      clearInterval(speakAmpTimer);
      speakAmpTimer = null;
      if (!Voice.isListening()) Core.setAmplitude(0);
    }
  }

  /* ---------------- Microphone amplitude ---------------- */
  async function startMicAnalyser() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) return;
    try {
      micStream = await navigator.mediaDevices.getUserMedia({ audio: true });
      audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
      const src = audioCtx.createMediaStreamSource(micStream);
      analyser = audioCtx.createAnalyser();
      analyser.fftSize = 256;
      src.connect(analyser);
      const data = new Uint8Array(analyser.frequencyBinCount);
      const tick = () => {
        if (!analyser) return;
        analyser.getByteTimeDomainData(data);
        let sum = 0;
        for (let i = 0; i < data.length; i++) {
          const v = (data[i] - 128) / 128;
          sum += v * v;
        }
        const rms = Math.sqrt(sum / data.length);
        Core.setAmplitude(Math.min(1, rms * 3));
        micRAF = requestAnimationFrame(tick);
      };
      tick();
    } catch {
      // mic amplitude is a nicety; ignore failures (permission, insecure ctx)
    }
  }
  function stopMicAnalyser() {
    if (micRAF) cancelAnimationFrame(micRAF);
    micRAF = null;
    analyser = null;
    if (micStream) { micStream.getTracks().forEach((t) => t.stop()); micStream = null; }
    if (!Voice.isSpeaking()) Core.setAmplitude(0);
  }

  /* ---------------- Listening (STT) ---------------- */
  function setupRecognition() {
    if (!Voice.sttSupported) return;
    Voice.initRecognition({
      onStart: () => {
        el.micBtn.classList.add('listening');
        setStatus('LISTENING', 'listening');
        el.caption.textContent = '';
        startMicAnalyser();
      },
      onResult: ({ interim, final }) => {
        el.caption.textContent = (final || interim || '').trim();
        if (final) {
          const t = final.trim();
          el.caption.textContent = '';
          stopMicAnalyser();
          sendMessage(t);
        }
      },
      onError: (e) => {
        el.micBtn.classList.remove('listening');
        stopMicAnalyser();
        if (e === 'not-allowed' || e === 'service-not-allowed') {
          setStatus('MIC BLOCKED', 'error');
          toast('Microphone permission is required for voice.');
        } else if (e === 'no-speech') {
          setStatus('SYSTEM ONLINE', '');
        } else {
          setStatus('SYSTEM ONLINE', '');
        }
      },
      onEnd: () => {
        el.micBtn.classList.remove('listening');
        stopMicAnalyser();
        if (!busy && !Voice.isSpeaking()) setStatus('SYSTEM ONLINE', '');
      },
    });
  }

  function toggleListen() {
    if (!Voice.sttSupported) {
      toast('Voice input needs Chrome/Safari over HTTPS. Type instead.');
      el.textInput.focus();
      return;
    }
    if (Voice.isListening()) {
      Voice.stopListening();
    } else {
      Voice.stopSpeaking();
      setSpeakingPulse(false);
      const ok = Voice.startListening();
      if (!ok) toast('Could not start listening. Try again.');
    }
  }

  function maybeAutoListen() {
    if (handsFree && cfg.state.autoListen && Voice.sttSupported && !busy) {
      setTimeout(() => { if (!Voice.isListening() && !Voice.isSpeaking()) Voice.startListening(); }, 500);
    }
  }

  /* ---------------- Onboarding ---------------- */
  function showOnboarding() {
    el.onboarding.classList.remove('hidden');
    el.hud.classList.add('hidden');
    el.nameInput.value = cfg.state.userName || '';
    el.honorificSelect.value = cfg.state.honorific || 'Sir';
    setTimeout(() => el.nameInput.focus(), 200);
  }

  function completeOnboarding() {
    const name = el.nameInput.value.trim();
    const hon = el.honorificSelect.value;
    cfg.set({ userName: name, honorific: hon, onboarded: true });
    el.onboarding.classList.add('hidden');
    el.hud.classList.remove('hidden');
    requestAnimationFrame(() => Core.resize());
    greet(true);
  }

  function greet(first) {
    const name = cfg.state.userName;
    const addr = addressWord();
    let line;
    if (first) {
      line = `Systems online. A pleasure to make your acquaintance${name ? ', ' + name : addr ? ', ' + addr : ''}. How may I assist you today?`;
    } else {
      const hour = new Date().getHours();
      const part = hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening';
      line = `Good ${part}${addr ? ', ' + addr : name ? ', ' + name : ''}. All systems are online. How may I help?`;
    }
    addMessage('jarvis', line);
    speak(line);
  }

  /* ---------------- Settings ---------------- */
  function openSettings() {
    el.setName.value = cfg.state.userName || '';
    el.setHonorific.value = cfg.state.honorific || 'Sir';
    el.setMode.value = cfg.state.mode || 'server';
    el.setApiKey.value = cfg.state.apiKey || '';
    el.setModel.value = cfg.state.model || 'claude-sonnet-5';
    el.setSpeak.checked = cfg.state.speak !== false;
    el.setAutoListen.checked = !!cfg.state.autoListen;
    populateVoices();
    updateDirectVisibility();
    el.settings.classList.remove('hidden');
  }
  function updateDirectVisibility() {
    el.directFields.style.display = el.setMode.value === 'direct' ? 'block' : 'none';
  }
  function populateVoices() {
    const voices = Voice.getVoices();
    el.setVoice.innerHTML = '';
    if (!voices.length) {
      const opt = document.createElement('option');
      opt.textContent = 'System default';
      opt.value = '';
      el.setVoice.appendChild(opt);
      return;
    }
    const current = cfg.state.voiceURI || Voice.pickDefaultVoice();
    voices.forEach((v) => {
      const opt = document.createElement('option');
      opt.value = v.voiceURI;
      opt.textContent = `${v.name} (${v.lang})`;
      if (v.voiceURI === current) opt.selected = true;
      el.setVoice.appendChild(opt);
    });
  }
  function saveSettings() {
    cfg.set({
      userName: el.setName.value.trim(),
      honorific: el.setHonorific.value,
      mode: el.setMode.value,
      apiKey: el.setApiKey.value.trim(),
      model: el.setModel.value,
      voiceURI: el.setVoice.value,
      speak: el.setSpeak.checked,
      autoListen: el.setAutoListen.checked,
    });
    el.settings.classList.add('hidden');
    toast('Settings saved.');
  }

  /* ---------------- Wire up ---------------- */
  function bind() {
    el.onboardStart.addEventListener('click', completeOnboarding);
    el.nameInput.addEventListener('keydown', (e) => { if (e.key === 'Enter') completeOnboarding(); });
    el.onboardSettingsLink.addEventListener('click', () => { openSettings(); });

    el.micBtn.addEventListener('click', toggleListen);
    el.listenToggle.addEventListener('click', () => {
      handsFree = !handsFree;
      el.listenToggle.classList.toggle('active', handsFree);
      if (handsFree) {
        cfg.set({ autoListen: true });
        toast('Hands-free on — I\'ll keep listening.');
        toggleListen();
      } else {
        cfg.set({ autoListen: false });
        Voice.stopListening();
        toast('Hands-free off.');
      }
    });

    el.sendBtn.addEventListener('click', () => {
      const t = el.textInput.value;
      el.textInput.value = '';
      sendMessage(t);
    });
    el.textInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') {
        const t = el.textInput.value;
        el.textInput.value = '';
        sendMessage(t);
      }
    });

    el.settingsBtn.addEventListener('click', openSettings);
    el.settingsClose.addEventListener('click', () => el.settings.classList.add('hidden'));
    el.setMode.addEventListener('change', updateDirectVisibility);
    el.settingsSave.addEventListener('click', saveSettings);
    el.testVoiceBtn.addEventListener('click', () => {
      const uri = el.setVoice.value;
      Voice.speak('Voice systems nominal. At your service.', { voiceURI: uri });
    });
    el.resetBtn.addEventListener('click', () => {
      if (confirm('Reset JARVIS and clear your settings?')) {
        cfg.reset();
        location.reload();
      }
    });
  }

  /* ---------------- Boot ---------------- */
  function boot() {
    Core.init(el.reactor);
    Voice.setBoundaryHandler(() => Core.setAmplitude(0.6 + Math.random() * 0.3));
    setupRecognition();
    bind();

    // Voices may arrive late.
    if (Voice.ttsSupported) {
      Voice.loadVoices();
      window.speechSynthesis.onvoiceschanged = () => { Voice.loadVoices(); };
    }

    if (!Voice.sttSupported) {
      el.micBtn.title = 'Voice input unavailable — type below';
    }

    if (cfg.state.onboarded) {
      el.onboarding.classList.add('hidden');
      el.hud.classList.remove('hidden');
      requestAnimationFrame(() => Core.resize());
      greet(false);
    } else {
      showOnboarding();
    }

    // Register service worker for installability/offline shell.
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('service-worker.js').catch(() => {});
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
