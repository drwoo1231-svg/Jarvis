// Portals: an oval opening stuck flush to a lab surface, described by a
// centre c and an orthonormal frame (r = right, u = up, n = out of the wall).
// Entering A's front comes out of B's front: local (x, y, z) -> (-x, y, -z).

final float PORTAL_HW = 68, PORTAL_HH = 110;          // half width / half height

class Portal {
  int id;                       // 0 = A, 1 = B
  boolean active;
  PVector c = new PVector(), n = new PVector(), u = new PVector(), r = new PVector();
  Box box;
  int face = -1;
  float open;                   // 0..1 formation
  float age;
  float spin;                   // extra in-plane rotation set by the player (radians)
  int col, colDark, colLight;

  Portal(int id) {
    this.id = id;
    col = id == 0 ? color(110, 255, 70) : color(40, 255, 175);
    colDark = id == 0 ? color(20, 110, 25) : color(10, 105, 80);
    colLight = id == 0 ? color(225, 255, 190) : color(200, 255, 235);
  }

  String label() { return id == 0 ? "A" : "B"; }

  void set(PVector c, PVector n, PVector u, Box box, int face) {
    this.c.set(c);
    this.n.set(n);
    this.u.set(u);
    this.r = n.cross(u);
    this.box = box;
    this.face = face;
    active = true;
    open = 0;
    age = 0;
  }

  // rotate the portal in its own plane (manipulation mode)
  void rotateInPlane(float ang) {
    PVector nu = PVector.add(PVector.mult(u, cos(ang)), PVector.mult(r, sin(ang)));
    u.set(nu.normalize());
    r = n.cross(u);
  }

  PVector toLocal(PVector p) {
    PVector d = PVector.sub(p, c);
    return new PVector(d.dot(r), d.dot(u), d.dot(n));
  }

  PVector toWorld(PVector l) {
    return new PVector(c.x + r.x * l.x + u.x * l.y + n.x * l.z,
                       c.y + r.y * l.x + u.y * l.y + n.y * l.z,
                       c.z + r.z * l.x + u.z * l.y + n.z * l.z);
  }

  PVector dirToLocal(PVector v) {
    return new PVector(v.dot(r), v.dot(u), v.dot(n));
  }

  PVector dirToWorld(PVector l) {
    return new PVector(r.x * l.x + u.x * l.y + n.x * l.z,
                       r.y * l.x + u.y * l.y + n.y * l.z,
                       r.z * l.x + u.z * l.y + n.z * l.z);
  }

  // is a local (x, y) inside the oval (k < 1 shrinks it)?
  boolean insideOval(float lx, float ly, float k) {
    float a = lx / (PORTAL_HW * k), b = ly / (PORTAL_HH * k);
    return a * a + b * b < 1;
  }

  void update(float dt) {
    if (!active) return;
    age += dt;
    open = min(1, open + dt / 0.45);
    // ambient energy specks drifting in and out of the opening
    if (open > 0.5 && random(1) < 0.75) {
      float a = random(TWO_PI);
      boolean inward = random(1) < 0.6;
      float rr = inward ? random(1.05, 1.35) : random(0.1, 0.4);
      PVector p = toWorld(new PVector(cos(a) * PORTAL_HW * rr, sin(a) * PORTAL_HH * rr, 3));
      PVector tangent = dirToWorld(new PVector(-sin(a) * PORTAL_HW, cos(a) * PORTAL_HH, 0)).normalize();
      PVector radial = dirToWorld(new PVector(cos(a), sin(a), 0));
      PVector v = PVector.mult(tangent, 120);
      v.add(PVector.mult(radial, inward ? -110 : 130));
      v.add(PVector.mult(n, inward ? random(0, 20) : random(30, 90)));
      parts.emit(p, v, random(0.5, 1.0), random(8, 16), lerpColor(col, colLight, random(1)), 0, 1.2);
    }
  }

  float pulse() { return 0.82 + 0.18 * sin(age * 6 + id * 2); }

  float scaleNow() { return easeOutBack(open); }

