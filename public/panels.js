/* ============================================================
   JARVIS — movable holographic panels
   Turns any element into a draggable hologram: pointer drag with
   inertia, optional snap-to-grid, per-panel persistence, bring-to-
   front, double-click-to-reset, and a global lock. Uses a transform
   offset on top of each panel's natural CSS position, so hidden or
   responsive panels keep working without hard-coded coordinates.
   ============================================================ */
(function () {
  'use strict';

  const LS_LAYOUT = 'jarvis.layout.v1';
  const LS_PREFS = 'jarvis.layoutprefs.v1';
  const GRID = 24;
  const registry = new Map();          // id -> { el, handle }
  let topZ = 70;
  let locked = false;
  let snap = false;

  const store = {
    load() { try { return JSON.parse(localStorage.getItem(LS_LAYOUT)) || {}; } catch { return {}; } },
    save(o) { try { localStorage.setItem(LS_LAYOUT, JSON.stringify(o)); } catch { /* ignore */ } },
  };
  let layout = store.load();
  (function loadPrefs() {
    try {
      const p = JSON.parse(localStorage.getItem(LS_PREFS)) || {};
      locked = !!p.locked; snap = !!p.snap;
    } catch { /* defaults */ }
  })();
  function savePrefs() {
    try { localStorage.setItem(LS_PREFS, JSON.stringify({ locked, snap })); } catch { /* ignore */ }
  }

  function apply(el, dx, dy) {
    el.style.transform = (dx || dy) ? `translate3d(${dx}px, ${dy}px, 0)` : '';
    el._px = dx; el._py = dy;
  }

  // Keep at least this much of a panel on-screen after any move.
  function clamp(el, dx, dy) {
    const prev = el.style.transform;
    el.style.transform = `translate3d(${dx}px, ${dy}px, 0)`;
    const r = el.getBoundingClientRect();
    el.style.transform = prev;
    const M = 44;
    let nx = dx, ny = dy;
    if (r.right < M) nx += (M - r.right);
    if (r.left > window.innerWidth - M) nx -= (r.left - (window.innerWidth - M));
    if (r.bottom < M) ny += (M - r.bottom);
    if (r.top > window.innerHeight - M) ny -= (r.top - (window.innerHeight - M));
    if (r.top < 0) ny += (0 - r.top);            // never hide behind the top edge
    return { dx: nx, dy: ny };
  }

  function bringToFront(el) { el.style.zIndex = String(++topZ); }

  function persist(id, dx, dy) {
    if (!dx && !dy) delete layout[id];
    else layout[id] = { dx: Math.round(dx), dy: Math.round(dy) };
    store.save(layout);
  }

  function enable(el, opts) {
    opts = opts || {};
    const id = opts.id || el.id;
    if (!id || registry.has(id)) return;
    const handle = opts.handle ? (el.querySelector(opts.handle) || el) : el;
    el.classList.add('movable');
    handle.classList.add('drag-handle');
    registry.set(id, { el, handle });

    // Restore a saved offset.
    const saved = layout[id];
    apply(el, saved ? saved.dx : 0, saved ? saved.dy : 0);

    let dragging = false, startX = 0, startY = 0, baseDx = 0, baseDy = 0;
    let lastX = 0, lastY = 0, lastT = 0, vx = 0, vy = 0, inertiaRAF = null, moved = false;

    function onDown(e) {
      if (locked) return;
      // ignore drags that begin on interactive controls
      if (e.target.closest('button, a, input, select, textarea, .np-controls, .no-drag')) return;
      if (e.button != null && e.button !== 0) return;
      dragging = true; moved = false;
      if (inertiaRAF) { cancelAnimationFrame(inertiaRAF); inertiaRAF = null; }
      bringToFront(el);
      el.classList.add('dragging');
      startX = e.clientX; startY = e.clientY;
      baseDx = el._px || 0; baseDy = el._py || 0;
      lastX = e.clientX; lastY = e.clientY; lastT = performance.now(); vx = vy = 0;
      try { handle.setPointerCapture(e.pointerId); } catch { /* older browsers */ }
      window.addEventListener('pointermove', onMove);
      window.addEventListener('pointerup', onUp);
      e.preventDefault();
    }
    function onMove(e) {
      if (!dragging) return;
      const dx = baseDx + (e.clientX - startX);
      const dy = baseDy + (e.clientY - startY);
      if (Math.abs(e.clientX - startX) + Math.abs(e.clientY - startY) > 3) moved = true;
      apply(el, dx, dy);
      const now = performance.now(), dt = Math.max(1, now - lastT);
      const cap = (v) => Math.max(-46, Math.min(46, v));
      vx = cap((e.clientX - lastX) / dt * 16);
      vy = cap((e.clientY - lastY) / dt * 16);
      lastX = e.clientX; lastY = e.clientY; lastT = now;
    }
    function onUp() {
      if (!dragging) return;
      dragging = false;
      el.classList.remove('dragging');
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
      // inertial glide, then clamp + optional snap
      const speed = Math.hypot(vx, vy);
      if (moved && speed > 1.5) glide(); else settle();
    }
    function glide() {
      let dx = el._px || 0, dy = el._py || 0;
      const step = () => {
        vx *= 0.9; vy *= 0.9;
        dx += vx; dy += vy;
        const c = clamp(el, dx, dy); dx = c.dx; dy = c.dy;
        apply(el, dx, dy);
        if (Math.hypot(vx, vy) > 0.6) inertiaRAF = requestAnimationFrame(step);
        else { inertiaRAF = null; settle(); }
      };
      inertiaRAF = requestAnimationFrame(step);
    }
    function settle() {
      let dx = el._px || 0, dy = el._py || 0;
      if (snap) {
        const r = el.getBoundingClientRect();
        dx += Math.round(r.left / GRID) * GRID - r.left;
        dy += Math.round(r.top / GRID) * GRID - r.top;
      }
      const c = clamp(el, dx, dy);
      apply(el, c.dx, c.dy);
      persist(id, c.dx, c.dy);
    }

    function reset() {
      if (inertiaRAF) { cancelAnimationFrame(inertiaRAF); inertiaRAF = null; }
      el.classList.add('snapback');
      apply(el, 0, 0);
      persist(id, 0, 0);
      setTimeout(() => el.classList.remove('snapback'), 320);
    }

    handle.addEventListener('pointerdown', onDown);
    handle.addEventListener('dblclick', (e) => { if (!e.target.closest('button,a,input,select')) reset(); });
    el.addEventListener('pointerdown', () => bringToFront(el), true);

    el._panelReset = reset;
  }

  function setLock(v) {
    locked = !!v; savePrefs();
    document.body.classList.toggle('layout-locked', locked);
    registry.forEach(({ el }) => el.classList.toggle('locked', locked));
  }
  function setSnap(v) { snap = !!v; savePrefs(); document.body.classList.toggle('snap-on', snap); }

  // Re-clamp everything when the viewport changes so nothing strands off-screen.
  let rz;
  window.addEventListener('resize', () => {
    clearTimeout(rz);
    rz = setTimeout(() => {
      registry.forEach(({ el }, id) => {
        const c = clamp(el, el._px || 0, el._py || 0);
        apply(el, c.dx, c.dy);
        persist(id, c.dx, c.dy);
      });
    }, 150);
  });

  window.JarvisPanels = {
    enable,
    isLocked: () => locked,
    isSnap: () => snap,
    setLock,
    toggleLock() { setLock(!locked); return locked; },
    setSnap,
    toggleSnap() { setSnap(!snap); return snap; },
    resetAll() {
      registry.forEach(({ el }) => el._panelReset && el._panelReset());
    },
    reset(id) { const r = registry.get(id); if (r && r.el._panelReset) r.el._panelReset(); },
    front(id) { const r = registry.get(id); if (r) bringToFront(r.el); },
    // sync body classes to any preloaded prefs
    initPrefs() { setLock(locked); setSnap(snap); },
  };
})();
