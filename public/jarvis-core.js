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
    speaking:  { r: 235, g: 245, b: 255 },
    searching: { r: 170, g: 120, b: 255 },
    analyzing: { r: 150, g: 130, b: 255 },
    warning:   { r: 255, g: 90,  b: 90  },
  };

  let canvas, ctx, dpr = 1;
  let W = 0, H = 0, cx = 0, cy = 0, baseR = 0;
  let raf = null, t = 0;
  let amp = 0, ampSmooth = 0;
  let color = PALETTE.idle, colorTarget = PALETTE.idle;
  let sphere = [];   // points on a unit sphere
  let stateLabel = 'ONLINE';
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

  // Latitude/longitude dot grid — the dense "data globe" look: rings of evenly
  // spaced points, denser at the equator, exactly as on a wireframe sphere.
  function seedSphere() {
    sphere = [];
    const LAT = 30;                       // latitude bands
    for (let i = 0; i <= LAT; i++) {
      const phi = -Math.PI / 2 + (i / LAT) * Math.PI;   // -90°..+90°
      const cp = Math.cos(phi), sp = Math.sin(phi);
      const n = Math.max(1, Math.round(cp * 76));       // fewer dots near poles
      for (let j = 0; j < n; j++) {
        const theta = (j / n) * Math.PI * 2;
        sphere.push({
          lat: phi, lon: theta, cp, sp,
          tw: Math.random() * Math.PI * 2,
        });
      }
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

  // Centre wordmark, letter-spaced by hand (canvas has no letterSpacing in
  // every engine we target).
  function spacedText(str, x, y, px, space, alpha, weight) {
    ctx.font = `${weight || 600} ${px}px ui-monospace, "SF Mono", Menlo, monospace`;
    const w = str.split('').reduce((a, ch) => a + ctx.measureText(ch).width + space, -space);
    let cur = x - w / 2;
    ctx.fillStyle = `rgba(238,250,255,${alpha})`;
    ctx.textBaseline = 'middle';
    for (const ch of str) {
      ctx.fillText(ch, cur, y);
      cur += ctx.measureText(ch).width + space;
    }
    return w;
  }
  function drawWordmark(R) {
    const s = Math.max(0.55, Math.min(1.5, R / 190));
    ctx.save();
    ctx.globalCompositeOperation = 'source-over';
    // A soft dark plate so the lettering stays crisp over the dot shell.
    const pg = ctx.createRadialGradient(cx, cy + 14 * s, 0, cx, cy + 14 * s, 132 * s);
    pg.addColorStop(0, 'rgba(1,7,16,0.72)');
    pg.addColorStop(0.6, 'rgba(1,7,16,0.42)');
    pg.addColorStop(1, 'rgba(1,7,16,0)');
    ctx.fillStyle = pg;
    ctx.beginPath(); ctx.ellipse(cx, cy + 14 * s, 132 * s, 66 * s, 0, 0, Math.PI * 2); ctx.fill();

    ctx.shadowColor = rgba(color, 0.95);
    ctx.shadowBlur = 20 * s;
    spacedText('J.A.R.V.I.S.', cx, cy - 4 * s, 26 * s, 2.5 * s, 0.99, 700);
    ctx.shadowBlur = 7 * s;
    spacedText('JUST A RATHER VERY', cx, cy + 21 * s, 8 * s, 2.4 * s, 0.86, 500);
    spacedText('INTELLIGENT SYSTEM', cx, cy + 33 * s, 8 * s, 2.4 * s, 0.86, 500);
    ctx.shadowBlur = 10 * s;
    spacedText(stateLabel, cx, cy + 52 * s, 7.4 * s, 3.2 * s, 0.92, 600);
    ctx.restore();
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

    // ---- glowing orb behind the dot shell ----
    const orbR = R * 0.98 * pulse;
    const og = ctx.createRadialGradient(cx, cy, orbR * 0.1, cx, cy, orbR);
    og.addColorStop(0, rgba(color, 0.30));
    og.addColorStop(0.55, rgba(color, 0.13));
    og.addColorStop(0.88, rgba(color, 0.05));
    og.addColorStop(1, rgba(color, 0));
    ctx.fillStyle = og;
    ctx.beginPath(); ctx.arc(cx, cy, orbR, 0, Math.PI * 2); ctx.fill();

    // ---- rotating lat/long dot globe ----
    const ry = t * 0.22;                          // slow yaw
    const rx = -0.28;                             // fixed tilt, as in the ref
    const cosY = Math.cos(ry), sinY = Math.sin(ry);
    const cosX = Math.cos(rx), sinX = Math.sin(rx);
    const globeR = R * 0.98 * pulse;

    for (let i = 0; i < sphere.length; i++) {
      const p = sphere[i];
      const lon = p.lon + ry;
      const x = p.cp * Math.cos(lon), y = p.sp, z = p.cp * Math.sin(lon);
      // tilt about X
      const y1 = y * cosX - z * sinX;
      const z1 = y * sinX + z * cosX;
      const depth = (z1 + 1) / 2;                 // 0 back .. 1 front
      const sx = cx + x * globeR;
      const sy = cy + y1 * globeR;
      const tw = 0.75 + 0.25 * Math.sin(t * 2.4 + p.tw);
      const size = (0.5 + depth * 1.7) * (1 + ampSmooth * 0.5);
      const alpha = (0.10 + depth * depth * 1.15) * tw;
      ctx.beginPath();
      ctx.arc(sx, sy, size, 0, Math.PI * 2);
      ctx.fillStyle = rgba(color, alpha);
      ctx.fill();
    }

    // ---- horizontal light flare across the equator ----
    const flareA = 0.55 + ampSmooth * 0.4 + Math.sin(t * 0.9) * 0.06;
    const fg = ctx.createLinearGradient(cx - R * 2.1, cy, cx + R * 2.1, cy);
    fg.addColorStop(0, rgba(color, 0));
    fg.addColorStop(0.32, rgba(color, flareA * 0.5));
    fg.addColorStop(0.5, `rgba(235,248,255,${flareA})`);
    fg.addColorStop(0.68, rgba(color, flareA * 0.5));
    fg.addColorStop(1, rgba(color, 0));
    ctx.fillStyle = fg;
    ctx.fillRect(cx - R * 2.1, cy - 2.2, R * 4.2, 4.4);
    // vertical companion beam
    const vg = ctx.createLinearGradient(cx, cy - R * 1.5, cx, cy + R * 1.5);
    vg.addColorStop(0, rgba(color, 0));
    vg.addColorStop(0.5, `rgba(220,244,255,${flareA * 0.5})`);
    vg.addColorStop(1, rgba(color, 0));
    ctx.fillStyle = vg;
    ctx.fillRect(cx - 1, cy - R * 1.5, 2, R * 3);

    // ---- soft core glow behind the wordmark ----
    const coreR = R * 0.62 * pulse;
    const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, coreR);
    g.addColorStop(0, rgba(color, 0.42 + ampSmooth * 0.3));
    g.addColorStop(0.45, rgba(color, 0.14));
    g.addColorStop(1, rgba(color, 0));
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.arc(cx, cy, coreR, 0, Math.PI * 2); ctx.fill();

    // ---- bright nodes riding the rings (as in the reference HUD) ----
    for (let i = 0; i < 8; i++) {
      const a = t * (i % 2 ? -0.32 : 0.24) + (i / 8) * Math.PI * 2;
      const rr = R * (1.16 + (i % 3) * 0.24);
      const nx = cx + Math.cos(a) * rr, ny = cy + Math.sin(a) * rr;
      const ng = ctx.createRadialGradient(nx, ny, 0, nx, ny, 7);
      ng.addColorStop(0, 'rgba(255,255,255,0.95)');
      ng.addColorStop(0.4, rgba(color, 0.7));
      ng.addColorStop(1, rgba(color, 0));
      ctx.fillStyle = ng;
      ctx.beginPath(); ctx.arc(nx, ny, 7, 0, Math.PI * 2); ctx.fill();
    }

    // ---- the J.A.R.V.I.S. wordmark at the heart of the core ----
    drawWordmark(R);

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
      seedSphere();
      seedMotes(30);
      window.addEventListener('resize', () => { resize(); seedMotes(30); });
      if (raf) cancelAnimationFrame(raf);
      frame();
    },
    resize() { resize(); seedMotes(30); },
    setState(s) {
      colorTarget = PALETTE[s] || PALETTE.idle;
      stateLabel = ({ listening: 'LISTENING', thinking: 'THINKING', speaking: 'SPEAKING',
        searching: 'SEARCHING', analyzing: 'ANALYSING', warning: 'ALERT' })[s] || 'ONLINE';
    },
    setAmplitude(v) { amp = Math.max(0, Math.min(1, v)); },
  };

  window.JarvisCore = JarvisCore;
})();
