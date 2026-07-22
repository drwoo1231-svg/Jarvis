/* ============================================================
   JARVIS — configuration & persistent state
   ============================================================ */
(function () {
  'use strict';

  const KEY = 'jarvis.config.v1';

  const DEFAULTS = {
    userName: '',
    honorific: 'Sir',
    platform: 'auto',          // 'auto' | 'pc' | 'mobile'
    mode: 'server',            // 'server' | 'direct' | 'ondevice' | 'demo'
    provider: 'anthropic',     // direct-mode AI provider
    apiKey: '',                // used only in 'direct' mode
    baseUrl: '',               // for the 'openai-compatible' provider
    model: 'claude-sonnet-5',
    localModel: 'Qwen2.5-0.5B-Instruct-q4f16_1-MLC', // on-device model (fast)
    voiceURI: '',              // chosen TTS voice
    speak: true,               // speak replies aloud
    autoListen: false,         // re-open the mic after JARVIS finishes talking
    onboarded: false,
  };

  function load() {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return { ...DEFAULTS };
      return { ...DEFAULTS, ...JSON.parse(raw) };
    } catch {
      return { ...DEFAULTS };
    }
  }

  function save(cfg) {
    try {
      localStorage.setItem(KEY, JSON.stringify(cfg));
    } catch (e) {
      console.warn('Could not persist config', e);
    }
  }

  function reset() {
    try { localStorage.removeItem(KEY); } catch {}
  }

  window.JarvisConfig = {
    DEFAULTS,
    state: load(),
    save() { save(this.state); },
    set(patch) { Object.assign(this.state, patch); this.save(); },
    reset,
  };
})();
