// The laboratory: every solid thing is an axis-aligned Box. The same boxes
// are used for drawing, collisions and portal raycasts, so what you see is
// exactly what you can hit. Light panels / floors take portals, dark metal
// and hazard surfaces don't.

final int FACE_NX = 0, FACE_PX = 1, FACE_NY = 2, FACE_PY = 3, FACE_NZ = 4, FACE_PZ = 5;
final int K_FLOOR = 0, K_PANEL = 1, K_METAL = 2, K_HAZARD = 3;

PVector faceNormal(int f) {
  switch (f) {
  case FACE_NX: return new PVector(-1, 0, 0);
  case FACE_PX: return new PVector(1, 0, 0);
  case FACE_NY: return new PVector(0, -1, 0);
  case FACE_PY: return new PVector(0, 1, 0);
  case FACE_NZ: return new PVector(0, 0, -1);
  default:      return new PVector(0, 0, 1);
  }
}

class Box {
  float x0, y0, z0, x1, y1, z1;
  int[] kind = new int[6];          // texture per face
  String name;
  boolean hidden;                   // collider only - drawn by custom code

  Box(String name, float x0, float y0, float z0, float x1, float y1, float z1, int allKind) {
    this.name = name;
    this.x0 = min(x0, x1); this.x1 = max(x0, x1);
    this.y0 = min(y0, y1); this.y1 = max(y0, y1);
    this.z0 = min(z0, z1); this.z1 = max(z0, z1);
    for (int i = 0; i < 6; i++) kind[i] = allKind;
  }

  Box face(int f, int k) { kind[f] = k; return this; }

  Box hide() { hidden = true; return this; }

  boolean portalable(int f) { return kind[f] == K_FLOOR || kind[f] == K_PANEL; }

  // the face rectangle in its two in-plane axes (for fitting portals)
  float[] faceRect(int f) {
    if (f == FACE_NX || f == FACE_PX) return new float[] { y0, y1, z0, z1 };   // axes y,z
    if (f == FACE_NY || f == FACE_PY) return new float[] { x0, x1, z0, z1 };   // axes x,z
    return new float[] { x0, x1, y0, y1 };                                     // axes x,y
  }

  float facePlane(int f) {
    switch (f) {
    case FACE_NX: return x0;
    case FACE_PX: return x1;
    case FACE_NY: return y0;
    case FACE_PY: return y1;
    case FACE_NZ: return z0;
    default:      return z1;
    }
  }
}

class RayHit {
  float t = Float.MAX_VALUE;
  PVector p, n;
  Box box;
  int face = -1;
  boolean hit() { return box != null; }
}

class Laboratory {
  ArrayList<Box> boxes = new ArrayList<Box>();
  PShape shFloor, shPanel, shMetal, shHazard, shDeco;
  ArrayList<float[]> edges = new ArrayList<float[]>();      // glowing edge strips x0,y0,z0,x1,y1,z1
  ArrayList<Sign> signs = new ArrayList<Sign>();
  PShape ring;

  Laboratory() {
    build();
    meshAll();
    ring = makeTorus(1, 0.035, 48, 6);
  }

  Box add(String name, float x0, float y0, float z0, float x1, float y1, float z1, int k) {
    Box b = new Box(name, x0, y0, z0, x1, y1, z1, k);
    boxes.add(b);
    return b;
  }

