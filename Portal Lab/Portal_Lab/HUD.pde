// Screen overlay: holographic research panel, crosshair + what you're aiming
// at, portal tags, controls, F3 debug, TAB terminal, toasts and flashes.

class HUD {
  ArrayList<Toast> toasts = new ArrayList<Toast>();
  PFont mono, monoSmall, sans, sansBig;
  boolean showControls = true, debug, terminalOpen;
  float terminalAnim;
  float lastJumpToast = -99;
  float[] tagX = new float[2], tagY = new float[2];
  boolean[] tagOn = new boolean[2];
  String aimText = "", aimSub = "";
  int aimCol;

  HUD() {
    mono = createFont("Monospaced.bold", 26, true);
    monoSmall = createFont("Monospaced", 22, true);
    sans = createFont("SansSerif.bold", 32, true);
    sansBig = createFont("SansSerif.bold", 48, true);
  }

  void toast(String s, int c) {
    toasts.add(0, new Toast(s, c));
    if (toasts.size() > 4) toasts.remove(toasts.size() - 1);
  }

  void update(float dt) {
    for (int i = toasts.size() - 1; i >= 0; i--) {
      toasts.get(i).age += dt;
      if (toasts.get(i).age > 2.6) toasts.remove(i);
    }
    terminalAnim += ((terminalOpen ? 1 : 0) - terminalAnim) * min(1, dt * 10);
    updateAim();
  }

  // what's under the crosshair
  void updateAim() {
    aimText = "";
    aimSub = "";
    if (objects.heldObj != null || manip.active()) return;
    ThrowableObject o = objects.pick(1200);
    Portal q = portals.rayPick(cam.pos, cam.fwd, 4000);
    float to = o != null ? PVector.dist(cam.pos, o.pos) : 1e9, tq = q != null ? PVector.dist(cam.pos, q.c) : 1e9;
    if (o != null && to <= tq) {
      aimText = o.name + "   [E] GRAB";
      aimSub = o.massLabel() + "   " + o.status;
      aimCol = color(170, 255, 230);
      return;
    }
    if (q != null) {
      aimText = "PORTAL " + q.label() + "   [E] SELECT / MOVE";
      aimSub = "on " + q.box.name;
      aimCol = q.colLight;
      return;
    }
    RayHit h = gun.aimRay();
    if (h.hit()) {
      float d = h.t / M;
      if (h.box.name.equals("MATTER DISPENSER") && d < 9) {
        aimText = "MATTER DISPENSER   [E] DISPENSE";
        aimSub = "results not guaranteed";
        aimCol = color(120, 255, 200);
      } else if (h.box.portalable(h.face)) {
        aimSub = h.box.name + "  -  PORTAL SURFACE  -  " + nf(d, 0, 1) + " m";
        aimCol = color(140, 255, 170);
      } else {
        aimSub = h.box.name + "  -  REJECTS PORTALS  -  " + nf(d, 0, 1) + " m";
        aimCol = color(255, 150, 120);
      }
    }
  }

  // called while the 3D camera is still active: where to put the A/B tags
  void capturePortalTags() {
    for (int i = 0; i < 2; i++) {
      Portal q = portals.p[i];
      tagOn[i] = false;
      if (!q.active) continue;
      PVector p = PVector.add(q.c, PVector.mult(q.u, PORTAL_HH * 1.35));
      p.add(PVector.mult(q.n, 20));
      if (PVector.sub(p, cam.pos).dot(cam.fwd) < 10) continue;
      tagX[i] = screenX(p.x, p.y, p.z);
      tagY[i] = screenY(p.x, p.y, p.z);
      tagOn[i] = true;
    }
  }

  void draw() {
    // camera teleport flash
    if (cam.teleportFlash > 0.01) {
      noStroke();
      fill(140, 255, 160, 160 * cam.teleportFlash);
      rect(0, 0, width, height);
      cam.teleportFlash *= 0.86;
    }
    // stability warning vignette
    if (physics.linked && physics.stability < 0.5) {
      float a = 70 * (0.5 - physics.stability) * 2 * (0.6 + 0.4 * sin(T * 8));
      noFill();
      for (int i = 0; i < 6; i++) {
        stroke(255, 60, 40, a * (1 - i / 6.0));
        strokeWeight(14);
        rect(i * 12, i * 12, width - i * 24, height - i * 24);
      }
      noStroke();
    }
    drawTags();
    boolean clean = terminalAnim > 0.5;          // the TAB computer takes over the screen
    if (!clean) drawPanel();
    drawAim();
    if (showControls && !clean) drawControls();
    if (debug && !clean) drawDebug();
    drawToasts();
    if (objects.heldObj != null) drawHolding();
    if (manip.active()) drawManip();
    if (terminalAnim > 0.02) drawTerminalOverlay();
    if (!cam.captured) {
      textFont(sans, 18);
      textAlign(CENTER, CENTER);
      fill(170, 255, 200, 150 + 100 * sin(T * 4));
      text("CLICK TO CONTROL THE CAMERA   (ESC RELEASES THE MOUSE)", width / 2, height - 22);
    }
    cam.drawCrosshair();
  }