  // multiply the current matrix by the portal frame (local x = r, y = u, z = n)
  void applyFrame(float lift) {
    PVector o = PVector.add(c, PVector.mult(n, lift));
    applyMatrix(r.x, u.x, n.x, o.x,
                r.y, u.y, n.y, o.y,
                r.z, u.z, n.z, o.z,
                0, 0, 0, 1);
  }

  // opaque part: the swirling green disc (drawn in the solid pass, unlit)
  void drawSolid() {
    if (!active || open <= 0.01) return;
    float s = scaleNow();
    pushMatrix();
    applyFrame(1.6);
    scale(s);
    noStroke();
    int seg = 40;
    beginShape(TRIANGLE_FAN);
    fill(colLight);
    vertex(0, 0, 0);
    for (int i = 0; i <= seg; i++) {
      float a = TWO_PI * i / seg;
      float w = 1 + 0.045 * (noise(cos(a) + 2, sin(a) + 2, age * 1.3 + id * 9) - 0.5) * 2;
      fill(lerpColor(col, colDark, 0.35 + 0.25 * sin(a * 3 + age * 4)));
      vertex(cos(a) * PORTAL_HW * w, sin(a) * PORTAL_HH * w, 0);
    }
    endShape();
    // swirl ribbons, slightly above the disc
    for (int arm = 0; arm < 4; arm++) {
      float a0 = arm * HALF_PI - age * (3.2 + id * 0.6) + spin;
      beginShape(TRIANGLE_STRIP);
      for (int i = 0; i <= 26; i++) {
        float t = i / 26.0;
        float a = a0 + t * 4.4;
        float rad = 0.08 + t * 0.9;
        float w = 0.025 + 0.07 * sin(PI * t);
        fill(lerpColor(colLight, col, t), 255 * (1 - t * 0.6));
        vertex(cos(a) * PORTAL_HW * (rad - w), sin(a) * PORTAL_HH * (rad - w), 0.5);
        vertex(cos(a) * PORTAL_HW * (rad + w), sin(a) * PORTAL_HH * (rad + w), 0.5);
      }
      endShape();
    }
    // dark rim
    noFill();
    stroke(colDark);
    strokeWeight(3);
    beginShape();
    for (int i = 0; i <= seg; i++) {
      float a = TWO_PI * i / seg;
      vertex(cos(a) * PORTAL_HW * 1.01, sin(a) * PORTAL_HH * 1.01, 0.8);
    }
    endShape();
    noStroke();
    popMatrix();
  }

  // additive part: glow, rotating rings, bright energy
  void drawGlow() {
    if (!active || open <= 0.01) return;
    float s = scaleNow(), p = pulse();
    pushMatrix();
    applyFrame(2.4);
    scale(s);
    planeQuad(texGlow, PORTAL_HW * 3.0, PORTAL_HH * 2.6, 0, col, 150 * p);
    if (age < 0.6) planeQuad(texGlow, PORTAL_HW * 6, PORTAL_HH * 5, 0, colLight, 255 * (1 - age / 0.6));
    for (int k = 0; k < 3; k++) {
      float sc = 1.06 + k * 0.1 + 0.03 * sin(age * 3 + k);
      float rot = age * (k % 2 == 0 ? 1.4 : -2.1) * (1 + k * 0.3) + spin;
      planeQuad(texRingDash, PORTAL_HW * 2 * sc, PORTAL_HH * 2 * sc, rot, lerpColor(col, colLight, k * 0.4), (200 - k * 45) * p);
    }
    planeQuad(texGlow, PORTAL_HW * 1.1, PORTAL_HH * 1.1, 0, colLight, 120 * p);
    popMatrix();
  }

  // a texture quad in the portal plane, elliptically stretched, rotated in texture space
  void planeQuad(PImage tex, float w, float h, float rot, int c, float a) {
    noStroke();
    tint(red(c), green(c), blue(c), a);
    beginShape(QUADS);
    texture(tex);
    for (int i = 0; i < 4; i++) {
      float cx = (i == 0 || i == 3) ? -1 : 1, cy = (i < 2) ? -1 : 1;
      float rx = cx * cos(rot) - cy * sin(rot), ry = cx * sin(rot) + cy * cos(rot);
      vertex(rx * w / 2, ry * h / 2, 0, (cx + 1) / 2, (cy + 1) / 2);
    }
    endShape();
    noTint();
  }
}