  void build() {
    // main deck (four slabs around the VOID PIT)
    add("DECK", -2000, 0, -2000, 2000, 80, 200, K_METAL).face(FACE_NY, K_FLOOR);
    add("DECK", -2000, 0, 900, 2000, 80, 2000, K_METAL).face(FACE_NY, K_FLOOR);
    add("DECK", -2000, 0, 200, -350, 80, 900, K_METAL).face(FACE_NY, K_FLOOR);
    add("DECK", 350, 0, 200, 2000, 80, 900, K_METAL).face(FACE_NY, K_FLOOR);
    edges.add(new float[] { -2000, 0, 2000, 2000, 0, 2000 });
    edges.add(new float[] { -2000, 0, -2000, -2000, 0, 2000 });
    edges.add(new float[] { 2000, 0, -2000, 2000, 0, 2000 });
    edges.add(new float[] { -350, 0, 200, 350, 0, 200 });
    edges.add(new float[] { -350, 0, 900, 350, 0, 900 });
    edges.add(new float[] { -350, 0, 200, -350, 0, 900 });
    edges.add(new float[] { 350, 0, 200, 350, 0, 900 });

    // walls and the ceiling over the back of the lab
    add("BACK WALL", -2000, -1400, -2080, 2000, 0, -2000, K_METAL).face(FACE_PZ, K_PANEL);
    add("CEILING", -2000, -1480, -2080, 2000, -1400, -1000, K_METAL).face(FACE_PY, K_PANEL);
    add("LEFT WALL", -2080, -1400, -2000, -2000, 0, -500, K_METAL).face(FACE_PX, K_PANEL);
    add("RIGHT WALL", 2000, -1400, -2000, 2080, 0, -500, K_METAL).face(FACE_NX, K_PANEL);
    add("PILLAR", -740, -1400, -1060, -660, 0, -1000, K_METAL);
    add("PILLAR", 660, -1400, -1060, 740, 0, -1000, K_METAL);
    edges.add(new float[] { -2000, -1400, -1000, 2000, -1400, -1000 });

    // portal testing chamber: free-standing panels
    add("TEST PANEL", -1100, -800, -500, -500, 0, -460, K_METAL).face(FACE_NZ, K_PANEL).face(FACE_PZ, K_PANEL);
    add("TEST PANEL", 500, -800, -500, 1100, 0, -460, K_METAL).face(FACE_NZ, K_PANEL).face(FACE_PZ, K_PANEL);
    add("TEST PANEL", -1500, -600, 300, -1460, 0, 1100, K_METAL).face(FACE_NX, K_PANEL).face(FACE_PX, K_PANEL);
    add("TEST PANEL", 1460, -600, 300, 1500, 0, 1100, K_METAL).face(FACE_NX, K_PANEL).face(FACE_PX, K_PANEL);
    add("DROP TOWER", 1100, -900, -1500, 1500, 0, -1100, K_PANEL).face(FACE_NY, K_FLOOR);

    // machines and storage (no portals on these)
    add("CALIBRATION PLINTH", -400, -120, -1350, 400, 0, -1050, K_METAL);
    add("RESEARCH CONSOLE", 900, -110, -1950, 1700, 0, -1720, K_METAL);
    add("CONTAINMENT BARRIER", -2000, -320, -1200, -1150, 0, -1160, K_HAZARD);
    add("MATTER DISPENSER", -1850, -260, 1450, -1550, 0, 1750, K_METAL);
    add("QUANTUM PEDESTAL", 1580, -100, 380, 1700, 0, 500, K_METAL);
    add("QUANTUM PEDESTAL", 1780, -100, 580, 1900, 0, 700, K_METAL);
    add("QUANTUM PEDESTAL", 1580, -100, 760, 1700, 0, 880, K_METAL);
    add("GENERATOR", -1830, -900, 1770, -1670, 0, 1930, K_METAL).hide();
    add("GENERATOR", 1670, -900, 1770, 1830, 0, 1930, K_METAL).hide();

    // floating platforms out in space
    add("ORBITAL TEST PLATFORM", 2700, -560, -900, 3700, -480, 300, K_METAL).face(FACE_NY, K_FLOOR);
    add("ORBITAL TEST WALL", 3620, -1300, -900, 3700, -560, 300, K_METAL).face(FACE_NX, K_PANEL);
    add("OBSERVATION DECK", -3900, -980, -600, -2800, -900, 500, K_METAL).face(FACE_NY, K_FLOOR);
    add("HIGH PLATFORM", -600, -2500, 500, 600, -2420, 1500, K_METAL).face(FACE_NY, K_FLOOR).face(FACE_PY, K_PANEL);
    add("SUB-DECK", -700, 1500, 0, 700, 1580, 1300, K_METAL).face(FACE_NY, K_FLOOR);
    edges.add(new float[] { 2700, -560, 300, 3700, -560, 300 });
    edges.add(new float[] { -3900, -980, 500, -2800, -980, 500 });
    edges.add(new float[] { -600, -2500, 1500, 600, -2500, 1500 });
    edges.add(new float[] { -700, 1500, 1300, 700, 1500, 1300 });

    signs.add(new Sign("PORTAL TESTING CHAMBER", "AUTHORISED GENIUSES ONLY", color(120, 255, 140), 0, -1180, -1995, 0, 900));
    signs.add(new Sign("UNSTABLE MATTER STORAGE", "DO NOT TOUCH", color(255, 90, 70), -1575, -560, -1150, 0, 560));
    signs.add(new Sign("QUANTUM OBJECT STORAGE", "STATUS: PROBABLY SAFE", color(170, 140, 255), 1960, -420, 630, -HALF_PI, 560));
    signs.add(new Sign("SPACETIME CALIBRATION", "DO NOT LOOK DIRECTLY AT THE GYRO", color(120, 220, 255), 0, -760, -1040, 0, 600));
    signs.add(new Sign("VOID PIT", "DO NOT LEAN.  SERIOUSLY.", color(255, 200, 80), 0, -230, 905, 0, 420));
    signs.add(new Sign("MATTER DISPENSER", "PRESS E FOR STUFF", color(120, 255, 200), -1700, -470, 1760, 0, 380));
    signs.add(new Sign("ORBITAL TEST PLATFORM", "GRAVITY: ON (MOSTLY)", color(120, 255, 140), 3200, -900, 310, 0, 520));
    signs.add(new Sign("PROBABLY SAFE", null, color(170, 255, 170), -800, -900, -455, 0, 300));
  }

