// FICTIONAL PORTAL PHYSICS - the numbers are real calculations on the live
// scene, the physics they pretend to describe is not.
//
//   D        = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)          metres
//   C        = 1 + 0.35 sin^2(theta / 2)        curvature coefficient (theta = angle between the openings)
//   E_portal = K x D^2 x C                      K = 0.9477 PJ/m^2  (made up, but consistent)
//   S        = E_available / E_required         stability (shown capped at 100 %)
//   ds^2     = -(c dt)^2 + dx^2 + dy^2 + dz^2   for the last jump (dt = 0, so it's spacelike - oops)
//   E        = m c^2                            rest energy of the last thing you threw through

final float C_LIGHT = 299792458;

class PortalPhysics {
  final float K = 0.9477;          // PJ per m^2
  boolean linked;
  float D, theta, C, Ereq, Eavail, S, stability = 1;
  float boost;                     // extra power from teleported batteries (decays)
  float baseOutput = 1180;         // generator output, PJ
  // last teleport event
  String lastName = "-";
  float lastIn, lastOut, lastMass, lastDs2, lastRestE, lastAgo = 999;
  int jumps;
  ThrowableObject focus;           // object whose velocity is tracked live
  boolean warned;

  void update(float dt) {
    Portal a = portals.p[0], b = portals.p[1];
    linked = a.active && b.active;
    boost = max(0, boost - dt * 25);
    Eavail = baseOutput + 70 * sin(T * 0.37) + 25 * sin(T * 2.3) + boost;
    if (linked) {
      D = portals.distance() / M;
      theta = portals.relativeAngle();
      C = 1 + 0.35 * sq(sin(radians(theta) / 2));
      Ereq = K * D * D * C;
      S = Eavail / max(Ereq, 0.001);
      stability = min(1, S);
    } else {
      D = theta = Ereq = 0;
      C = 1;
      S = 0;
      stability = 1;
    }
    lastAgo += dt;
    if (linked && stability < 0.5 && !warned) {
      warned = true;
      sfx.play(sfx.warn, 0.4, 1);
      onLowStability();
    }
    if (stability > 0.6) warned = false;
  }

  void recordTeleport(ThrowableObject o, Portal from, Portal to) {
    lastName = o.name;
    lastIn = o.speedIn;
    lastOut = o.speedOut;
    lastMass = o.mass;
    lastDs2 = D * D;                                     // dt = 0
    lastRestE = o.mass * C_LIGHT * C_LIGHT / 1e15;       // PJ
    lastAgo = 0;
    jumps++;
    focus = o;
  }

  float focusSpeed() {
    if (focus == null) return 0;
    return focus.vel.mag() / M;
  }

  String stabilityWord() {
    if (!linked) return "NO LINK";
    if (S >= 1.5) return "STABLE (SURPLUS)";
    if (S >= 1) return "STABLE";
    if (S >= 0.75) return "WOBBLY";
    if (S >= 0.5) return "UNSTABLE";
    return "CRITICAL - SPACETIME TAFFY";
  }
}

// ====================================================================
// PORTAL RESEARCH TERMINAL: a big hologram over the research console,
// redrawn a few times a second into an offscreen image. TAB shows the same
// screen full size.

class ResearchTerminal {
  PGraphics g;
  PImage img;                  // GPU-friendly copy: only re-uploaded when it changes
  float refresh;
  PFont head, mono, small, val;
  float[] history = new float[160];
  int histPos;
  final float X = 1290, Y = -640, Z = -1790, ROT = -0.42, W = 980, H = 612;

  ResearchTerminal() {
    g = createGraphics(1024, 640);
    img = createImage(1024, 640, RGB);
    head = createFont("SansSerif.bold", 30, true);
    mono = createFont("Monospaced.bold", 17, true);
    small = createFont("Monospaced", 13, true);
    val = createFont("Monospaced.bold", 14, true);
  }

  void update(float dt) {
    refresh -= dt;
    if (refresh <= 0) {
      refresh = hud.terminalOpen ? 0.2 : 0.3;
      history[histPos] = physics.linked ? physics.stability : -1;
      histPos = (histPos + 1) % history.length;
      if (visible()) render();
    }
  }

  // only redraw the screen when someone can actually see it
  boolean visible() {
    if (hud.terminalOpen || img.width == 0 || frameCount < 5) return true;
    PVector d = new PVector(X - cam.pos.x, Y - cam.pos.y, Z - cam.pos.z);
    return d.mag() < 6000 && d.normalize().dot(cam.fwd) > 0.2;
  }

  String m(float units) { return fm(units / M); }
  String up(float y) { return fm(-y / M); }             // show heights as positive-up

