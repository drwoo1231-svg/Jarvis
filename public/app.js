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
    ondeviceFields: $('ondeviceFields'),
    setLocalModel: $('setLocalModel'),
    loadModelBtn: $('loadModelBtn'),
    loadProgress: $('loadProgress'),
    setProvider: $('setProvider'),
    baseUrlField: $('baseUrlField'),
    setBaseUrl: $('setBaseUrl'),
    setApiKey: $('setApiKey'),
    keyHint: $('keyHint'),
    setModel: $('setModel'),
    modelSuggestions: $('modelSuggestions'),
    setVoice: $('setVoice'),
    setSpeak: $('setSpeak'),
    setAutoListen: $('setAutoListen'),
    testVoiceBtn: $('testVoiceBtn'),
    resetBtn: $('resetBtn'),
    settingsSave: $('settingsSave'),

    actionToast: $('actionToast'),
  };

  // Bump this whenever the app changes so users can confirm they're on the
  // latest build (shown at the bottom of Settings).
  const APP_VERSION = 'v1.2 · on-device + providers';
  const DEFAULT_LOCAL_MODEL = 'Llama-3.2-1B-Instruct-q4f16_1-MLC';

  // Per-provider defaults for the Direct-mode connection.
  const PROVIDER_DEFAULTS = {
    anthropic:           { model: 'claude-sonnet-5',  keyPlaceholder: 'sk-ant-…', keyUrl: 'console.anthropic.com' },
    gemini:              { model: 'gemini-2.0-flash',  keyPlaceholder: 'AIza…',    keyUrl: 'aistudio.google.com/apikey' },
    openai:              { model: 'gpt-4o-mini',       keyPlaceholder: 'sk-…',     keyUrl: 'platform.openai.com/api-keys' },
    'openai-compatible': { model: '',                  keyPlaceholder: 'provider key', keyUrl: '' },
  };
  const MODEL_SUGGESTIONS = {
    anthropic: ['claude-sonnet-5', 'claude-opus-4-8', 'claude-haiku-4-5-20251001'],
    gemini: ['gemini-2.0-flash', 'gemini-2.0-flash-lite', 'gemini-1.5-flash', 'gemini-1.5-pro'],
    openai: ['gpt-4o-mini', 'gpt-4o', 'gpt-4.1-mini', 'o4-mini'],
    'openai-compatible': ['llama-3.3-70b-versatile', 'llama-3.1-8b-instant', 'mixtral-8x7b-32768'],
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
  const NO_SERVER_MSG =
    "There's no JARVIS server at this address — the app is running from static " +
    "hosting (like GitHub Pages). Tap the settings gear at the top right, set " +
    "Connection mode to Direct, paste your Anthropic API key, and save.";

  async function callModel(messages) {
    const mode = cfg.state.mode;
    if (mode === 'demo') return demoReply(messages);
    if (mode === 'ondevice') return callLocal(messages);
    if (mode === 'direct') return callDirect(messages);

    // Server mode — but on static hosting (e.g. GitHub Pages) there is no
    // backend, so POST /api/chat comes back 404/405 or fails outright. In that
    // case, quietly use Direct mode if a key is available, otherwise explain.
    let res;
    try {
      res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages,
          userName: cfg.state.userName,
          honorific: cfg.state.honorific,
          model: cfg.state.model,
        }),
      });
    } catch (e) {
      if (cfg.state.apiKey) { cfg.set({ mode: 'direct' }); return callDirect(messages); }
      throw new Error(NO_SERVER_MSG);
    }

    if (res.ok) {
      const data = await res.json();
      return data.text || '';
    }

    // Not OK. Our own server always answers with JSON; a non-JSON body (or a
    // "method not supported" status) means there is no JARVIS backend here —
    // i.e. we're on static hosting like GitHub Pages.
    let info = null;
    try { info = await res.json(); } catch { /* non-JSON => not our server */ }

    if (info && info.error === 'no_key') {
      if (cfg.state.apiKey) { cfg.set({ mode: 'direct' }); return callDirect(messages); }
      throw new Error('This JARVIS server has no API key configured. Tap the settings gear, choose Direct mode, and paste your own Anthropic API key.');
    }

    const noBackend = !info || res.status === 404 || res.status === 405 || res.status === 501;
    if (noBackend) {
      if (cfg.state.apiKey) { cfg.set({ mode: 'direct' }); return callDirect(messages); }
      throw new Error(NO_SERVER_MSG);
    }

    throw new Error(info.message || info.error || `Server error (${res.status}).`);
  }

  // Direct (browser) mode — talks to the chosen provider's API directly.
  async function callDirect(messages) {
    const key = cfg.state.apiKey;
    if (!key) throw new Error('Direct mode needs an API key. Tap the settings gear and paste your provider key.');
    const provider = cfg.state.provider || 'anthropic';
    const model = cfg.state.model || (PROVIDER_DEFAULTS[provider] || {}).model || '';
    const system = buildClientSystemPrompt();
    try {
      if (provider === 'anthropic') return await callAnthropic(messages, key, model, system);
      if (provider === 'gemini') return await callGemini(messages, key, model, system);
      // openai and openai-compatible both speak the OpenAI chat-completions API
      const baseUrl = provider === 'openai'
        ? 'https://api.openai.com/v1'
        : (cfg.state.baseUrl || '').trim().replace(/\/+$/, '');
      if (!baseUrl) throw new Error('Please set the API base URL in Settings for this provider (e.g. https://api.groq.com/openai/v1).');
      return await callOpenAICompatible(messages, key, model, system, baseUrl);
    } catch (e) {
      // A failed fetch (CORS / offline / bad host) surfaces as a TypeError.
      if (e instanceof TypeError) {
        throw new Error(`Couldn't reach the ${provider} API from the browser — it may block direct browser requests (CORS), or the base URL is wrong. Anthropic, OpenAI, Google Gemini and OpenRouter are known to work from the browser.`);
      }
      throw e;
    }
  }

  function providerError(name, raw, status) {
    let msg = raw;
    try {
      const j = JSON.parse(raw);
      msg = (j.error && (j.error.message || j.error.status)) || j.message || raw;
    } catch { /* keep raw */ }
    return new Error(`${name} error (${status}): ${String(msg).slice(0, 240)}`);
  }

  async function callAnthropic(messages, key, model, system) {
    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
        'anthropic-dangerous-direct-browser-access': 'true',
      },
      body: JSON.stringify({ model, max_tokens: 1024, system, messages }),
    });
    const raw = await res.text();
    if (!res.ok) throw providerError('Anthropic API', raw, res.status);
    const data = JSON.parse(raw);
    return (data.content || []).filter((b) => b.type === 'text').map((b) => b.text).join('\n').trim();
  }

  async function callOpenAICompatible(messages, key, model, system, baseUrl) {
    const res = await fetch(baseUrl + '/chat/completions', {
      method: 'POST',
      headers: { 'Authorization': 'Bearer ' + key, 'content-type': 'application/json' },
      body: JSON.stringify({
        model,
        max_tokens: 1024,
        messages: [{ role: 'system', content: system }].concat(
          messages.map((m) => ({ role: m.role, content: String(m.content) }))
        ),
      }),
    });
    const raw = await res.text();
    if (!res.ok) throw providerError('API', raw, res.status);
    const data = JSON.parse(raw);
    const text = data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content;
    return (text || '').trim();
  }

  async function callGemini(messages, key, model, system) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(key)}`;
    const contents = messages.map((m) => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: String(m.content) }],
    }));
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        system_instruction: { parts: [{ text: system }] },
        contents,
        generationConfig: { maxOutputTokens: 1024 },
      }),
    });
    const raw = await res.text();
    if (!res.ok) throw providerError('Gemini API', raw, res.status);
    const data = JSON.parse(raw);
    const cand = data.candidates && data.candidates[0];
    const parts = (cand && cand.content && cand.content.parts) || [];
    return parts.map((p) => p.text || '').join('').trim();
  }

  /* ---------------- On-device (no key) ---------------- */
  const ONDEVICE_UNSUPPORTED =
    "This device can't run on-device AI — it needs WebGPU, which requires a " +
    "recent phone (iOS 18+, with WebGPU enabled) or a recent desktop Chrome/Edge. " +
    "Open Settings and pick a cloud provider (Direct mode) instead — Google " +
    "Gemini has a free tier.";

  function friendlyLocalError(e) {
    const msg = (e && e.message) ? e.message : String(e);
    if (/dynamically imported module|Failed to fetch|NetworkError|load failed/i.test(msg)) {
      return "Couldn't download the on-device AI engine. This first load needs a solid internet connection — please check your connection and try again.";
    }
    if (/webgpu|gpu|adapter|createDevice|requestAdapter/i.test(msg)) {
      return ONDEVICE_UNSUPPORTED;
    }
    if (/not found in|cannot find model|model_id/i.test(msg)) {
      return "That on-device model isn't available. Open Settings and choose a different on-device model.";
    }
    return 'On-device AI error: ' + msg;
  }

  async function callLocal(messages) {
    if (!window.JarvisLocal || !JarvisLocal.isSupported()) {
      throw new Error(ONDEVICE_UNSUPPORTED);
    }
    const model = cfg.state.localModel || DEFAULT_LOCAL_MODEL;
    try {
      if (!JarvisLocal.isReady(model)) {
        setStatus('LOADING MODEL', 'thinking');
        await JarvisLocal.ensure(model, (p) => {
          const pct = Math.round((p && p.progress || 0) * 100);
          setStatus('LOADING ' + pct + '%', 'thinking');
          el.caption.textContent = (p && p.text) || 'Preparing on-device AI…';
        });
        el.caption.textContent = '';
      }
      setStatus('THINKING', 'thinking');
      return await JarvisLocal.chat(messages, buildClientSystemPrompt());
    } catch (e) {
      throw new Error(friendlyLocalError(e));
    }
  }

  // Kick off the model download/load from Settings, showing progress there.
  async function ensureLocalModel(model) {
    if (!window.JarvisLocal || !JarvisLocal.isSupported()) {
      el.loadProgress.textContent = ONDEVICE_UNSUPPORTED;
      return false;
    }
    el.loadModelBtn.disabled = true;
    const prev = el.loadModelBtn.textContent;
    el.loadModelBtn.textContent = 'Loading…';
    try {
      await JarvisLocal.ensure(model, (p) => {
        const pct = Math.round((p && p.progress || 0) * 100);
        el.loadProgress.textContent = (p && p.text ? p.text : 'Loading…') +
          (pct ? '  (' + pct + '%)' : '');
      });
      el.loadProgress.textContent = 'Model ready — JARVIS now runs on your device.';
      return true;
    } catch (e) {
      el.loadProgress.textContent = friendlyLocalError(e);
      return false;
    } finally {
      el.loadModelBtn.disabled = false;
      el.loadModelBtn.textContent = prev;
    }
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
    probeEnvironment();
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

  /* Detect whether a usable backend exists. On static hosting (GitHub Pages)
     there isn't one, so guide the user to set up Direct mode with a key. */
  async function probeEnvironment() {
    let health = null;
    try {
      const r = await fetch('/api/health', { cache: 'no-store' });
      if (r.ok) health = await r.json();
    } catch { /* no server reachable */ }

    if (health && health.keyConfigured) return;          // server ready to chat
    if (cfg.state.mode === 'ondevice') return;            // runs locally, no key
    if (cfg.state.apiKey) {                                // we have our own key
      if (cfg.state.mode === 'server') cfg.set({ mode: 'direct' });
      return;
    }
    if (cfg.state.mode === 'demo') return;                // user deliberately offline

    // No server and no key: JARVIS can't converse yet. Guide the user.
    addMessage('jarvis',
      "One small matter before we begin. To hold a proper conversation I'll need " +
      "an API key from an AI provider. I'm opening settings now — choose a provider " +
      "(Google Gemini offers a free tier), paste your key, and save.");
    setTimeout(() => {
      openSettings();
      el.setMode.value = 'direct';
      updateDirectVisibility();
      el.setApiKey && el.setApiKey.focus();
    }, 1100);
  }

  /* ---------------- Settings ---------------- */
  function openSettings() {
    el.setName.value = cfg.state.userName || '';
    el.setHonorific.value = cfg.state.honorific || 'Sir';
    el.setMode.value = cfg.state.mode || 'server';
    el.setProvider.value = cfg.state.provider || 'anthropic';
    el.setBaseUrl.value = cfg.state.baseUrl || '';
    el.setApiKey.value = cfg.state.apiKey || '';
    el.setModel.value = cfg.state.model || 'claude-sonnet-5';
    el.setLocalModel.value = cfg.state.localModel || DEFAULT_LOCAL_MODEL;
    el.loadProgress.textContent = '';
    el.setSpeak.checked = cfg.state.speak !== false;
    el.setAutoListen.checked = !!cfg.state.autoListen;
    populateVoices();
    updateDirectVisibility();
    updateProviderUI();
    const ver = document.getElementById('appVersion');
    if (ver) ver.textContent = 'JARVIS ' + APP_VERSION;
    el.settings.classList.remove('hidden');
  }
  function updateDirectVisibility() {
    const m = el.setMode.value;
    el.directFields.style.display = m === 'direct' ? 'block' : 'none';
    el.ondeviceFields.style.display = m === 'ondevice' ? 'block' : 'none';
  }
  function updateProviderUI() {
    const p = el.setProvider.value;
    const d = PROVIDER_DEFAULTS[p] || {};
    el.baseUrlField.style.display = (p === 'openai-compatible') ? 'block' : 'none';
    el.setApiKey.placeholder = d.keyPlaceholder || 'API key';
    el.setModel.placeholder = d.model || 'model name';
    el.modelSuggestions.innerHTML = (MODEL_SUGGESTIONS[p] || [])
      .map((m) => `<option value="${m}"></option>`).join('');
    el.keyHint.textContent = d.keyUrl
      ? `Stored only in this browser. Get a key at ${d.keyUrl}.`
      : 'Stored only in this browser (localStorage).';
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
      provider: el.setProvider.value,
      baseUrl: el.setBaseUrl.value.trim(),
      apiKey: el.setApiKey.value.trim(),
      model: el.setModel.value.trim(),
      localModel: el.setLocalModel.value,
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
    el.setProvider.addEventListener('change', () => {
      // Switching provider swaps in that provider's default model.
      const p = el.setProvider.value;
      el.setModel.value = (PROVIDER_DEFAULTS[p] || {}).model || '';
      updateProviderUI();
    });
    el.loadModelBtn.addEventListener('click', () => ensureLocalModel(el.setLocalModel.value));
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
      probeEnvironment();
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
