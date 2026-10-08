// The portal gun is not a weapon model on screen - it's an aiming device.
// M1 raycasts from the centre of the screen, then fires a glowing energy
// projectile from just below the view toward the hit. When it lands, the
// portal opens there (or fizzles if the surface rejects portals).

class PortalGun {
  ArrayList<Shot> shots = new ArrayList<Shot>();
  int next = 0;                 // 0 -> portal A, 1 -> portal B (alternates every shot)
  float cooldown;
  int shotsFired;
  String lastResult = "";
  final float SPEED = 7500;     // projectile speed, units/s (75 m/s)
  float device;                 // 0..1 visibility of the floating aiming device
  float recoil;

  void fire() {
    if (cooldown > 0) return;
    cooldown = 0.28;
    shotsFired++;
    RayHit h = aimRay();
    checkShotThroughRick(h);
    PVector muzzle = PVector.add(cam.pos, PVector.mult(cam.fwd, 34));
    muzzle.add(PVector.mult(cam.right, 24)).sub(PVector.mult(cam.up, 20));   // off-axis, so the bolt visibly crosses into the centre
    PVector target = h.hit() ? h.p : PVector.add(cam.pos, PVector.mult(cam.fwd, 9000));
    shots.add(new Shot(muzzle, target, h, next, cam.fwd.copy()));
    next = 1 - next;
    device = 1.6;
    recoil = 1;
    parts.burst(muzzle, 10, 160, portals.p[shots.get(shots.size() - 1).which].col, 0.25, 10);
    sfx.play(sfx.fire, 0.6, random(0.95, 1.05));
  }

  // what the centre of the screen is pointing at (lab surfaces only)
  RayHit aimRay() {
    return lab.raycast(cam.pos, cam.fwd, 20000);
  }

  void update(float dt) {
    cooldown -= dt;
    if (manip.active()) device = max(device, 1);
    device = max(0, device - dt);
    recoil *= exp(-dt * 9);
    for (int i = shots.size() - 1; i >= 0; i--) {
      Shot s = shots.get(i);
      s.update(dt);
      if (s.done) shots.remove(i);
    }
  }

  void draw() {
    for (Shot s : shots) s.draw();
    drawDevice();
  }

  // the portal gun as a small floating emitter that fades in when you use it
  void drawDevice() {
    float a = min(1, device);
    if (a <= 0.01) return;
    int c = manip.active() ? manip.sel.colLight : portals.p[next].col;
    PVector p = PVector.add(cam.pos, PVector.mult(cam.fwd, 58 - recoil * 6));
    p.add(PVector.mult(cam.right, 21 + sin(T * 2) * 0.6)).sub(PVector.mult(cam.up, 14 + cos(T * 2.3) * 0.6));
    glowSprite(p.x, p.y, p.z, 11 + recoil * 7, c, 210 * a);
    glowSprite(p.x, p.y, p.z, 5, color(255), 255 * a);
    // two little rings spinning round the emitter
    noFill();
    strokeWeight(1.3);
    for (int k = 0; k < 2; k++) {
      stroke(c, 200 * a);
      beginShape();
      for (int i = 0; i <= 24; i++) {
        float t = TWO_PI * i / 24;
        float sp = T * (k == 0 ? 5 : -4);
        PVector ax = k == 0 ? cam.right : cam.up;
        PVector bx = cam.fwd;
        float rx = cos(t) * 5.5, ry = sin(t) * 5.5;
        PVector q = PVector.add(p, PVector.mult(ax, rx * cos(sp))).add(PVector.mult(bx, rx * sin(sp))).add(PVector.mult(k == 0 ? cam.up : cam.right, ry));
        vertex(q.x, q.y, q.z);
      }
      endShape();
    }
    noStroke();
  }

  class Shot {
    PVector pos, from, to, dir, aimDir;
    RayHit hit;
    int which;
    float travelled, total, age;
    boolean done;

    Shot(PVector from, PVector to, RayHit hit, int which, PVector aimDir) {
      this.from = from.copy();
      this.to = to.copy();
      this.hit = hit;
      this.which = which;
      this.aimDir = aimDir;
      pos = from.copy();
      dir = PVector.sub(to, from);
      total = dir.mag();
      dir.normalize();
    }