  void holoBox(float x, float y, float w, float h) {
    noStroke();
    fill(0, 30, 28, 150);
    rect(x, y, w, h, 6);
    stroke(80, 255, 200, 170);
    strokeWeight(1.2);
    noFill();
    rect(x, y, w, h, 6);
    stroke(80, 255, 200, 255);
    strokeWeight(2.5);
    line(x, y + 14, x, y);
    line(x, y, x + 14, y);
    line(x + w, y + h - 14, x + w, y + h);
    line(x + w, y + h, x + w - 14, y + h);
    noStroke();
  }

  void drawPanel() {
    float x = 14, y = 14, w = 300, h = 236;
    holoBox(x, y, w, h);
    textFont(mono, 15);
    textAlign(LEFT, TOP);
    fill(120, 255, 200);
    text("PORTAL RESEARCH SYSTEM", x + 14, y + 10);
    stroke(80, 255, 200, 90);
    line(x + 12, y + 32, x + w - 12, y + 32);
    noStroke();
    float ly = y + 42;
    for (int i = 0; i < 2; i++) {
      Portal q = portals.p[i];
      fill(q.active ? q.col : color(80));
      ellipse(x + 22, ly + 8, 10, 10);
      fill(q.active ? color(220, 255, 240) : color(140));
      textFont(mono, 14);
      text("PORTAL " + q.label() + ": " + (q.active ? "ACTIVE" : "OFFLINE"), x + 34, ly);
      ly += 20;
    }
    ly += 6;
    textFont(monoSmall, 14);
    fill(200, 240, 255);
    text("DISTANCE:  " + (physics.linked ? nf(physics.D, 0, 1) + " m" : "-"), x + 16, ly);
    ly += 19;
    text("ENERGY:    " + (physics.linked ? nf(physics.Ereq, 0, 1) + " PJ" : "-"), x + 16, ly);
    ly += 19;
    int sc = physics.stability >= 1 ? color(140, 255, 170) : physics.stability >= 0.5 ? color(255, 220, 120) : color(255, 110, 90);
    fill(sc);
    text("STABILITY: " + (physics.linked ? nf(physics.stability * 100, 0, 1) + " %" : "-"), x + 16, ly);
    ly += 19;
    fill(200, 240, 255);
    text("ANGLE:     " + (physics.linked ? nf(physics.theta, 0, 1) + " deg" : "-"), x + 16, ly);
    ly += 25;
    text("OBJECTS: " + objects.list.size() + "     FPS: " + nf(frameRate, 0, 0), x + 16, ly);
    ly += 19;
    fill(170, 255, 220);
    text("NEXT SHOT: PORTAL " + (gun.next == 0 ? "A" : "B") + "   THROW " + nf(objects.throwPower, 0, 0) + " m/s", x + 16, ly);
  }

  void drawTags() {
    textFont(sans, 22);
    textAlign(CENTER, CENTER);
    for (int i = 0; i < 2; i++) {
      if (!tagOn[i]) continue;
      Portal q = portals.p[i];
      fill(0, 120);
      ellipse(tagX[i], tagY[i], 30, 30);
      fill(q.colLight);
      text(q.label(), tagX[i], tagY[i] - 2);
    }
  }

  void drawAim() {
    textAlign(CENTER, TOP);
    if (aimText.length() > 0) {
      textFont(sans, 17);
      fill(0, 140);
      text(aimText, width / 2 + 1, height / 2 + 26 + 1);
      fill(aimCol);
      text(aimText, width / 2, height / 2 + 26);
    }
    if (aimSub.length() > 0) {
      textFont(monoSmall, 13);
      fill(aimCol, 200);
      text(aimSub, width / 2, height / 2 + (aimText.length() > 0 ? 48 : 26));
    }
  }

  void drawHolding() {
    ThrowableObject o = objects.heldObj;
    String s = "HOLDING " + o.name + "  (" + o.massLabel() + ")";
    String t = "LEFT CLICK THROW  -  R / RIGHT CLICK RELEASE  -  WHEEL POWER " + nf(objects.throwPower, 0, 0) + " m/s";
    textAlign(CENTER, TOP);
    textFont(sans, 17);
    fill(170, 255, 230);
    text(s, width / 2, height / 2 + 30);
    textFont(monoSmall, 13);
    fill(170, 255, 230, 200);
    text(t, width / 2, height / 2 + 54);
  }

  void drawManip() {
    Portal q = manip.sel;
    float w = 330, h = 128, x = width / 2 - w / 2, y = height / 2 + 40;
    holoBox(x, y, w, h);
    textAlign(LEFT, TOP);
    textFont(mono, 16);
    fill(q.colLight);
    text("PORTAL " + q.label() + " SELECTED", x + 14, y + 10);
    textFont(monoSmall, 14);
    fill(200, 240, 255);
    text("MOVE / REPOSITION   aim at a surface", x + 14, y + 36);
    text("ROTATE              Q / R  (or wheel)", x + 14, y + 54);
    text("CONFIRM             LEFT CLICK", x + 14, y + 72);
    text("CANCEL              RIGHT CLICK", x + 14, y + 90);
    fill(manip.valid ? color(140, 255, 170) : color(255, 120, 100));
    text(manip.status, x + 14, y + 108);
  }

