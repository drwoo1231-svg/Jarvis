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

    displayPanel: $('displayPanel'),
    dispClose: $('dispClose'),
    dispBody: $('dispBody'),

    nowPlaying: $('nowPlaying'),
    npClose: $('npClose'),
    npFrame: $('npFrame'),
    npDisk: $('npDisk'),
    npTitle: $('npTitle'),
    npViz: $('npViz'),
    npProgress: $('npProgress'),
    npBar: $('npBar'),
    npCur: $('npCur'),
    npDur: $('npDur'),
    npPrev: $('npPrev'),
    npBack: $('npBack'),
    npPlay: $('npPlay'),
    npFwd: $('npFwd'),
    npNext: $('npNext'),
    npShuffle: $('npShuffle'),
    npRepeat: $('npRepeat'),
    npFav: $('npFav'),
    npVol: $('npVol'),

    widgetsBtn: $('widgetsBtn'),
    lockBtn: $('lockBtn'),
    dashboard: $('dashboard'),
    widgetLib: $('widgetLib'),
    wlGrid: $('wlGrid'),
    wlClose: $('wlClose'),
    wlSnap: $('wlSnap'),
    wlReset: $('wlReset'),
    bgParticles: $('bgParticles'),
    mouseLight: $('mouseLight'),

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
    setCareer: $('setCareer'),
    careerPick: $('careerPick'),
    careerBtn: $('careerBtn'),
    careerLab: $('careerLab'),
    clClose: $('clClose'),
    clIcon: $('clIcon'),
    clTitle: $('clTitle'),
    clSub: $('clSub'),
    clDomains: $('clDomains'),
    clDecks: $('clDecks'),
    clStage: $('clStage'),
    clField: $('clField'),
    clEmpty: $('clEmpty'),
    clCurrent: $('clCurrent'),
    clCurrentSub: $('clCurrentSub'),
    clBar: $('clBar'),
    clCount: $('clCount'),
    clGroup: $('clGroup'),
    clQuiz: $('clQuiz'),
    clQuizQ: $('clQuizQ'),
    clQuizOpts: $('clQuizOpts'),
    clQuizScore: $('clQuizScore'),
    clScatter: $('clScatter'),
    clPause: $('clPause'),
    clPrev: $('clPrev'),
    clNext: $('clNext'),
    clQuizBtn: $('clQuizBtn'),
    clReset: $('clReset'),
    clSpeed: $('clSpeed'),
    setGoogleClientId: $('setGoogleClientId'),
    gcalConnect: $('gcalConnect'),
    gcalDisconnect: $('gcalDisconnect'),
    gcalStatus: $('gcalStatus'),
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
  const APP_VERSION = 'v3.1 · Career Lab + upgraded X-ray scanner';
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
  let identifyPending = false;   // next picked image goes through identifyImage
  let selectedPlatform = null;   // onboarding platform choice
  let selectedCareer = '';       // onboarding career-field choice
  let pendingSave = null;        // analysis awaiting a filing decision
  let pendingDeepSearch = false; // awaiting deep-search kind
  let lastAnalysisSubject = '';  // subject/title of the most recent analysis
  const RESEARCH_KEY = 'jarvis.research.v1';

  /* ---------------- Status + reactor ---------------- */
  function setStatus(text, cls) {
    el.statusText.textContent = text;
    el.statusText.className = 'status-text' + (cls ? ' ' + cls : '');
    // Map the status class to a core visual state (drives the colored ring too).
    const state = cls === 'listening' ? 'listening'
      : cls === 'thinking' ? 'thinking'
        : cls === 'speaking' ? 'speaking'
          : cls === 'searching' ? 'searching'
            : cls === 'analyzing' ? 'analyzing'
              : cls === 'warning' ? 'warning'
                : 'idle';
    Core.setState(state);
    document.body.setAttribute('data-core', state);
    jlog(text);
  }

  // Rolling JARVIS log used by the LOG widget.
  const _jlog = [];
  function jlog(text) {
    if (!text) return;
    const stamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    _jlog.unshift({ t: stamp, m: text });
    if (_jlog.length > 30) _jlog.pop();
    const body = document.getElementById('wlBody');
    if (body) {
      body.innerHTML = _jlog.slice(0, 12).map((e) =>
        `<div class="jl-row"><span class="jl-t">${e.t}</span><span class="jl-m">${escapeHtml(e.m)}</span></div>`).join('');
    }
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
    const dom = (cfg.state.career && window.JarvisCareer && window.JarvisCareer.getDomain(cfg.state.career)) || null;
    const careerBlock = dom ? `

# The User's Field — ${dom.name}
The user is training as ${/^[aeiou]/i.test(dom.title) ? 'an' : 'a'} ${dom.title.toLowerCase()}. Tailor explanations, examples, analogies and terminology to ${dom.name} whenever it fits, and pitch answers at a serious student of that field — precise, correct, unpatronising. When they ask you to teach, list or memorise something in this area, be rigorous and complete. You have a Career Lab with study modules (${dom.decks.map((d) => d.name).join(', ')}) that scatters items across a holographic field one at a time for memorisation and can quiz them; mention it when it would genuinely help.` : '';
    return `${BASE_PERSONA}

# The User
${address}${careerBlock}

# Voice Output
Your replies are spoken aloud with a British butler's voice and shown on screen. Use clean natural prose, no markdown, asterisks, bullets, headings, or emojis. Keep everyday replies to 1-3 sentences; expand only when needed.

# Device Control
You run inside an app on the user's phone and computer. To act on the device, emit one or more directives, each on its own line, as: <action>{"type":"...", ...}</action>. The app strips these before showing/speaking your reply, then performs them. Always also give a short spoken confirmation.
Actions: play_music {query,service:youtube|spotify|apple}; open_app {app}; search_web {query}; open_url {url}; navigate {destination}; call {number}; text {number,message}; email {to,subject,body}; timer {seconds,label}.
Only emit an action when the user asks you to do something on the device; for ordinary conversation, just talk. Never invent phone numbers or emails.

# Holographic Interface (v2.7)
The interface is a movable holographic operating system. Every panel is draggable (with inertia and optional snap-to-grid), remembers its position, can be brought to front, and double-clicking a panel's title bar returns it to its default spot. You can guide the user to: lock or unlock the layout, reset the layout, toggle snap-to-grid, open the widget library (the "＋" button) to add or remove panels, and add widgets such as Clock, Weather, System Status, Applications, JARVIS Log, World Map, Notes, Calculator, and Music. These layout commands are handled directly by the app, so simply confirm and describe them naturally when asked. The music player has real transport controls (previous, rewind 10 seconds, play/pause, forward 10 seconds, next, shuffle, repeat, volume, and a seekable progress bar). The Applications panel launches the actual installed app on the user's own device via its URL scheme (Spotify, Discord, Slack, WhatsApp, Mail, and more), opens real web apps directly rather than searching for them, opens the real webcam for Camera, and the real file picker for Files. Weather is shown as a live animated hologram — a glowing rotating sun, drifting clouds, falling rain, snow, or a lightning storm — matched to the current conditions. The "identify" command runs a visible X-ray scan and uses on-device object detection (COCO-SSD, which knows everyday objects like carrot, apple, banana, cup, laptop, dog) plus fine-grained classification, drawing labelled boxes around what it finds; it is teachable, so if it is wrong the user can type the correct name in the "Teach me" box and it will remember and recognise it next time. The Career Lab (the mortarboard button, or "open the career lab") holds study modules for Medical Science, Chemistry, Computer Science and Engineering — for example all 206 bones of the human skeleton, the 118 elements, the twelve cranial nerves, Big-O complexity. Ask things like "show all the 206 bones and scatter them one by one so I can memorise them" and JARVIS lays them out across a holographic field one at a time, with step controls, a speed slider and a quiz mode. JARVIS can add events to the user's REAL Google Calendar once they connect their Google account in Settings (otherwise it opens a pre-filled event for them to save); connected events also schedule phone reminders. Alarms sound in-app while JARVIS is open — a web app cannot set the phone's native Clock app, so JARVIS also offers a calendar reminder that notifies the phone at that time. If asked to set a native phone alarm, explain this honestly and offer the calendar reminder (or suggest Siri/Google Assistant for a true Clock alarm). The central core shows a colored status ring: blue idle, cyan listening, amber thinking, purple searching, white speaking, red warning.`;
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

    const tail0 = addressWord() ? ', ' + addressWord() : '';

    // Visual weather forecast (lively panel beside the core).
    if (/\b(weather|forecast|temperature|how (?:hot|cold)|is it (?:raining|sunny|snowing|cold|hot))\b/i.test(text)) {
      addMessage('user', text);
      const cm = text.match(/\b(?:in|for|at|around|near)\s+([a-z .'-]+?)\s*\??$/i);
      showWeather(cm ? cm[1].trim() : null);
      return;
    }

    // Alarm — sounds in-app; also adds a phone-notifying reminder (a browser
    // app can't set the native Clock app, so we use a calendar alert instead).
    if (/\b(?:set|create|put)?\s*(?:an?\s+)?alarm\b|\bwake me(?:\s+up)?\b/i.test(text)) {
      addMessage('user', text);
      const target = parseClockTime(text);
      if (!target) { const l = `At what time shall I set the alarm${tail0}?`; addMessage('jarvis', l); speak(l); return; }
      const label = (text.match(/\b(?:for|labelled|called)\s+([a-z ]{3,30})$/i) || [])[1] || '';
      const ts = setAlarm(target, label.trim());
      const title = 'Alarm' + (label.trim() ? ' — ' + label.trim() : '');
      if (gcalConnected()) {
        (async () => {
          try {
            await gcalCreate({ title, when: target });
            const l = `Alarm set for ${ts}${tail0}. I'll sound it in-app, and I've added a reminder to your Google Calendar so your phone alerts you at ${ts} even if JARVIS is closed.`;
            addMessage('jarvis', l); speak(l);
          } catch {
            const l = `Alarm set for ${ts}${tail0}. I'll sound it while JARVIS is open.`;
            addMessage('jarvis', l); speak(l);
          }
        })();
        return;
      }
      const action = { type: 'calendar', title, start: fmtCal(target), end: fmtCal(new Date(target.getTime() + 300000)) };
      const l = `Alarm set for ${ts}${tail0}. I'll sound it while JARVIS is open. A phone's Clock app can't be set from the web — but tap below to add a reminder that alerts your phone at ${ts} even when JARVIS is closed.`;
      addMessage('jarvis', l, [action]); speak(`Alarm set for ${ts}${tail0}. I'll sound it while JARVIS is open, and you can add a phone reminder from the button.`);
      return;
    }

    // Google Calendar event / appointment.
    if (/\b(calendar|appointment)\b/i.test(text) || /^\s*schedule\s+/i.test(text) ||
        /\b(add|create|set up|put|make)\b.*\b(event|meeting|reminder)\b/i.test(text)) {
      addMessage('user', text);
      let title = text
        .replace(/^(?:hey )?(?:jarvis[,\s]+)?(?:can you |could you |please )?(?:add|create|schedule|set up|put|make)\s+/i, '')
        .replace(/\b(?:an?|a)\s+(?:calendar\s+)?(?:event|appointment|meeting|reminder)\b(?:\s+(?:for|to|about|called|named|titled|with|of))?/i, '')
        .replace(/\b(?:on|in|to)\s+(?:my\s+)?calendar\b/i, '')
        .replace(/\b(?:at|for|on)\s+\d{1,2}(?::\d{2})?\s*(?:a\.?m\.?|p\.?m\.?)?/i, '')
        .replace(/\b(?:today|tomorrow)\b/i, '')
        .replace(/\s+/g, ' ').trim() || 'New event';
      const when = parseClockTime(text);
      const whenStr = when ? ' for ' + when.toLocaleString([], { weekday: 'short', hour: '2-digit', minute: '2-digit' }) : '';
      const template = () => {
        const action = { type: 'calendar', title };
        if (when) { action.start = fmtCal(when); action.end = fmtCal(new Date(when.getTime() + 3600000)); }
        return action;
      };
      if (gcalConnected()) {
        // Create the event directly on the user's Google Calendar.
        (async () => {
          try {
            const created = await gcalCreate({ title, when });
            const l = `Done${tail0} — "${title}" is on your Google Calendar${whenStr}. You'll get a reminder on your phone.`;
            addMessage('jarvis', l, created && created.htmlLink ? [{ type: 'open_url', url: created.htmlLink }] : undefined);
            speak(l);
            updateGcalStatus();
          } catch (e) {
            const action = template();
            const l = `I couldn't reach your Google account${tail0} — opening a pre-filled event to save instead.`;
            addMessage('jarvis', l, [action]); executeAction(action); speak(l);
          }
        })();
        return;
      }
      const action = template();
      const say = `Opening a new calendar event${whenStr}${tail0}. Adjust and save it in Google Calendar. Tip: connect your Google account in Settings and I'll add events directly.`;
      addMessage('jarvis', say, [action]); executeAction(action); speak(say);
      return;
    }

    // "identify ___" — X-ray scan + probability breakdown of a picture.
    if (/^\s*(?:jarvis[,\s]+)?(?:can you |could you |please )?identif(?:y|ies)\b/i.test(text) ||
        /^\s*what(?:'s| is| are)?\s+(?:this|that|these|it)\b.*\??$/i.test(text) && /\b(image|picture|photo|pic|thing|object|shown?)\b/i.test(text)) {
      addMessage('user', text);
      const who = titledName();
      identifyPending = true;
      addMessage('jarvis', `Select the image to identify${who ? ', ' + who : ''} — I'll scan it and break down the probabilities.`);
      speak('Select the image to identify. I will scan it and break down the probabilities.');
      setTimeout(pickImage, 250);
      return;
    }

    // Career Lab — set a field, study a deck, scatter it, get quizzed.
    {
      const who = titledName(); const t3 = who ? ', ' + who : '';
      // "I want to be a doctor" / "set my field to chemistry"
      const wantsCareer = /\bi\s+(?:want|wish|would like|am going)\s+to\s+(?:be|become|study)\b|\bi'?m\s+(?:a|an|studying)\b|\bset\s+my\s+(?:career|field|major|profession)\b|\bmy\s+(?:career|field|major|profession)\s+is\b/i.test(text);
      if (wantsCareer) {
        const hit = CAREER_WORDS.find(([re]) => re.test(text));
        if (hit) {
          addMessage('user', text);
          cfg.set({ career: hit[1] });
          if (el.setCareer) el.setCareer.value = hit[1];
          const d = Career.getDomain(hit[1]);
          const l = `Noted${t3} — I'll tutor you as ${/^[aeiou]/i.test(d.title) ? 'an' : 'a'} ${d.title.toLowerCase()}. ${d.blurb} Your modules: ${d.decks.map((k) => k.name).join(', ')}. Say "open the career lab" any time.`;
          addMessage('jarvis', l); speak(`Noted${t3}. I'll tutor you in ${d.name}. Say open the career lab whenever you're ready.`);
          return;
        }
      }
      // "quiz me [on X]"
      if (/\bquiz me\b|\btest me\b/i.test(text)) {
        addMessage('user', text);
        const dk = matchDeck(text);
        if (dk) { openCareerLab(dk, false); startQuiz(); }
        else if (CL.deck) { el.careerLab.classList.remove('hidden'); startQuiz(); }
        else { openCareerLab(); const l = `Pick a module and I'll test you${t3}.`; addMessage('jarvis', l); speak(l); return; }
        const l = `Very well${t3} — eyes on the field. Answer as they come.`;
        addMessage('jarvis', l); speak(l); return;
      }
      // "show all the 206 bones … and scatter them one by one so I can memorise"
      const wantsStudy = /\b(show|list|display|pull up|teach me|study|memoris|memoriz|scatter|drill|revise|learn)\b/i.test(text);
      const dk = wantsStudy ? matchDeck(text) : null;
      if (dk) {
        addMessage('user', text);
        const scatter = /\bscatter\b|\bone by one\b|\bmemoris|\bmemoriz|\bdrill\b|\bshow (me )?(all|every)\b|\blist\b/i.test(text);
        openCareerLab(dk, scatter);
        const found = Career.getDeck(dk);
        const n = Career.items(found.deck).length;
        const l = scatter
          ? `Bringing up all ${n} — ${found.deck.name}${t3}. I'll scatter them one at a time so you can commit each to memory. Use ◀ ▶ to step, and the speed slider to slow me down.`
          : `${found.deck.name} is on the field${t3} — ${n} items. Press Scatter when you're ready.`;
        addMessage('jarvis', l);
        speak(scatter ? `Bringing up all ${n}${t3}. I'll scatter them one at a time.` : `${found.deck.name} ready${t3}.`);
        return;
      }
      if (/\b(open|show|bring up|start)\s+(the\s+)?(career|study)\s*(lab|mode|centre|center)?\b|\bcareer lab\b|\bstudy mode\b/i.test(text)) {
        addMessage('user', text);
        openCareerLab();
        const d = careerDomain();
        const l = d ? `Career Lab open${t3} — ${d.name}. Choose a module.`
          : `Career Lab open${t3}. Choose your field along the top, then a module.`;
        addMessage('jarvis', l); speak(l); return;
      }
    }

    // Layout / widgets — the movable holographic interface.
    {
      const who = titledName(); const t2 = who ? ', ' + who : '';
      if (/\b(lock|unlock)\s+(the\s+)?(layout|panels?|widgets?)\b/i.test(text) || /\block\s+(the\s+)?(layout|panels?)\b/i.test(text)) {
        addMessage('user', text);
        const wantLock = /\block\b/i.test(text) && !/\bunlock\b/i.test(text);
        Panels.setLock(wantLock); syncLockBtn();
        const l = wantLock ? `Layout locked${t2}. Panels are pinned in place.` : `Layout unlocked${t2} — drag any panel where you like.`;
        addMessage('jarvis', l); speak(l); return;
      }
      if (/\breset\s+(the\s+|my\s+)?(layout|panels?|widgets?)\b/i.test(text)) {
        addMessage('user', text); Panels.resetAll();
        const l = `Layout restored to defaults${t2}.`; addMessage('jarvis', l); speak(l); return;
      }
      if (/\bsnap\s+to\s+grid\b|\bgrid\s+snap\b/i.test(text)) {
        addMessage('user', text); const on = /\b(off|disable|stop)\b/i.test(text) ? (Panels.setSnap(false), false) : (Panels.setSnap(true), true);
        el.wlSnap.textContent = 'Snap to grid: ' + (on ? 'On' : 'Off');
        const l = `Snap-to-grid ${on ? 'enabled' : 'disabled'}${t2}.`; addMessage('jarvis', l); speak(l); return;
      }
      if (/\b(open|show|bring up)\s+(the\s+)?widget\s+(library|menu|list)\b|\badd\s+a\s+widget\b|\bwidget\s+library\b/i.test(text)) {
        addMessage('user', text); el.widgetLib.classList.remove('hidden');
        const l = `Widget library open${t2}. Tap a widget to add or remove it.`; addMessage('jarvis', l); speak(l); return;
      }
      const wm2 = text.match(/\b(show|add|open|display|hide|remove|close)\s+(?:the\s+|my\s+)?(clock|time|weather|system|status|applications?|apps|calculator|calc|notes?|world\s*map|map|music|log)\b(?:\s+(widget|panel))?/i);
      if (wm2 && (wm2[3] || /\b(widget|panel)\b/i.test(text))) {
        addMessage('user', text);
        const map = { clock: 'wTime', time: 'wTime', weather: 'wWeather', system: 'wSystem', status: 'wSystem', application: 'wApps', applications: 'wApps', app: 'wApps', apps: 'wApps', calculator: 'wCalc', calc: 'wCalc', note: 'wNotes', notes: 'wNotes', worldmap: 'wMap', map: 'wMap', music: 'nowPlaying', log: 'wLog' };
        const key = wm2[2].toLowerCase().replace(/\s+/g, '');
        const id = map[key];
        const hide = /\b(hide|remove|close)\b/i.test(wm2[1]);
        if (id) { setWidgetVisible(id, !hide); const l = `${hide ? 'Hid' : 'Added'} the ${wm2[2]} ${wm2[3] || 'panel'}${t2}.`; addMessage('jarvis', l); speak(l); return; }
      }
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
    // "open_app" launches the real native app on the device (URL scheme) with
    // the web app as fallback — never a web search.
    if (a && String(a.type).toLowerCase() === 'open_app' && a.app) {
      const r = Actions.openApp(a.app);
      toast((r && r.native ? 'Opening ' : 'Launching ') + (r ? r.label : a.app));
      return;
    }
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
      beep(4);
      try { navigator.vibrate && navigator.vibrate([200, 100, 200]); } catch {}
    }, seconds * 1000);
  }

  // A short alarm tone via WebAudio.
  /* ---------------- Google Calendar (real one-tap events) ----------------
     With a Google OAuth client ID (Settings), JARVIS signs in and writes
     events straight to the user's calendar via the Calendar API — which also
     schedules phone reminders. Without it, we fall back to a pre-filled
     Calendar link the user saves themselves. */
  let gcalTokenClient = null, gcalToken = '', gcalTokenExp = 0;
  function loadGIS() {
    return new Promise((res, rej) => {
      if (window.google && window.google.accounts && window.google.accounts.oauth2) return res();
      const s = document.createElement('script');
      let done = false;
      const fin = (fn, a) => { if (!done) { done = true; fn(a); } };
      s.src = 'https://accounts.google.com/gsi/client'; s.async = true; s.defer = true;
      s.onload = () => fin(res);
      s.onerror = () => fin(rej, new Error('Google sign-in failed to load'));
      setTimeout(() => fin(rej, new Error('Google sign-in timed out')), 10000);
      document.head.appendChild(s);
    });
  }
  function gcalInitClient() {
    const cid = (cfg.state.googleClientId || '').trim();
    if (!cid || !(window.google && window.google.accounts)) return null;
    gcalTokenClient = window.google.accounts.oauth2.initTokenClient({
      client_id: cid,
      scope: 'https://www.googleapis.com/auth/calendar.events',
      callback: () => {},
    });
    return gcalTokenClient;
  }
  function gcalGetToken(interactive) {
    return new Promise((resolve, reject) => {
      if (gcalToken && Date.now() < gcalTokenExp - 60000) return resolve(gcalToken);
      if (!gcalTokenClient && !gcalInitClient()) return reject(new Error('Add a Google client ID in Settings'));
      gcalTokenClient.callback = (resp) => {
        if (resp && resp.access_token) { gcalToken = resp.access_token; gcalTokenExp = Date.now() + (resp.expires_in || 3600) * 1000; resolve(gcalToken); }
        else reject(new Error((resp && resp.error) || 'authorisation failed'));
      };
      try { gcalTokenClient.requestAccessToken({ prompt: interactive ? 'consent' : '' }); } catch (e) { reject(e); }
    });
  }
  function gcalConnected() { return !!(cfg.state.googleClientId || '').trim(); }
  function fmtDateOnly(d) { const p = (n) => String(n).padStart(2, '0'); return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`; }
  async function gcalCreate(ev) {
    await loadGIS();
    const token = await gcalGetToken(false);
    const body = {
      summary: ev.title || 'New event',
      reminders: { useDefault: false, overrides: [{ method: 'popup', minutes: 0 }, { method: 'popup', minutes: 10 }] },
    };
    if (ev.when) {
      body.start = { dateTime: ev.when.toISOString() };
      body.end = { dateTime: new Date(ev.when.getTime() + 3600000).toISOString() };
    } else {
      const d = fmtDateOnly(new Date());
      body.start = { date: d }; body.end = { date: d };
    }
    const r = await fetch('https://www.googleapis.com/calendar/v3/calendars/primary/events', {
      method: 'POST', headers: { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' }, body: JSON.stringify(body),
    });
    if (!r.ok) throw new Error('calendar returned ' + r.status);
    return r.json();
  }
  function updateGcalStatus() {
    if (!el.gcalStatus) return;
    const has = gcalConnected();
    el.gcalStatus.textContent = !has ? 'Not connected — using pre-filled links.'
      : (gcalToken ? '✓ Connected — events go straight to your calendar.' : 'Client ID saved — tap “Connect Google”.');
    el.gcalStatus.style.color = gcalToken ? '#23d18b' : '';
  }

  function beep(times) {
    try {
      audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
      let t0 = audioCtx.currentTime;
      for (let i = 0; i < (times || 4); i++) {
        const o = audioCtx.createOscillator(), g = audioCtx.createGain();
        o.frequency.value = i % 2 ? 880 : 660;
        o.connect(g); g.connect(audioCtx.destination);
        g.gain.setValueAtTime(0.0001, t0);
        g.gain.exponentialRampToValueAtTime(0.3, t0 + 0.02);
        g.gain.exponentialRampToValueAtTime(0.0001, t0 + 0.35);
        o.start(t0); o.stop(t0 + 0.36); t0 += 0.5;
      }
    } catch { /* audio unavailable */ }
  }

  // Parse a clock time (with am/pm and today/tomorrow) out of free text.
  function parseClockTime(text) {
    const m = text.match(/(\d{1,2})(?::(\d{2}))?\s*(a\.?m\.?|p\.?m\.?)?/i);
    if (!m) return null;
    let h = parseInt(m[1], 10); const min = m[2] ? parseInt(m[2], 10) : 0;
    const ap = (m[3] || '').toLowerCase().replace(/\./g, '');
    if (ap === 'pm' && h < 12) h += 12;
    if (ap === 'am' && h === 12) h = 0;
    const now = new Date();
    const target = new Date(now.getFullYear(), now.getMonth(), now.getDate(), h, min, 0, 0);
    if (/tomorrow/i.test(text)) target.setDate(target.getDate() + 1);
    else if (target <= now && !/today/i.test(text)) target.setDate(target.getDate() + 1);
    return target;
  }
  function fmtCal(d) {
    const p = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}${p(d.getMonth() + 1)}${p(d.getDate())}T${p(d.getHours())}${p(d.getMinutes())}00`;
  }
  function setAlarm(target, label) {
    const ts = target.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    const ms = target - Date.now();
    setTimeout(() => {
      const who = titledName();
      const line = `${label ? label + ' — ' : ''}Alarm${who ? ', ' + who : ''}. It is ${ts}.`;
      addMessage('jarvis', line);
      speak(`Alarm. It is ${ts}. ${label || ''}`);
      beep(8);
      try { navigator.vibrate && navigator.vibrate([400, 200, 400, 200, 400]); } catch {}
    }, ms);
    return ts;
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

  /* ---------------- In-app music player (spinning disk) ----------------
     The disk design is unchanged; on top of it we drive a real YouTube
     IFrame player so the transport controls (−10s / +10s / play-pause /
     volume / seek) actually work. Falls back to a plain embed if the API
     can't load. */
  let ytPlayer = null, npTick = null, npRepeat = false, npShuffle = false;
  const musicHistory = [];     // { id, title } session queue for prev/next
  let musicIdx = -1;

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
    stopNpTick();
    try { if (ytPlayer && ytPlayer.destroy) ytPlayer.destroy(); } catch { /* ignore */ }
    ytPlayer = null;
    el.npFrame.innerHTML = '';                // stop playback
    el.npDisk.classList.remove('spinning');
    el.nowPlaying.classList.remove('playing');
  }

  function loadYTApi() {
    return new Promise((resolve) => {
      if (window.YT && window.YT.Player) return resolve(true);
      const prev = window.onYouTubeIframeAPIReady;
      window.onYouTubeIframeAPIReady = () => { try { prev && prev(); } catch { /* */ } resolve(true); };
      if (!document.getElementById('yt-iframe-api')) {
        const s = document.createElement('script');
        s.id = 'yt-iframe-api'; s.src = 'https://www.youtube.com/iframe_api';
        s.onerror = () => resolve(false);
        document.head.appendChild(s);
      }
      setTimeout(() => resolve(!!(window.YT && window.YT.Player)), 4500);
    });
  }

  async function playVideoId(id, title, fromNav) {
    el.npTitle.textContent = title;
    el.npDisk.classList.add('spinning');
    el.nowPlaying.classList.add('playing');
    if (!fromNav) {                          // record in the session queue
      musicHistory.splice(musicIdx + 1);     // drop any forward history
      musicHistory.push({ id, title });
      musicIdx = musicHistory.length - 1;
    }
    const ok = await loadYTApi();
    if (ok && window.YT && window.YT.Player) {
      if (ytPlayer && ytPlayer.loadVideoById) {
        ytPlayer.loadVideoById(id);
        startNpTick();
      } else {
        el.npFrame.innerHTML = '<div id="ytplayer"></div>';
        ytPlayer = new window.YT.Player('ytplayer', {
          videoId: id,
          playerVars: { autoplay: 1, playsinline: 1, rel: 0, controls: 0, modestbranding: 1, iv_load_policy: 3 },
          events: {
            onReady: (e) => { try { e.target.playVideo(); } catch { /* */ } applyVol(); startNpTick(); },
            onStateChange: onYtState,
          },
        });
      }
    } else {
      // Fallback: plain embed (no programmatic seek).
      el.npFrame.innerHTML =
        `<iframe src="https://www.youtube.com/embed/${id}?autoplay=1&playsinline=1&rel=0" ` +
        `title="player" allow="autoplay; encrypted-media" allowfullscreen></iframe>`;
    }
  }

  function onYtState(e) {
    const S = window.YT && window.YT.PlayerState;
    if (!S) return;
    if (e.data === S.PLAYING) { el.npPlay.textContent = '⏸'; el.npDisk.classList.add('spinning'); startNpTick(); }
    else if (e.data === S.PAUSED) { el.npPlay.textContent = '▶'; el.npDisk.classList.remove('spinning'); }
    else if (e.data === S.ENDED) {
      el.npDisk.classList.remove('spinning');
      if (npRepeat) { try { ytPlayer.seekTo(0, true); ytPlayer.playVideo(); } catch { /* */ } }
      else musicNext();
    }
  }
  function fmtTime(s) {
    s = Math.max(0, Math.floor(s || 0));
    const m = Math.floor(s / 60); return m + ':' + String(s % 60).padStart(2, '0');
  }
  function startNpTick() {
    stopNpTick();
    npTick = setInterval(() => {
      if (!ytPlayer || !ytPlayer.getDuration) return;
      const cur = ytPlayer.getCurrentTime() || 0;
      const dur = ytPlayer.getDuration() || 0;
      el.npCur.textContent = fmtTime(cur);
      el.npDur.textContent = fmtTime(dur);
      el.npBar.style.width = dur ? (cur / dur * 100) + '%' : '0%';
    }, 500);
  }
  function stopNpTick() { if (npTick) { clearInterval(npTick); npTick = null; } }
  function applyVol() { try { if (ytPlayer && ytPlayer.setVolume) ytPlayer.setVolume(parseInt(el.npVol.value, 10)); } catch { /* */ } }
  function musicSeek(delta) { try { if (ytPlayer && ytPlayer.getCurrentTime) ytPlayer.seekTo(Math.max(0, ytPlayer.getCurrentTime() + delta), true); } catch { /* */ } }
  function musicToggle() {
    try {
      const S = window.YT && window.YT.PlayerState;
      if (!ytPlayer || !S) return;
      const st = ytPlayer.getPlayerState();
      if (st === S.PLAYING) ytPlayer.pauseVideo(); else ytPlayer.playVideo();
    } catch { /* */ }
  }
  function musicPrev() {
    try { if (ytPlayer && ytPlayer.getCurrentTime && ytPlayer.getCurrentTime() > 3) { ytPlayer.seekTo(0, true); return; } } catch { /* */ }
    if (musicIdx > 0) { musicIdx--; const it = musicHistory[musicIdx]; playVideoId(it.id, it.title, true); }
    else musicSeek(-9999);
  }
  function musicNext() {
    if (musicIdx < musicHistory.length - 1) { musicIdx++; const it = musicHistory[musicIdx]; playVideoId(it.id, it.title, true); }
    else { try { ytPlayer && ytPlayer.seekTo(0, true); } catch { /* */ } }
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

  /* ---- Shared display panel beside the core ---- */
  function showDisplayPanel(html) {
    el.dispBody.innerHTML = html;
    el.displayPanel.classList.remove('hidden');
  }
  function closeDisplay() { el.displayPanel.classList.add('hidden'); el.dispBody.innerHTML = ''; }

  // Fetch a representative image URL for a subject (Wikipedia REST summary is
  // the most reliable for thumbnails; falls back to the search generator).
  async function fetchImage(query) {
    try {
      const s = await fetch('https://en.wikipedia.org/api/rest_v1/page/summary/' + encodeURIComponent(query.replace(/\s+/g, '_')));
      if (s.ok) {
        const d = await s.json();
        const src = (d.originalimage && d.originalimage.source) || (d.thumbnail && d.thumbnail.source);
        if (src) return { title: d.title || query, image: src, extract: d.extract || '' };
      }
    } catch { /* try generator */ }
    const w = await fetchWiki(query).catch(() => null);
    if (w && w.image) return w;
    return w ? { ...w, image: '' } : null;
  }

  /* ---- Visual pull-up (a picture, shown beside the core) ---- */
  async function showVisual(query) {
    const tail = addressWord() ? ', ' + addressWord() : '';
    showDisplayPanel('<div class="disp-title">◉ Visual Feed</div><div class="disp-loading">Retrieving imagery…</div>');
    const t = startThinking(['Searching visual archives', 'Retrieving imagery', 'Rendering']);
    const data = await fetchImage(query);
    if (data && data.image) {
      lastAnalysisSubject = data.title;
      t.finish('Pulled up ' + data.title + '.', 96);
      showDisplayPanel(
        `<div class="disp-title">◉ ${escapeHtml(data.title || 'Visual')}</div>` +
        `<img src="${data.image}" alt="" referrerpolicy="no-referrer" onerror="this.style.display='none'"/>` +
        (data.extract ? `<div class="disp-cap">${escapeHtml(data.extract.split('. ').slice(0, 2).join('. '))}</div>` : '')
      );
      addMessage('jarvis', `Here is ${data.title}${tail}. I've put it on the display beside me.`);
      speak(`Here is ${data.title}${tail}.`);
    } else {
      closeDisplay();
      t.finish("I couldn't pull that from my archives — opening image results.", 45);
      Actions.autoOpen('https://www.google.com/search?tbm=isch&q=' + encodeURIComponent(query));
    }
  }

  /* ---- Live visual weather forecast ---- */
  function wxIcon(code) {
    if (code === 0 || code === 1) return { emoji: '☀️', cls: 'sun', precip: null };
    if (code === 2) return { emoji: '⛅', cls: '', precip: null };
    if (code === 3) return { emoji: '☁️', cls: '', precip: null };
    if (code === 45 || code === 48) return { emoji: '🌫️', cls: '', precip: null };
    if (code >= 51 && code <= 67) return { emoji: '🌧️', cls: '', precip: 'rain' };
    if ((code >= 71 && code <= 77) || code === 85 || code === 86) return { emoji: '❄️', cls: '', precip: 'snow' };
    if (code >= 80 && code <= 82) return { emoji: '🌦️', cls: '', precip: 'rain' };
    if (code >= 95) return { emoji: '⛈️', cls: '', precip: 'rain' };
    return { emoji: '🌡️', cls: '', precip: null };
  }
  function precipHTML(kind) {
    if (!kind) return '';
    let drops = '';
    for (let i = 0; i < 14; i++) {
      const left = Math.round(Math.random() * 100);
      const dur = (0.5 + Math.random() * 0.7).toFixed(2);
      const delay = (Math.random()).toFixed(2);
      drops += `<i style="left:${left}%;animation-duration:${dur}s;animation-delay:${delay}s"></i>`;
    }
    return `<div class="wx-precip ${kind === 'snow' ? 'snow' : ''}">${drops}</div>`;
  }

  /* Live holographic weather scene (animated CSS, not an emoji): glowing sun
     with rotating rays, drifting clouds, falling rain, snow, lightning. */
  function weatherSceneType(code) {
    if (code === 0 || code === 1) return 'sun';
    if (code === 2) return 'partly';
    if (code === 3) return 'cloud';
    if (code === 45 || code === 48) return 'fog';
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return 'rain';
    if ((code >= 71 && code <= 77) || code === 85 || code === 86) return 'snow';
    if (code >= 95) return 'storm';
    return 'sun';
  }
  function weatherSceneHTML(code, size) {
    const type = weatherSceneType(code);
    const hasSun = type === 'sun' || type === 'partly';
    const hasCloud = type === 'partly' || type === 'cloud' || type === 'rain' || type === 'snow' || type === 'storm';
    let inner = '';
    if (hasSun) inner += '<div class="wsc-sun"><span class="wsc-rays"></span><span class="wsc-core"></span></div>';
    if (type === 'fog') inner += '<div class="wsc-fog"><i></i><i></i><i></i></div>';
    if (hasCloud) inner += '<div class="wsc-cloud"><b></b><b></b><b></b><b></b></div>';
    if (type === 'rain' || type === 'storm') {
      let r = '';
      for (let i = 0; i < 16; i++) {
        const l = 8 + Math.random() * 82, dur = (0.45 + Math.random() * 0.45).toFixed(2), dl = (Math.random()).toFixed(2);
        r += `<i style="left:${l}%;animation-duration:${dur}s;animation-delay:${dl}s"></i>`;
      }
      inner += `<div class="wsc-rain">${r}</div>`;
    }
    if (type === 'snow') {
      let s = '';
      for (let i = 0; i < 16; i++) {
        const l = 6 + Math.random() * 88, dur = (1.8 + Math.random() * 1.8).toFixed(2), dl = (Math.random() * 2).toFixed(2), dx = Math.round(Math.random() * 14 - 7);
        s += `<i style="left:${l}%;animation-duration:${dur}s;animation-delay:${dl}s;--dx:${dx}px"></i>`;
      }
      inner += `<div class="wsc-snow">${s}</div>`;
    }
    if (type === 'storm') inner += '<span class="wsc-bolt"></span>';
    return `<div class="wsc wsc-${type} ${size === 'sm' ? 'wsc-sm' : 'wsc-lg'}">${inner}</div>`;
  }
  async function showWeather(city) {
    const tail = addressWord() ? ', ' + addressWord() : '';
    showDisplayPanel('<div class="disp-title">◉ Weather</div><div class="disp-loading">Acquiring location…</div>');
    const t = startThinking(['Fixing location', 'Contacting meteorological feed', 'Rendering forecast']);
    try {
      let lat, lon, place;
      if (city) {
        const g = await fetch('https://geocoding-api.open-meteo.com/v1/search?count=1&name=' + encodeURIComponent(city));
        const gd = await g.json();
        if (!gd.results || !gd.results[0]) { t.finish("I couldn't find that place.", 40); showDisplayPanel(`<div class="disp-title">◉ Weather</div><div class="disp-loading">Couldn't locate ${escapeHtml(city)}.</div>`); return; }
        lat = gd.results[0].latitude; lon = gd.results[0].longitude; place = gd.results[0].name + (gd.results[0].country_code ? ', ' + gd.results[0].country_code : '');
      } else {
        const pos = await new Promise((res, rej) => navigator.geolocation.getCurrentPosition(res, rej, { timeout: 9000 }));
        lat = pos.coords.latitude; lon = pos.coords.longitude; place = 'Your location';
      }
      const r = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min&forecast_days=1&timezone=auto`);
      const d = await r.json();
      const c = d.current;
      const temp = Math.round(c.temperature_2m);
      const hi = d.daily ? Math.round(d.daily.temperature_2m_max[0]) : null;
      const lo = d.daily ? Math.round(d.daily.temperature_2m_min[0]) : null;
      t.finish('Forecast ready.', 97);
      showDisplayPanel(
        `<div class="disp-title">◉ Weather · ${escapeHtml(place)}</div>` +
        `<div class="wx">` +
        weatherSceneHTML(c.weather_code, 'lg') +
        `<div class="wx-temp">${temp}°C</div>` +
        `<div class="wx-cond">${(WMO[c.weather_code] || 'clear')}</div>` +
        `<div class="wx-loc">${escapeHtml(place)}</div>` +
        (hi != null ? `<div class="wx-extra">H ${hi}°  ·  L ${lo}°</div>` : '') +
        `</div>`
      );
      speak(`It's ${temp} degrees and ${WMO[c.weather_code] || 'clear'} in ${place}${tail}.`);
    } catch (e) {
      t.finish('Weather feed unavailable.', 40);
      showDisplayPanel(`<div class="disp-title">◉ Weather</div><div class="disp-loading">${city ? "Couldn't reach the weather feed." : 'Tell me a city — location access was denied.'}</div>`);
    }
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
      const identify = identifyPending; identifyPending = false;
      const r = new FileReader();
      r.onload = () => (identify ? identifyImage(r.result, file.type, file.name) : analyzeImage(r.result, file.type, file.name));
      r.readAsDataURL(file); return;
    }
    identifyPending = false;
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

  /* ---------- Keyless image identification (on-device MobileNet) ---------- */
  function loadScript(src) {
    return new Promise((res, rej) => {
      const s = document.createElement('script');
      let done = false;
      const finish = (fn, arg) => { if (!done) { done = true; fn(arg); } };
      s.src = src;
      s.onload = () => finish(res);
      s.onerror = () => finish(rej, new Error('load failed: ' + src));
      // Don't let a hung CDN block a scan forever.
      setTimeout(() => finish(rej, new Error('load timeout: ' + src)), 12000);
      document.head.appendChild(s);
    });
  }
  const CDN = 'https://cdn.jsdelivr.net/npm/';
  let _tf = null, _mobilenet = null, _coco = null, _knn = null;
  async function loadTF() { if (!window.tf) await loadScript(CDN + '@tensorflow/tfjs@4/dist/tf.min.js'); _tf = window.tf; return _tf; }
  async function loadMobileNet() {
    if (_mobilenet) return _mobilenet;
    await loadTF();
    if (!window.mobilenet) await loadScript(CDN + '@tensorflow-models/mobilenet@2/dist/mobilenet.min.js');
    _mobilenet = await window.mobilenet.load({ version: 2, alpha: 1.0 });
    return _mobilenet;
  }
  // COCO-SSD detects 80 EVERYDAY objects — including carrot, apple, banana,
  // orange, broccoli, cup, laptop, phone, dog, cat, person… — the "basic
  // stuff" MobileNet's 1,000 fine-grained classes miss. It also gives boxes.
  async function loadCoco() {
    if (_coco) return _coco;
    await loadTF();
    if (!window.cocoSsd) await loadScript(CDN + '@tensorflow-models/coco-ssd@2/dist/coco-ssd.min.js');
    _coco = await window.cocoSsd.load({ base: 'lite_mobilenet_v2' });
    return _coco;
  }
  // KNN classifier = on-device "training". The user teaches it labels and it
  // remembers them (persisted), consulted first on future scans.
  async function loadKNN() {
    if (_knn) return _knn;
    await loadTF();
    if (!window.knnClassifier) await loadScript(CDN + '@tensorflow-models/knn-classifier@1/dist/knn-classifier.min.js');
    _knn = window.knnClassifier.create();
    try {
      const raw = localStorage.getItem('jarvis.knn.v1');
      if (raw) {
        const obj = JSON.parse(raw), t = {};
        Object.keys(obj).forEach((k) => { const a = obj[k]; t[k] = window.tf.tensor(a, [a.length / 1024, 1024]); });
        _knn.setClassifierDataset(t);
      }
    } catch { /* start fresh */ }
    return _knn;
  }
  function persistKNN(knn) {
    try {
      const ds = knn.getClassifierDataset(), obj = {};
      Object.keys(ds).forEach((k) => { obj[k] = Array.from(ds[k].dataSync()); });
      localStorage.setItem('jarvis.knn.v1', JSON.stringify(obj));
    } catch { /* quota / unsupported */ }
  }
  function knnCount(knn) { try { return Object.keys(knn.getClassifierDataset()).length; } catch { return 0; } }

  function imgFromDataUrl(dataUrl) {
    return new Promise((res, rej) => { const im = new Image(); im.crossOrigin = 'anonymous'; im.onload = () => res(im); im.onerror = rej; im.src = dataUrl; });
  }
  // Run every available detector on one image element.
  async function visionScan(imgEl) {
    const out = { detections: [], classifications: [], taught: null };
    let emb = null;
    try { const coco = await loadCoco(); out.detections = await coco.detect(imgEl, 10); } catch { /* offline */ }
    try {
      const mn = await loadMobileNet();
      out.classifications = (await mn.classify(imgEl, 5)).map((p) => ({ label: String(p.className).split(',')[0].trim(), prob: p.probability }));
      try { if (mn.infer) emb = mn.infer(imgEl, true); } catch { emb = null; }
    } catch { /* offline */ }
    // Consult what the user has taught (if anything).
    try {
      if (emb && localStorage.getItem('jarvis.knn.v1')) {
        const knn = await loadKNN();
        if (knnCount(knn) > 0) { const r = await knn.predictClass(emb, 3); out.taught = { label: r.label, prob: r.confidences[r.label] }; }
      }
    } catch { /* no taught data */ }
    if (emb && emb.dispose) emb.dispose();
    return out;
  }
  // Teach a label for the current image (adds a KNN example, persists it).
  async function teachLabel(dataUrl, label) {
    try {
      const mn = await loadMobileNet();
      const knn = await loadKNN();
      const imgEl = await imgFromDataUrl(dataUrl);
      const emb = mn.infer(imgEl, true);
      knn.addExample(emb, label);
      emb.dispose();
      persistKNN(knn);
      return true;
    } catch { return false; }
  }
  function articleFor(word) { return /^[aeiou]/i.test((word || '').trim()) ? 'an' : 'a'; }
  function probListHTML(preds) {
    return '<div class="prob-list">' + preds.map((p, i) => {
      const pct = Math.round(p.prob * 100);
      return `<div class="prob-row${i === 0 ? ' top' : ''}"><span class="pn">${escapeHtml(p.label)}</span>` +
        `<span class="ptrack"><span class="pbar" style="width:${pct}%"></span></span>` +
        `<span class="pp">${pct}%</span></div>`;
    }).join('') + '</div>';
  }
  // Headline result: radial gauge + name + source, above the breakdown.
  function identHeadHTML(label, pct, source) {
    const src = source === 'taught' ? 'MATCHED · YOUR TRAINING'
      : source === 'coco' ? 'OBJECT DETECTION · LOCKED'
        : source === 'mobilenet' ? 'CLASSIFIER · BEST MATCH' : 'LOW CONFIDENCE';
    return `<div class="ident-head">${confDialHTML(pct)}<div>` +
      `<div class="ident-name">${escapeHtml(label)}</div>` +
      `<div class="ident-meta${source ? '' : ' warn'}">${src}</div>` +
      `</div></div>`;
  }
  // Merge detections + classifications into one ranked probability list.
  function buildPredList(scan) {
    const map = new Map();
    (scan.detections || []).forEach((d) => { if (!map.has(d.class) || map.get(d.class) < d.score) map.set(d.class, d.score); });
    (scan.classifications || []).forEach((c) => { if (!map.has(c.label)) map.set(c.label, c.prob); });
    return [...map.entries()].map(([label, prob]) => ({ label, prob })).sort((a, b) => b.prob - a.prob).slice(0, 5);
  }

  /* ---- Visible X-ray scan overlay ---- */
  function startXray(media, img) {
    if (img) img.classList.add('xray');
    if (!media) return;
    media.classList.add('scanning', 'ident-media');
    if (!media.querySelector('.xray-fx')) {
      media.insertAdjacentHTML('beforeend',
        '<div class="xray-fx">' +
        '<span class="xr-grid"></span><span class="xr-beam"></span><span class="xr-sweepline"></span>' +
        '<span class="xr-label">◉ X-RAY SCAN</span>' +
        '<span class="xr-corner tl"></span><span class="xr-corner tr"></span><span class="xr-corner bl"></span><span class="xr-corner br"></span>' +
        '<span class="xr-hud">' +
        '<span class="xh-tr">SPECTRAL DECOMPOSITION<br>NEURAL NET · ACTIVE</span>' +
        '<span class="xh-bl">ANALYSING<span class="xh-bar"><i></i></span></span>' +
        '</span></div>');
    }
  }
  function stopXray(media, img) {
    if (img) img.classList.remove('xray');
    if (media) { media.classList.remove('scanning'); const fx = media.querySelector('.xray-fx'); if (fx) fx.remove(); }
  }
  // Draw lock-on reticles over each detection (object-fit: contain mapping),
  // snapping on one at a time like a targeting system.
  function drawBoxes(media, img, detections) {
    if (!media || !img) return;
    const nW = img.naturalWidth, nH = img.naturalHeight, cW = img.clientWidth, cH = img.clientHeight;
    if (!nW || !cW) return;
    const scale = Math.min(cW / nW, cH / nH);
    const offX = (cW - nW * scale) / 2, offY = (cH - nH * scale) / 2;
    const hits = detections.filter((d) => d.score >= 0.35).slice(0, 6);
    const old = media.querySelector('.ident-boxes'); if (old) old.remove();
    if (!hits.length) return;
    const wrap = document.createElement('div');
    wrap.className = 'ident-boxes';
    media.appendChild(wrap);
    hits.forEach((d, i) => {
      const [x, y, w, h] = d.bbox;
      setTimeout(() => {
        const b = document.createElement('div');
        b.className = 'ident-box lock';
        b.style.cssText = `left:${offX + x * scale}px;top:${offY + y * scale}px;width:${w * scale}px;height:${h * scale}px`;
        b.innerHTML = '<i></i><i></i><i></i><i></i>' +
          `<span>${escapeHtml(d.class)} ${Math.round(d.score * 100)}%</span>`;
        wrap.appendChild(b);
      }, i * 180);
    });
  }
  // Radial confidence gauge for the headline result.
  function confDialHTML(pct) {
    const R = 32, C = 2 * Math.PI * R;
    const off = C * (1 - Math.max(0, Math.min(100, pct)) / 100);
    return `<div class="conf-dial"><svg width="74" height="74" viewBox="0 0 74 74" aria-hidden="true">` +
      `<defs><linearGradient id="cdGrad" x1="0" y1="0" x2="1" y2="1">` +
      `<stop offset="0%" stop-color="#46b6ff"/><stop offset="100%" stop-color="#ffffff"/></linearGradient></defs>` +
      `<circle class="cd-track" cx="37" cy="37" r="${R}"/>` +
      `<circle class="cd-val" cx="37" cy="37" r="${R}" stroke-dasharray="${C.toFixed(1)}" stroke-dashoffset="${C.toFixed(1)}"/>` +
      `</svg><span class="cd-num">${pct}%</span></div>`;
  }
  // Animate the dial to its value once it's in the DOM.
  function runConfDial(root, pct) {
    const c = root && root.querySelector('.conf-dial .cd-val');
    if (!c) return;
    const R = 32, C = 2 * Math.PI * R;
    requestAnimationFrame(() => { c.style.strokeDashoffset = String(C * (1 - Math.max(0, Math.min(100, pct)) / 100)); });
  }
  // "Not right? teach me" — trains the on-device classifier.
  function addTeachRow(actions, textEl, dataUrl, currentLabel, who) {
    const wrap = document.createElement('div');
    wrap.className = 'teach-row';
    wrap.innerHTML = '<input class="teach-input no-drag" type="text" maxlength="40" placeholder="Not right? Teach me what it is…"><button class="teach-btn">Teach</button>';
    const input = wrap.querySelector('.teach-input'), btn = wrap.querySelector('.teach-btn');
    const go = async () => {
      const label = (input.value || '').trim();
      if (!label) { input.focus(); return; }
      btn.disabled = true; btn.textContent = 'Learning…';
      const ok = await teachLabel(dataUrl, label);
      btn.textContent = ok ? 'Learned ✓' : 'Try again';
      if (ok) {
        lastAnalysisSubject = label;
        const say = `Understood${who ? ', ' + who : ''}. I'll remember this is ${articleFor(label)} ${label}.`;
        textEl.innerHTML = `<b>${escapeHtml(label)}</b> — learned from you. I'll recognise it next time.`;
        addMessage('jarvis', say); speak(say);
        try { const ref = await fetchImage(label); if (ref && ref.image) showDisplayPanel(`<div class="disp-title">◉ ${escapeHtml(ref.title || label)}</div><img src="${ref.image}" referrerpolicy="no-referrer" onerror="this.style.display='none'"/>`); } catch { /* */ }
      } else { btn.disabled = false; }
    };
    btn.addEventListener('click', go);
    input.addEventListener('keydown', (e) => { if (e.key === 'Enter') go(); });
    actions.appendChild(wrap);
  }

  // The "identify" flow: visible X-ray scan → object detection + classification
  // → name it (with boxes) & pull a reference image, or focus-mode Google.
  async function identifyImage(dataUrl, mime, name) {
    closeHoloScanner();
    const who = titledName();
    const tail = who ? ', ' + who : '';
    renderAnalysisCard({ title: name || 'Unidentified subject', image: dataUrl, extract: '' }, { image: true });
    const cards = el.log.querySelectorAll('.analysis-card');
    const card = cards[cards.length - 1];
    const media = card.querySelector('.analysis-media');
    const img = card.querySelector('.analysis-media img');
    const textEl = card.querySelector('.analysis-text');
    const actions = card.querySelector('.analysis-actions');
    actions.innerHTML = '';
    const started = Date.now();
    startXray(media, img);

    const line = `Scanning${tail} — decomposing the image.`;
    addMessage('jarvis', line); speak(line);
    const t = startThinking(['Initialising neural nets', 'X-ray decomposition', 'Detecting objects', 'Matching known classes', 'Computing probabilities']);

    const imgEl = await imgFromDataUrl(dataUrl).catch(() => null);
    let scan = { detections: [], classifications: [], taught: null };
    if (imgEl) { try { scan = await visionScan(imgEl); } catch { /* offline */ } }

    // Hold the x-ray on screen for at least ~1.7s so it's clearly visible.
    await new Promise((r) => setTimeout(r, Math.max(0, 1700 - (Date.now() - started))));
    stopXray(media, img);
    if (scan.detections.length) drawBoxes(media, img, scan.detections);

    const preds = buildPredList(scan);
    let best = null, source = '';
    if (scan.taught && scan.taught.prob >= 0.65) { best = { label: scan.taught.label, prob: scan.taught.prob }; source = 'taught'; }
    if (!best) { const d = scan.detections.slice().sort((a, b) => b.score - a.score)[0]; if (d && d.score >= 0.5) { best = { label: d.class, prob: d.score }; source = 'coco'; } }
    if (!best && scan.classifications.length && scan.classifications[0].prob >= 0.18) { best = { label: scan.classifications[0].label, prob: scan.classifications[0].prob }; source = 'mobilenet'; }

    if (!best) {
      const guess = (scan.classifications[0] && scan.classifications[0].label) || (name || 'this object').replace(/\.[a-z0-9]+$/i, '');
      const lowPct = scan.classifications[0] ? Math.round(scan.classifications[0].prob * 100) : 0;
      t.finish('Confidence too low — engaging focus mode.', lowPct || 30);
      textEl.innerHTML = preds.length
        ? (identHeadHTML(guess, lowPct, '') + probListHTML(preds))
        : `I couldn't identify it on-device${escapeHtml(tail)}.`;
      runConfDial(textEl, lowPct);
      const say = `I cannot identify this with confidence${tail}. Engaging focus mode — searching it on Google.`;
      addMessage('jarvis', say); speak(say);
      Actions.autoOpen('https://www.google.com/search?tbm=isch&q=' + encodeURIComponent(guess));
      buildConfirmedActions(actions, { title: guess, image: dataUrl, extract: 'Low-confidence identification.', type: 'photo' });
      addTeachRow(actions, textEl, dataUrl, guess, who);
      return;
    }

    const pct = Math.round(best.prob * 100);
    const others = scan.detections.filter((d) => d.score >= 0.4).length;
    t.finish(`Identified: ${best.label}${source === 'coco' && others > 1 ? ` (+${others - 1} more)` : ''}.`, Math.min(99, Math.max(55, pct)));
    lastAnalysisSubject = best.label;
    const extra = source === 'taught' ? ' (from what you taught me)' : '';
    textEl.innerHTML = identHeadHTML(best.label, pct, source) + probListHTML(preds);
    runConfDial(textEl, pct);
    addMessage('jarvis', `It seems your image is ${articleFor(best.label)} ${best.label} — ${pct}% confidence${extra}${tail}.`);
    speak(`It seems your image is ${articleFor(best.label)} ${best.label}, ${pct} percent confidence${tail}.`);

    try {
      const ref = await fetchImage(best.label);
      if (ref && ref.image) {
        showDisplayPanel(
          `<div class="disp-title">◉ ${escapeHtml(ref.title || best.label)}</div>` +
          `<img src="${ref.image}" alt="" referrerpolicy="no-referrer" onerror="this.style.display='none'"/>` +
          (ref.extract ? `<div class="disp-cap">${escapeHtml(ref.extract.split('. ').slice(0, 2).join('. '))}</div>` : '')
        );
        if (ref.extract) textEl.innerHTML += `<div class="ident-desc">${escapeHtml(ref.extract.split('. ').slice(0, 2).join('. '))}.</div>`;
      }
    } catch { /* reference image is a bonus */ }

    buildConfirmedActions(actions, { title: best.label, image: dataUrl, extract: textEl.textContent, type: 'photo' });
    addTeachRow(actions, textEl, dataUrl, best.label, who);
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
    selectedCareer = cfg.state.career || '';
    if (el.careerPick) el.careerPick.querySelectorAll('.career-opt').forEach((b) =>
      b.classList.toggle('selected', b.dataset.career === selectedCareer));
    setTimeout(() => el.nameInput.focus(), 200);
  }

  function completeOnboarding() {
    const name = el.nameInput.value.trim();
    const hon = el.honorificSelect.value;
    cfg.set({ userName: name, honorific: hon, platform: selectedPlatform || 'auto', career: selectedCareer || '', onboarded: true });
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
    if (el.setCareer) el.setCareer.value = cfg.state.career || '';
    if (el.setGoogleClientId) el.setGoogleClientId.value = cfg.state.googleClientId || '';
    updateGcalStatus();
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
      googleClientId: el.setGoogleClientId ? el.setGoogleClientId.value.trim() : (cfg.state.googleClientId || ''),
      career: el.setCareer ? el.setCareer.value : (cfg.state.career || ''),
    });
    gcalTokenClient = null; // pick up any client-id change on next request
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

    // Career field picker (onboarding)
    if (el.careerPick) el.careerPick.querySelectorAll('.career-opt').forEach((btn) => {
      btn.addEventListener('click', () => {
        selectedCareer = selectedCareer === btn.dataset.career ? '' : btn.dataset.career;
        el.careerPick.querySelectorAll('.career-opt').forEach((b) =>
          b.classList.toggle('selected', b.dataset.career === selectedCareer));
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

    // Display panel + Now Playing
    el.dispClose.addEventListener('click', closeDisplay);
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

    // Google Calendar connect / disconnect
    if (el.gcalConnect) el.gcalConnect.addEventListener('click', async () => {
      const cid = el.setGoogleClientId.value.trim();
      if (!cid) { toast('Paste your Google client ID first.'); return; }
      cfg.set({ googleClientId: cid }); gcalTokenClient = null;
      el.gcalConnect.disabled = true; el.gcalConnect.textContent = 'Connecting…';
      try { await loadGIS(); await gcalGetToken(true); toast('Google Calendar connected.'); }
      catch (e) { toast('Could not connect: ' + (e && e.message || 'error')); }
      el.gcalConnect.disabled = false; el.gcalConnect.textContent = 'Connect Google';
      updateGcalStatus();
    });
    if (el.gcalDisconnect) el.gcalDisconnect.addEventListener('click', () => {
      try { if (gcalToken && window.google) window.google.accounts.oauth2.revoke(gcalToken, () => {}); } catch { /* */ }
      gcalToken = ''; gcalTokenExp = 0;
      toast('Google Calendar disconnected.');
      updateGcalStatus();
    });
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

  /* ========================================================================
     v2.7 — movable panels, widget library, dashboard widgets, dog companion,
     ambient visuals. Everything below is additive to the existing HUD.
     ======================================================================== */
  const Panels = window.JarvisPanels;
  const LS_WIDGETS = 'jarvis.widgets.v1';
  const WIDGETS = [
    { id: 'wTime', name: 'Clock', icon: '◷' },
    { id: 'wWeather', name: 'Weather', icon: '☁' },
    { id: 'wSystem', name: 'System', icon: '▤' },
    { id: 'wApps', name: 'Applications', icon: '⌘' },
    { id: 'wLog', name: 'JARVIS Log', icon: '❯' },
    { id: 'wMap', name: 'World Map', icon: '◍' },
    { id: 'wNotes', name: 'Notes', icon: '✎' },
    { id: 'wCalc', name: 'Calculator', icon: '=' },
    { id: 'nowPlaying', name: 'Music', icon: '♪' },
  ];

  function initDashboard() {
    if (!Panels) return;
    // Make every panel draggable. Overlay panels drag from their body; widgets
    // drag from their title bar; music drags from the NOW PLAYING tag.
    Panels.enable(el.displayPanel, { id: 'displayPanel' });
    const npPanel = el.nowPlaying.querySelector('.np-panel');
    if (npPanel) Panels.enable(npPanel, { id: 'nowPlaying', handle: '.np-tag' });
    const holoPanel = el.holoScanner.querySelector('.holo-panel');
    if (holoPanel) Panels.enable(holoPanel, { id: 'holoScanner', handle: '.holo-title' });
    ['wTime', 'wWeather', 'wSystem', 'wApps', 'wLog', 'wMap', 'wNotes', 'wCalc'].forEach((id) => {
      const node = document.getElementById(id);
      if (node) Panels.enable(node, { id, handle: '.w-head' });
    });
    Panels.initPrefs();
    syncLockBtn();

    // Per-widget close buttons.
    document.querySelectorAll('.widget .w-x').forEach((b) => {
      b.addEventListener('click', (e) => {
        const w = e.target.closest('.widget');
        if (w) setWidgetVisible(w.id, false);
      });
    });

    buildWidgetLibrary();
    buildAppsGrid();
    const wwr = document.getElementById('wwRefresh');
    if (wwr) wwr.addEventListener('click', loadWeatherWidget);
    buildCalc();
    buildWorldMap();
    initNotes();
    initMusicControls();
    restoreWidgets();

    // Widget library + layout controls.
    el.widgetsBtn.addEventListener('click', () => el.widgetLib.classList.toggle('hidden'));
    el.wlClose.addEventListener('click', () => el.widgetLib.classList.add('hidden'));
    el.lockBtn.addEventListener('click', () => { Panels.toggleLock(); syncLockBtn(); toast(Panels.isLocked() ? 'Layout locked.' : 'Layout unlocked — drag panels freely.'); });
    el.wlSnap.addEventListener('click', () => { const on = Panels.toggleSnap(); el.wlSnap.textContent = 'Snap to grid: ' + (on ? 'On' : 'Off'); });
    el.wlReset.addEventListener('click', () => { Panels.resetAll(); toast('Layout reset to defaults.'); });
    el.wlSnap.textContent = 'Snap to grid: ' + (Panels.isSnap() ? 'On' : 'Off');

    // Live updaters.
    tickWidgetClock(); setInterval(tickWidgetClock, 1000);
    updateSystemWidget(); setInterval(updateSystemWidget, 4000);
  }

  function syncLockBtn() {
    if (el.lockBtn) el.lockBtn.classList.toggle('active', Panels.isLocked());
  }

  /* ---- Widget visibility + library ---- */
  function loadWidgetPrefs() {
    try { return JSON.parse(localStorage.getItem(LS_WIDGETS)); } catch { return null; }
  }
  function saveWidgetPrefs(list) {
    try { localStorage.setItem(LS_WIDGETS, JSON.stringify(list)); } catch { /* */ }
  }
  function visibleWidgets() {
    return WIDGETS.filter((w) => { const n = document.getElementById(w.id); return n && !n.classList.contains('hidden'); }).map((w) => w.id);
  }
  function setWidgetVisible(id, show, quiet) {
    const node = document.getElementById(id);
    if (!node) return;
    node.classList.toggle('hidden', !show);
    if (show) Panels.front(id);
    const chip = el.wlGrid && el.wlGrid.querySelector(`[data-w="${id}"]`);
    if (chip) chip.classList.toggle('on', show);
    if (!quiet) saveWidgetPrefs(visibleWidgets());
    if (show && id === 'wWeather') loadWeatherWidget();
  }
  function buildWidgetLibrary() {
    el.wlGrid.innerHTML = '';
    WIDGETS.forEach((w) => {
      const b = document.createElement('button');
      b.className = 'wl-chip'; b.dataset.w = w.id;
      b.innerHTML = `<span class="wl-ic">${w.icon}</span><span>${w.name}</span>`;
      b.addEventListener('click', () => {
        const node = document.getElementById(w.id);
        setWidgetVisible(w.id, node.classList.contains('hidden'));
      });
      el.wlGrid.appendChild(b);
    });
  }
  function restoreWidgets() {
    let list = loadWidgetPrefs();
    if (!Array.isArray(list)) list = isPC() ? ['wTime', 'wWeather', 'wSystem', 'wApps', 'wLog', 'wMap'] : [];
    WIDGETS.forEach((w) => setWidgetVisible(w.id, list.indexOf(w.id) >= 0, true));
    saveWidgetPrefs(list);
  }

  /* ---- Clock widget ---- */
  function tickWidgetClock() {
    const c = document.getElementById('wtClock'), d = document.getElementById('wtDate');
    if (!c) return;
    const now = new Date();
    c.textContent = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    d.textContent = now.toLocaleDateString([], { weekday: 'long', month: 'short', day: 'numeric' });
  }

  /* ---- Weather widget (keyless open-meteo) ---- */
  async function loadWeatherWidget() {
    const body = document.getElementById('wwBody');
    if (!body) return;
    body.innerHTML = '<div class="w-loading">Acquiring…</div>';
    try {
      let lat, lon, place;
      const saved = localStorage.getItem('jarvis.wxcity');
      if (saved) {
        const g = await (await fetch('https://geocoding-api.open-meteo.com/v1/search?count=1&name=' + encodeURIComponent(saved))).json();
        if (g.results && g.results[0]) { lat = g.results[0].latitude; lon = g.results[0].longitude; place = g.results[0].name; }
      }
      if (lat == null) {
        const pos = await new Promise((res, rej) => navigator.geolocation.getCurrentPosition(res, rej, { timeout: 8000 }));
        lat = pos.coords.latitude; lon = pos.coords.longitude; place = 'Local';
      }
      const d = await (await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code&timezone=auto`)).json();
      body.innerHTML = `<div class="ww">${weatherSceneHTML(d.current.weather_code, 'sm')}` +
        `<span class="ww-temp">${Math.round(d.current.temperature_2m)}°C</span></div>` +
        `<div class="ww-cond">${WMO[d.current.weather_code] || 'clear'} · ${escapeHtml(place)}</div>`;
    } catch {
      body.innerHTML = '<div class="w-loading">Allow location, or set a city with "weather in ___".</div>';
    }
  }

  /* ---- System status widget ---- */
  let _batt = null;
  async function updateSystemWidget() {
    const body = document.getElementById('wsBody');
    if (!body || document.getElementById('wSystem').classList.contains('hidden')) return;
    const cores = navigator.hardwareConcurrency || 4;
    // No true CPU meter in a browser; show a lively estimate that trends with activity.
    const cpu = Math.min(99, Math.round(12 + Math.random() * 22 + (busy ? 30 : 0)));
    let ram = null;
    if (performance && performance.memory) ram = Math.round(performance.memory.usedJSHeapSize / performance.memory.jsHeapSizeLimit * 100);
    else if (navigator.deviceMemory) ram = Math.round(35 + Math.random() * 20);
    else ram = 45;
    const conn = navigator.connection || {};
    const net = conn.downlink ? Math.min(100, Math.round(conn.downlink / 10 * 100)) : 68;
    if (!_batt && navigator.getBattery) { try { _batt = await navigator.getBattery(); _batt.addEventListener('levelchange', updateSystemWidget); } catch { /* */ } }
    const batt = _batt ? Math.round(_batt.level * 100) : 97;
    const rows = [
      ['CPU', cpu, cores + ' cores'],
      ['RAM', ram, ''],
      ['NETWORK', net, conn.effectiveType ? conn.effectiveType.toUpperCase() : ''],
      ['BATTERY', batt, _batt && _batt.charging ? '⚡' : ''],
    ];
    body.innerHTML = rows.map(([k, v, note]) =>
      `<div class="ss-row"><span class="ss-k">${k}</span>` +
      `<span class="ss-track"><span class="ss-bar" style="width:${v}%"></span></span>` +
      `<span class="ss-v">${v}%${note ? ' <em>' + note + '</em>' : ''}</span></div>`).join('');
  }

  /* ---- Applications widget (quick launch) ----
     Tiles open the REAL app on the user's machine: native URL schemes launch
     the installed desktop/mobile app (web app as fallback), Camera opens the
     actual webcam, Files opens the real file picker. No web searches. */
  function buildAppsGrid() {
    const grid = document.getElementById('waGrid');
    if (!grid) return;
    const apps = [
      ['Spotify', '♫', () => launchNative('spotify')],
      ['Discord', '🎮', () => launchNative('discord')],
      ['YouTube', '▶', () => launchNative('youtube')],
      ['Maps', '◈', () => launchNative('maps')],
      ['Mail', '✉', () => launchNative('mail')],
      ['Calendar', '▦', () => Actions.autoOpen('https://calendar.google.com')],
      ['Camera', '◉', () => openCamera()],
      ['Files', '▤', () => openFiles()],
    ];
    grid.innerHTML = '';
    apps.forEach(([name, ic, fn]) => {
      const b = document.createElement('button');
      b.className = 'app-tile'; b.innerHTML = `<span class="app-ic">${ic}</span><span>${name}</span>`;
      b.addEventListener('click', fn);
      grid.appendChild(b);
    });
  }
  function launchNative(key) {
    const r = Actions.openApp(key);
    toast((r && r.native ? 'Opening ' : 'Launching ') + (r ? r.label : key) + (r && r.native ? ' on your device' : ''));
  }

  // Real webcam feed — "connect to my computer's camera".
  let camStream = null;
  async function openCamera() {
    const who = addressWord() ? ', ' + addressWord() : '';
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      toast('Camera not available in this browser.'); return;
    }
    showDisplayPanel('<div class="disp-title">◉ Camera Feed</div><div class="disp-loading">Requesting camera…</div>');
    try {
      camStream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' }, audio: false });
      el.dispBody.innerHTML = '<div class="disp-title">◉ Live Camera</div><video id="camVideo" autoplay playsinline muted class="cam-video"></video>' +
        '<div class="cam-row"><button class="w-mini-btn" id="camSnap" style="margin:8px 6px 0 0">📸 Snapshot</button><button class="w-mini-btn" id="camStop" style="margin:8px 0 0">■ Stop</button></div>';
      const v = document.getElementById('camVideo'); v.srcObject = camStream;
      document.getElementById('camStop').addEventListener('click', stopCamera);
      document.getElementById('camSnap').addEventListener('click', () => {
        const cv = document.createElement('canvas'); cv.width = v.videoWidth || 640; cv.height = v.videoHeight || 480;
        cv.getContext('2d').drawImage(v, 0, 0, cv.width, cv.height);
        toast('Snapshot captured.');
        identifyImage(cv.toDataURL('image/png'), 'image/png', 'camera-snapshot.png');
      });
      addMessage('jarvis', `Camera online${who}. I've put the live feed on the display.`);
    } catch (e) {
      el.dispBody.innerHTML = '<div class="disp-title">◉ Camera</div><div class="disp-loading">Camera access was denied.</div>';
      toast('Camera access denied.');
    }
  }
  function stopCamera() {
    if (camStream) { camStream.getTracks().forEach((t) => t.stop()); camStream = null; }
    closeDisplay();
  }

  // Real file access — "connect to my computer's files".
  async function openFiles() {
    const who = addressWord() ? ', ' + addressWord() : '';
    if (window.showOpenFilePicker) {
      try {
        const [handle] = await window.showOpenFilePicker();
        const file = await handle.getFile();
        addMessage('jarvis', `Opening ${file.name}${who}.`);
        handleImageFile(file);
        return;
      } catch { /* user cancelled or unsupported — fall through */ }
    }
    // Fallback: the OS file chooser (opens the user's real files).
    const inp = document.createElement('input');
    inp.type = 'file';
    inp.addEventListener('change', () => { const f = inp.files && inp.files[0]; if (f) handleImageFile(f); });
    inp.click();
  }

  /* ---- World map widget (decorative dotted globe) ---- */
  function buildWorldMap() {
    const wrap = document.getElementById('wmDots');
    if (!wrap) return;
    const COLS = 42, ROWS = 18;
    // A coarse land-mask so the dots read as continents.
    const mask = [
      '......xxx.......xxxxx......', '...xxxxxxxx...xxxxxxxxxx...', '..xxxxxxxx...xxxxxxxxxxxx..',
      '..xxxxxx......xxxxxxxx.....', '...xxxx.......xxxxxxx......', '....xx.........xxxxxx......',
      '....x...........xxxx.......', '.................xx........',
    ];
    let html = '';
    for (let r = 0; r < ROWS; r++) {
      for (let c = 0; c < COLS; c++) {
        const mr = mask[Math.floor(r / ROWS * mask.length)] || '';
        const on = mr[Math.floor(c / COLS * mr.length)] === 'x';
        const hot = on && Math.random() < 0.06;
        html += `<span class="wm-dot${on ? ' on' : ''}${hot ? ' hot' : ''}"></span>`;
      }
    }
    wrap.style.setProperty('--cols', COLS);
    wrap.innerHTML = html;
  }

  /* ---- Notes widget ---- */
  function initNotes() {
    const t = document.getElementById('wnText');
    if (!t) return;
    t.value = localStorage.getItem('jarvis.notes') || '';
    t.addEventListener('input', () => { try { localStorage.setItem('jarvis.notes', t.value); } catch { /* */ } });
  }

  /* ---- Calculator widget ---- */
  function buildCalc() {
    const keys = document.getElementById('wcKeys'), screen = document.getElementById('wcScreen');
    if (!keys) return;
    const layout = ['C', '(', ')', '/', '7', '8', '9', '*', '4', '5', '6', '-', '1', '2', '3', '+', '0', '.', '⌫', '='];
    let expr = '';
    const render = () => { screen.textContent = expr || '0'; };
    keys.innerHTML = '';
    layout.forEach((k) => {
      const b = document.createElement('button');
      b.className = 'calc-key' + (k === '=' ? ' eq' : (/[/*\-+()]/.test(k) ? ' op' : ''));
      b.textContent = k;
      b.addEventListener('click', () => {
        if (k === 'C') expr = '';
        else if (k === '⌫') expr = expr.slice(0, -1);
        else if (k === '=') {
          try {
            if (/^[0-9+\-*/().\s]+$/.test(expr)) { const v = Function('"use strict";return (' + expr + ')')(); expr = String(+(+v).toFixed(8)); }
            else expr = 'Error';
          } catch { expr = 'Error'; }
        } else { if (expr === 'Error') expr = ''; expr += k; }
        render();
      });
      keys.appendChild(b);
    });
    render();
  }

  /* ---- Music transport controls ---- */
  function initMusicControls() {
    el.npPlay.addEventListener('click', musicToggle);
    el.npBack.addEventListener('click', () => musicSeek(-10));
    el.npFwd.addEventListener('click', () => musicSeek(10));
    el.npPrev.addEventListener('click', musicPrev);
    el.npNext.addEventListener('click', musicNext);
    el.npVol.addEventListener('input', applyVol);
    el.npShuffle.addEventListener('click', () => { npShuffle = !npShuffle; el.npShuffle.classList.toggle('on', npShuffle); });
    el.npRepeat.addEventListener('click', () => { npRepeat = !npRepeat; el.npRepeat.classList.toggle('on', npRepeat); });
    el.npFav.addEventListener('click', () => {
      const on = el.npFav.classList.toggle('on');
      el.npFav.textContent = on ? '♥' : '♡';
      toast(on ? 'Added to favourites.' : 'Removed from favourites.');
    });
    el.npProgress.addEventListener('click', (e) => {
      try {
        if (!ytPlayer || !ytPlayer.getDuration) return;
        const r = el.npProgress.getBoundingClientRect();
        const frac = Math.max(0, Math.min(1, (e.clientX - r.left) / r.width));
        ytPlayer.seekTo(frac * ytPlayer.getDuration(), true);
      } catch { /* */ }
    });
  }

  /* ---- Ambient particles + mouse-responsive lighting ---- */
  function initAmbient() {
    if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    // Mouse light + parallax.
    window.addEventListener('pointermove', (e) => {
      if (el.mouseLight) el.mouseLight.style.transform = `translate(${e.clientX}px, ${e.clientY}px)`;
      const px = (e.clientX / window.innerWidth - 0.5) * 2;
      const py = (e.clientY / window.innerHeight - 0.5) * 2;
      document.body.style.setProperty('--par-x', (px * 8).toFixed(1) + 'px');
      document.body.style.setProperty('--par-y', (py * 8).toFixed(1) + 'px');
    }, { passive: true });

    const cv = el.bgParticles;
    if (!cv) return;
    const ctx = cv.getContext('2d');
    let W, H, dots = [];
    const seed = () => {
      W = cv.width = window.innerWidth; H = cv.height = window.innerHeight;
      const n = Math.min(90, Math.round(W * H / 26000));
      dots = Array.from({ length: n }, () => ({
        x: Math.random() * W, y: Math.random() * H,
        vx: (Math.random() - 0.5) * 0.25, vy: (Math.random() - 0.5) * 0.25,
        r: Math.random() * 1.6 + 0.4, a: Math.random() * 0.5 + 0.15,
      }));
    };
    seed(); window.addEventListener('resize', seed);
    const draw = () => {
      ctx.clearRect(0, 0, W, H);
      for (const d of dots) {
        d.x += d.vx; d.y += d.vy;
        if (d.x < 0) d.x = W; if (d.x > W) d.x = 0;
        if (d.y < 0) d.y = H; if (d.y > H) d.y = 0;
        ctx.beginPath(); ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(120,210,255,${d.a})`; ctx.fill();
      }
      requestAnimationFrame(draw);
    };
    draw();
  }

  /* ========================================================================
     CAREER LAB — domain-tailored study modules.
     Pick a field (medicine / chemistry / CS / engineering) and JARVIS scatters
     a deck of knowledge into a holographic field one item at a time so it can
     be memorised, then drills it back with a quiz.
     ======================================================================== */
  const Career = window.JarvisCareer;
  const CL = {
    domain: null, deck: null, items: [], idx: -1,
    timer: null, running: false, speed: 620, quiz: null,
  };

  function careerDomain() {
    return (cfg.state.career && Career.getDomain(cfg.state.career)) || null;
  }
  function careerName() {
    const d = careerDomain();
    return d ? d.name : '';
  }

  function openCareerLab(deckId, autoScatter) {
    if (!Career) return;
    el.careerLab.classList.remove('hidden');
    const startDomain = (deckId && Career.getDeck(deckId) && Career.getDeck(deckId).domain)
      || careerDomain() || Career.getDomain('medicine');
    renderDomains(startDomain.id);
    selectDomain(startDomain.id, deckId);
    if (deckId) selectDeck(deckId, autoScatter);
  }
  function closeCareerLab() {
    stopScatter();
    el.careerLab.classList.add('hidden');
  }

  function renderDomains(activeId) {
    el.clDomains.innerHTML = '';
    Career.domainIds.forEach((id) => {
      const d = Career.getDomain(id);
      const b = document.createElement('button');
      b.className = 'cl-dom' + (id === activeId ? ' on' : '');
      b.innerHTML = `<span>${d.icon}</span><em>${escapeHtml(d.name)}</em>`;
      b.addEventListener('click', () => { renderDomains(id); selectDomain(id); });
      el.clDomains.appendChild(b);
    });
  }
  function selectDomain(id, keepDeck) {
    const d = Career.getDomain(id);
    if (!d) return;
    CL.domain = d;
    el.careerLab.style.setProperty('--cl-accent', d.accent);
    el.clIcon.textContent = d.icon;
    el.clTitle.textContent = d.name.toUpperCase();
    el.clSub.textContent = d.blurb;
    el.clDecks.innerHTML = '';
    d.decks.forEach((deck) => {
      const n = Career.items(deck).length;
      const b = document.createElement('button');
      b.className = 'cl-deck';
      b.dataset.deck = deck.id;
      b.innerHTML = `<span class="cl-deck-ic">${deck.icon}</span>` +
        `<span class="cl-deck-txt"><b>${escapeHtml(deck.name)}</b><em>${escapeHtml(deck.blurb)}</em></span>` +
        `<span class="cl-deck-n">${n}</span>`;
      b.addEventListener('click', () => selectDeck(deck.id, false));
      el.clDecks.appendChild(b);
    });
    if (!keepDeck) { CL.deck = null; CL.items = []; resetField(); }
  }

  function selectDeck(deckId, autoScatter) {
    const found = Career.getDeck(deckId);
    if (!found) return;
    if (!CL.domain || CL.domain.id !== found.domain.id) { renderDomains(found.domain.id); selectDomain(found.domain.id, true); }
    CL.deck = found.deck;
    CL.items = Career.items(found.deck);
    el.clDecks.querySelectorAll('.cl-deck').forEach((b) => b.classList.toggle('on', b.dataset.deck === deckId));
    el.clSub.textContent = `${found.deck.name} · ${CL.items.length} items`;
    resetField();
    if (autoScatter) startScatter();
  }

  function resetField() {
    stopScatter();
    CL.idx = -1;
    el.clField.innerHTML = '';
    el.clQuiz.classList.add('hidden');
    el.clEmpty.classList.toggle('hidden', !!CL.deck);
    if (CL.deck) el.clEmpty.classList.add('hidden');
    el.clCurrent.textContent = CL.deck ? CL.deck.name : '—';
    el.clCurrentSub.textContent = CL.deck ? CL.deck.blurb : '';
    el.clBar.style.width = '0%';
    el.clCount.textContent = `0 / ${CL.items.length}`;
    el.clGroup.textContent = '';
  }

  // Scatter positions: a golden-angle spiral fills the field evenly, but items
  // are *dealt* to those slots with a coprime stride so each new one lands far
  // from the last — it spreads across the whole field from the very first bone
  // instead of piling up in the middle.
  function coprimeStride(n) {
    const gcd = (a, b) => (b ? gcd(b, a % b) : a);
    let s = Math.max(1, Math.round(n * 0.618));
    for (let k = 0; k < n; k++) { if (gcd(s, n) === 1) return s; s++; if (s >= n) s = 1; }
    return 1;
  }
  function scatterPos(i, n) {
    if (CL._posN !== n) { CL._posN = n; CL._stride = coprimeStride(n); }
    const slot = (i * CL._stride) % n;              // deal, don't fill in order
    const a = slot * 2.39996;                       // golden angle
    const r = Math.sqrt((slot + 0.6) / n);
    const jit = (k) => ((Math.sin(k * 12.9898) * 43758.5453) % 1) * 3.2;
    return {
      x: Math.max(5, Math.min(95, 50 + Math.cos(a) * r * 45 + jit(i))),
      y: Math.max(6, Math.min(94, 50 + Math.sin(a) * r * 42 + jit(i + 7))),
    };
  }
  function sizeClass(n) { return n > 130 ? ' xs' : n > 60 ? ' sm' : ''; }

  function emitItem(i) {
    const item = CL.items[i];
    if (!item) return;
    const p = scatterPos(i, CL.items.length);
    const chip = document.createElement('div');
    chip.className = 'cl-chip' + sizeClass(CL.items.length);
    chip.dataset.i = String(i);
    chip.style.left = p.x + '%';
    chip.style.top = p.y + '%';
    chip.innerHTML = (item.badge ? `<b class="cl-badge">${escapeHtml(item.badge)}</b>` : '') +
      `<span class="cl-chip-l">${escapeHtml(item.label)}</span>`;
    chip.addEventListener('click', () => focusItem(i));
    el.clField.appendChild(chip);
    requestAnimationFrame(() => chip.classList.add('in'));
    focusItem(i, true);
  }

  function focusItem(i, fromScatter) {
    CL.idx = i;
    const item = CL.items[i];
    if (!item) return;
    el.clField.querySelectorAll('.cl-chip.now').forEach((c) => c.classList.remove('now'));
    const chip = el.clField.querySelector(`.cl-chip[data-i="${i}"]`);
    if (chip) { chip.classList.add('now'); }
    el.clCurrent.textContent = item.label;
    el.clCurrentSub.textContent = item.sub || '';
    el.clGroup.textContent = item.group || '';
    el.clCount.textContent = `${i + 1} / ${CL.items.length}`;
    el.clBar.style.width = ((i + 1) / CL.items.length * 100) + '%';
    // Announce each new region as it begins — useful, not chatty.
    if (fromScatter && item.group && item.group !== CL._lastGroup) {
      CL._lastGroup = item.group;
      speak(item.group);
    }
  }

  function startScatter() {
    if (!CL.deck || !CL.items.length) return;
    if (CL.idx >= CL.items.length - 1) { el.clField.innerHTML = ''; CL.idx = -1; CL._lastGroup = ''; }
    CL.running = true;
    el.clEmpty.classList.add('hidden');
    el.clQuiz.classList.add('hidden');
    el.clPause.textContent = '⏸ Pause';
    const tick = () => {
      if (!CL.running) return;
      const next = CL.idx + 1;
      if (next >= CL.items.length) { finishScatter(); return; }
      emitItem(next);
      CL.timer = setTimeout(tick, CL.speed);
    };
    CL.timer = setTimeout(tick, 120);
  }
  function stopScatter() {
    CL.running = false;
    if (CL.timer) { clearTimeout(CL.timer); CL.timer = null; }
    if (el.clPause) el.clPause.textContent = '▶ Resume';
  }
  function finishScatter() {
    stopScatter();
    const who = addressWord() ? ', ' + addressWord() : '';
    const line = `All ${CL.items.length} ${CL.deck.name.replace(/^The\s+\d+\s+/, '').toLowerCase()} are on the field${who}. Say "quiz me" and I'll test you.`;
    addMessage('jarvis', line); speak(`All ${CL.items.length} are laid out${who}. Shall I quiz you?`);
  }
  function stepBy(d) {
    stopScatter();
    const target = Math.max(0, Math.min(CL.items.length - 1, CL.idx + d));
    // Emit any items we haven't drawn yet.
    for (let i = el.clField.childElementCount; i <= target; i++) emitItem(i);
    focusItem(target);
    const item = CL.items[target];
    if (item) speak(item.label.replace(/·\s*L$/, ' left').replace(/·\s*R$/, ' right'));
  }

  /* ---- Quiz ---- */
  function startQuiz() {
    if (!CL.deck || !CL.items.length) { toast('Pick a module first.'); return; }
    stopScatter();
    CL.quiz = { score: 0, asked: 0 };
    el.clQuiz.classList.remove('hidden');
    nextQuestion();
  }
  function nextQuestion() {
    const pool = CL.items;
    let answer = pool[Math.floor(Math.random() * pool.length)];
    // Don't ask the same thing twice in a row.
    for (let k = 0; k < 12 && pool.length > 1 && answer.label === CL._lastAsked; k++) {
      answer = pool[Math.floor(Math.random() * pool.length)];
    }
    CL._lastAsked = answer.label;
    // A subtitle is only a fair question if it identifies exactly one item
    // ("smell · sensory" does; a bone's region "hand" does not — several share
    // it). Unique subtitle → ask by definition; shared → ask by region, with
    // distractors drawn from OTHER regions so the question has one answer.
    if (CL._subUnique === undefined || CL._subDeck !== CL.deck.id) {
      CL._subDeck = CL.deck.id;
      const subs = pool.map((x) => x.sub).filter(Boolean);
      CL._subUnique = subs.length === pool.length && new Set(subs).size === pool.length;
    }
    const byDefinition = CL._subUnique && !!answer.sub;
    const src = byDefinition
      ? pool.filter((x) => x.label !== answer.label && x.group === answer.group)
      : pool.filter((x) => x.group !== answer.group);
    const fallback = pool.filter((x) => x.label !== answer.label);
    const from = src.length >= 3 ? src : fallback;
    const opts = [answer];
    let guard = 0;
    while (opts.length < 4 && from.length && guard++ < 200) {
      const c = from[Math.floor(Math.random() * from.length)];
      if (!opts.some((o) => o.label === c.label)) opts.push(c);
    }
    opts.sort(() => Math.random() - 0.5);
    el.clQuizQ.innerHTML = byDefinition
      ? `Which is <b>${escapeHtml(answer.sub)}</b>?`
      : `Which of these belongs to the <b>${escapeHtml(answer.group || CL.deck.name)}</b>?`;
    el.clQuizOpts.innerHTML = '';
    opts.forEach((o) => {
      const b = document.createElement('button');
      b.className = 'cl-opt';
      b.textContent = o.label;
      b.addEventListener('click', () => answerQuestion(b, o.label === answer.label, answer));
      el.clQuizOpts.appendChild(b);
    });
    el.clQuizScore.textContent = CL.quiz.asked ? `Score ${CL.quiz.score} / ${CL.quiz.asked}` : 'Answer to begin.';
  }
  function answerQuestion(btn, correct, answer) {
    CL.quiz.asked++;
    if (correct) { CL.quiz.score++; btn.classList.add('right'); }
    else {
      btn.classList.add('wrong');
      [...el.clQuizOpts.children].forEach((b) => { if (b.textContent === answer.label) b.classList.add('right'); });
    }
    [...el.clQuizOpts.children].forEach((b) => { b.disabled = true; });
    const hit = CL.items.findIndex((x) => x.label === answer.label);
    if (hit >= 0) { for (let i = el.clField.childElementCount; i <= hit; i++) emitItem(i); focusItem(hit); }
    el.clQuizScore.textContent = `Score ${CL.quiz.score} / ${CL.quiz.asked}` + (correct ? ' · correct' : ` · it was ${answer.label}`);
    setTimeout(nextQuestion, correct ? 750 : 1600);
  }

  function initCareerLab() {
    if (!Career || !el.careerLab) return;
    el.careerBtn.addEventListener('click', () => openCareerLab());
    el.clClose.addEventListener('click', closeCareerLab);
    el.clScatter.addEventListener('click', () => { el.clField.innerHTML = ''; CL.idx = -1; CL._lastGroup = ''; startScatter(); });
    el.clPause.addEventListener('click', () => { if (CL.running) stopScatter(); else startScatter(); });
    el.clPrev.addEventListener('click', () => stepBy(-1));
    el.clNext.addEventListener('click', () => stepBy(1));
    el.clQuizBtn.addEventListener('click', startQuiz);
    el.clReset.addEventListener('click', resetField);
    el.clSpeed.addEventListener('input', () => { CL.speed = 1720 - parseInt(el.clSpeed.value, 10); });
    CL.speed = 1720 - parseInt(el.clSpeed.value, 10);
    if (Panels) Panels.enable(el.careerLab.querySelector('.cl-panel'), { id: 'careerLab', handle: '.cl-head' });
  }

  // Map free text to a study deck.
  function matchDeck(text) {
    const t = text.toLowerCase();
    if (/\bbones?\b|\bskeleton\b|\bskeletal\b/.test(t)) return 'bones';
    if (/\bcranial nerves?\b|\bnerves?\b/.test(t)) return 'nerves';
    if (/\borgan systems?\b|\bbody systems?\b/.test(t)) return 'systems';
    if (/\bvitals?\b|\blab (values|ranges)\b|\breference ranges?\b/.test(t)) return 'vitals';
    if (/\bperiodic table\b|\belements?\b/.test(t)) return 'elements';
    if (/\bpolyatomic\b|\bions?\b/.test(t)) return 'ions';
    if (/\bbig[- ]?o\b|\bcomplexit(y|ies)\b/.test(t)) return 'bigo';
    if (/\bdata structures?\b/.test(t)) return 'ds';
    if (/\balgorithms?\b|\bcs concepts?\b/.test(t)) return 'concepts';
    if (/\bmechanics?\b|\bmaterials?\b|\bstress\b|\bstrain\b/.test(t)) return 'mechanics';
    if (/\belectrical\b|\bcircuits?\b|\bohm\b/.test(t)) return 'electrical';
    if (/\bconstants?\b/.test(t)) return careerDomain() && careerDomain().id === 'engineering' ? 'engconst' : 'constants';
    return null;
  }
  const CAREER_WORDS = [
    [/\b(doctor|physician|surgeon|medical|medicine|med school|nurse|anatomy|pre[- ]?med)\b/i, 'medicine'],
    [/\b(chemist|chemistry|biochem|pharmac)/i, 'chemistry'],
    [/\b(computer science|software|programmer|developer|coding|cs student|swe)\b/i, 'cs'],
    [/\b(engineer|engineering|mechanical|electrical|civil)\b/i, 'engineering'],
  ];

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
    initDashboard();
    initCareerLab();
    initAmbient();
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
