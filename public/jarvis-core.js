/* ============================================================
   JARVIS — reactor core visualiser (canvas)
   A rotating 3D particle globe (energy core) wrapped in HUD
   rings, tick marks and orbiting motes. Reacts to audio amplitude.
   ============================================================ */
(function () {
  'use strict';

  const PALETTE = {
    idle:      { r: 70,  g: 170, b: 255 },
    listening: { r: 90,  g: 220, b: 255 },
    thinking:  { r: 255, g: 200, b: 110 },
    speaking:  { r: 120, g: 210, b: 255 },
    analyzing: { r: 150, g: 130, b: 255 },
  };

  let canvas, ctx, dpr = 1;
  let W = 0, H = 0, cx = 0, cy = 0, baseR = 0;
  let raf = null, t = 0;
  let amp = 0, ampSmooth = 0;
  let color = PALETTE.idle, colorTarget = PALETTE.idle;
  let sphere = [];   // points on a unit sphere
  let motes = [];    // orbiting outer particles

  function resize() {
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    W = Math.max(1, rect.width);
    H = Math.max(1, rect.height);
    canvas.width = W * dpr;
    canvas.height = H * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    cx = W / 2; cy = H / 2;
    baseR = Math.min(W, H) * 0.32;
  }

  // Fibonacci sphere for an even point distribution.
  function seedSphere(n) {
    sphere = [];
    const golden = Math.PI * (3 - Math.sqrt(5));
    for (let i = 0; i < n; i++) {
      const y = 1 - (i / (n - 1)) * 2;
      const r = Math.sqrt(1 - y * y);
      const theta = golden * i;
      sphere.push({
        x: Math.cos(theta) * r,
        y,
        z: Math.sin(theta) * r,
        // a little inward jitter so it reads as a dense energy cluster
        rr: 0.62 + Math.random() * 0.4,
        tw: Math.random() * Math.PI * 2,
      });
    }
  }

  function seedMotes(n) {
    motes = [];
    for (let i = 0; i < n; i++) {
      motes.push({
        a: Math.random() * Math.PI * 2,
        rad: baseR * (1.25 + Math.random() * 0.95),
        speed: (Math.random() * 0.4 + 0.12) * (Math.random() < 0.5 ? 1 : -1),
        size: Math.random() * 1.5 + 0.4,
        phase: Math.random() * Math.PI * 2,
      });
    }
  }

  const rgba = (c, a) => `rgba(${c.r|0},${c.g|0},${c.b|0},${a})`;
  const lerp = (a, b, k) => a + (b - a) * k;

  function drawRing(radius, start, end, width, alpha, dash) {
    ctx.save();
    if (dash) ctx.setLineDash(dash);
    ctx.beginPath();
    ctx.arc(cx, cy, radius, start, end);
    ctx.strokeStyle = rgba(color, alpha);
    ctx.lineWidth = width;
    ctx.lineCap = 'round';
    ctx.stroke();
    ctx.restore();
  }

  function drawTicks(radius, count, len, alpha) {
    for (let i = 0; i < count; i++) {
      const a = (i / count) * Math.PI * 2 + t * 0.08;
      const x1 = cx + Math.cos(a) * radius, y1 = cy + Math.sin(a) * radius;
      const x2 = cx + Math.cos(a) * (radius + len), y2 = cy + Math.sin(a) * (radius + len);
      ctx.beginPath();
      ctx.moveTo(x1, y1); ctx.lineTo(x2, y2);
      ctx.strokeStyle = rgba(color, alpha);
      ctx.lineWidth = 1.2;
      ctx.stroke();
    }
  }

  function drawPoly(radius, sides, rot, alpha, width) {
    ctx.beginPath();
    for (let i = 0; i <= sides; i++) {
      const a = rot + (i / sides) * Math.PI * 2;
      const x = cx + Math.cos(a) * radius, y = cy + Math.sin(a) * radius;
      i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
    }
    ctx.strokeStyle = rgba(color, alpha);
    ctx.lineWidth = width;
    ctx.stroke();
  }

  // Longer radial spokes reaching outward, spinning slowly (as in the ref HUD).
  function drawSpokes(radius, count, len, alpha, dir) {
    for (let i = 0; i < count; i++) {
      const a = (i / count) * Math.PI * 2 + t * 0.05 * dir;
      const x1 = cx + Math.cos(a) * radius, y1 = cy + Math.sin(a) * radius;
      const x2 = cx + Math.cos(a) * (radius + len), y2 = cy + Math.sin(a) * (radius + len);
      ctx.beginPath();
      ctx.moveTo(x1, y1); ctx.lineTo(x2, y2);
      ctx.strokeStyle = rgba(color, alpha);
      ctx.lineWidth = 1;
      ctx.stroke();
    }
  }

  function frame() {
    t += 0.016;
    ampSmooth = lerp(ampSmooth, amp, 0.2);
    color = {
      r: lerp(color.r, colorTarget.r, 0.06),
      g: lerp(color.g, colorTarget.g, 0.06),
      b: lerp(color.b, colorTarget.b, 0.06),
    };

    ctx.clearRect(0, 0, W, H);
    ctx.globalCompositeOperation = 'lighter';

    const R = baseR;
    const pulse = 1 + ampSmooth * 0.28 + Math.sin(t * 1.6) * 0.015;

    // ---- geometric HUD frames ----
    drawPoly(R * 1.62, 6, t * 0.12, 0.22, 1.2);                  // rotating hexagon
    drawPoly(R * 1.5, 3, -t * 0.09, 0.14, 1);                    // counter triangle

    // ---- radar sweep over the globe ----
    const sweepA = t * 0.8;
    ctx.save();
    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.arc(cx, cy, R * 1.28, sweepA, sweepA + 0.5);
    ctx.closePath();
    const sg = ctx.createRadialGradient(cx, cy, 0, cx, cy, R * 1.28);
    sg.addColorStop(0, rgba(color, 0));
    sg.addColorStop(1, rgba(color, 0.22));
    ctx.fillStyle = sg;
    ctx.fill();
    ctx.restore();

    // ---- HUD rings ----
    drawRing(R * 1.82, 0, Math.PI * 2, 1, 0.22, [1, 7]);        // fine dotted outer ring
    drawSpokes(R * 1.68, 36, 12 + ampSmooth * 10, 0.28, 1);      // radial spokes
    drawRing(R * 1.72, t * 0.35, t * 0.35 + Math.PI * 1.92, 1.3, 0.32, [3, 13]);
    drawTicks(R * 1.5, 60, 6 + ampSmooth * 8, 0.22);
    drawRing(R * 1.42, 0, Math.PI * 2, 1, 0.18, [2, 10]);        // second dotted ring
    drawSpokes(R * 1.44, 72, 5, 0.16, -1);
    drawRing(R * 1.3, -t * 0.6, -t * 0.6 + Math.PI * 0.55, 2.2, 0.5);
    drawRing(R * 1.3, -t * 0.6 + Math.PI, -t * 0.6 + Math.PI * 1.5, 2.2, 0.5);
    drawRing(R * 1.15, t * 0.9, t * 0.9 + Math.PI * 0.85, 1.4, 0.36);
    drawRing(R * 1.15, t * 0.9 + Math.PI, t * 0.9 + Math.PI * 1.7, 1.4, 0.36);

    // ---- rotating particle globe ----
    const ry = t * 0.35;              // yaw
    const rx = Math.sin(t * 0.2) * 0.35;
    const cosY = Math.cos(ry), sinY = Math.sin(ry);
    const cosX = Math.cos(rx), sinX = Math.sin(rx);
    const globeR = R * 0.92 * pulse;

    // sort-free additive draw; depth via alpha
    for (let i = 0; i < sphere.length; i++) {
      const p = sphere[i];
      const rad = p.rr;
      let x = p.x * rad, y = p.y * rad, z = p.z * rad;
      // rotate Y
      let x1 = x * cosY - z * sinY;
      let z1 = x * sinY + z * cosY;
      // rotate X
      let y1 = y * cosX - z1 * sinX;
      let z2 = y * sinX + z1 * cosX;
      const depth = (z2 + 1) / 2;                 // 0 (back) .. 1 (front)
      const sx = cx + x1 * globeR;
      const sy = cy + y1 * globeR;
      const tw = 0.6 + 0.4 * Math.sin(t * 3 + p.tw);
      const size = (0.5 + depth * 1.9) * (1 + ampSmooth * 0.7);
      const alpha = (0.06 + depth * 0.6) * tw;
      ctx.beginPath();
      ctx.arc(sx, sy, size, 0, Math.PI * 2);
      ctx.fillStyle = rgba(color, alpha);
      ctx.fill();
    }

    // ---- soft core glow (brighter, denser center) ----
    const coreR = R * 0.55 * pulse;
    const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, coreR);
    g.addColorStop(0, rgba(color, 0.6 + ampSmooth * 0.35));
    g.addColorStop(0.35, rgba(color, 0.22));
    g.addColorStop(1, rgba(color, 0));
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.arc(cx, cy, coreR, 0, Math.PI * 2); ctx.fill();
    // hot white nucleus
    const nucR = R * 0.14 * pulse;
    const gn = ctx.createRadialGradient(cx, cy, 0, cx, cy, nucR);
    gn.addColorStop(0, `rgba(240,250,255,${0.75 + ampSmooth * 0.2})`);
    gn.addColorStop(1, rgba(color, 0));
    ctx.fillStyle = gn;
    ctx.beginPath(); ctx.arc(cx, cy, nucR, 0, Math.PI * 2); ctx.fill();

    // ---- orbiting motes ----
    for (const m of motes) {
      m.a += m.speed * 0.01 * (1 + ampSmooth);
      const rr = m.rad + Math.sin(t * 1.5 + m.phase) * 4;
      const x = cx + Math.cos(m.a) * rr, y = cy + Math.sin(m.a) * rr;
      ctx.beginPath();
      ctx.arc(x, y, m.size * (1 + ampSmooth * 0.6), 0, Math.PI * 2);
      ctx.fillStyle = rgba(color, 0.6);
      ctx.fill();
    }

    // ---- outer rim + audio waveform ----
    drawRing(R * 1.0 * pulse, 0, Math.PI * 2, 1.6, 0.4);
    if (ampSmooth > 0.02) {
      ctx.beginPath();
      const segs = 90;
      for (let i = 0; i <= segs; i++) {
        const a = (i / segs) * Math.PI * 2;
        const noise = Math.sin(a * 6 + t * 8) * Math.sin(a * 3 - t * 5);
        const rr = R * 1.08 + noise * ampSmooth * 24 + ampSmooth * 8;
        const x = cx + Math.cos(a) * rr, y = cy + Math.sin(a) * rr;
        i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.strokeStyle = rgba(color, 0.7);
      ctx.lineWidth = 1.6;
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
      seedSphere(260);
      seedMotes(30);
      window.addEventListener('resize', () => { resize(); seedMotes(30); });
      if (raf) cancelAnimationFrame(raf);
      frame();
    },
    resize() { resize(); seedMotes(30); },
    setState(s) { colorTarget = PALETTE[s] || PALETTE.idle; },
    setAmplitude(v) { amp = Math.max(0, Math.min(1, v)); },
  };

  window.JarvisCore = JarvisCore;
})();