    void update(float dt) {
      age += dt;
      travelled += SPEED * dt;
      if (travelled >= total) {
        pos.set(to);
        land();
        done = true;
        return;
      }
      pos = PVector.add(from, PVector.mult(dir, travelled));
      // spiralling trail
      int c = portals.p[which].col;
      for (int k = 0; k < 3; k++) {
        float a = age * 40 + k * TWO_PI / 3;
        PVector off = PVector.add(PVector.mult(cam.right, cos(a) * 6), PVector.mult(cam.up, sin(a) * 6));
        parts.emit(PVector.add(pos, off), PVector.mult(dir, -150), random(0.2, 0.45), random(8, 14), c, 0, 4);
      }
    }

    void land() {
      Portal q = portals.p[which];
      if (!hit.hit()) {
        lastResult = "SHOT LOST IN SPACE";
        hud.toast("SHOT LOST IN SPACE", color(255, 150, 110));
        sfx.play(sfx.fizzle, 0.35, 0.8);
        giveLetterBack();
        onShotLost();
        return;
      }
      String fail = portals.place(which, hit, aimDir);
      PVector at = PVector.add(hit.p, PVector.mult(hit.n, 4));
      if (fail == null) {
        lastResult = "PORTAL " + q.label() + " OPENED ON " + hit.box.name;
        hud.toast("PORTAL " + q.label() + " OPENED", q.col);
        parts.burst(at, 40, 420, q.colLight, 0.6, 22);
        sfx.play(sfx.portalOpen, 0.75, which == 0 ? 1 : 1.12);
        onPortalPlaced(q);
      } else {
        lastResult = "FIZZLED: " + fail;
        hud.toast(fail, color(255, 120, 90));
        parts.burst(at, 26, 300, color(255, 150, 90), 0.4, 14);
        PVector[] ax = planeAxes(hit.n);
        portals.waves.add(new Shockwave(at, ax[0], ax[1], 70, 0.3, color(255, 140, 80)));
        sfx.play(sfx.fizzle, 0.6, 1);
        giveLetterBack();
        onPortalFizzled(fail, hit);
      }
    }

    // a shot that didn't open anything doesn't use up its letter (unless a newer shot is already flying)
    void giveLetterBack() {
      if (shots.get(shots.size() - 1) == this) next = which;
    }

    void draw() {
      int c = portals.p[which].col;
      // about the same size on screen at any distance, so it reads as a bolt all the way to the wall
      float s = constrain(PVector.dist(pos, cam.pos) * 0.11, 22, 700);
      for (int k = 6; k >= 1; k--) {                          // comet tail
        PVector t = PVector.sub(pos, PVector.mult(dir, min(k * s * 0.22, travelled)));
        glowSprite(t.x, t.y, t.z, s * (0.8 - k * 0.1), c, 170 - k * 24);
      }
      glowSprite(pos.x, pos.y, pos.z, s, c, 235);
      glowSprite(pos.x, pos.y, pos.z, s * 0.32, color(240, 255, 230), 255);
    }
  }
}

// two axes spanning the plane with normal n
PVector[] planeAxes(PVector n) {
  PVector a = abs(n.y) > 0.9 ? new PVector(1, 0, 0) : new PVector(0, 1, 0);
  PVector x = n.cross(a).normalize();
  PVector y = n.cross(x).normalize();
  return new PVector[] { x, y };
}

// ====================================================================
// Portal manipulation: look at a portal + E to select it, then the portal
// follows the crosshair across valid surfaces. Q / R rotate it in its own
// plane (that changes which way things come out), LEFT CLICK confirms,
// RIGHT CLICK puts it back where it was.

class PortalManipulator {
  Portal sel;
  PVector oc = new PVector(), on = new PVector(), ou = new PVector();
  Box obox;
  int oface;
  float spin;
  boolean valid = true;
  String status = "";
  PVector ghost;
  PVector lastFwd = new PVector();   // where the crosshair pointed last frame

  boolean active() { return sel != null; }