// ====================================================================
// The pair of portals and everything that needs both of them.

class PortalPair implements PassFilter {
  Portal[] p = { new Portal(0), new Portal(1) };
  ArrayList<Shockwave> waves = new ArrayList<Shockwave>();

  boolean linked() { return p[0].active && p[1].active && p[0].open > 0.6 && p[1].open > 0.6; }

  Portal other(Portal q) { return q == p[0] ? p[1] : p[0]; }

  // try to open portal `which` on a ray hit; returns null on success or the reason it failed
  String place(int which, RayHit h, PVector shotDir) {
    if (!h.hit()) return "NO SURFACE";
    if (!h.box.portalable(h.face)) return "SURFACE REJECTS PORTALS";
    PVector n = h.n.copy();
    PVector u;
    if (abs(n.y) > 0.5) {
      // floor / ceiling: the top of the portal points the way you were looking
      u = PVector.sub(shotDir, PVector.mult(n, shotDir.dot(n)));
      if (u.magSq() < 1e-4) u = new PVector(0, 0, -1);
      u.normalize();
    } else {
      u = new PVector(0, -1, 0);                     // walls: upright
    }
    PVector c = h.p.copy();
    if (!fit(c, n, u, h.box, h.face)) return "NOT ENOUGH ROOM";
    // don't overlap the other portal on the same face
    Portal o = p[1 - which];
    if (o.active && o.box == h.box && o.face == h.face) {
      PVector d = PVector.sub(c, o.c);
      float need = PORTAL_HH * 2.05;
      if (d.mag() < need) {
        if (d.magSq() < 1) d = u.copy();
        d.normalize().mult(need);
        c = PVector.add(o.c, d);
        if (!fit(c, n, u, h.box, h.face) || PVector.dist(c, o.c) < need * 0.98) return "TOO CLOSE TO PORTAL " + o.label();
      }
    }
    Portal q = p[which];
    q.set(c, n, u, h.box, h.face);
    q.spin = 0;
    openFx(q);
    return null;
  }

  // slide the centre so the whole oval fits on the face; false if the face is too small
  boolean fit(PVector c, PVector n, PVector u, Box b, int face) {
    PVector r = n.cross(u);
    float[] rect = b.faceRect(face);
    PVector e1, e2;
    if (face == FACE_NX || face == FACE_PX) { e1 = new PVector(0, 1, 0); e2 = new PVector(0, 0, 1); }
    else if (face == FACE_NY || face == FACE_PY) { e1 = new PVector(1, 0, 0); e2 = new PVector(0, 0, 1); }
    else { e1 = new PVector(1, 0, 0); e2 = new PVector(0, 1, 0); }
    float m = 6;
    float ext1 = sqrt(sq(PORTAL_HW * r.dot(e1)) + sq(PORTAL_HH * u.dot(e1))) + m;
    float ext2 = sqrt(sq(PORTAL_HW * r.dot(e2)) + sq(PORTAL_HH * u.dot(e2))) + m;
    if (rect[1] - rect[0] < ext1 * 2 || rect[3] - rect[2] < ext2 * 2) return false;
    float a = constrain(c.dot(e1), rect[0] + ext1, rect[1] - ext1);
    float bb = constrain(c.dot(e2), rect[2] + ext2, rect[3] - ext2);
    float plane = b.facePlane(face);
    // rebuild the centre from the two in-plane coords and the plane
    PVector nAxis = new PVector(abs(n.x), abs(n.y), abs(n.z));
    c.set(PVector.add(PVector.mult(e1, a), PVector.mult(e2, bb)));
    c.add(PVector.mult(nAxis, plane));
    return true;
  }