  // ---------------------------------------------------------------- meshing
  void meshAll() {
    shFloor = beginMesh(texFloor);
    shPanel = beginMesh(texPanel);
    shMetal = beginMesh(texMetal);
    shHazard = beginMesh(texHazard);
    for (Box b : boxes) {
      if (b.hidden) continue;
      for (int f = 0; f < 6; f++) {
        PShape s = b.kind[f] == K_FLOOR ? shFloor : b.kind[f] == K_PANEL ? shPanel : b.kind[f] == K_HAZARD ? shHazard : shMetal;
        meshFace(s, b, f, b.kind[f] == K_HAZARD ? 160 : 240);
      }
    }
    shFloor.endShape();
    shPanel.endShape();
    shMetal.endShape();
    shHazard.endShape();
  }

  PShape beginMesh(PImage tex) {
    PShape s = createShape();
    s.beginShape(QUADS);
    s.noStroke();
    s.texture(tex);
    s.fill(255);
    return s;
  }

  // a face split into tiles (so per-vertex lighting looks right), UVs in world space
  void meshFace(PShape s, Box b, int f, float tile) {
    float[] r = b.faceRect(f);
    float plane = b.facePlane(f);
    PVector n = faceNormal(f);
    int nu = max(1, ceil((r[1] - r[0]) / 200)), nv = max(1, ceil((r[3] - r[2]) / 200));
    for (int i = 0; i < nu; i++) {
      for (int j = 0; j < nv; j++) {
        float a0 = lerp(r[0], r[1], i / (float) nu), a1 = lerp(r[0], r[1], (i + 1) / (float) nu);
        float c0 = lerp(r[2], r[3], j / (float) nv), c1 = lerp(r[2], r[3], (j + 1) / (float) nv);
        s.normal(n.x, n.y, n.z);
        faceVertex(s, f, plane, a0, c0, tile);
        faceVertex(s, f, plane, a1, c0, tile);
        faceVertex(s, f, plane, a1, c1, tile);
        faceVertex(s, f, plane, a0, c1, tile);
      }
    }
  }

  void faceVertex(PShape s, int f, float plane, float a, float c, float tile) {
    if (f == FACE_NX || f == FACE_PX) s.vertex(plane, a, c, c / tile, a / tile);
    else if (f == FACE_NY || f == FACE_PY) s.vertex(a, plane, c, a / tile, c / tile);
    else s.vertex(a, c, plane, a / tile, c / tile);
  }

  // ring (torus) mesh of radius 1 for machines
  PShape makeTorus(float R, float r, int seg, int sides) {
    PShape s = createShape();
    s.beginShape(QUADS);
    s.noStroke();
    for (int i = 0; i < seg; i++) {
      float a0 = TWO_PI * i / seg, a1 = TWO_PI * (i + 1) / seg;
      for (int j = 0; j < sides; j++) {
        float b0 = TWO_PI * j / sides, b1 = TWO_PI * (j + 1) / sides;
        torusV(s, R, r, a0, b0);
        torusV(s, R, r, a1, b0);
        torusV(s, R, r, a1, b1);
        torusV(s, R, r, a0, b1);
      }
    }
    s.endShape();
    return s;
  }