  void select(Portal q) {
    sel = q;
    oc.set(q.c);
    on.set(q.n);
    ou.set(q.u);
    obox = q.box;
    oface = q.face;
    lastFwd.set(cam.fwd);
    // keep its current rotation relative to the default orientation for this surface
    PVector ud = abs(q.n.y) > 0.5 ? PVector.sub(cam.fwd, PVector.mult(q.n, cam.fwd.dot(q.n))) : new PVector(0, -1, 0);
    if (ud.magSq() < 1e-4) ud = new PVector(0, 0, -1);
    ud.normalize();
    PVector rd = q.n.cross(ud);
    spin = atan2(q.u.dot(rd), q.u.dot(ud));
    sfx.play(sfx.select, 0.6, 1);
    hud.toast("PORTAL " + q.label() + " SELECTED", q.colLight);
    q.splash(PVector.add(q.c, PVector.mult(q.n, 10)), 0.4);
  }

  void update(float dt) {
    if (sel == null) return;
    // steering a selected portal is doing something, even across surfaces that reject it
    if (PVector.dist(lastFwd, cam.fwd) > 0.001) markAction();
    lastFwd.set(cam.fwd);
    if (kRotL) spin -= 1.7 * dt;
    if (kRotR) spin += 1.7 * dt;
    RayHit h = lab.raycast(cam.pos, cam.fwd, 20000);
    Placement pl = portals.tryPlace(sel.id, h, cam.fwd, spin);
    if (pl.fail == null) {
      if (PVector.dist(sel.c, pl.c) > 0.5 || PVector.dist(sel.u, pl.u) > 0.01) markAction();   // dragging it around counts as doing something
      sel.c.set(pl.c);
      sel.n.set(pl.n);
      sel.u.set(pl.u);
      sel.r = sel.n.cross(sel.u);
      sel.box = pl.box;
      sel.face = pl.face;
      onHoloPortalMoved(sel);
      valid = true;
      status = "REPOSITIONING";
      ghost = null;
    } else {
      valid = false;
      status = pl.fail;
      ghost = h.hit() ? h.p.copy() : null;
    }
  }

  void rotateStep(float a) {
    spin += a;
  }

  void confirm() {
    if (sel == null) return;
    sfx.play(sfx.confirm, 0.6, 1);
    sel.splash(PVector.add(sel.c, PVector.mult(sel.n, 10)), 0.7);
    hud.toast("PORTAL " + sel.label() + " LOCKED IN", sel.colLight);
    Portal q = sel;
    sel = null;
    onPortalManipulated(q);
  }

  void cancel() {
    if (sel == null) return;
    sel.c.set(oc);
    sel.n.set(on);
    sel.u.set(ou);
    sel.r = sel.n.cross(sel.u);
    sel.box = obox;
    sel.face = oface;
    sfx.play(sfx.cancel, 0.6, 1);
    hud.toast("CANCELLED - PORTAL " + sel.label() + " RESTORED", color(200, 220, 255));
    sel = null;
  }

  // holographic selection brackets + an arrow showing the portal's "up"
  void drawGlow() {
    if (sel == null) return;
    Portal q = sel;
    pushMatrix();
    q.applyFrame(6);
    noFill();
    int c = valid ? color(200, 255, 240) : color(255, 110, 90);
    stroke(c, 220);
    strokeWeight(2.5);
    float k = 1.25 + 0.05 * sin(T * 6);
    for (int i = 0; i < 4; i++) {
      float a0 = HALF_PI * i + T * 0.8, a1 = a0 + 0.9;
      beginShape();
      for (int j = 0; j <= 10; j++) {
        float a = lerp(a0, a1, j / 10.0);
        vertex(cos(a) * PORTAL_HW * k, sin(a) * PORTAL_HH * k, 0);
      }
      endShape();
    }
    // up arrow
    float top = PORTAL_HH * 1.42;
    line(0, PORTAL_HH * 1.1, 0, 0, top, 0);
    line(-14, top - 16, 0, 0, top, 0);
    line(14, top - 16, 0, 0, top, 0);
    noStroke();
    popMatrix();
    if (ghost != null && !valid) glowSprite(ghost.x, ghost.y, ghost.z, 60, color(255, 90, 70), 200);
  }
}