  void openFx(Portal q) {
    PVector cc = PVector.add(q.c, PVector.mult(q.n, 4));
    waves.add(new Shockwave(cc, q.r, q.u, PORTAL_HH * 3.2, 0.7, q.col));
    waves.add(new Shockwave(cc, q.r, q.u, PORTAL_HH * 1.8, 0.45, q.colLight));
    for (int i = 0; i < 70; i++) {
      float a = random(TWO_PI), sp = random(150, 700);
      PVector v = q.dirToWorld(new PVector(cos(a) * sp, sin(a) * sp, random(20, 260)));
      parts.emit(cc, v, random(0.4, 1.1), random(10, 26), lerpColor(q.col, q.colLight, random(1)), 0, 2.5);
    }
  }

  void update(float dt) {
    for (Portal q : p) q.update(dt);
    for (int i = waves.size() - 1; i >= 0; i--) {
      Shockwave w = waves.get(i);
      w.age += dt;
      if (w.dead()) waves.remove(i);
    }
  }

  void drawSolid() {
    for (Portal q : p) q.drawSolid();
  }

  void drawGlow() {
    for (Portal q : p) q.drawGlow();
    for (Shockwave w : waves) w.draw();
  }

  // green light spilling out of open portals (uses 2 of the 8 lights)
  void lights() {
    lightFalloff(1, 0, 0.000004);
    for (Portal q : p) {
      if (!q.active) continue;
      float k = q.open * q.pulse();
      PVector lp = PVector.add(q.c, PVector.mult(q.n, 90));
      pointLight(red(q.col) * k, green(q.col) * k, blue(q.col) * k, lp.x, lp.y, lp.z);
    }
  }

  // PassFilter: let a sphere through a wall where a linked portal sits
  boolean passes(Box b, int face, PVector pos, float rad) {
    if (!linked()) return false;
    for (Portal q : p) {
      if (q.box != b || q.face != face) continue;
      PVector l = q.toLocal(pos);
      if (q.insideOval(l.x, l.y, 1)) return true;
    }
    return false;
  }

  // if the segment a->b went in through a portal's front, return that portal
  Portal crossed(PVector a, PVector b) {
    if (!linked()) return null;
    for (Portal q : p) {
      float da = PVector.sub(a, q.c).dot(q.n), db = PVector.sub(b, q.c).dot(q.n);
      if (da >= 0 && db < 0) {
        float t = da / (da - db);
        PVector hit = PVector.lerp(a, b, t);
        PVector l = q.toLocal(hit);
        if (q.insideOval(l.x, l.y, 1)) return q;
      }
    }
    return null;
  }

  // portal transform for a point, a direction
  PVector mapPoint(Portal from, PVector pt, float minOut) {
    Portal to = other(from);
    PVector l = from.toLocal(pt);
    return to.toWorld(new PVector(-l.x, l.y, max(-l.z, minOut)));
  }

  PVector mapDir(Portal from, PVector v) {
    Portal to = other(from);
    PVector l = from.dirToLocal(v);
    return to.dirToWorld(new PVector(-l.x, l.y, -l.z));
  }

  // exitFx: a burst where something comes out
  void exitFx(Portal from, PVector where, float strength) {
    Portal to = other(from);
    waves.add(new Shockwave(PVector.add(to.c, PVector.mult(to.n, 5)), to.r, to.u, PORTAL_HH * 1.6 * strength, 0.4, to.colLight));
    parts.burst(where, int(24 * strength), 380, to.col, 0.7, 20);
  }

  float distance() { return PVector.dist(p[0].c, p[1].c); }

  // angle between the two openings' facing directions, degrees
  float relativeAngle() { return degrees(acos(constrain(p[0].n.dot(p[1].n), -1, 1))); }

  // ray vs portal ovals (for selecting a portal)
  Portal rayPick(PVector o, PVector d, float maxT) {
    Portal best = null;
    float bestT = maxT;
    for (Portal q : p) {
      if (!q.active) continue;
      float den = d.dot(q.n);
      if (den >= -1e-4) continue;                 // must look at its front
      float t = PVector.sub(q.c, o).dot(q.n) / den;
      if (t < 0 || t > bestT) continue;
      PVector l = q.toLocal(PVector.add(o, PVector.mult(d, t)));
      if (q.insideOval(l.x, l.y, 1.15)) {
        best = q;
        bestT = t;
      }
    }
    return best;
  }
}