  void torusV(PShape s, float R, float r, float a, float b) {
    float cx = cos(a), cz = sin(a);
    s.normal(cos(b) * cx, sin(b), cos(b) * cz);
    s.vertex((R + r * cos(b)) * cx, r * sin(b), (R + r * cos(b)) * cz);
  }

  // ---------------------------------------------------------------- per frame
  void update(float dt) {
  }

  void lightsOn() {
    lightFalloff(1, 0, 0);
    ambientLight(58, 62, 78);
    directionalLight(250, 236, 214, -0.35, 0.85, -0.4);
    directionalLight(70, 90, 150, 0.4, -0.7, 0.6);
    lightFalloff(1, 0, 0.0000016);
    pointLight(60, 255, 120, -1750, -400, 1850);
    pointLight(60, 255, 120, 1750, -400, 1850);
    pointLight(255, 70, 60, -1600, -300, -1600);
  }

  void drawSolid() {
    shape(shFloor);
    shape(shPanel);
    shape(shMetal);
    shape(shHazard);
    drawMachines();
  }

  void drawMachines() {
    // generators: a glowing core column with spinning rings
    for (int s = -1; s <= 1; s += 2) {
      pushMatrix();
      translate(s * 1750, -450, 1850);
      noStroke();
      fill(40, 44, 52);
      emissive(20, 160, 60);
      drawCylinder(70, 900, 16);
      emissive(0);
      for (int i = 0; i < 3; i++) {
        pushMatrix();
        translate(0, 300 - i * 250, 0);
        rotateY(T * (1.2 + i * 0.7) * s);
        rotateX(sin(T + i) * 0.25);
        scale(150 + i * 10);
        fill(120, 130, 140);
        emissive(10, 90, 40);
        shape(ring);
        emissive(0);
        popMatrix();
      }
      popMatrix();
    }
    // spacetime calibration gyroscope above the plinth
    pushMatrix();
    translate(0, -420, -1200);
    for (int i = 0; i < 3; i++) {
      pushMatrix();
      if (i == 0) rotateX(T * 0.8);
      if (i == 1) { rotateZ(T * 1.1); rotateX(HALF_PI); }
      if (i == 2) { rotateY(T * 0.6); rotateZ(HALF_PI); }
      scale(260 - i * 55);
      fill(200, 210, 230);
      emissive(30, 70, 110);
      shape(ring);
      emissive(0);
      popMatrix();
    }
    fill(30, 40, 60);
    emissive(60, 160, 255);
    sphere(60);
    emissive(0);
    popMatrix();
    // containment pods in unstable storage
    for (int i = 0; i < 3; i++) {
      pushMatrix();
      translate(-1850 + i * 260, -40, -1700);
      fill(50, 54, 62);
      drawCylinder(95, 40, 14);
      translate(0, -460, 0);
      drawCylinder(95, 40, 14);
      popMatrix();
    }
    // console screens frame
    pushMatrix();
    translate(1300, -110, -1835);
    fill(35, 38, 46);
    box(760, 30, 200);
    popMatrix();
  }

  // vertical cylinder centred on the origin
  void drawCylinder(float r, float h, int seg) {
    beginShape(QUAD_STRIP);
    for (int i = 0; i <= seg; i++) {
      float a = TWO_PI * i / seg;
      normal(cos(a), 0, sin(a));
      vertex(cos(a) * r, -h / 2, sin(a) * r);
      vertex(cos(a) * r, h / 2, sin(a) * r);
    }
    endShape();
    beginShape(TRIANGLE_FAN);
    normal(0, -1, 0);
    vertex(0, -h / 2, 0);
    for (int i = 0; i <= seg; i++) vertex(cos(TWO_PI * i / seg) * r, -h / 2, sin(TWO_PI * i / seg) * r);
    endShape();
  }

