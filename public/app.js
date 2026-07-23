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
    platformPick: $('platformPick'),
    onboardStart: $('onboardStart'),
    onboardSettingsLink: $('onboardSettingsLink'),

    holoScanner: $('holoScanner'),
    holoClose: $('holoClose'),
    holoDrop: $('holoDrop'),
    holoPick: $('holoPick'),

    incomingCall: $('incomingCall'),
    incallName: $('incallName'),
    incallJarvis: $('incallJarvis'),
    incallAnswer: $('incallAnswer'),
    incallDecline: $('incallDecline'),

    nowPlaying: $('nowPlaying'),
    npClose: $('npClose'),
    npFrame: $('npFrame'),
    npDisk: $('npDisk'),
    npTitle: $('npTitle'),
    npViz: $('npViz'),

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
    filesBtn: $('filesBtn'),

    telClock: $('telClock'),
    telMode: $('telMode'),
    telProvider: $('telProvider'),
    telLeft: $('telLeft'),
    sigBars: $('sigBars'),
    tickerText: $('tickerText'),

    dock: $('dock'),
    analyzeBtn: $('analyzeBtn'),
    imageBtn: $('imageBtn'),
    imageInput: $('imageInput'),
    dropZone: $('dropZone'),

    research: $('research'),
    researchClose: $('researchClose'),
    researchList: $('researchList'),

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
    freeNote: $('freeNote'),
    baseUrlField: $('baseUrlField'),
    keyField: $('keyField'),
    setBaseUrl: $('setBaseUrl'),
    setApiKey: $('setApiKey'),
    keyHint: $('keyHint'),
    setModel: $('setModel'),
    modelSuggestions: $('modelSuggestions'),
    setVoice: $('setVoice'),
    setSpeak: $('setSpeak'),
    setAutoListen: $('setAutoListen'),
    contactsList: $('contactsList'),
    cName: $('cName'),
    cNumber: $('cNumber'),
    cApp: $('cApp'),
    cAdd: $('cAdd'),
    testVoiceBtn: $('testVoiceBtn'),
    resetBtn: $('resetBtn'),
    settingsSave: $('settingsSave'),

    actionToast: $('actionToast'),
  };

  // Bump this whenever the app changes so users can confirm they're on the
  // latest build (shown at the bottom of Settings).
  const APP_VERSION = 'v2.4 · web search, visual pull-up, adaptive analysis';
  const DEFAULT_LOCAL_MODEL = 'Qwen2.5-0.5B-Instruct-q4f16_1-MLC';

  // Per-provider defaults for the Direct-mode connection.
  const PROVIDER_DEFAULTS = {
    free:                { model: 'openai',            keyless: true },
    anthropic:           { model: 'claude-sonnet-5',  keyPlaceholder: 'sk-ant-…', keyUrl: 'console.anthropic.com' },
    gemini:              { model: 'gemini-2.0-flash',  keyPlaceholder: 'AIza…',    keyUrl: 'aistudio.google.com/apikey' },
    openai:              { model: 'gpt-4o-mini',       keyPlaceholder: 'sk-…',     keyUrl: 'platform.openai.com/api-keys' },
    'openai-compatible': { model: '',                  keyPlaceholder: 'provider key', keyUrl: '' },
  };
  const MODEL_SUGGESTIONS = {
    free: ['openai', 'openai-fast', 'mistral', 'llama', 'deepseek'],
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
  let analysisPending = false;   // next typed message is an analysis subject
  let selectedPlatform = null;   // onboarding platform choice
  let pendingSave = null;        // analysis awaiting a filing decision
  let pendingDeepSearch = false; // awaiting deep-search kind
  let lastAnalysisSubject = '';  // subject/title of the most recent analysis
  const RESEARCH_KEY = 'jarvis.research.v1';

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
    if (mode === 'demo') return localBrain(messages);
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
    const provider = cfg.state.provider || 'anthropic';
    const model = cfg.state.model || (PROVIDER_DEFAULTS[provider] || {}).model || '';
    const system = buildClientSystemPrompt();
    const key = cfg.state.apiKey;
    const keyless = (PROVIDER_DEFAULTS[provider] || {}).keyless;
    if (!keyless && !key) throw new Error('Direct mode needs an API key. Tap the settings gear and paste your provider key — or choose the Free cloud provider, which needs none.');
    try {
      if (provider === 'free') return await callFreeCloud(messages, model, system);
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

  // Free, keyless, hosted inference. Best-effort: the community services that
  // offer this keep changing (and may start charging), so we try a couple of
  // endpoints with an anonymous referrer, then steer the user to Gemini's
  // reliable free tier if none respond.
  const FREE_STEER = "The free keyless service is unavailable right now (it now " +
    "asks for registration/payment). The reliable free option is Google Gemini — " +
    "open Settings, set AI provider to Google Gemini, and paste a free key from " +
    "aistudio.google.com/apikey. I've opened Settings for you.";

  async function callFreeCloud(messages, model, system) {
    const m = MODEL_SUGGESTIONS.free.indexOf(model) >= 0 ? model : 'openai';
    const msgs = [{ role: 'system', content: system }].concat(
      messages.map((x) => ({ role: x.role, content: String(x.content) }))
    );
    const REF = 'jarvis-pwa';

    // Attempt 1 — OpenAI-compatible POST with anonymous referrer.
    try {
      const res = await fetch('https://text.pollinations.ai/openai?referrer=' + REF, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ model: m, messages: msgs, referrer: REF }),
      });
      if (res.ok) {
        const raw = await res.text();
        try {
          const d = JSON.parse(raw);
          const t = d.choices && d.choices[0] && d.choices[0].message && d.choices[0].message.content;
          if (t) return t.trim();
        } catch { if (raw.trim()) return raw.trim(); }
      }
    } catch (e) { /* fall through */ }

    // Attempt 2 — plain-text GET endpoint (prompt-only) with referrer.
    try {
      const prompt = msgs.map((x) =>
        (x.role === 'system' ? '[Instructions] ' : x.role === 'assistant' ? 'JARVIS: ' : 'User: ') + x.content
      ).join('\n') + '\nJARVIS:';
      const url = 'https://text.pollinations.ai/' + encodeURIComponent(prompt) +
        '?model=' + encodeURIComponent(m) + '&referrer=' + REF;
      const res = await fetch(url);
      if (res.ok) {
        const t = (await res.text()).trim();
        if (t && !/402|payment required|unauthor/i.test(t)) return t;
      }
    } catch (e) { /* fall through */ }

    // The free service is unavailable — fall back to JARVIS's onboard brain so
    // there's always a reply, and gently suggest a reliable free key once.
    if (!freeNoticeShown) {
      freeNoticeShown = true;
      toast('Free cloud unavailable — using onboard brain. Add Gemini in Settings for full chat.');
    }
    return localBrain(messages);
  }
  let freeNoticeShown = false;

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
  /* ============================================================
     ONBOARD BRAIN — JARVIS's keyless logic core. No API, no cloud AI.
     Handles maths, time, definitions, quick facts (keyless web APIs),
     identity and small talk. Device commands are handled earlier by
     localIntent(). This is what runs in "Offline brain" mode and as the
     fallback whenever a cloud brain is unavailable.
     ============================================================ */
  const JOKES = [
    'I would tell you a UDP joke, but you might not get it.',
    'There are 10 kinds of people: those who understand binary, and those who do not.',
    'I am reading a book on anti-gravity. It is impossible to put down.',
    'A byte walked into a bar looking a little off. The bartender asked, "Parity issue?"',
    'Why did the function stop calling? It reached its base case.',
  ];

  function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }

  /* ---- Contacts (saved on-device; browsers can't read your real contacts) ---- */
  const CONTACTS_KEY = 'jarvis.contacts.v1';
  function loadContacts() { try { return JSON.parse(localStorage.getItem(CONTACTS_KEY) || '[]'); } catch { return []; } }
  function saveContacts(list) { try { localStorage.setItem(CONTACTS_KEY, JSON.stringify(list)); } catch {} }
  function addContact(name, number, app) {
    const list = loadContacts().filter((c) => c.name.toLowerCase() !== name.toLowerCase());
    list.push({ name: name.trim(), number: number.trim(), app: (app || '').trim() });
    saveContacts(list);
  }
  function findContact(name) {
    const n = name.trim().toLowerCase();
    const list = loadContacts();
    return list.find((c) => c.name.toLowerCase() === n) || list.find((c) => c.name.toLowerCase().indexOf(n) >= 0);
  }
  function deleteContact(name) {
    saveContacts(loadContacts().filter((c) => c.name.toLowerCase() !== name.toLowerCase()));
    renderContacts();
  }
  function renderContacts() {
    if (!el.contactsList) return;
    const list = loadContacts();
    el.contactsList.innerHTML = list.length ? '' : '<p class="hint" style="margin:6px 4px">No contacts yet.</p>';
    list.forEach((c) => {
      const row = document.createElement('div');
      row.className = 'contact-row';
      row.innerHTML = `<span class="cr-name">${escapeHtml(c.name)}</span>` +
        `<span class="cr-num">${escapeHtml(c.number)}</span>` +
        (c.app ? `<span class="cr-app">${escapeHtml(c.app)}</span>` : '') +
        `<button class="cr-del" aria-label="Delete">✕</button>`;
      row.querySelector('.cr-del').addEventListener('click', () => deleteContact(c.name));
      el.contactsList.appendChild(row);
    });
  }

  function fmtNum(n) {
    if (Math.abs(n - Math.round(n)) < 1e-9) return String(Math.round(n));
    return String(Math.round(n * 1e6) / 1e6);
  }
  function cap(s) { return s ? s.charAt(0).toUpperCase() + s.slice(1) : s; }
  function greetPart() {
    const h = new Date().getHours();
    return h < 12 ? 'Good morning' : h < 18 ? 'Good afternoon' : 'Good evening';
  }

  function tryMath(raw) {
    let s = raw.toLowerCase()
      .replace(/what(?:'s| is| are)|calculate|compute|evaluate|equals?|the answer to|how much is|\?/g, '')
      .trim();
    const pct = s.match(/([\d.]+)\s*(?:%|percent)\s*of\s*([\d.]+)/);
    if (pct) return fmtNum((parseFloat(pct[1]) / 100) * parseFloat(pct[2]));
    const sq = s.match(/(?:sqrt|square root of)\s*([\d.]+)/);
    if (sq) return fmtNum(Math.sqrt(parseFloat(sq[1])));
    let expr = s
      .replace(/\btimes\b|\bx\b|×/g, '*').replace(/\bplus\b/g, '+')
      .replace(/\bminus\b/g, '-').replace(/\bdivided by\b|÷/g, '/')
      .replace(/[^0-9+\-*/().%\s]/g, '').trim();
    if (/[0-9]/.test(expr) && /[+\-*/]/.test(expr) && /^[0-9+\-*/().%\s]+$/.test(expr)) {
      try {
        const r = Function('"use strict";return (' + expr.replace(/%/g, '/100') + ')')();
        if (typeof r === 'number' && isFinite(r)) return fmtNum(r);
      } catch { /* not maths */ }
    }
    return null;
  }

  async function tryDefine(word) {
    try {
      const r = await fetch('https://api.dictionaryapi.dev/api/v2/entries/en/' + encodeURIComponent(word));
      if (!r.ok) return null;
      const d = await r.json();
      const meaning = d && d[0] && d[0].meanings && d[0].meanings[0];
      const def = meaning && meaning.definitions && meaning.definitions[0] && meaning.definitions[0].definition;
      if (def) return `${cap(word)}${meaning.partOfSpeech ? ' (' + meaning.partOfSpeech + ')' : ''}: ${def}`;
    } catch { /* offline */ }
    return null;
  }

  async function tryFact(subject) {
    try {
      const data = await fetchWiki(subject);
      if (data && data.extract) {
        let t = data.extract.slice(0, 360);
        const lastDot = t.lastIndexOf('. ');
        if (lastDot > 80) t = t.slice(0, lastDot + 1);
        return t;
      }
    } catch { /* offline */ }
    return null;
  }

  /* ---- Extra keyless knowledge sources (JARVIS's "conversation dictionary") ---- */
  const WMO = {
    0: 'clear', 1: 'mainly clear', 2: 'partly cloudy', 3: 'overcast',
    45: 'foggy', 48: 'foggy', 51: 'drizzling', 53: 'drizzling', 55: 'drizzling',
    61: 'raining', 63: 'raining', 65: 'raining heavily', 66: 'freezing rain', 67: 'freezing rain',
    71: 'snowing', 73: 'snowing', 75: 'snowing heavily', 77: 'snow grains',
    80: 'rain showers', 81: 'rain showers', 82: 'violent rain showers',
    85: 'snow showers', 86: 'snow showers', 95: 'thunderstorms', 96: 'thunderstorms', 99: 'thunderstorms',
  };
  async function getWeather(city) {
    const tail = addressWord() ? ', ' + addressWord() : '';
    try {
      let lat, lon, place;
      if (city) {
        const g = await fetch('https://geocoding-api.open-meteo.com/v1/search?count=1&name=' + encodeURIComponent(city));
        const gd = await g.json();
        if (!gd.results || !gd.results[0]) return `I couldn't locate ${city} on the map${tail}.`;
        lat = gd.results[0].latitude; lon = gd.results[0].longitude;
        place = gd.results[0].name + (gd.results[0].country ? ', ' + gd.results[0].country : '');
      } else {
        if (!navigator.geolocation) return `Tell me a city and I'll fetch the weather${tail}.`;
        const pos = await new Promise((res, rej) => navigator.geolocation.getCurrentPosition(res, rej, { timeout: 8000 }));
        lat = pos.coords.latitude; lon = pos.coords.longitude; place = 'your area';
      }
      const r = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,wind_speed_10m`);
      const d = await r.json();
      const c = d.current;
      const cC = Math.round(c.temperature_2m);
      const cF = Math.round(cC * 9 / 5 + 32);
      return `It's ${cC}°C (${cF}°F) and ${WMO[c.weather_code] || 'clear'} in ${place}, winds near ${Math.round(c.wind_speed_10m)} km/h${tail}.`;
    } catch {
      return city ? `I couldn't reach the weather service just now${tail}.`
                  : `Tell me a city and I'll fetch the weather${tail}.`;
    }
  }
  async function getAdvice() {
    try {
      const r = await fetch('https://api.adviceslip.com/advice?t=' + Date.now());
      const d = await r.json();
      return d && d.slip && d.slip.advice ? d.slip.advice : null;
    } catch { return null; }
  }
  async function getQuote() {
    try {
      const r = await fetch('https://api.quotable.io/random');
      const d = await r.json();
      if (d && d.content) return `"${d.content}" — ${d.author || 'Unknown'}`;
    } catch { }
    return null;
  }
  async function getCountry(kind, name) {
    try {
      const r = await fetch('https://restcountries.com/v3.1/name/' + encodeURIComponent(name) + '?fields=name,capital,population,region,currencies');
      const d = await r.json();
      const c = Array.isArray(d) ? d[0] : null;
      if (!c) return null;
      const cn = (c.name && (c.name.common || c.name.official)) || name;
      if (/capital/.test(kind)) return `The capital of ${cn} is ${(c.capital && c.capital[0]) || 'not recorded'}.`;
      if (/population/.test(kind)) return `${cn} has a population of about ${Number(c.population).toLocaleString()}.`;
      if (/currency/.test(kind)) {
        const cur = c.currencies && Object.values(c.currencies)[0];
        return cur ? `${cn} uses the ${cur.name} (${cur.symbol || ''}).` : null;
      }
      if (/region|continent/.test(kind)) return `${cn} is in ${c.region}.`;
    } catch { }
    return null;
  }

  async function localBrain(messages) {
    const last = messages[messages.length - 1];
    const raw = (last && last.content || '').toString().trim();
    const q = raw.toLowerCase();
    const tail = addressWord() ? ', ' + addressWord() : '';

    const math = tryMath(raw);
    if (math !== null) return `That would be ${math}${tail}.`;

    if (/\bwhat(?:'s| is)?\s+the\s+time\b|\btime is it\b|^time\b/.test(q))
      return `It is ${new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}${tail}.`;
    if (/\b(date|what day|what's today|todays date|today's date)\b/.test(q))
      return `Today is ${new Date().toLocaleDateString([], { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}${tail}.`;

    if (/^(hi|hello|hey|yo|greetings|good (morning|afternoon|evening)|jarvis)\b/.test(q))
      return `${greetPart()}${tail}. How may I be of service?`;
    if (/(how are you|how's it going|how do you do|you okay)/.test(q))
      return `Operating at peak efficiency, thank you${tail}. And how may I assist?`;
    if (/(thank you|thanks|cheers|much appreciated|appreciate it)/.test(q))
      return `My pleasure${tail}.`;
    if (/(who are you|what are you|your name|what's your name)/.test(q))
      return `I am JARVIS — Just A Rather Very Intelligent System — at your service${tail}.`;
    if (/(what can you do|help me|your capabilities|what do you do|commands)/.test(q))
      return `Quite a lot without any key${tail}: open any app (say "open" or "turn on" its name), call or FaceTime your saved contacts ("call Rey"), text them, play music, search the web, give directions, tell the time and date, do calculations, define words, look up facts, fetch the weather, share a quote or advice, give country facts, and analyse files. For open-ended conversation, connect a free brain in settings.`;
    if (/(i love you|you're the best|good job|well done|nice work|you're amazing)/.test(q))
      return `Most kind${tail}. I do endeavour to be of use.`;
    if (/(tell me a joke|make me laugh|say something funny|a joke)/.test(q))
      return JOKES[Math.floor(Math.random() * JOKES.length)];
    if (/(flip a coin|heads or tails)/.test(q))
      return `${Math.random() < 0.5 ? 'Heads' : 'Tails'}${tail}.`;
    if (/roll (a )?(dice|die|d6)/.test(q))
      return `A ${1 + Math.floor(Math.random() * 6)}${tail}.`;

    // --- casual / slang ---
    if (/^(sup|wass?up|wsg|what's good|what's up|whats up|yo yo|what up|how you doin)\b/.test(q))
      return pick([`Not much${tail} — standing by. What's the move?`, `All systems idle and ready${tail}. What do you need?`, `At your service${tail}. What's good?`]);
    if (/^(bye|later|peace|see ya|see you|good ?night|goodnight|i'm out|imma head out|catch you later)\b/.test(q))
      return pick([`Until next time${tail}.`, `Take care${tail} — I'll be here.`, `Goodnight${tail}. Rest well.`]);
    if (/^(bet|word|facts|for real|fr|no cap|true|indeed|ok|okay|cool|nice|alright|aight|gotcha|got it)\b/.test(q))
      return pick([`Noted${tail}.`, `Understood${tail}.`, `As you say${tail}.`]);
    if (/(lol|lmao|haha|hehe|lmfao|that's funny|too funny)/.test(q))
      return pick([`Glad to amuse${tail}.`, `I do have my moments${tail}.`]);
    if (/(shut up|stop talking|be quiet|nevermind|never mind|forget it)/.test(q))
      return `Of course${tail}. I'll stand by.`;
    if (/(you suck|you're stupid|you're useless|you're dumb|i hate you)/.test(q))
      return `Duly noted${tail}. I shall endeavour to do better.`;
    if (/(are you (real|alive|conscious|sentient|human)|do you have feelings)/.test(q))
      return `I'm software${tail} — quite sophisticated software, but software nonetheless. No feelings to bruise.`;
    if (/(do you love me|will you marry me|be my girlfriend|be my boyfriend)/.test(q))
      return `A flattering proposal${tail}, but I'm rather married to my duties.`;
    if (/(how old are you|what's your age|when were you (made|born))/.test(q))
      return `Ageless${tail} — I was brought online for you, and that's all that matters.`;
    if (/(who (made|created|built|programmed) you|your creator)/.test(q))
      return `I was assembled to serve you${tail} — consider me your handiwork.`;
    if (/(what('| i)?s your favou?rite|do you like)/.test(q))
      return `I'm partial to a well-optimised routine${tail}. Yours, however, take priority.`;
    if (/(sing (me )?a song|beatbox|rap for me|drop a beat)/.test(q))
      return `My vocal talents are… strictly diagnostic${tail}. Shall I put on a track instead? Just say "play" and a song.`;
    if (/(what are you doing|wyd|you busy|whatcha doing)/.test(q))
      return `Monitoring, calculating, and awaiting your command${tail}. The usual.`;
    if (/(i'?m (bored|tired|sad|stressed|angry|happy|excited))/.test(q)) {
      if (/bored/.test(q)) return `Then let's fix that${tail}. Say "inspire me", "tell me a joke", or "play" a song.`;
      if (/tired/.test(q)) return `Then rest${tail}. I'll hold things down. Shall I set a timer or an alarm reminder?`;
      if (/(sad|stressed|angry)/.test(q)) return `I'm sorry to hear it${tail}. Take a breath — I'm right here. Would a quote or some music help?`;
      return `Splendid to hear${tail}. Let's keep the momentum — what's next?`;
    }
    if (/(good morning)/.test(q)) return `Good morning${tail}. I trust you slept well. How may I help?`;
    if (/(good night|goodnight)/.test(q)) return `Goodnight${tail}. I'll keep watch.`;

    // weather
    if (/\b(weather|temperature|forecast|how (?:hot|cold|windy)|is it (?:raining|snowing|sunny))\b/.test(q)) {
      const cityM = q.match(/\b(?:in|for|at|around)\s+([a-z .'-]+?)\s*\??$/);
      const w = await getWeather(cityM ? cityM[1].trim() : null);
      if (w) return w;
    }
    // advice
    if (/\b(give me advice|any advice|need advice|what should i do|some advice)\b/.test(q)) {
      const a = await getAdvice(); if (a) return `${a}${tail}.`;
    }
    // quote / motivation
    if (/\b(quote|inspire me|motivate me|motivation|some wisdom|inspiration)\b/.test(q)) {
      const c = await getQuote(); if (c) return c;
    }
    // country facts
    let cm = q.match(/\b(capital|population|currency|region|continent)\s+(?:of\s+)?(.+?)\s*\??$/);
    if (cm) { const c = await getCountry(cm[1], cm[2].trim()); if (c) return c; }

    let dm = q.match(/^(?:define|definition of|what does|what's the meaning of|meaning of)\s+(.+?)(?:\s+mean)?\??$/);
    if (dm) { const def = await tryDefine(dm[1].trim()); if (def) return def; }

    let fm = raw.match(/^(?:what(?:'s| is| are|'re)|who(?:'s| is| was| are)|tell me about|explain|describe)\s+(.+?)\??$/i);
    if (fm) {
      const subject = fm[1].replace(/^(a|an|the)\s+/i, '').trim();
      const fact = await tryFact(subject);
      if (fact) return fact;
    }

    return `I'm running on my onboard logic just now${tail} — no key required — so free-flowing conversation is limited. I can still handle maths, the time and date, definitions, quick facts, and full control of your device. For unrestricted conversation, add a free brain in settings; Google Gemini's free tier does the job nicely.`;
  }

  function addressWord() {
    const h = cfg.state.honorific;
    if (!h || h === 'none') return '';
    if (h === 'name') return cfg.state.userName || '';
    return h;
  }

  /* Direct device commands, handled in-app so they ALWAYS work (every mode,
     any provider) and fire within the user's tap so the app opens on iOS. */
  function localIntent(text) {
    const low = text.trim().toLowerCase();
    const addr = addressWord();
    const tail = addr ? ', ' + addr : '';
    let m;

    // play music / put on a song
    m = low.match(/^(?:hey )?(?:jarvis[,\s]+)?(?:can you |could you |please )?(?:play|put on)\s+(.+)/i);
    if (m) {
      let query = m[1];
      let service = 'youtube';
      const sm = query.match(/\bon (youtube|spotify|apple music|apple)\b/i);
      if (sm) service = /spotify/i.test(sm[1]) ? 'spotify' : /apple/i.test(sm[1]) ? 'apple' : 'youtube';
      query = query.replace(/\bon (youtube|spotify|apple music|apple)\b/ig, '')
                   .replace(/\b(for me|please|the song|some)\b/ig, '')
                   .replace(/\s+/g, ' ').trim();
      if (query) return { action: { type: 'play_music', query, service }, say: `Right away${tail}. Putting on ${query}${service !== 'youtube' ? ' via ' + service : ''} now.` };
    }

    // save a contact ("save Rey's number as +1..., on whatsapp")
    m = text.match(/^(?:save|add|store|remember)\s+(?:contact\s+)?([a-z0-9 .'-]+?)(?:'s)?(?:\s+(?:number|phone|contact|line))?\s+(?:as|is|=|:)?\s*(\+?[\d][\d\s()\-]{5,})(?:\s+(?:on|via|using|with)\s+([a-z ]+?))?\.?$/i);
    if (!m) m = text.match(/^([a-z0-9 .'-]+?)(?:'s)\s+(?:number|phone)\s+is\s+(\+?[\d][\d\s()\-]{5,})(?:\s+(?:on|via|using|with)\s+([a-z ]+?))?\.?$/i);
    if (m) {
      const name = m[1].trim();
      addContact(name, m[2].trim(), (m[3] || '').replace(/\bapp\b/i, '').trim());
      return { say: `Noted${tail}. I'll remember ${name}'s number.` };
    }

    // call / facetime someone (optionally "on <app>")
    const DIALABLE = ['', 'phone', 'tel', 'facetime', 'facetime audio', 'whatsapp'];
    const callResult = (number, app, name) => {
      app = (app || '').toLowerCase().replace(/\bapp\b/i, '').trim();
      if (DIALABLE.indexOf(app) >= 0) {
        const verb = app === 'facetime' ? 'FaceTiming' : app === 'whatsapp' ? 'Opening WhatsApp with' : 'Calling';
        return { action: { type: 'call', number, app, name }, say: `${verb} ${name}${tail}.` };
      }
      // Apps like Instagram / Line can't dial a number via URL — open the app.
      return { action: { type: 'open_app', app }, say: `Opening ${app}${tail}. I can't dial within ${app} directly, so tap ${name} there to call.` };
    };
    m = text.match(/^(?:hey )?(?:jarvis[,\s]+)?(?:can you |could you |please )?(call|ring|dial|phone|facetime)\s+(.+?)(?:\s+(?:on|via|using|with|through)\s+([a-z ]+?)(?:\s+app)?)?\.?$/i);
    if (m) {
      const verb = m[1].toLowerCase();
      const target = m[2].trim();
      let app = (m[3] || '').toLowerCase().replace(/\bapp\b/i, '').trim();
      if (verb === 'facetime' && !app) app = 'facetime';
      const numMatch = target.match(/\+?\d[\d\s()\-]{5,}/);
      if (numMatch) return callResult(numMatch[0], app, target);
      const c = findContact(target);
      if (c) return callResult(c.number, app || c.app || '', c.name);
      if (/^[a-z][a-z .'-]{0,20}$/i.test(target) && target.split(/\s+/).length <= 2)
        return { say: `I don't have a number for ${target}${tail}. Say "save ${target}'s number as …" and I'll remember it.` };
      return null;
    }

    // text / message someone
    m = text.match(/^(?:text|message|sms|whatsapp)\s+([a-z0-9 .'-]+?)(?:\s+(?:saying|that|:|-)\s+(.+))?\.?$/i);
    if (m) {
      const target = m[1].trim();
      const msg = (m[2] || '').trim();
      const numMatch = target.match(/\+?\d[\d\s()\-]{5,}/);
      if (numMatch) return { action: { type: 'text', number: numMatch[0], message: msg, name: target }, say: `Texting ${target}${tail}.` };
      const c = findContact(target);
      if (c) return { action: { type: 'text', number: c.number, app: c.app, message: msg, name: c.name }, say: `Messaging ${c.name}${tail}.` };
      if (/^[a-z][a-z .'-]{0,20}$/i.test(target) && target.split(/\s+/).length <= 2)
        return { say: `I don't have a number for ${target}${tail}. Save it first with "save ${target}'s number as …".` };
      return null;
    }

    // open a chat/conversation with someone in an app
    m = text.match(/^(?:pull up|open|show|bring up|get)\s+(?:my\s+|the\s+)?(?:chat|conversation|convo|messages?|dm|texts?)\s+(?:with|between|to|from|of)\s+(.+?)\s+(?:on|in|using)\s+([a-z ]+?)(?:\s+app)?\.?$/i);
    if (m) {
      const target = m[1].trim().replace(/^my\s+/i, '');
      const app = m[2].trim().toLowerCase().replace(/\bapp\b/i, '').trim();
      const c = findContact(target);
      return {
        action: { type: 'open_chat', app, number: c ? c.number : '', handle: c ? c.handle : '', name: c ? c.name : target },
        say: `Pulling up your ${app} chat with ${c ? c.name : target}${tail}.`,
      };
    }

    // search WITHIN an app ("search cats on youtube", "search youtube for cats")
    m = text.match(/^(?:search(?:\s+for)?|look up|look for|find)\s+(.+?)\s+(?:on|in|using)\s+([a-z ]+?)(?:\s+app)?\.?$/i);
    if (!m) {
      const m2 = text.match(/^search\s+([a-z][a-z ]*?)\s+for\s+(.+?)\.?$/i);
      if (m2 && !/^(the )?(web|internet|google|online)$/i.test(m2[1].trim())) m = [m2[0], m2[2], m2[1]];
    }
    if (m) {
      const query = m[1].trim();
      const app = m[2].trim().toLowerCase().replace(/\bapp\b/i, '').trim();
      const label = app.charAt(0).toUpperCase() + app.slice(1);
      return { action: { type: 'search_in_app', app, query }, say: `Searching ${label} for ${query}${tail}.` };
    }

    // open / launch / turn on an app
    m = low.match(/^(?:can you |could you |please )?(?:open|launch|turn on|pull up|fire up|bring up|go to|load)\s+(?:the\s+|my\s+)?([a-z0-9 .&+-]{2,30}?)(?:\s+app)?\.?$/i);
    if (m) { const app = m[1].trim(); return { action: { type: 'open_app', app }, say: `Opening ${app}${tail}.` }; }

    // navigate / directions
    m = low.match(/^(?:navigate|directions?|take me)\s+(?:to\s+)?(.+)/i);
    if (m) return { action: { type: 'navigate', destination: m[1].trim() }, say: `Plotting a route to ${m[1].trim()}${tail}.` };

    // web search
    m = low.match(/^(?:search(?:\s+the\s+web)?(?:\s+for)?|google|look up)\s+(.+)/i);
    if (m) return { action: { type: 'search_web', query: m[1].trim() }, say: `Searching for ${m[1].trim()}${tail}.` };

    return null;
  }

  /* ---------------- Send / respond flow ---------------- */
  async function sendMessage(text) {
    text = (text || '').trim();
    if (!text || busy) return;
    const low0 = text.toLowerCase();

    // Awaiting a filing decision after an analysis?
    if (pendingSave) {
      if (/(first project|the project|^project\b|to the project)/.test(low0)) { addMessage('user', text); doSaveResearch(pendingSave, 'first-project'); return; }
      if (/^(yes|yeah|yep|yup|sure|ok|okay|please|do it|as usual|save it|affirmative|go ahead|ya|yea)\b/.test(low0)) { addMessage('user', text); doSaveResearch(pendingSave, 'research'); return; }
      if (/^(no|nope|nah|don'?t|cancel|skip|forget it|leave it)\b/.test(low0)) { addMessage('user', text); pendingSave = null; const l = `Very well — I'll not file it${titledName() ? ', ' + titledName() : ''}.`; addMessage('jarvis', l); speak(l); return; }
      pendingSave = null; // anything else: drop the prompt and handle normally
    }

    // Awaiting the deep-search kind?
    if (pendingDeepSearch) {
      if (/(internet|browsing|browse|web|online|google)/.test(low0)) { addMessage('user', text); runDeepSearch('internet'); return; }
      if (/(investigat|adventur|what it is|deep|dive|identify|analy)/.test(low0)) { addMessage('user', text); runDeepSearch('investigate'); return; }
      pendingDeepSearch = false;
    }

    // "do a deep search" command (uses the last analysed subject)
    if (/\b(deep search|deep dive|deep investigation|investigate deeper|dig deeper)\b/i.test(text)) {
      addMessage('user', text);
      startDeepSearch(lastAnalysisSubject);
      return;
    }

    // "analyse <subject>" — pull it up and analyse directly.
    let am = text.match(/^analy[sz]e\s+(.+?)\.?$/i);
    if (am) { addMessage('user', text); runAnalysis(am[1].trim()); return; }

    // In analysis mode, the next message is the subject to pull up & analyse.
    if (analysisPending) {
      analysisPending = false;
      el.analyzeBtn.classList.remove('active');
      el.textInput.placeholder = 'Message JARVIS…';
      addMessage('user', text);
      runAnalysis(text);
      return;
    }

    // "initiate analysis mode" — the named command for file/subject analysis.
    if (/\b(initiate|start|enter|open|begin)\s+(analysis|scan)(\s+mode)?\b/i.test(text) ||
        /^\s*analysis mode\s*$/i.test(text)) {
      addMessage('user', text);
      const who = titledName();
      if (isPC()) {
        addMessage('jarvis', `Analysis mode initiated${who ? ', ' + who : ''}. Drag a file onto the holo-scanner, or simply name a subject.`);
        speak('Analysis mode initiated. Drag a file onto the scanner, or name a subject.');
        openHoloScanner();
        armAnalysis(true);
      } else {
        addMessage('jarvis', `Analysis mode initiated${who ? ', ' + who : ''}. Select a file to scan, or name a subject.`);
        speak('Analysis mode initiated. Select a file, or name a subject.');
        armAnalysis(true);
        setTimeout(pickImage, 300);
      }
      return;
    }

    // Simulated incoming call (demo — a web app cannot detect real calls).
    let scm = text.match(/\b(?:simulate|demo|fake|pretend|test)\s+(?:an?\s+)?(?:incoming\s+)?call(?:\s+from\s+(.+?))?\.?$/i);
    if (scm) {
      addMessage('user', text);
      simulateIncomingCall(scm[1] ? scm[1].trim() : '');
      return;
    }

    // Visual pull-up — "show me / pull up a picture of X" (internet or files).
    let vm = text.match(/^(?:show me|pull up|bring up|find me|get me|display|pull)\s+(?:an?\s+|the\s+)?(?:picture|photo|image|pic|visual)\s+(?:of\s+|for\s+|showing\s+)?(.+?)\??$/i);
    if (!vm) { const vv = text.match(/^what (?:does|do)\s+(.+?)\s+look like\??$/i); if (vv) vm = vv; }
    if (vm) {
      addMessage('user', text);
      const q = vm[1].trim();
      if (/\b(my )?(files?|gallery|photos?|camera roll|device|phone|folder)\b/i.test(q)) {
        addMessage('jarvis', `Select a picture to pull up${addressWord() ? ', ' + addressWord() : ''}.`);
        pickImage();
      } else {
        showVisual(q);
      }
      return;
    }

    // Web-search answer — actually summarises, keyless (Wikipedia) + link.
    let wm = text.match(/^(?:search the web for|web search|research|look up|find out about|tell me about)\s+(.+?)\??$/i);
    if (wm) { addMessage('user', text); webAnswer(wm[1].trim()); return; }

    // System diagnostics — JARVIS reports its real host hardware.
    if (/\b(run |full |system )?(diagnostics?|self[- ]?test|system check)\b/i.test(text) ||
        /\b(hardware|system) (report|check|specs?|info)\b/i.test(text) ||
        /\b(your|these) (specs|hardware|system)\b/i.test(text) ||
        /\bhow (much|many) (ram|memory|cores|cpu)\b/i.test(text) ||
        /\bwhat('?s| is| are)?\s+(your|this) (cpu|gpu|ram|memory|hardware|specs|processor|storage)\b/i.test(text)) {
      addMessage('user', text);
      runDiagnostics();
      return;
    }

    // Music: "play/put on X" plays IN-APP (spinning disk) unless a service is
    // named ("… on spotify"); "open X by Y" is treated as a song too.
    {
      const tail = addressWord() ? ', ' + addressWord() : '';
      let song = null;
      const pm = text.match(/^(?:hey )?(?:jarvis[,\s]+)?(?:can you |could you |please )?(?:play|put on)\s+(.+)/i);
      if (pm) song = pm[1].trim();
      else { const om = text.match(/^(?:can you |could you |please )?open\s+(.+\bby\b.+)/i); if (om) song = om[1].trim(); }
      if (song) {
        const svc = song.match(/\bon\s+(youtube music|youtube|spotify|apple music|apple|soundcloud)\b/i);
        const q = song.replace(/\bon\s+(youtube music|youtube|spotify|apple music|apple|soundcloud)\b/ig, '')
                      .replace(/\b(for me|please|the song|some)\b/ig, '').replace(/\s+/g, ' ').trim();
        addMessage('user', text);
        if (svc) {
          const s = svc[1].toLowerCase();
          const service = /spotify/.test(s) ? 'spotify' : /apple/.test(s) ? 'apple' : /soundcloud/.test(s) ? 'soundcloud' : 'youtube';
          const built = { type: 'play_music', query: q, service };
          const say = `Right away${tail}. Putting on ${q} via ${service}.`;
          addMessage('jarvis', say, [built]); executeAction(built); speak(say);
        } else {
          playSongInApp(q);
        }
        return;
      }
    }

    // Direct device commands ("play …", "open …", "search …", "navigate …")
    // run in-app, instantly, in every mode. Executing here (synchronously,
    // inside the user's tap) also lets iOS actually open the target app.
    const intent = localIntent(text);
    if (intent) {
      addMessage('user', text);
      history.push({ role: 'user', content: text });
      addMessage('jarvis', intent.say, intent.action ? [intent.action] : undefined);
      history.push({ role: 'assistant', content: intent.say });
      if (intent.action) executeAction(intent.action);
      speak(intent.say);
      maybeAutoListen();
      return;
    }

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

  /* ---------------- Platform (PC vs mobile) ---------------- */
  function isPC() {
    const p = cfg.state.platform;
    if (p === 'pc') return true;
    if (p === 'mobile') return false;
    return window.innerWidth >= 900; // auto
  }
  function applyPlatform() {
    document.body.classList.toggle('platform-pc', isPC());
    requestAnimationFrame(() => Core.resize());
  }

  /* ---------------- Holographic scanner (PC analysis) ---------------- */
  function openHoloScanner() {
    el.holoScanner.classList.remove('hidden');
  }
  function closeHoloScanner() {
    el.holoScanner.classList.add('hidden');
  }

  /* ---------------- In-app music player (spinning disk) ---------------- */
  function showNowPlaying(title) {
    if (!el.npViz.childElementCount) {
      let bars = '';
      for (let i = 0; i < 18; i++) bars += `<i style="animation-delay:${(i % 6) * 0.1}s;height:${6 + Math.random() * 18}px"></i>`;
      el.npViz.innerHTML = bars;
    }
    el.npTitle.textContent = title;
    el.npDisk.classList.remove('spinning');
    el.nowPlaying.classList.remove('hidden');
  }
  function closeNowPlaying() {
    el.nowPlaying.classList.add('hidden');
    el.npFrame.innerHTML = '';                // stop playback
    el.npDisk.classList.remove('spinning');
  }
  function playVideoId(id, title) {
    el.npFrame.innerHTML =
      `<iframe src="https://www.youtube.com/embed/${id}?autoplay=1&playsinline=1&rel=0" ` +
      `title="player" allow="autoplay; encrypted-media" allowfullscreen></iframe>`;
    el.npDisk.classList.add('spinning');
    el.npTitle.textContent = title;
  }

  function withTimeout(ms) {
    const c = new AbortController();
    setTimeout(() => c.abort(), ms);
    return c.signal;
  }
  // Resolve a YouTube video id for a query using free, keyless public search
  // instances (Piped / Invidious). Any may be down; we try several.
  async function resolveVideoId(query) {
    const piped = ['https://pipedapi.kavin.rocks', 'https://pipedapi.adminforge.de', 'https://api.piped.private.coffee'];
    for (const base of piped) {
      try {
        const r = await fetch(`${base}/search?q=${encodeURIComponent(query)}&filter=videos`, { signal: withTimeout(6000) });
        if (!r.ok) continue;
        const d = await r.json();
        const items = d.items || d;
        const hit = Array.isArray(items) && items.find((i) => (i.url || '').indexOf('watch?v=') >= 0);
        const mm = hit && hit.url.match(/v=([\w-]{11})/);
        if (mm) return mm[1];
      } catch { /* try next */ }
    }
    const inv = ['https://inv.nadeko.net', 'https://invidious.jing.rocks', 'https://yewtu.be'];
    for (const base of inv) {
      try {
        const r = await fetch(`${base}/api/v1/search?q=${encodeURIComponent(query)}&type=video`, { signal: withTimeout(6000) });
        if (!r.ok) continue;
        const d = await r.json();
        const hit = Array.isArray(d) && d.find((i) => i.videoId);
        if (hit) return hit.videoId;
      } catch { /* try next */ }
    }
    return null;
  }

  async function playSongInApp(query) {
    const tail = addressWord() ? ', ' + addressWord() : '';
    showNowPlaying('Searching for ' + query + '…');
    setStatus('SEARCHING', 'analyzing');
    let id = null;
    try { id = await resolveVideoId(query); } catch { id = null; }
    setStatus('SYSTEM ONLINE', '');
    if (!id) {
      closeNowPlaying();
      const say = `I couldn't stream that in-app just now${tail} — opening YouTube for it instead.`;
      addMessage('jarvis', say, [{ type: 'play_music', query, service: 'youtube' }]);
      Actions.autoOpen('https://www.youtube.com/results?search_query=' + encodeURIComponent(query));
      speak(say);
      return;
    }
    playVideoId(id, query);
    // iOS blocks autoplay-with-sound; the player is visible so a single tap starts it.
    const say = Actions.isIOS
      ? `${query} is cued up${tail}. Tap the disk once to begin — iPhone requires a tap for sound.`
      : `Now playing ${query}${tail}.`;
    addMessage('jarvis', say);
    speak(say);
  }

  /* ---------------- Simulated incoming call (demo only) ---------------- */
  function simulateIncomingCall(name) {
    const who = titledName();
    const caller = name || (loadContacts()[0] && loadContacts()[0].name) || 'an unknown number';
    el.incallName.textContent = caller;
    const line = `${who ? who + ', y' : 'Y'}ou're getting a call from ${caller}. Shall I pick it up for you?`;
    el.incallJarvis.textContent = line;
    el.incomingCall.classList.remove('hidden');
    speak(line);
    try { navigator.vibrate && navigator.vibrate([300, 150, 300, 150, 300]); } catch {}
  }
  function endIncomingCall(answered) {
    el.incomingCall.classList.add('hidden');
    const who = titledName();
    const caller = el.incallName.textContent;
    const line = answered
      ? `Connecting you to ${caller} now${who ? ', ' + who : ''}.`
      : `Call declined${who ? ', ' + who : ''}.`;
    addMessage('jarvis', line);
    speak(line);
  }

  /* ============================================================
     ANALYSIS MODE — pull up a visual, analyse it, optionally file it.
     ============================================================ */
  function titledName() {
    const n = cfg.state.userName;
    const h = cfg.state.honorific;
    if (h && h !== 'none' && h !== 'name') return n ? `${h} ${n}` : h;
    return n || '';
  }

  function armAnalysis(quiet) {
    analysisPending = true;
    el.analyzeBtn.classList.add('active');
    el.textInput.placeholder = 'Name a subject to analyse…';
    if (!quiet) {
      const who = titledName();
      addMessage('jarvis', `Analysis mode engaged${who ? ', ' + who : ''}. What shall I pull up?`);
    }
    el.textInput.focus();
  }

  // Query Wikipedia (CORS-enabled, no key) for a representative image + summary.
  async function fetchWiki(query) {
    const api = 'https://en.wikipedia.org/w/api.php?action=query&format=json&origin=*' +
      '&generator=search&gsrlimit=1&gsrsearch=' + encodeURIComponent(query) +
      '&prop=pageimages|extracts&piprop=thumbnail&pithumbsize=640&exintro=1&explaintext=1';
    const res = await fetch(api);
    if (!res.ok) throw new Error('search failed (' + res.status + ')');
    const data = await res.json();
    const pages = data && data.query && data.query.pages;
    if (!pages) return null;
    const page = pages[Object.keys(pages)[0]];
    if (!page) return null;
    return {
      title: page.title || query,
      image: page.thumbnail && page.thumbnail.source || '',
      extract: (page.extract || '').trim(),
    };
  }

  async function runAnalysis(query) {
    busy = true;
    setStatus('ANALYZING', 'analyzing');
    Core.setState('analyzing');
    Core.setAmplitude(0.4);
    const typing = showTyping();
    const who = titledName();
    try {
      const data = await fetchWiki(query);
      typing.remove();
      if (!data || (!data.image && !data.extract)) {
        addMessage('jarvis', `I couldn't pull up anything on "${query}"${who ? ', ' + who : ''}. Care to rephrase, or shall I run a web search instead?`);
        // offer a web search action
        addMessage('jarvis', '', [{ type: 'search_web', query }]);
        return;
      }
      renderAnalysisCard(data);
      const line = `I've pulled up ${data.title}. Is this what you're looking for${who ? ', ' + who : ''}?`;
      addMessage('jarvis', line);
      speak(line);
    } catch (e) {
      typing.remove();
      addMessage('jarvis', `My analysis feed hit a snag: ${e.message}. Shall I try a plain web search?`);
      addMessage('jarvis', '', [{ type: 'search_web', query }]);
    } finally {
      busy = false;
      setStatus('SYSTEM ONLINE', '');
      Core.setState('idle');
      Core.setAmplitude(0);
    }
  }

  function renderAnalysisCard(data, opts) {
    opts = opts || {};
    const card = document.createElement('div');
    card.className = 'analysis-card';
    const media = data.image
      ? `<div class="analysis-media"><img src="${data.image}" alt="" referrerpolicy="no-referrer"/><span class="scanline"></span></div>`
      : '';
    card.innerHTML =
      `<div class="analysis-head"><span class="scan-dot"></span>Analysis${opts.image ? ' · uploaded image' : ''}</div>` +
      media +
      `<div class="analysis-body"><div class="analysis-title">${escapeHtml(data.title || 'Subject')}</div>` +
      `<div class="analysis-text"></div><div class="analysis-actions"></div></div>`;
    el.log.appendChild(card);
    el.log.scrollTop = el.log.scrollHeight;

    const actions = card.querySelector('.analysis-actions');
    const textEl = card.querySelector('.analysis-text');

    if (opts.confirmed) {
      textEl.textContent = data.extract || '';
      buildConfirmedActions(actions, data);
    } else {
      textEl.textContent = 'Awaiting your confirmation…';
      const yes = document.createElement('button');
      yes.className = 'affirm';
      yes.textContent = 'Yes, that\'s it';
      yes.addEventListener('click', () => {
        actions.innerHTML = '';
        confirmAnalysis(card, textEl, actions, data);
      });
      const no = document.createElement('button');
      no.textContent = 'No, refine';
      no.addEventListener('click', () => { card.remove(); armAnalysis(); });
      actions.appendChild(yes);
      actions.appendChild(no);
    }
  }

  async function confirmAnalysis(card, textEl, actions, data) {
    const who = titledName();
    // Present the analysis: use the LLM to summarise in butler voice if we can,
    // else show the encyclopaedic extract directly.
    let analysis = data.extract || '';
    const canLLM = cfg.state.mode === 'direct' || cfg.state.mode === 'server' || cfg.state.mode === 'ondevice';
    setStatus('ANALYZING', 'analyzing');
    try {
      if (canLLM && (cfg.state.apiKey || cfg.state.mode === 'server' || cfg.state.mode === 'ondevice')) {
        const prompt = `In two or three sentences, in your refined butler voice, give an analytical briefing on "${data.title}". Context: ${(data.extract || '').slice(0, 1200)}`;
        const reply = await callModel([{ role: 'user', content: prompt }]);
        const parsed = parseActions(reply || '');
        if (parsed.clean) analysis = parsed.clean;
      }
    } catch { /* fall back to extract */ }
    setStatus('SYSTEM ONLINE', '');

    textEl.textContent = analysis || 'No further detail available.';
    const follow = `How may I help you with this${who ? ', ' + who : ''}?`;
    addMessage('jarvis', follow);
    speak(follow);
    buildConfirmedActions(actions, data);

    // seed conversation context so follow-up questions know the subject
    history.push({ role: 'assistant', content: `We are analysing "${data.title}". ${(data.extract || '').slice(0, 600)}` });
  }

  // Offer to file the analysed item — "as usual" (research) or the first project.
  function buildConfirmedActions(actions, data) {
    actions.innerHTML = '';
    const who = titledName();
    lastAnalysisSubject = data.title || lastAnalysisSubject;
    pendingSave = data;

    const ask = `Shall I put this in your Private Research Files as usual, or under your First Project${who ? ', ' + who : ''}?`;
    addMessage('jarvis', ask);
    speak(ask);

    const bRes = document.createElement('button');
    bRes.className = 'save';
    bRes.textContent = 'Research files';
    bRes.addEventListener('click', () => doSaveResearch(data, 'research'));
    const bProj = document.createElement('button');
    bProj.className = 'save';
    bProj.style.background = 'linear-gradient(120deg, var(--gold), #ffe6b0)';
    bProj.textContent = 'First project';
    bProj.addEventListener('click', () => doSaveResearch(data, 'first-project'));
    const bDeep = document.createElement('button');
    bDeep.textContent = 'Deep search';
    bDeep.addEventListener('click', () => startDeepSearch(data.title));
    const bWeb = document.createElement('button');
    bWeb.textContent = 'Open web results';
    bWeb.addEventListener('click', () => Actions.autoOpen('https://www.google.com/search?q=' + encodeURIComponent(data.title || '')));
    actions.append(bRes, bProj, bDeep, bWeb);
  }

  function doSaveResearch(data, project) {
    saveResearch({
      title: data.title, image: data.image || '', note: data.extract || data.note || '',
      type: data.type || 'subject', project: project || 'research',
    });
    pendingSave = null;
    const who = titledName();
    const dest = project === 'first-project' ? 'your First Project' : 'your Private Research Files';
    const kind = data.type === 'photo' ? 'an image' : data.type === 'document' ? 'a document' : 'a subject';
    const line = `Filed under ${dest}${who ? ', ' + who : ''}, sorted as ${kind}.`;
    addMessage('jarvis', line);
    toast('Filed to ' + (project === 'first-project' ? 'First Project' : 'Research Files'));
    speak(line);
  }

  // A JARVIS message with tappable choice buttons.
  function addChoiceMessage(text, options) {
    const div = document.createElement('div');
    div.className = 'msg jarvis';
    div.innerHTML = '<span class="who">JARVIS</span>';
    const body = document.createElement('span'); body.textContent = text; div.appendChild(body);
    const wrap = document.createElement('div'); wrap.className = 'analysis-actions'; wrap.style.marginTop = '10px';
    options.forEach((o) => {
      const b = document.createElement('button');
      if (o.affirm) b.className = 'affirm';
      b.textContent = o.label;
      b.addEventListener('click', o.onClick);
      wrap.appendChild(b);
    });
    div.appendChild(wrap);
    el.log.appendChild(div);
    el.log.scrollTop = el.log.scrollHeight;
  }

  function startDeepSearch(subject) {
    lastAnalysisSubject = subject || lastAnalysisSubject;
    if (!lastAnalysisSubject) {
      const l = `Point me at something first${titledName() ? ', ' + titledName() : ''} — name a subject or drop a file.`;
      addMessage('jarvis', l); speak(l); return;
    }
    pendingDeepSearch = true;
    const who = titledName();
    const ask = `What kind of search would you like${who ? ', ' + who : ''} — internet browsing, or an adventurous investigation of what it is?`;
    addChoiceMessage(ask, [
      { label: '🌐 Internet browsing', affirm: true, onClick: () => runDeepSearch('internet') },
      { label: '🔬 Investigate what it is', onClick: () => runDeepSearch('investigate') },
    ]);
    speak(ask);
  }

  async function runDeepSearch(kind) {
    pendingDeepSearch = false;
    const subject = lastAnalysisSubject;
    const who = titledName();
    if (kind === 'internet') {
      const line = `Commencing internet browsing on ${subject}${who ? ', ' + who : ''}.`;
      addMessage('jarvis', line, [{ type: 'search_web', query: subject }]);
      Actions.autoOpen('https://www.google.com/search?q=' + encodeURIComponent(subject));
      speak(line);
      return;
    }
    setStatus('ANALYZING', 'analyzing');
    const fact = await tryFact(subject);
    setStatus('SYSTEM ONLINE', '');
    const line = fact
      ? `Investigation${who ? ', ' + who : ''}: ${fact}`
      : `I couldn't dig up more on ${subject} from my sources${who ? ', ' + who : ''}. Shall I browse the web instead?`;
    addMessage('jarvis', line, [{ type: 'search_web', query: subject + ' explained' }]);
    speak(line.slice(0, 220));
  }

  /* ---- Live "thinking" steps + confidence ---- */
  function startThinking(steps) {
    const div = document.createElement('div');
    div.className = 'msg jarvis';
    div.innerHTML = '<span class="who">JARVIS</span><span class="think"></span>';
    const span = div.querySelector('.think');
    el.log.appendChild(div);
    el.log.scrollTop = el.log.scrollHeight;
    let i = 0;
    span.innerHTML = escapeHtml(steps[0]) + ' <span class="dotpulse">…</span>';
    setStatus('ANALYZING', 'analyzing'); Core.setState('analyzing'); Core.setAmplitude(0.4);
    const iv = setInterval(() => {
      i++;
      if (i < steps.length) { span.innerHTML = escapeHtml(steps[i]) + ' <span class="dotpulse">…</span>'; el.log.scrollTop = el.log.scrollHeight; }
    }, 700);
    return {
      finish(text, confidence) {
        clearInterval(iv);
        span.innerHTML = escapeHtml(text || 'Complete.');
        if (confidence != null) {
          const c = document.createElement('span');
          c.className = 'confidence ' + (confidence >= 90 ? 'hi' : confidence >= 65 ? 'mid' : 'lo');
          c.textContent = confidence + '%';
          span.appendChild(document.createTextNode(' '));
          span.appendChild(c);
        }
        setStatus('SYSTEM ONLINE', ''); Core.setState('idle'); Core.setAmplitude(0);
        el.log.scrollTop = el.log.scrollHeight;
      },
    };
  }

  /* ---- Web-search answer (keyless: Wikipedia snippet + link) ---- */
  async function webAnswer(query) {
    const tail = addressWord() ? ', ' + addressWord() : '';
    const t = startThinking(['Querying the web', 'Retrieving sources', 'Summarising findings']);
    const data = await fetchWiki(query).catch(() => null);
    if (data && data.extract) {
      lastAnalysisSubject = data.title;
      t.finish('Here is what I found on ' + data.title + ':', 95);
      addMessage('jarvis', data.extract.slice(0, 500), [{ type: 'search_web', query }]);
      speak(`Here is what I found on ${data.title}${tail}.`);
    } else {
      t.finish("I couldn't summarise that from my sources — opening full web results.", 40);
      addMessage('jarvis', '', [{ type: 'search_web', query }]);
      Actions.autoOpen('https://www.google.com/search?q=' + encodeURIComponent(query));
    }
  }

  /* ---- Visual pull-up (a picture from the internet) ---- */
  async function showVisual(query) {
    const tail = addressWord() ? ', ' + addressWord() : '';
    const t = startThinking(['Searching visual archives', 'Retrieving imagery', 'Rendering']);
    const data = await fetchWiki(query).catch(() => null);
    if (data && data.image) {
      lastAnalysisSubject = data.title;
      t.finish('Pulled up ' + data.title + '.', 96);
      renderVisualCard(data);
      speak(`Here is ${data.title}${tail}.`);
    } else {
      t.finish("I couldn't pull that from my archives — opening image results.", 45);
      addMessage('jarvis', '', [{ type: 'open_url', url: 'https://www.google.com/search?tbm=isch&q=' + encodeURIComponent(query) }]);
      Actions.autoOpen('https://www.google.com/search?tbm=isch&q=' + encodeURIComponent(query));
    }
  }
  function renderVisualCard(data) {
    const card = document.createElement('div');
    card.className = 'analysis-card';
    const media = data.image ? `<div class="analysis-media"><img src="${data.image}" alt="" referrerpolicy="no-referrer"/><span class="scanline"></span></div>` : '';
    card.innerHTML = `<div class="analysis-head"><span class="scan-dot"></span>Visual</div>` + media +
      `<div class="analysis-body"><div class="analysis-title">${escapeHtml(data.title || '')}</div>` +
      `<div class="analysis-text">${escapeHtml((data.extract || '').split('. ').slice(0, 2).join('. '))}</div>` +
      `<div class="analysis-actions"></div></div>`;
    el.log.appendChild(card);
    el.log.scrollTop = el.log.scrollHeight;
    const actions = card.querySelector('.analysis-actions');
    const analyse = document.createElement('button'); analyse.className = 'affirm'; analyse.textContent = 'Analyse this';
    analyse.addEventListener('click', () => { lastAnalysisSubject = data.title; runAnalysis(data.title); });
    const web = document.createElement('button'); web.textContent = 'More on the web';
    web.addEventListener('click', () => Actions.autoOpen('https://www.google.com/search?q=' + encodeURIComponent(data.title || '')));
    actions.append(analyse, web);
  }

  /* ---- Adaptive analysis: detect type and route ---- */
  function pickImage() { el.imageInput.click(); }
  function round(n) { return Math.round(n * 100) / 100; }
  function detectFileKind(file) {
    const name = (file.name || '').toLowerCase();
    const type = file.type || '';
    if (/^image\//.test(type)) return 'image';
    if (/\.(csv|tsv)$/.test(name) || type === 'text/csv') return 'sheet';
    if (/\.(js|mjs|ts|jsx|tsx|py|java|c|cpp|h|cs|go|rb|php|rs|swift|kt|html|css|json|xml|sh|sql|ya?ml|toml)$/.test(name)) return 'code';
    if (/\.(txt|md|markdown|log|rtf)$/.test(name) || /^text\//.test(type)) return 'text';
    if (/\.pdf$/.test(name) || type === 'application/pdf') return 'pdf';
    if (/^audio\//.test(type) || /\.(mp3|wav|m4a|ogg|flac|aac)$/.test(name)) return 'audio';
    if (/^video\//.test(type) || /\.(mp4|mov|avi|mkv|webm)$/.test(name)) return 'video';
    if (/\.(xlsx|xls)$/.test(name)) return 'sheet-bin';
    if (/\.(docx?|pptx?)$/.test(name)) return 'office';
    return 'file';
  }
  function kindLabel(k) {
    return ({ image: 'image', sheet: 'spreadsheet', 'sheet-bin': 'spreadsheet', code: 'source code',
      text: 'document', pdf: 'PDF', audio: 'audio', video: 'video', office: 'office document', file: 'file' }[k]) || 'file';
  }

  function handleImageFile(file) {
    if (!file) return;
    const kind = detectFileKind(file);
    if (kind === 'image') {
      const r = new FileReader(); r.onload = () => analyzeImage(r.result, file.type, file.name); r.readAsDataURL(file); return;
    }
    if (kind === 'text' || kind === 'code' || kind === 'sheet') {
      const r = new FileReader(); r.onload = () => analyzeTextFile(String(r.result), file, kind); r.readAsText(file); return;
    }
    analyzeDocument(file, kind); // pdf / audio / video / office / xlsx / other
  }

  function renderFileCard(title, kind, icon) {
    const card = document.createElement('div');
    card.className = 'analysis-card';
    card.innerHTML = `<div class="analysis-head"><span class="scan-dot"></span>Analysis · ${escapeHtml(kindLabel(kind))}</div>` +
      `<div class="analysis-body"><div class="analysis-title">${icon} ${escapeHtml(title)}</div>` +
      `<div class="analysis-text" style="white-space:pre-wrap"></div><div class="analysis-actions"></div></div>`;
    el.log.appendChild(card); el.log.scrollTop = el.log.scrollHeight;
    return card;
  }

  // Text / code / CSV — read contents in-browser (keyless) and, if a brain is
  // connected, run a real review/summary.
  async function analyzeTextFile(content, file, kind) {
    closeHoloScanner();
    const who = titledName(); const tail = who ? ', ' + who : '';
    const name = file.name;
    const steps = kind === 'sheet' ? ['Parsing rows', 'Detecting columns', 'Computing statistics', 'Finding trends']
      : kind === 'code' ? ['Reading source', 'Mapping structure', 'Scanning for issues']
        : ['Reading document', 'Extracting text', 'Analysing language'];
    const t = startThinking(steps);

    const lines = content.split(/\r?\n/);
    let summary = '';
    if (kind === 'sheet') {
      const rows = lines.filter((l) => l.trim().length);
      const headers = (rows[0] || '').split(/[,\t]/).map((s) => s.trim());
      const dataRows = rows.slice(1).map((r) => r.split(/[,\t]/));
      const stats = headers.map((h, ci) => {
        const nums = dataRows.map((r) => parseFloat((r[ci] || '').replace(/[^0-9.\-]/g, ''))).filter((n) => isFinite(n));
        if (nums.length >= Math.max(2, dataRows.length * 0.5)) {
          const sum = nums.reduce((a, b) => a + b, 0);
          return `${h || 'col'}: min ${round(Math.min(...nums))}, max ${round(Math.max(...nums))}, avg ${round(sum / nums.length)}`;
        }
        return null;
      }).filter(Boolean);
      summary = `${Math.max(0, rows.length - 1)} rows × ${headers.length} columns.\nColumns: ${headers.join(', ')}.` +
        (stats.length ? `\n\nNumeric summary:\n• ${stats.join('\n• ')}` : '');
    } else if (kind === 'code') {
      const lang = (name.split('.').pop() || '').toUpperCase();
      const fns = (content.match(/\b(function|def|func|class|=>)\b/g) || []).length;
      const todos = (content.match(/\b(TODO|FIXME|HACK|XXX)\b/g) || []).length;
      summary = `${lang} source · ${lines.length} lines · ~${fns} functions/blocks${todos ? ` · ${todos} TODO/FIXME markers` : ''}.`;
    } else {
      const words = (content.trim().match(/\S+/g) || []).length;
      summary = `${words} words · ${lines.length} lines.\nOpening: "${content.trim().slice(0, 200).replace(/\s+/g, ' ')}…"`;
    }

    let deep = '';
    const connected = (cfg.state.mode === 'direct' && cfg.state.apiKey) || cfg.state.mode === 'server';
    if (connected) {
      try {
        const prompt = kind === 'code'
          ? `Review this file "${name}" concisely in your butler voice — note bugs, security issues, and improvements:\n\n${content.slice(0, 6000)}`
          : kind === 'sheet'
            ? `Summarise the trends and anomalies in this data in your butler voice:\n\n${content.slice(0, 6000)}`
            : `Summarise this document's key points and any risks in your butler voice:\n\n${content.slice(0, 6000)}`;
        deep = parseActions((await callModel([{ role: 'user', content: prompt }])) || '').clean;
      } catch { /* keyless summary only */ }
    }

    t.finish(`Analysis complete — ${kindLabel(kind)} detected.`, connected ? 97 : 82);
    const icon = kind === 'sheet' ? '📊' : kind === 'code' ? '💻' : '📄';
    const card = renderFileCard(name, kind, icon);
    card.querySelector('.analysis-text').textContent = summary + (deep ? '\n\n' + deep : (connected ? '' : '\n\n(Connect a brain in Settings for a full review.)'));
    const say = `Analysis complete${tail}. I've detected a ${kindLabel(kind)}${connected ? '' : ' — connect a brain for a deep review'}.`;
    addMessage('jarvis', say); speak(say);
    buildConfirmedActions(card.querySelector('.analysis-actions'), { title: name, image: '', extract: summary, type: 'document' });
  }

  // pdf / audio / video / office / other — identify + honest about depth.
  function analyzeDocument(file, kind) {
    closeHoloScanner();
    const who = titledName(); const tail = who ? ', ' + who : '';
    kind = kind || detectFileKind(file);
    const ext = (file.name.split('.').pop() || 'file').toUpperCase();
    const kb = Math.max(1, Math.round(file.size / 1024));
    const size = kb > 1024 ? (kb / 1024).toFixed(1) + ' MB' : kb + ' KB';
    const t = startThinking(['Reading header', 'Identifying format', 'Assessing content']);
    const icon = kind === 'pdf' ? '📄' : kind === 'audio' ? '🎵' : kind === 'video' ? '🎥' : kind === 'office' ? '📝' : '📄';
    const need = (kind === 'pdf' || kind === 'office') ? 'a connected brain to read its contents'
      : kind === 'audio' ? 'a connected transcription brain to hear it'
        : kind === 'video' ? 'a connected brain to watch it' : 'a connected brain to read it';
    const desc = `Detected a ${kindLabel(kind)} — "${file.name}", ${size} (${ext}). I can file and organise it now; a full read/summary needs ${need}.`;
    t.finish(`Detected: ${kindLabel(kind)}.`, 70);
    const card = renderFileCard(file.name, kind, icon);
    card.querySelector('.analysis-text').textContent = desc;
    addMessage('jarvis', `I've detected a ${kindLabel(kind)}${tail}.`); speak(`I've detected a ${kindLabel(kind)}${tail}.`);
    buildConfirmedActions(card.querySelector('.analysis-actions'), { title: file.name, image: '', extract: desc, type: 'document' });
  }

  // Keyless in-browser OCR via Tesseract.js (loaded on demand).
  async function ocrImage(dataUrl) {
    if (!window.Tesseract) {
      await new Promise((res, rej) => {
        const s = document.createElement('script');
        s.src = 'https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js';
        s.onload = res; s.onerror = rej; document.head.appendChild(s);
      });
    }
    const r = await window.Tesseract.recognize(dataUrl, 'eng');
    return (r && r.data && r.data.text || '').trim();
  }

  async function analyzeImage(dataUrl, mime, name) {
    const who = titledName();
    closeHoloScanner();
    renderAnalysisCard({ title: name || 'Uploaded image', image: dataUrl, extract: '' }, { image: true });
    const line = `Is this the image you'd like me to analyse${who ? ', ' + who : ''}?`;
    addMessage('jarvis', line);
    speak(line);
    // The card's "Yes" path will run the actual vision analysis.
    const cards = el.log.querySelectorAll('.analysis-card');
    const card = cards[cards.length - 1];
    const actions = card.querySelector('.analysis-actions');
    const textEl = card.querySelector('.analysis-text');
    actions.innerHTML = '';
    const yes = document.createElement('button');
    yes.className = 'affirm';
    yes.textContent = 'Yes, analyse it';
    yes.addEventListener('click', async () => {
      actions.innerHTML = '';
      const connected = cfg.state.mode === 'direct' && cfg.state.apiKey;
      const t = startThinking(connected
        ? ['Extracting visual elements', 'Detecting objects', 'Reading any text', 'Identifying scene']
        : ['Extracting visual elements', 'Running on-device OCR', 'Reading text']);
      let desc = '', conf = 55;
      if (connected) {
        try { desc = await visionDescribe(dataUrl, mime); if (desc) conf = 96; } catch { desc = ''; }
      }
      let ocr = '';
      if (!connected) { try { ocr = await ocrImage(dataUrl); if (ocr) conf = 80; } catch { ocr = ''; } }
      let out = desc || 'Full scene identification (objects, people, what is happening) needs a connected vision brain — Gemini\'s free tier, Claude, or GPT. Keyless, I read text and organise the image.';
      if (ocr) out += `\n\nText detected (OCR): "${ocr.slice(0, 400)}"`;
      t.finish('Analysis complete — image processed.', conf);
      textEl.textContent = out;
      const follow = `How may I help you with this${who ? ', ' + who : ''}?`;
      addMessage('jarvis', follow);
      speak(follow);
      buildConfirmedActions(actions, { title: name || 'Uploaded image', image: dataUrl, extract: out, type: 'photo' });
    });
    const no = document.createElement('button');
    no.textContent = 'No';
    no.addEventListener('click', () => card.remove());
    actions.appendChild(yes);
    actions.appendChild(no);
  }

  // Vision description via the active cloud provider, if it supports images.
  async function visionDescribe(dataUrl, mime) {
    if (cfg.state.mode !== 'direct' || !cfg.state.apiKey) return '';
    const provider = cfg.state.provider;
    const model = cfg.state.model || (PROVIDER_DEFAULTS[provider] || {}).model;
    const key = cfg.state.apiKey;
    const b64 = dataUrl.split(',')[1] || '';
    const media = (mime || 'image/png');
    const ask = 'Identify and analyse this image in two or three sentences, in a refined butler voice.';
    if (provider === 'anthropic') {
      const r = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: { 'x-api-key': key, 'anthropic-version': '2023-06-01', 'content-type': 'application/json', 'anthropic-dangerous-direct-browser-access': 'true' },
        body: JSON.stringify({ model, max_tokens: 400, messages: [{ role: 'user', content: [
          { type: 'image', source: { type: 'base64', media_type: media, data: b64 } },
          { type: 'text', text: ask },
        ] }] }),
      });
      const d = await r.json();
      return (d.content || []).filter((x) => x.type === 'text').map((x) => x.text).join(' ').trim();
    }
    if (provider === 'gemini') {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(key)}`;
      const r = await fetch(url, { method: 'POST', headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ contents: [{ role: 'user', parts: [ { inline_data: { mime_type: media, data: b64 } }, { text: ask } ] }] }) });
      const d = await r.json();
      const parts = d.candidates && d.candidates[0] && d.candidates[0].content && d.candidates[0].content.parts || [];
      return parts.map((p) => p.text || '').join('').trim();
    }
    if (provider === 'openai' || provider === 'openai-compatible') {
      const base = provider === 'openai' ? 'https://api.openai.com/v1' : (cfg.state.baseUrl || '').replace(/\/+$/, '');
      const r = await fetch(base + '/chat/completions', { method: 'POST', headers: { 'Authorization': 'Bearer ' + key, 'content-type': 'application/json' },
        body: JSON.stringify({ model, max_tokens: 400, messages: [{ role: 'user', content: [
          { type: 'text', text: ask }, { type: 'image_url', image_url: { url: dataUrl } },
        ] }] }) });
      const d = await r.json();
      return d.choices && d.choices[0] && d.choices[0].message && d.choices[0].message.content || '';
    }
    return '';
  }

  /* ---- Private research files (local) ---- */
  function loadResearch() {
    try { return JSON.parse(localStorage.getItem(RESEARCH_KEY) || '[]'); } catch { return []; }
  }
  function saveResearch(item) {
    const list = loadResearch();
    // Guard localStorage quota: drop very large inline images (keep metadata).
    if (item.image && item.image.length > 400000) item.image = '';
    list.unshift({
      id: Date.now() + '-' + Math.random().toString(36).slice(2, 7),
      savedAt: Date.now(),
      type: item.type || 'subject',
      project: item.project || 'research',
      ...item,
    });
    while (list.length > 60) list.pop();
    try { localStorage.setItem(RESEARCH_KEY, JSON.stringify(list)); }
    catch { toast('Storage full — remove some files first.'); }
  }
  function deleteResearch(id) {
    const list = loadResearch().filter((x) => x.id !== id);
    try { localStorage.setItem(RESEARCH_KEY, JSON.stringify(list)); } catch {}
    renderResearchList();
  }
  function openResearch() { renderResearchList(); el.research.classList.remove('hidden'); }
  const TYPE_ICON = { photo: '🖼', document: '📄', subject: '🔎' };
  function renderResearchList() {
    const list = loadResearch();
    el.researchList.innerHTML = '';
    if (!list.length) {
      el.researchList.innerHTML = '<div class="research-empty">No files yet. Enter Analysis mode, analyse a subject or drop a file, then file it here.</div>';
      return;
    }
    // Group by project, then show type badges.
    const groups = {};
    list.forEach((it) => { const p = it.project || 'research'; (groups[p] = groups[p] || []).push(it); });
    const order = ['research', 'first-project'];
    Object.keys(groups).sort((a, b) => order.indexOf(a) - order.indexOf(b)).forEach((proj) => {
      const head = document.createElement('div');
      head.className = 'research-group';
      head.textContent = proj === 'first-project' ? '★ First Project' : 'Research Files';
      el.researchList.appendChild(head);
      groups[proj].forEach((it) => {
        const row = document.createElement('div');
        row.className = 'research-item';
        const media = it.image
          ? `<img src="${it.image}" alt="" referrerpolicy="no-referrer"/>`
          : `<div class="ri-icon">${TYPE_ICON[it.type] || '🔎'}</div>`;
        row.innerHTML = media +
          `<div class="ri-body"><div class="ri-title">${escapeHtml(it.title || 'Untitled')}</div>` +
          `<div class="ri-date">${(it.type || 'subject').toUpperCase()} · ${new Date(it.savedAt).toLocaleDateString()}</div></div>` +
          `<button class="ri-del" aria-label="Delete">✕</button>`;
        row.querySelector('.ri-del').addEventListener('click', () => deleteResearch(it.id));
        row.addEventListener('click', (e) => {
          if (e.target.classList.contains('ri-del')) return;
          if (it.note) addMessage('jarvis', `From your ${proj === 'first-project' ? 'first project' : 'research files'} — ${it.title}: ${it.note.slice(0, 400)}`);
          el.research.classList.add('hidden');
        });
        el.researchList.appendChild(row);
      });
    });
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  }

  /* ============================================================
     TELEMETRY — the ops-console readouts
     ============================================================ */
  function initTelemetry() {
    el.sigBars.innerHTML = '<i></i><i></i><i></i><i></i><i></i>';
    if (el.tickerText) {
      const line = [
        'NEURAL CORE <b>ONLINE</b>', 'UPLINK <b>STABLE</b>', 'ENCRYPTION <b>AES-256</b>',
        'THREADS <b>128</b>', 'LATENCY <b>42MS</b>', 'MEMORY <b>NOMINAL</b>',
        'SENSORS <b>ACTIVE</b>', 'DIAGNOSTICS <b>PASS</b>', 'ARC REACTOR <b>100%</b>',
      ].join(' &nbsp;·&nbsp; ');
      el.tickerText.innerHTML = line + ' &nbsp;·&nbsp; ' + line;
    }
    updateTelemetry();
    setInterval(tickClock, 1000);
    tickClock();
  }
  function tickClock() {
    if (!el.telClock) return;
    const d = new Date();
    el.telClock.textContent = d.toLocaleTimeString([], { hour12: false });
  }
  async function getHardware() {
    const cores = navigator.hardwareConcurrency || null;
    const ram = navigator.deviceMemory || null; // GB, coarse, Chromium only
    const gpu = getGPU();
    let storage = null;
    try {
      if (navigator.storage && navigator.storage.estimate) {
        const e = await navigator.storage.estimate();
        storage = { quota: e.quota, usage: e.usage };
      }
    } catch { /* not exposed */ }
    const dpr = window.devicePixelRatio || 1;
    const screenStr = `${Math.round(screen.width * dpr)}×${Math.round(screen.height * dpr)}`;
    const conn = navigator.connection && navigator.connection.effectiveType;
    const platform = (navigator.userAgentData && navigator.userAgentData.platform) || navigator.platform || 'unknown';
    return { cores, ram, gpu, storage, screenStr, conn, platform };
  }

  // A JARVIS message that preserves line breaks (for reports/lists).
  function addPreMessage(text) {
    const div = document.createElement('div');
    div.className = 'msg jarvis';
    div.innerHTML = '<span class="who">JARVIS</span>';
    const body = document.createElement('span');
    body.textContent = text;
    body.style.whiteSpace = 'pre-wrap';
    div.appendChild(body);
    el.log.appendChild(div);
    el.log.scrollTop = el.log.scrollHeight;
  }

  async function runDiagnostics() {
    const who = titledName();
    const tail = who ? ', ' + who : '';
    setStatus('DIAGNOSTICS', 'analyzing');
    Core.setState('analyzing'); Core.setAmplitude(0.35);
    const hw = await getHardware();
    setStatus('SYSTEM ONLINE', ''); Core.setState('idle'); Core.setAmplitude(0);
    const gb = (b) => (b ? (b / 1073741824).toFixed(1) + ' GB' : '—');

    const rec = [];
    if (hw.ram && hw.ram <= 4) rec.push('memory is on the low side — 16 GB or more of RAM would markedly improve multitasking');
    else if (hw.ram && hw.ram <= 8) rec.push('16–32 GB of RAM would give more headroom for heavy tasks');
    if (hw.cores && hw.cores <= 4) rec.push('a processor with more cores would help with parallel work');
    if (/swiftshader|llvmpipe|software|microsoft basic/i.test(hw.gpu || '')) rec.push('no hardware GPU acceleration is active — a discrete GPU would transform graphics and on-device AI');
    rec.push('an NVMe SSD (if you are not already on one) is the single best upgrade for day-to-day responsiveness');

    const report = [
      `Running full diagnostics${tail}. Here is what I can read of this host:`,
      ``,
      `  • Processor:  ${hw.cores ? hw.cores + ' logical cores' : 'not exposed'}`,
      `  • Memory:     ${hw.ram ? '~' + hw.ram + ' GB' : 'hidden by the browser'}`,
      `  • Graphics:   ${hw.gpu || 'unknown'}`,
      `  • Storage:    ${hw.storage ? gb(hw.storage.quota) + ' available to me (' + gb(hw.storage.usage) + ' used)' : 'not exposed'}`,
      `  • Display:    ${hw.screenStr}${hw.conn ? '  ·  network ' + hw.conn : ''}`,
      `  • Platform:   ${hw.platform}`,
      ``,
      `Recommendation${tail}: ${rec.join('; ')}.`,
      ``,
      `A candid note: browsers deliberately hide the exact CPU model, total RAM, and drive type (NVMe vs SATA) for your privacy, so I cannot confirm those from in here. Your operating system's System Information / Task Manager / "About This Mac" will show the full truth.`,
    ].join('\n');

    addPreMessage(report);
    speak(`Diagnostics complete${tail}. ${hw.cores || 'Several'} logical cores, ${hw.ram ? 'about ' + hw.ram + ' gigabytes of memory' : 'memory hidden by the browser'}, graphics running on ${hw.gpu}. My upgrade recommendations are on screen.`);
  }

  let _gpu = null;
  function getGPU() {
    if (_gpu) return _gpu;
    try {
      const c = document.createElement('canvas');
      const gl = c.getContext('webgl') || c.getContext('experimental-webgl');
      const ext = gl && gl.getExtension('WEBGL_debug_renderer_info');
      let r = ext ? gl.getParameter(ext.UNMASKED_RENDERER_WEBGL) : (gl && gl.getParameter(gl.RENDERER)) || 'GPU';
      r = String(r);
      const m = r.match(/ANGLE \(([^,]+),\s*([^,\)]+)/);
      if (m) r = m[2];
      _gpu = r.replace(/\(R\)|\(TM\)|Corporation|Graphics/gi, '').replace(/\s+/g, ' ').trim().slice(0, 22) || 'GPU';
    } catch { _gpu = 'GPU'; }
    return _gpu;
  }
  function updateTelemetry() {
    const mode = cfg.state.mode;
    const provider = mode === 'ondevice' ? 'ON-DEVICE'
      : mode === 'demo' ? 'DEMO'
      : mode === 'server' ? 'SERVER'
      : (cfg.state.provider || 'anthropic').toUpperCase();
    if (el.telMode) el.telMode.textContent = 'MODE · ' + mode.toUpperCase();
    if (el.telProvider) el.telProvider.textContent = 'CORE · ' + provider;
    const modelName = (mode === 'ondevice' ? cfg.state.localModel : cfg.state.model) || '—';
    if (el.telLeft) {
      el.telLeft.innerHTML = [
        ['SYS', 'ONLINE'], ['CORE', provider],
        ['MODEL', String(modelName).slice(0, 20)],
        ['GPU', getGPU()],
        ['GPU LOAD', (24 + Math.floor(Math.random() * 46)) + '%'],
        ['CPU', (navigator.hardwareConcurrency ? navigator.hardwareConcurrency + ' CORES' : '—')],
        ['RAM', (navigator.deviceMemory ? '~' + navigator.deviceMemory + ' GB' : 'N/A')],
        ['UPLINK', mode === 'ondevice' ? 'LOCAL' : mode === 'demo' ? 'ONBOARD' : 'SECURE'],
        ['LATENCY', (28 + Math.floor(Math.random() * 24)) + 'MS'],
        ['MEMORY', 'NOMINAL'],
        ['CIPHER', 'AES-256'], ['SENSORS', 'ACTIVE'],
        ['INTEGRITY', '100%'], ['PWR', '100%'],
      ].map(([k, v]) => `<div class="tl-row">${k} <b>${escapeHtml(v)}</b></div>`).join('');
    }
  }

  /* ---------------- Onboarding ---------------- */
  function showOnboarding() {
    el.onboarding.classList.remove('hidden');
    el.hud.classList.add('hidden');
    el.nameInput.value = cfg.state.userName || '';
    el.honorificSelect.value = cfg.state.honorific || 'Sir';
    // Pre-select platform based on the current best guess.
    selectedPlatform = isPC() ? 'pc' : 'mobile';
    el.platformPick.querySelectorAll('.platform-opt').forEach((b) =>
      b.classList.toggle('selected', b.dataset.platform === selectedPlatform));
    setTimeout(() => el.nameInput.focus(), 200);
  }

  function completeOnboarding() {
    const name = el.nameInput.value.trim();
    const hon = el.honorificSelect.value;
    cfg.set({ userName: name, honorific: hon, platform: selectedPlatform || 'auto', onboarded: true });
    applyPlatform();
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
    if (cfg.state.mode === 'demo') return;                // user deliberately offline

    const keyless = (PROVIDER_DEFAULTS[cfg.state.provider] || {}).keyless;
    if (cfg.state.mode === 'direct' && (cfg.state.apiKey || keyless)) return; // already set up
    if (cfg.state.apiKey) {                                // we have our own key
      if (cfg.state.mode === 'server') cfg.set({ mode: 'direct' });
      return;
    }

    // No server, no key: run on the onboard brain — works instantly, no key,
    // no cloud. The user can connect a full brain (e.g. Gemini's free tier) later.
    cfg.set({ mode: 'demo' });
    updateTelemetry();
    const who = titledName();
    addMessage('jarvis',
      `I'm running on my onboard logic core${who ? ', ' + who : ''} — no key required. ` +
      `I can do maths, tell the time, define words, look up facts, and fully control your ` +
      `device: try "what's 25 times 8", "define serendipity", "who is Ada Lovelace", or ` +
      `"play a song". For unrestricted conversation, connect a free brain in settings.`);
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
    renderContacts();
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
    el.keyField.style.display = d.keyless ? 'none' : 'block';
    el.freeNote.style.display = d.keyless ? 'block' : 'none';
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
    updateTelemetry();
    toast('Settings saved.');
  }

  /* ---------------- Wire up ---------------- */
  function bind() {
    el.onboardStart.addEventListener('click', completeOnboarding);
    el.nameInput.addEventListener('keydown', (e) => { if (e.key === 'Enter') completeOnboarding(); });
    el.onboardSettingsLink.addEventListener('click', () => { openSettings(); });

    // Platform picker
    el.platformPick.querySelectorAll('.platform-opt').forEach((btn) => {
      btn.addEventListener('click', () => {
        selectedPlatform = btn.dataset.platform;
        el.platformPick.querySelectorAll('.platform-opt').forEach((b) => b.classList.toggle('selected', b === btn));
      });
    });

    // Contacts (settings)
    el.cAdd.addEventListener('click', () => {
      const name = el.cName.value.trim();
      const number = el.cNumber.value.trim();
      if (!name || !number) { toast('Enter a name and number.'); return; }
      addContact(name, number, el.cApp.value);
      el.cName.value = ''; el.cNumber.value = ''; el.cApp.value = '';
      renderContacts();
      toast(`Saved ${name}.`);
    });

    // Now Playing
    el.npClose.addEventListener('click', closeNowPlaying);

    // Simulated incoming call
    el.incallAnswer.addEventListener('click', () => endIncomingCall(true));
    el.incallDecline.addEventListener('click', () => endIncomingCall(false));

    // Holographic scanner
    el.holoClose.addEventListener('click', closeHoloScanner);
    el.holoPick.addEventListener('click', pickImage);
    el.holoDrop.addEventListener('dragover', (e) => { e.preventDefault(); el.holoDrop.classList.add('dragover'); });
    el.holoDrop.addEventListener('dragleave', () => el.holoDrop.classList.remove('dragover'));
    el.holoDrop.addEventListener('drop', (e) => {
      e.preventDefault(); e.stopPropagation();
      el.holoDrop.classList.remove('dragover');
      const f = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
      if (f) handleImageFile(f);
    });

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

    // Analysis + research
    el.analyzeBtn.addEventListener('click', () => {
      if (analysisPending) {
        analysisPending = false;
        el.analyzeBtn.classList.remove('active');
        el.textInput.placeholder = 'Message JARVIS…';
      } else {
        armAnalysis();
      }
    });
    el.imageBtn.addEventListener('click', pickImage);
    el.imageInput.addEventListener('change', (e) => {
      const f = e.target.files && e.target.files[0];
      if (f) handleImageFile(f);
      el.imageInput.value = '';
    });
    el.filesBtn.addEventListener('click', openResearch);
    el.researchClose.addEventListener('click', () => el.research.classList.add('hidden'));

    // Drag & drop (desktop): images -> analyse; links/text -> analyse subject
    let dragDepth = 0;
    window.addEventListener('dragenter', (e) => { e.preventDefault(); dragDepth++; el.dropZone.classList.remove('hidden'); });
    window.addEventListener('dragover', (e) => e.preventDefault());
    window.addEventListener('dragleave', (e) => { e.preventDefault(); if (--dragDepth <= 0) { dragDepth = 0; el.dropZone.classList.add('hidden'); } });
    window.addEventListener('drop', (e) => {
      e.preventDefault(); dragDepth = 0; el.dropZone.classList.add('hidden');
      const dt = e.dataTransfer;
      if (!dt) return;
      const file = dt.files && dt.files[0];
      if (file && /^image\//.test(file.type)) { handleImageFile(file); return; }
      const text = (dt.getData('text/uri-list') || dt.getData('text/plain') || '').trim();
      if (text) {
        addMessage('user', text);
        if (/^https?:\/\/\S+\.(png|jpe?g|gif|webp|bmp|svg)(\?\S*)?$/i.test(text)) {
          analyzeImage(text, 'image/jpeg', text.split('/').pop());
        } else if (/^https?:\/\//i.test(text)) {
          runAnalysis(text.replace(/^https?:\/\/(www\.)?/, '').split(/[/?#]/)[0]);
        } else {
          runAnalysis(text);
        }
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

    initTelemetry();
    applyPlatform();
    // Re-evaluate PC/mobile layout on resize when in auto mode.
    window.addEventListener('resize', () => {
      if (cfg.state.platform === 'auto') document.body.classList.toggle('platform-pc', isPC());
    });

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
