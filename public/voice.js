/* ============================================================
   JARVIS — voice: speech recognition (STT) + synthesis (TTS)
   Uses the Web Speech API. Gracefully degrades where absent.
   ============================================================ */
(function () {
  'use strict';

  const synth = window.speechSynthesis || null;
  const SR = window.SpeechRecognition || window.webkitSpeechRecognition || null;

  /* ---------------- Voice selection ---------------- */
  let voices = [];

  function loadVoices() {
    if (!synth) return [];
    voices = synth.getVoices() || [];
    return voices;
  }

  // A British male butler-ish voice, ranked by preference.
  const PREFERRED = [
    'Google UK English Male',
    'Daniel',                 // iOS/macOS en-GB male
    'Arthur',
    'Oliver',
    'Microsoft Ryan',
    'Microsoft George',
    'Microsoft Guy',
  ];

  function pickDefaultVoice() {
    if (!voices.length) loadVoices();
    // exact preferred name
    for (const name of PREFERRED) {
      const v = voices.find((x) => x.name === name);
      if (v) return v.voiceURI;
    }
    // any en-GB voice
    const gb = voices.find((x) => /en-GB/i.test(x.lang));
    if (gb) return gb.voiceURI;
    // any male-sounding english
    const en = voices.find((x) => /^en/i.test(x.lang));
    return en ? en.voiceURI : (voices[0] ? voices[0].voiceURI : '');
  }

  function voiceByURI(uri) {
    if (!uri) return null;
    return voices.find((v) => v.voiceURI === uri) || null;
  }

  /* ---------------- Text to speech ---------------- */
  let onBoundaryAmp = null; // callback to drive the reactor amplitude

  function speak(text, opts = {}) {
    return new Promise((resolve) => {
      if (!synth || !text) { resolve(); return; }
      try { synth.cancel(); } catch {}

      const u = new SpeechSynthesisUtterance(text);
      const v = voiceByURI(opts.voiceURI) || voiceByURI(pickDefaultVoice());
      if (v) { u.voice = v; u.lang = v.lang; }
      else { u.lang = 'en-GB'; }

      // A composed butler cadence.
      u.rate = opts.rate != null ? opts.rate : 0.98;
      u.pitch = opts.pitch != null ? opts.pitch : 0.92;
      u.volume = opts.volume != null ? opts.volume : 1;

      // Fake amplitude animation while speaking (boundary events are sparse
      // and unreliable across browsers, so we pulse on word boundaries and
      // also run a light oscillation via the caller's animation loop).
      u.onstart = () => { if (opts.onStart) opts.onStart(); };
      u.onboundary = () => { if (onBoundaryAmp) onBoundaryAmp(); };
      u.onend = () => { if (opts.onEnd) opts.onEnd(); resolve(); };
      u.onerror = () => { if (opts.onEnd) opts.onEnd(); resolve(); };

      synth.speak(u);
    });
  }

  function stopSpeaking() {
    if (synth) { try { synth.cancel(); } catch {} }
  }

  /* ---------------- Speech recognition ---------------- */
  let recognition = null;
  let listening = false;

  function createRecognition(handlers) {
    if (!SR) return null;
    const rec = new SR();
    rec.lang = 'en-US';
    rec.interimResults = true;
    rec.continuous = false;
    rec.maxAlternatives = 1;

    rec.onstart = () => { listening = true; handlers.onStart && handlers.onStart(); };
    rec.onresult = (e) => {
      let interim = '';
      let final = '';
      for (let i = e.resultIndex; i < e.results.length; i++) {
        const r = e.results[i];
        if (r.isFinal) final += r[0].transcript;
        else interim += r[0].transcript;
      }
      handlers.onResult && handlers.onResult({ interim, final });
    };
    rec.onerror = (e) => { handlers.onError && handlers.onError(e.error || 'error'); };
    rec.onend = () => { listening = false; handlers.onEnd && handlers.onEnd(); };
    return rec;
  }

  const JarvisVoice = {
    ttsSupported: !!synth,
    sttSupported: !!SR,

    loadVoices,
    getVoices: () => voices,
    pickDefaultVoice,
    speak,
    stopSpeaking,
    isSpeaking: () => !!(synth && synth.speaking),
    setBoundaryHandler(fn) { onBoundaryAmp = fn; },

    initRecognition(handlers) {
      recognition = createRecognition(handlers);
      return recognition;
    },
    startListening() {
      if (!recognition || listening) return false;
      try { recognition.start(); return true; }
      catch { return false; }
    },
    stopListening() {
      if (recognition && listening) { try { recognition.stop(); } catch {} }
    },
    isListening: () => listening,
  };

  // Voices load asynchronously in most browsers.
  if (synth) {
    loadVoices();
    synth.onvoiceschanged = loadVoices;
  }

  window.JarvisVoice = JarvisVoice;
})();