  void drawGlow() {
    // edge strips
    strokeWeight(2.5);
    for (float[] e : edges) {
      stroke(80, 220, 255, 150 + 60 * sin(T * 2 + e[0] * 0.001));
      line(e[0], e[1] - 1, e[2], e[3], e[4] - 1, e[5]);
    }
    noStroke();
    // generator cores
    for (int s = -1; s <= 1; s += 2) {
      for (int i = 0; i < 4; i++) glowSprite(s * 1750, -200 - i * 200, 1850, 420 + 60 * sin(T * 3 + i), color(60, 255, 120), 90);
    }
    // containment pod glass + unstable blobs
    for (int i = 0; i < 3; i++) {
      float x = -1850 + i * 260;
      float wob = sin(T * 3 + i * 2);
      glowSprite(x + wob * 20, -270 + cos(T * 2.3 + i) * 30, -1700, 160 + 40 * wob, color(255, 80 + i * 40, 60), 190);
      noFill();
      stroke(160, 220, 255, 70);
      strokeWeight(1.5);
      for (int k = 0; k < 2; k++) {
        float y = k == 0 ? -60 : -480;
        beginShape();
        for (int j = 0; j <= 20; j++) vertex(x + cos(TWO_PI * j / 20) * 90, y, -1700 + sin(TWO_PI * j / 20) * 90);
        endShape();
      }
      for (int j = 0; j < 6; j++) {
        float a = TWO_PI * j / 6;
        line(x + cos(a) * 90, -60, -1700 + sin(a) * 90, x + cos(a) * 90, -480, -1700 + sin(a) * 90);
      }
      noStroke();
    }
    // gyroscope core glow
    glowSprite(0, -420, -1200, 420 + 50 * sin(T * 2), color(80, 170, 255), 150);
    for (Sign s : signs) s.draw();
  }

  // ---------------------------------------------------------------- physics queries
  // push a sphere out of every box; returns the last contact normal (or null).
  // skip, if given, may let the sphere pass through a box face (portals).
  PVector collideSphere(PVector p, PVector v, float r, PassFilter skip) {
    PVector contact = null;
    for (Box b : boxes) {
      if (p.x < b.x0 - r || p.x > b.x1 + r || p.y < b.y0 - r || p.y > b.y1 + r || p.z < b.z0 - r || p.z > b.z1 + r) continue;
      float qx = constrain(p.x, b.x0, b.x1), qy = constrain(p.y, b.y0, b.y1), qz = constrain(p.z, b.z0, b.z1);
      float dx = p.x - qx, dy = p.y - qy, dz = p.z - qz;
      float d2 = dx * dx + dy * dy + dz * dz;
      if (d2 > r * r) continue;
      PVector n;
      float pen;
      if (d2 > 1e-6) {
        float d = sqrt(d2);
        n = new PVector(dx / d, dy / d, dz / d);
        pen = r - d;
      } else {
        // centre is inside the box: leave by the nearest face
        float[] ds = { p.x - b.x0, b.x1 - p.x, p.y - b.y0, b.y1 - p.y, p.z - b.z0, b.z1 - p.z };
        int best = 0;
        for (int i = 1; i < 6; i++) if (ds[i] < ds[best]) best = i;
        n = faceNormal(best);
        pen = ds[best] + r;
      }
      int face = dominantFace(n);
      if (skip != null && skip.passes(b, face, p, r)) continue;
      p.add(PVector.mult(n, pen));
      float vn = v.dot(n);
      if (vn < 0) v.sub(PVector.mult(n, vn));
      contact = n;
    }
    return contact;
  }

  // bounce a moving body off the lab: restitution e, friction mu (per second), substep h.
  // Returns the hardest impact speed this step (0 = no contact); nOut = contact normal.
  float collideBody(PVector p, PVector v, float r, float e, float mu, float h, PassFilter skip, PVector nOut) {
    float impact = 0;
    for (Box b : boxes) {
      if (p.x < b.x0 - r || p.x > b.x1 + r || p.y < b.y0 - r || p.y > b.y1 + r || p.z < b.z0 - r || p.z > b.z1 + r) continue;
      float qx = constrain(p.x, b.x0, b.x1), qy = constrain(p.y, b.y0, b.y1), qz = constrain(p.z, b.z0, b.z1);
      float dx = p.x - qx, dy = p.y - qy, dz = p.z - qz;
      float d2 = dx * dx + dy * dy + dz * dz;
      if (d2 > r * r) continue;
      PVector n;
      float pen;
      if (d2 > 1e-6) {
        float d = sqrt(d2);
        n = new PVector(dx / d, dy / d, dz / d);
        pen = r - d;
      } else {
        float[] ds = { p.x - b.x0, b.x1 - p.x, p.y - b.y0, b.y1 - p.y, p.z - b.z0, b.z1 - p.z };
        int best = 0;
        for (int i = 1; i < 6; i++) if (ds[i] < ds[best]) best = i;
        n = faceNormal(best);
        pen = ds[best] + r;
      }
      if (skip != null && skip.passes(b, dominantFace(n), p, r)) continue;
      p.add(PVector.mult(n, pen));
      float vn = v.dot(n);
      if (vn < 0) {
        impact = max(impact, -vn);
        PVector vt = PVector.sub(v, PVector.mult(n, vn));
        vt.mult(exp(-mu * h * 6));
        float out = -vn * e;
        if (out < 40) out = 0;                     // settle instead of jittering
        v.set(PVector.add(vt, PVector.mult(n, out)));
        nOut.set(n);
      }
    }
    return impact;
  }