  void drawControls() {
    String[][] rows = {
      { "WASD", "MOVE" }, { "SPACE", "UP" }, { "CTRL", "DOWN" }, { "SHIFT", "SPEED BOOST" }, { "MOUSE", "LOOK" },
      { "M1", "FIRE PORTAL / THROW" }, { "E", "INTERACT / GRAB / SELECT" }, { "R", "RELEASE OBJECT" }, { "Q/R", "ROTATE PORTAL" },
      { "WHEEL", "THROW POWER" }, { "TAB", "PORTAL COMPUTER" }, { "F3", "DEBUG" }, { "H", "HIDE CONTROLS" }, { "ESC", "RELEASE MOUSE" }
    };
    float w = 270, h = rows.length * 17 + 18, x = 14, y = height - h - 14;
    holoBox(x, y, w, h);
    textAlign(LEFT, TOP);
    textFont(monoSmall, 13);
    for (int i = 0; i < rows.length; i++) {
      fill(120, 255, 200);
      text(rows[i][0], x + 14, y + 9 + i * 17);
      fill(200, 240, 255);
      text(rows[i][1], x + 86, y + 9 + i * 17);
    }
  }

  void drawDebug() {
    Portal a = portals.p[0], b = portals.p[1];
    String[] lines = {
      "DEBUG (F3)",
      "FPS            " + nf(frameRate, 0, 1) + "   frame " + nf(dt * 1000, 0, 1) + " ms",
      "CAMERA XYZ     " + v3(cam.pos),
      "CAMERA DIR     " + nf(cam.fwd.x, 0, 2) + ", " + nf(cam.fwd.y, 0, 2) + ", " + nf(cam.fwd.z, 0, 2) + "  yaw " + nf(degrees(cam.yaw) % 360, 0, 0) + " pitch " + nf(degrees(cam.pitch), 0, 0),
      "PORTAL A XYZ   " + (a.active ? v3(a.c) : "-"),
      "PORTAL B XYZ   " + (b.active ? v3(b.c) : "-"),
      "PORTAL DIST    " + (physics.linked ? nf(physics.D, 0, 2) + " m" : "-"),
      "STABILITY      " + (physics.linked ? nf(physics.S, 0, 3) + "  (" + nf(physics.stability * 100, 0, 1) + " %)" : "-"),
      "OBJECTS        " + objects.list.size() + (objects.heldObj != null ? "  holding " + objects.heldObj.name : ""),
      "PARTICLES      " + parts.count + " / " + parts.CAP,
      "IDLE TIMER     " + nf(idleSeconds(), 0, 1) + " s  (Rick at 20)",
      "LIQUID SHADER  " + (liquidShader != null ? "GPU" : "CPU fallback"),
      "NOCLIP (N)     " + (cam.noclip ? "ON" : "OFF"),
      "MOUSE          " + (cam.captured ? "captured" : "free") + (cam.win == null ? "  (no NEWT window)" : "")
    };
    float w = 470, h = lines.length * 17 + 18, x = width - w - 14, y = 14;
    holoBox(x, y, w, h);
    textAlign(LEFT, TOP);
    textFont(monoSmall, 13);
    for (int i = 0; i < lines.length; i++) {
      fill(i == 0 ? color(255, 220, 120) : color(200, 240, 255));
      text(lines[i], x + 14, y + 9 + i * 17);
    }
  }

  String v3(PVector p) {
    return fm(p.x / M) + ", " + fm(-p.y / M) + ", " + fm(p.z / M) + " m";
  }

  void drawToasts() {
    textAlign(CENTER, CENTER);
    for (int i = 0; i < toasts.size(); i++) {
      Toast t = toasts.get(i);
      float a = 255 * min(1, (2.6 - t.age) / 0.5) * min(1, t.age / 0.12);
      textFont(sans, 19);
      fill(0, a * 0.6);
      text(t.s, width / 2 + 2, height * 0.74 + i * 28 + 2);
      fill(red(t.c), green(t.c), blue(t.c), a);
      text(t.s, width / 2, height * 0.74 + i * 28);
    }
  }

  void drawTerminalOverlay() {
    float k = terminalAnim;
    noStroke();
    fill(0, 10, 12, 210 * k);
    rect(0, 0, width, height);
    float w = 1100 * (0.9 + 0.1 * k), h = w * 640 / 1024.0;
    imageMode(CENTER);
    blendMode(ADD);
    tint(255, 255 * k);
    image(terminal.img, width / 2, height / 2 - 10, w, h);
    noTint();
    blendMode(BLEND);
    imageMode(CORNER);
    textFont(mono, 14);
    textAlign(CENTER, CENTER);
    fill(170, 255, 220, 220 * k);
    text("TAB TO CLOSE", width / 2, height / 2 + h / 2 + 6);
  }
}

class Toast {
  String s;
  int c;
  float age;

  Toast(String s, int c) {
    this.s = s;
    this.c = c;
  }
}
