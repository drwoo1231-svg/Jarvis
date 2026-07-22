/* ============================================================
   JARVIS — reactor core visualiser (canvas)
   A layered HUD: rotating arc rings, tick marks, orbiting
   particles and a pulsing core that reacts to audio amplitude.
   ============================================================ */
(function () {
  'use strict';

  const PALETTE = {
    idle:      { r: 56,  g: 225, b: 255 },
    listening: { r: 90,  g: 240, b: 255 },
    thinking:  { r: 255, g: 212, b: 121 },
    speaking:  { r: 111, g: 240, b: 255 },
  };

  let canvas, ctx, dpr = 1;
  let W = 0, H = 0, cx = 0, cy = 0, baseR = 0;
  let raf = null, t = 0;
  let state = 'idle';
  let amp = 0;          // target amplitude 0..1
  let ampSmooth = 0;    // smoothed amplitude
  let color = PALETTE.idle;
  let colorTarget = PALETTE.idle;
  let particles = [];

  function resize() {
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    W = Math.max(1, rect.width);
    H = Math.max(1, rect.height);
    canvas.width = W * dpr;
    canvas.height = H * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    cx = W / 2;
    cy = H / 2;
    baseR = Math.min(W, H) * 0.30;
  }

  function seedParticles() {
    particles = [];
    const n = 28;
    for (let i = 0; i < n; i++) {
      particles.push({
        a: Math.random() * Math.PI * 2,
        rad: baseR * (1.15 + Math.random() * 0.85),
        speed: (Math.random() * 0.4 + 0.15) * (Math.random() < 0.5 ? 1 : -1),
        size: Math.random() * 1.6 + 0.5,
        phase: Math.random() * Math.PI * 2,
      });
    }
  }

  function rgba(c, a) { return `rgba(${c.r|0},${c.g|0},${c.b|0},${a})`; }

  function lerp(a, b, k) { return a + (b - a) * k; }

  function drawRing(radius, start, end, width, alpha) {
    ctx.beginPath();
    ctx.arc(cx, cy, radius, start, end);
    ctx.strokeStyle = rgba(color, alpha);
    ctx.lineWidth = width;
    ctx.lineCap = 'round';
    ctx.stroke();
  }

  function drawTicks(radius, count, len, alpha) {
    for (let i = 0; i < count; i++) {
      const a = (i / count) * Math.PI * 2 + t * 0.1;
      const x1 = cx + Math.cos(a) * radius;
      const y1 = cy + Math.sin(a) * radius;
      const x2 = cx + Math.cos(a) * (radius + len);
      const y2 = cy + Math.sin(a) * (radius + len);
      ctx.beginPath();
      ctx.moveTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.strokeStyle = rgba(color, alpha);
      ctx.lineWidth = 1.4;
      ctx.stroke();
    }
  }

  function frame() {
    t += 0.016;

    // smooth transitions
    ampSmooth = lerp(ampSmooth, amp, 0.2);
    color = {
      r: lerp(color.r, colorTarget.r, 0.06),
      g: lerp(color.g, colorTarget.g, 0.06),
      b: lerp(color.b, colorTarget.b, 0.06),
    };

    ctx.clearRect(0, 0, W, H);
    ctx.globalCompositeOperation = 'lighter';

    const pulse = 1 + ampSmooth * 0.5 + Math.sin(t * 2) * 0.02;
    const R = baseR;

    // Outer dashed rotating ring
    ctx.save();
    ctx.setLineDash([4, 14]);
    drawRing(R * 1.75, t * 0.4, t * 0.4 + Math.PI * 1.9, 1.5, 0.35);
    ctx.setLineDash([]);
    ctx.restore();

    // Tick ring
    drawTicks(R * 1.5, 48, 6 + ampSmooth * 8, 0.25);

    // Segmented arcs (rotate different directions/speeds)
    drawRing(R * 1.28, -t * 0.7, -t * 0.7 + Math.PI * 0.6, 2.4, 0.55);
    drawRing(R * 1.28, -t * 0.7 + Math.PI, -t * 0.7 + Math.PI * 1.55, 2.4, 0.55);
    drawRing(R * 1.12, t * 1.1, t * 1.1 + Math.PI * 0.9, 1.6, 0.4);
    drawRing(R * 1.12, t * 1.1 + Math.PI, t * 1.1 + Math.PI * 1.75, 1.6, 0.4);

    // Orbiting particles
    for (const p of particles) {
      p.a += p.speed * 0.01 * (1 + ampSmooth);
      const rr = p.rad + Math.sin(t * 1.5 + p.phase) * 4;
      const x = cx + Math.cos(p.a) * rr;
      const y = cy + Math.sin(p.a) * rr;
      const s = p.size * (1 + ampSmooth * 0.8);
      ctx.beginPath();
      ctx.arc(x, y, s, 0, Math.PI * 2);
      ctx.fillStyle = rgba(color, 0.7);
      ctx.fill();
    }

    // Inner glow core
    const coreR = R * 0.62 * pulse;
    const grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, coreR);
    grad.addColorStop(0, rgba(color, 0.55 + ampSmooth * 0.35));
    grad.addColorStop(0.5, rgba(color, 0.14));
    grad.addColorStop(1, rgba(color, 0));
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(cx, cy, coreR, 0, Math.PI * 2);
    ctx.fill();

    // Core rim
    drawRing(R * 0.66 * pulse, 0, Math.PI * 2, 2, 0.5);

    // Audio waveform ring (reacts to amplitude)
    if (ampSmooth > 0.02) {
      ctx.beginPath();
      const segs = 96;
      for (let i = 0; i <= segs; i++) {
        const a = (i / segs) * Math.PI * 2;
        const noise = Math.sin(a * 6 + t * 8) * Math.sin(a * 3 - t * 5);
        const rr = R * 0.8 + noise * ampSmooth * 26 + ampSmooth * 10;
        const x = cx + Math.cos(a) * rr;
        const y = cy + Math.sin(a) * rr;
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.strokeStyle = rgba(color, 0.75);
      ctx.lineWidth = 1.8;
      ctx.stroke();
    }

    ctx.globalCompositeOperation = 'source-over';
    raf = requestAnimationFrame(frame);
  }

  const JarvisCore = {
    init(el) {
      canvas = el;
      ctx = canvas.getContext('2d');
      resize();
      seedParticles();
      window.addEventListener('resize', () => { resize(); seedParticles(); });
      if (raf) cancelAnimationFrame(raf);
      frame();
    },
    resize() { resize(); seedParticles(); },
    setState(s) {
      state = s;
      colorTarget = PALETTE[s] || PALETTE.idle;
    },
    setAmplitude(v) {
      amp = Math.max(0, Math.min(1, v));
    },
    getState() { return state; },
  };

  window.JarvisCore = JarvisCore;
})();
