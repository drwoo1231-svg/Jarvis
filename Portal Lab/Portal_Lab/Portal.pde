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

  LiquidSurface liquid = new LiquidSurface();
  float rippleAge = 99;         // seconds since something splashed through
  float jig;                    // wobble impulse

  void update(float dt) {
    if (!active) return;
    age += dt;
    open = min(1, open + dt / 0.55);
    rippleAge += dt;
    jig *= exp(-dt * 4);
    if (open < 0.5) return;
    // droplets flung off the spinning rim
    if (random(1) < 0.55) {
      float a = random(TWO_PI);
      PVector p = toWorld(new PVector(cos(a) * PORTAL_HW, sin(a) * PORTAL_HH, 8));
      PVector tangent = dirToWorld(new PVector(sin(a) * PORTAL_HW, -cos(a) * PORTAL_HH, 0)).normalize();
      PVector radial = dirToWorld(new PVector(cos(a) * PORTAL_HH, sin(a) * PORTAL_HW, 0)).normalize();
      PVector v = PVector.mult(tangent, random(120, 260));
      v.add(PVector.mult(radial, random(30, 110))).add(PVector.mult(n, random(60, 160)));
      parts.emit(p, v, random(0.5, 0.9), random(7, 13), lerpColor(col, colLight, random(0.6)), 650, 0.6);
    }
    // glowing motes being sucked into the eye
    if (random(1) < 0.5) {
      float a = random(TWO_PI);
      float rr = random(0.5, 0.95);
      PVector p = toWorld(new PVector(cos(a) * PORTAL_HW * rr, sin(a) * PORTAL_HH * rr, 30));
      PVector v = dirToWorld(new PVector(-cos(a) * 140 + sin(a) * 160, -sin(a) * 140 - cos(a) * 160, -25));
      parts.emit(p, v, random(0.35, 0.6), random(6, 11), colLight, 0, 0.5);
    }
  }

  // something went through: ripple + splash
  void splash(PVector where, float strength) {
    rippleAge = 0;
    jig = min(1.5, jig + strength);
    for (int i = 0; i < 26 * strength; i++) {
      PVector v = PVector.add(PVector.random3D().mult(random(150, 420)), PVector.mult(n, random(100, 380)));
      parts.emit(where, v, random(0.4, 0.9), random(8, 18), lerpColor(col, colLight, random(1)), 650, 0.8);
    }
  }

  float pulse() { return 0.82 + 0.18 * sin(age * 6 + id * 2); }

  float scaleNow() { return easeOutBack(open) * (1 + 0.05 * jig * sin(age * 22)); }

  // multiply the current matrix by the portal frame (local x = r, y = u, z = n)
  void applyFrame(float lift) {
    PVector o = PVector.add(c, PVector.mult(n, lift));
    applyMatrix(r.x, u.x, n.x, o.x,
                r.y, u.y, n.y, o.y,
                r.z, u.z, n.z, o.z,
                0, 0, 0, 1);
  }

  // the liquid vortex (solid pass, unlit, depth-tested)
  void drawSolid() {
    if (!active || open <= 0.01) return;
    float s = scaleNow();
    float lift = 0.8;
    float ripR = rippleAge * 0.9, ripA = rippleAge < 3 ? 9 * exp(-rippleAge * 2.2) : 0;
    float o = smooth01(open);
    boolean gpu = liquidShader != null && liquidMesh != null;
    if (gpu) liquid.buildRim(age);             // the vertex shader shapes the liquid
    else liquid.build(age, o, ripR, ripA);     // CPU fallback: whole height field
    PVector camL = toLocal(cam.pos);
    camL.z -= lift;
    camL.div(s);
    pushMatrix();
    applyFrame(lift);
    scale(s);
    if (gpu) {
      liquidShader.set("time", age);
      liquidShader.set("open", o);
      liquidShader.set("camLocal", camL.x, camL.y, camL.z);
      liquidShader.set("colA", red(col) / 255.0, green(col) / 255.0, blue(col) / 255.0);
      liquidShader.set("colB", red(colLight) / 255.0, green(colLight) / 255.0, blue(colLight) / 255.0);
      liquidShader.set("colC", red(colDark) / 255.0, green(colDark) / 255.0, blue(colDark) / 255.0);
      liquidShader.set("halfSize", PORTAL_HW, PORTAL_HH);
      liquidShader.set("ripR", ripR);
      liquidShader.set("ripA", ripA);
      shader(liquidShader);
      shape(liquidMesh);
      resetShader();
    } else {
      liquid.drawCPU(this, camL, age);
    }
    liquid.drawRim(this, camL, age, o);
    popMatrix();
  }

  // additive part: halo, floating energy rings above the whirlpool, opening flash
  void drawGlow() {
    if (!active || open <= 0.01) return;
    float s = scaleNow(), p = pulse();
    pushMatrix();
    applyFrame(1.5);
    scale(s);
    planeQuad(texGlow, PORTAL_HW * 3.2, PORTAL_HH * 2.8, 0, col, 120 * p);
    if (age < 0.7) planeQuad(texGlow, PORTAL_HW * 7, PORTAL_HH * 6, 0, colLight, 255 * (1 - age / 0.7));
    popMatrix();
    // rotating rings, out past the glossy rim: two counter-rotating in the plane, one tilted and precessing above it
    pushMatrix();
    applyFrame(12);
    scale(s);
    planeQuad(texRingDash, PORTAL_HW * 2.95, PORTAL_HH * 2.75, age * 1.3, col, 170 * p);
    planeQuad(texRingDash, PORTAL_HW * 3.4, PORTAL_HH * 3.15, -age * 0.8, colLight, 110 * p);
    translate(0, 0, 44);
    rotateZ(age * 0.5);
    rotateX(0.33);
    planeQuad(texRingDash, PORTAL_HW * 2.7, PORTAL_HW * 2.7, age * 2.1, colLight, 120 * p);
    popMatrix();
    // energy beads orbiting above the whirlpool, spiralling down into the eye
    for (int k = 0; k < 10; k++) {
      float ph = (age * 0.35 + k / 10.0) % 1.0;           // 0 = outer edge, 1 = in the eye
      float rr = (1 - ph) * 0.95;
      float a = k * TWO_PI / 10 - age * 2.4 - ph * 5;
      float zh = (8 + 40 * sin(PI * (1 - ph)) * (1 - ph)) * s;
      PVector w = toWorld(new PVector(cos(a) * PORTAL_HW * rr * s, sin(a) * PORTAL_HH * rr * s, zh + 2));
      float fade = sin(PI * ph);
      glowSprite(w.x, w.y, w.z, 26, colLight, 230 * fade);
      glowSprite(w.x, w.y, w.z, 60, col, 90 * fade);
    }
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

class Placement {
  PVector c, n, u;
  Box box;
  int face;
  String fail;
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
    Placement pl = tryPlace(which, h, shotDir, 0);
    if (pl.fail != null) return pl.fail;
    Portal q = p[which];
    q.set(pl.c, pl.n, pl.u, pl.box, pl.face);
    q.spin = 0;
    openFx(q);
    return null;
  }

  // work out where a portal would go (without moving it)
  Placement tryPlace(int which, RayHit h, PVector shotDir, float spin) {
    Placement pl = new Placement();
    if (!h.hit()) { pl.fail = "NO SURFACE"; return pl; }
    if (!h.box.portalable(h.face)) { pl.fail = "SURFACE REJECTS PORTALS"; return pl; }
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
    if (spin != 0) {
      PVector rr = n.cross(u);
      u = PVector.add(PVector.mult(u, cos(spin)), PVector.mult(rr, sin(spin))).normalize();
    }
    PVector c = h.p.copy();
    if (!fit(c, n, u, h.box, h.face)) { pl.fail = "NOT ENOUGH ROOM"; return pl; }
    Portal o = p[1 - which];
    if (o.active && o.box == h.box && o.face == h.face) {
      PVector d = PVector.sub(c, o.c);
      float need = PORTAL_HH * 2.05;
      if (d.mag() < need) {
        if (d.magSq() < 1) d = u.copy();
        d.normalize().mult(need);
        c = PVector.add(o.c, d);
        if (!fit(c, n, u, h.box, h.face) || PVector.dist(c, o.c) < need * 0.98) { pl.fail = "TOO CLOSE TO PORTAL " + o.label(); return pl; }
      }
    }
    pl.c = c;
    pl.n = n;
    pl.u = u;
    pl.box = h.box;
    pl.face = h.face;
    return pl;
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
    // slide out from under anything standing on (or hanging over) this face:
    // test panels on the floor, the back wall under the ceiling, ...
    PVector nn = faceNormal(face);
    float side = nn.x + nn.y + nn.z;
    PVector nAx = new PVector(abs(nn.x), abs(nn.y), abs(nn.z));
    for (int iter = 0; iter < 4; iter++) {
      boolean moved = false;
      for (Box o : lab.boxes) {
        if (o == b) continue;
        float lo = o.x0 * nAx.x + o.y0 * nAx.y + o.z0 * nAx.z, hi = o.x1 * nAx.x + o.y1 * nAx.y + o.z1 * nAx.z;
        float probe = plane + side;
        if (probe <= lo || probe >= hi) continue;
        float o1a = e1.x * o.x0 + e1.y * o.y0 + e1.z * o.z0, o1b = e1.x * o.x1 + e1.y * o.y1 + e1.z * o.z1;
        float o2a = e2.x * o.x0 + e2.y * o.y0 + e2.z * o.z0, o2b = e2.x * o.x1 + e2.y * o.y1 + e2.z * o.z1;
        float p1 = min(a + ext1 - o1a, o1b - (a - ext1)), p2 = min(bb + ext2 - o2a, o2b - (bb - ext2));
        if (p1 <= 0 || p2 <= 0) continue;
        if (p1 < p2) a += (a < (o1a + o1b) / 2) ? -p1 : p1;
        else bb += (bb < (o2a + o2b) / 2) ? -p2 : p2;
        moved = true;
      }
      if (!moved) break;
      if (a < rect[0] + ext1 - 0.01 || a > rect[1] - ext1 + 0.01 || bb < rect[2] + ext2 - 0.01 || bb > rect[3] - ext2 + 0.01 || iter == 3) return false;
    }
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

  // a centre that sits just behind a linked portal's mouth (closer than one radius) without having crossed it
  Portal behindMouth(PVector pt, float rad) {
    if (!linked()) return null;
    for (Portal q : p) {
      PVector l = q.toLocal(pt);
      if (l.z < 0 && l.z > -rad && q.insideOval(l.x, l.y, 1)) return q;
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
    to.splash(PVector.add(to.c, PVector.mult(to.n, 12)), strength);
  }

  // the rotation a portal trip applies (for an object's orientation)
  PMatrix3D mapMatrix(Portal from) {
    Portal to = other(from);
    PVector[] a = { from.r, from.u, from.n };
    PVector[] b = { PVector.mult(to.r, -1), to.u, PVector.mult(to.n, -1) };
    float[][] m = new float[3][3];
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        m[i][j] = comp(b[0], i) * comp(a[0], j) + comp(b[1], i) * comp(a[1], j) + comp(b[2], i) * comp(a[2], j);
    return new PMatrix3D(m[0][0], m[0][1], m[0][2], 0, m[1][0], m[1][1], m[1][2], 0, m[2][0], m[2][1], m[2][2], 0, 0, 0, 0, 1);
  }

  float comp(PVector v, int i) { return i == 0 ? v.x : i == 1 ? v.y : v.z; }

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