  int dominantFace(PVector n) {
    float ax = abs(n.x), ay = abs(n.y), az = abs(n.z);
    if (ax >= ay && ax >= az) return n.x < 0 ? FACE_NX : FACE_PX;
    if (ay >= az) return n.y < 0 ? FACE_NY : FACE_PY;
    return n.z < 0 ? FACE_NZ : FACE_PZ;
  }

  // nearest box face hit by a ray (slab method)
  RayHit raycast(PVector o, PVector d, float maxT) {
    RayHit best = new RayHit();
    best.t = maxT;
    for (Box b : boxes) {
      float tmin = -Float.MAX_VALUE, tmax = Float.MAX_VALUE;
      int face = -1;
      float[] lo = { b.x0, b.y0, b.z0 }, hi = { b.x1, b.y1, b.z1 };
      float[] oo = { o.x, o.y, o.z }, dd = { d.x, d.y, d.z };
      boolean miss = false;
      for (int a = 0; a < 3; a++) {
        if (abs(dd[a]) < 1e-9) {
          if (oo[a] < lo[a] || oo[a] > hi[a]) { miss = true; break; }
          continue;
        }
        float t1 = (lo[a] - oo[a]) / dd[a], t2 = (hi[a] - oo[a]) / dd[a];
        int f1 = a * 2, f2 = a * 2 + 1;        // entering through the low face has normal -axis
        if (t1 > t2) { float tt = t1; t1 = t2; t2 = tt; int ff = f1; f1 = f2; f2 = ff; }
        if (t1 > tmin) { tmin = t1; face = f1; }
        if (t2 < tmax) tmax = t2;
        if (tmin > tmax) { miss = true; break; }
      }
      if (miss || face < 0 || tmin < 0 || tmin >= best.t) continue;
      best.t = tmin;
      best.box = b;
      best.face = face;
    }
    if (best.box != null) {
      best.p = PVector.add(o, PVector.mult(d, best.t));
      best.n = faceNormal(best.face);
    }
    return best;
  }
}

interface PassFilter {
  boolean passes(Box b, int face, PVector p, float r);
}

// floating holographic sign (drawn in the glow pass)
class Sign {
  PImage img;
  float x, y, z, rotY, w;

  Sign(String title, String sub, int c, float x, float y, float z, float rotY, float w) {
    img = makeSign(title, sub, c);
    this.x = x;
    this.y = y;
    this.z = z;
    this.rotY = rotY;
    this.w = w;
  }

  void draw() {
    float h = w * img.height / img.width;
    pushMatrix();
    translate(x, y + sin(T * 1.3 + x * 0.01) * 8, z);
    rotateY(rotY);
    // readable from both sides
    if ((cam.pos.x - x) * sin(rotY) + (cam.pos.z - z) * cos(rotY) < 0) rotateY(PI);
    noStroke();
    tint(255, 200 + 55 * sin(T * 9 + x) * sin(T * 3.1));
    beginShape(QUADS);
    texture(img);
    vertex(-w / 2, -h / 2, 0, 0, 0);
    vertex(w / 2, -h / 2, 0, 1, 0);
    vertex(w / 2, h / 2, 0, 1, 1);
    vertex(-w / 2, h / 2, 0, 0, 1);
    endShape();
    noTint();
    popMatrix();
  }
}
