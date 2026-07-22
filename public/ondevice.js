/* ============================================================
   JARVIS — on-device AI (no API key)
   Runs a small open model entirely in the browser via WebLLM
   (WebGPU). The library and model weights load lazily on first
   use. Requires WebGPU (recent iOS/Safari or desktop Chrome).
   ============================================================ */
(function () {
  'use strict';

  // Pinned WebLLM build, loaded on demand from the esm.run CDN.
  const WEBLLM_URL = 'https://esm.run/@mlc-ai/web-llm@0.2.79';

  let libPromise = null;     // resolves to the webllm module
  let enginePromise = null;  // resolves to the loaded engine
  let currentModel = null;
  let ready = false;

  function loadLib() {
    if (!libPromise) libPromise = import(/* webpackIgnore: true */ WEBLLM_URL);
    return libPromise;
  }

  const JarvisLocal = {
    // WebGPU is required. Absent on older phones / Safari without the flag.
    isSupported() {
      return typeof navigator !== 'undefined' && !!navigator.gpu;
    },

    isReady(model) {
      return ready && currentModel === model;
    },

    // Ensure the engine for `model` is loaded, reporting download/compile
    // progress via onProgress({ progress: 0..1, text }).
    async ensure(model, onProgress) {
      if (enginePromise && currentModel === model) return enginePromise;
      ready = false;
      currentModel = model;
      const webllm = await loadLib();
      enginePromise = webllm
        .CreateMLCEngine(model, { initProgressCallback: onProgress })
        .then((engine) => { ready = true; return engine; })
        .catch((err) => { enginePromise = null; ready = false; throw err; });
      return enginePromise;
    },

    // Generate a reply. `messages` is [{role,content}]; `system` is the prompt.
    async chat(messages, system) {
      if (!enginePromise) throw new Error('On-device model is not loaded yet.');
      const engine = await enginePromise;
      const full = [{ role: 'system', content: system }].concat(
        messages.map((m) => ({ role: m.role, content: String(m.content) }))
      );
      const res = await engine.chat.completions.create({
        messages: full,
        temperature: 0.7,
        max_tokens: 800,
      });
      return (res && res.choices && res.choices[0] && res.choices[0].message &&
              res.choices[0].message.content || '').trim();
    },

    reset() { enginePromise = null; currentModel = null; ready = false; },
  };

  window.JarvisLocal = JarvisLocal;
})();