  void render() {
    PortalPhysics ph = physics;
    Portal a = portals.p[0], b = portals.p[1];
    g.beginDraw();
    g.background(4, 18, 22);
    // faint grid
    g.stroke(30, 90, 90, 60);
    g.strokeWeight(1);
    for (int x = 0; x < g.width; x += 32) g.line(x, 0, x, g.height);
    for (int y = 0; y < g.height; y += 32) g.line(0, y, g.width, y);
    g.noStroke();
    // header
    g.fill(120, 255, 200);
    g.textFont(head);
    g.textAlign(LEFT, TOP);
    g.text("PORTAL RESEARCH TERMINAL", 22, 14);
    g.fill(255, 190, 70);
    g.rect(g.width - 330, 16, 308, 34, 6);
    g.fill(20, 10, 0);
    g.textFont(mono);
    g.textAlign(CENTER, CENTER);
    g.text("FICTIONAL PORTAL PHYSICS", g.width - 176, 32);
    g.textAlign(LEFT, TOP);
    g.textFont(small);
    g.fill(110, 200, 180);
    g.text("live numbers from the lab  -  real-ish equations  -  completely made-up portals", 24, 54);
    g.stroke(80, 220, 200, 160);
    g.line(20, 76, g.width - 20, 76);
    g.noStroke();

    float y = 86;
    g.textFont(mono);
    y = portalLine(a, y);
    y = portalLine(b, y);
    y += 6;
    String dx = ph.linked ? m(b.c.x) + " - " + m(a.c.x) : "x2 - x1";
    String dy = ph.linked ? up(b.c.y) + " - " + up(a.c.y) : "y2 - y1";
    String dz = ph.linked ? m(b.c.z) + " - " + m(a.c.z) : "z2 - z1";
    y = section("SPACETIME", "ds² = gμν dxμ dxν", y);
    y = value(ph.jumps > 0 ? "  last jump: ds² = -(c·Δt)² + Δx²+Δy²+Δz² = 0 + " + nf(ph.lastDs2, 0, 1) + " m²  (spacelike!)" : "no jumps yet - throw something through", y);
    y = section("DISTANCE", "D = √((x₂-x₁)² + (y₂-y₁)² + (z₂-z₁)²)", y);
    y = value(ph.linked ? "  = √((" + dx + ")² + (" + dy + ")² + (" + dz + ")²) = " + nf(ph.D, 0, 2) + " m" : "  = needs both portals", y);
    y = section("ENERGY", "E = mc²", y);
    y = value(ph.jumps > 0 ? "  " + ph.lastName + ": " + nf(ph.lastMass, 0, 2) + " kg × (2.998e8 m/s)² = " + nf(ph.lastRestE, 0, 1) + " PJ" : "  = (nothing has jumped yet)", y);
    y = section("PORTAL ENERGY", "E_portal = K × D² × C", y);
    y = value(ph.linked ? "  = " + nf(ph.K, 0, 4) + " PJ/m² × " + nf(ph.D, 0, 2) + "² m² × " + nf(ph.C, 0, 3) + " = " + nf(ph.Ereq, 0, 1) + " PJ" : "  = 0 PJ (portals not linked)", y);
    y = section("STABILITY", "S = E_available / E_required", y);
    y = value(ph.linked ? "  = " + nf(ph.Eavail, 0, 1) + " / " + nf(ph.Ereq, 0, 1) + " = " + nf(ph.S, 0, 2) + "  ->  " + nf(ph.stability * 100, 0, 1) + " %  " + ph.stabilityWord() : "  = no link", y);
    y = section("RELATIVE ANGLE", "θ = acos(nA · nB)      C = 1 + 0.35 sin²(θ/2)", y);
    y = value(ph.linked ? "  = " + nf(ph.theta, 0, 1) + "°          C = " + nf(ph.C, 0, 3) : "  = -", y);
    y = section("OBJECT VELOCITY", "|v| = √(vx² + vy² + vz²)", y);
    String fname = ph.focus != null ? ph.focus.name : "-";
    y = value("  = " + nf(ph.focusSpeed(), 0, 1) + " m/s  (" + fname + ")" + (ph.jumps > 0 ? "   last jump: in " + nf(ph.lastIn, 0, 2) + " -> out " + nf(ph.lastOut, 0, 2) + " m/s" : ""), y);

    drawMap(706, 92, 296, 296);
    drawStabilityGraph(706, 404, 296, 120);
    g.fill(110, 200, 180);
    g.textFont(small);
    g.text("GENERATORS " + nf(ph.Eavail, 0, 0) + " PJ", 706, 534);
    g.text("BATTERY BOOST " + nf(ph.boost, 0, 0) + " PJ   JUMPS " + ph.jumps, 706, 552);
    g.fill(255, 190, 70, 200);
    g.text("Portal mechanics on this screen are fictional. The arithmetic is real.", 24, g.height - 26);
    g.endDraw();
    g.loadPixels();
    img.loadPixels();
    arrayCopy(g.pixels, img.pixels);
    img.updatePixels();
  }

