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

  void fire() {
    if (cooldown > 0) return;
    cooldown = 0.28;
    shotsFired++;
    RayHit h = aimRay();
    PVector muzzle = PVector.add(cam.pos, PVector.mult(cam.fwd, 34));
    muzzle.add(PVector.mult(cam.right, 13)).sub(PVector.mult(cam.up, 12));
    PVector target = h.hit() ? h.p : PVector.add(cam.pos, PVector.mult(cam.fwd, 9000));
    shots.add(new Shot(muzzle, target, h, next, cam.fwd.copy()));
    next = 1 - next;
    parts.burst(muzzle, 10, 160, portals.p[shots.get(shots.size() - 1).which].col, 0.25, 10);
    sfx.play(sfx.fire, 0.6, random(0.95, 1.05));
  }

  // what the centre of the screen is pointing at (lab surfaces only)
  RayHit aimRay() {
    return lab.raycast(cam.pos, cam.fwd, 20000);
  }

  void update(float dt) {
    cooldown -= dt;
    for (int i = shots.size() - 1; i >= 0; i--) {
      Shot s = shots.get(i);
      s.update(dt);
      if (s.done) shots.remove(i);
    }
  }

  void draw() {
    for (Shot s : shots) s.draw();
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
        onPortalFizzled(fail, hit);
      }
    }

    void draw() {
      int c = portals.p[which].col;
      glowSprite(pos.x, pos.y, pos.z, 90, c, 200);
      glowSprite(pos.x, pos.y, pos.z, 26, color(240, 255, 230), 255);
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