  float portalLine(Portal q, float y) {
    g.fill(q.active ? q.col : color(90));
    g.ellipse(32, y + 10, 12, 12);
    g.fill(q.active ? color(220, 255, 240) : color(120));
    String s = "PORTAL " + q.label() + "  " + (q.active ? "ACTIVE " : "OFFLINE");
    if (q.active) s += "  X " + m(q.c.x) + "  Y " + up(q.c.y) + "  Z " + m(q.c.z) + "   on " + q.box.name;
    g.text(s, 46, y);
    return y + 24;
  }

  float section(String title, String eq, float y) {
    g.textFont(mono);
    g.fill(120, 255, 200);
    g.text(title, 24, y);
    g.fill(200, 240, 255);
    g.text(eq, 196, y);
    return y + 21;
  }

  float value(String s, float y) {
    g.textFont(val);
    g.fill(255, 230, 140);
    g.text(s, 34, y);
    return y + 27;
  }

  // top-down map: deck, portals with their facing, objects, you
  void drawMap(float x, float y, float w, float h) {
    g.noFill();
    g.stroke(80, 220, 200, 160);
    g.rect(x, y, w, h);
    float s = min(w, h) / 9000.0;           // 90 m across
    float cx = x + w / 2, cy = y + h / 2;
    g.stroke(120, 200, 220, 120);
    g.rect(cx - 2000 * s, cy - 2000 * s, 4000 * s, 4000 * s);
    g.rect(cx - 350 * s, cy + 200 * s, 700 * s, 700 * s);
    g.noStroke();
    for (ThrowableObject o : objects.list) {
      if (o.gone > 0) continue;
      g.fill(o.held ? color(255, 255, 255) : color(150, 170, 190));
      g.ellipse(cx + o.pos.x * s, cy + o.pos.z * s, 4, 4);
    }
    Portal a = portals.p[0], b = portals.p[1];
    if (physics.linked) {
      g.stroke(255, 230, 140, 180);
      g.line(cx + a.c.x * s, cy + a.c.z * s, cx + b.c.x * s, cy + b.c.z * s);
    }
    for (Portal q : portals.p) {
      if (!q.active) continue;
      float px = cx + q.c.x * s, pz = cy + q.c.z * s;
      g.stroke(q.col);
      g.strokeWeight(2);
      g.line(px, pz, px + q.n.x * 18, pz + q.n.z * 18);
      g.noStroke();
      g.fill(q.col);
      g.ellipse(px, pz, 11, 11);
      g.fill(0);
      g.textFont(small);
      g.textAlign(CENTER, CENTER);
      g.text(q.label(), px, pz - 1);
      g.textAlign(LEFT, TOP);
      g.strokeWeight(1);
    }
    // you
    g.fill(255, 120, 200);
    g.pushMatrix();
    g.translate(cx + cam.pos.x * s, cy + cam.pos.z * s);
    g.rotate(atan2(cam.fwd.z, cam.fwd.x));
    g.triangle(8, 0, -6, -5, -6, 5);
    g.popMatrix();
    g.fill(110, 200, 180);
    g.textFont(small);
    g.text("TOP VIEW  (90 m)", x + 6, y + 4);
  }

  void drawStabilityGraph(float x, float y, float w, float h) {
    g.noFill();
    g.stroke(80, 220, 200, 160);
    g.rect(x, y, w, h);
    g.stroke(255, 120, 90, 120);
    g.line(x, y + h * 0.5, x + w, y + h * 0.5);
    g.stroke(120, 255, 170);
    g.strokeWeight(2);
    g.beginShape();
    for (int i = 0; i < history.length; i++) {
      float v = history[(histPos + i) % history.length];
      if (v < 0) continue;
      g.vertex(x + w * i / (history.length - 1.0), y + h - v * h);
    }
    g.endShape();
    g.strokeWeight(1);
    g.noStroke();
    g.fill(110, 200, 180);
    g.textFont(small);
    g.text("STABILITY HISTORY", x + 6, y + 4);
    g.fill(255, 140, 110);
    g.text("50%: things come out wrong", x + 6, y + h * 0.5 + 2);
  }

  // the floating hologram in the lab (glow pass)
  void drawGlow() {
    pushMatrix();
    translate(X, Y + sin(T * 0.8) * 6, Z);
    rotateY(ROT);
    noStroke();
    tint(255, 235 + 20 * sin(T * 11) * sin(T * 3.7));
    beginShape(QUADS);
    texture(img);
    vertex(-W / 2, -H / 2, 0, 0, 0);
    vertex(W / 2, -H / 2, 0, 1, 0);
    vertex(W / 2, H / 2, 0, 1, 1);
    vertex(-W / 2, H / 2, 0, 0, 1);
    endShape();
    noTint();
    // projector light from the console
    beginShape(QUADS);
    fill(60, 255, 200, 40);
    vertex(-W / 2, H / 2, 0);
    vertex(W / 2, H / 2, 0);
    fill(60, 255, 200, 0);
    vertex(W * 0.3, H / 2 + 420, 60);
    vertex(-W * 0.3, H / 2 + 420, 60);
    endShape();
    popMatrix();
  }
}
