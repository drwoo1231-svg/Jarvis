// The universe outside: a camera-centred sky (stars, galaxies, nebulae,
// planets) that never moves when you fly - only rotates when you look -
// plus world-space asteroids and cosmic dust that do give parallax.

class Galaxy {
  final float SKY = 45000;              // sky sphere radius (inside the far plane)
  PShape stars, dust;
  ArrayList<PVector> brightStars = new ArrayList<PVector>();
  PImage[] galTex = new PImage[3], nebTex = new PImage[6];
  ArrayList<SkyBill> bills = new ArrayList<SkyBill>();
  PShape[] planet = new PShape[3];
  PVector[] planetDir = new PVector[3];
  float[] planetSize = { 5200, 2600, 1500 };
  PImage ringTex;
  PVector sunDir = new PVector(0.55, -0.35, -0.75);
  PShape[] rockMesh = new PShape[3];
  Rock[] rocks = new Rock[70];

  Galaxy() {
    sunDir.normalize();
    buildStars();
    for (int i = 0; i < 3; i++) galTex[i] = makeGalaxyTex(256, i);
    int[][][] pal = {
      { { 140, 40, 200 }, { 255, 90, 160 } }, { { 30, 90, 200 }, { 80, 230, 255 } }, { { 200, 50, 80 }, { 255, 170, 90 } },
      { { 20, 140, 120 }, { 120, 255, 200 } }, { { 90, 50, 220 }, { 170, 140, 255 } }, { { 180, 70, 30 }, { 255, 220, 140 } }
    };
    for (int i = 0; i < 6; i++) nebTex[i] = makeNebulaTex(256, i, pal[i][0], pal[i][1]);
    randomSeed(5);
    for (int i = 0; i < 12; i++) {
      PVector d = PVector.random3D();
      bills.add(new SkyBill(nebTex[i % 6], d, random(26000, 52000), random(TWO_PI), color(255), random(170, 255)));
    }
    // the milky band: a chain of soft clouds along a great circle
    PVector ba = new PVector(1, 0.35, 0.2).normalize(), bb = ba.cross(new PVector(0, 0, 1)).normalize();
    for (int i = 0; i < 16; i++) {
      float t = TWO_PI * i / 16 + random(-0.1, 0.1);
      PVector d = PVector.add(PVector.mult(ba, cos(t)), PVector.mult(bb, sin(t)));
      bills.add(new SkyBill(nebTex[i % 2 == 0 ? 1 : 4], d, random(20000, 30000), random(TWO_PI), color(200, 210, 255), random(90, 140)));
    }
    for (int i = 0; i < 10; i++) {
      PVector d = PVector.random3D();
      bills.add(new SkyBill(galTex[i % 3], d, random(4500, 11000), random(TWO_PI), color(255), random(190, 255)));
    }
    // one big spiral galaxy hanging near the horizon
    bills.add(new SkyBill(galTex[0], new PVector(-0.2, 0.05, 1).normalize(), 26000, 0.5, color(255), 255));
    for (int i = 0; i < 40; i++) brightStars.add(PVector.random3D());
    randomSeed(millis());
    planetDir[0] = new PVector(-0.75, -0.18, -0.65).normalize();
    planetDir[1] = new PVector(0.82, 0.25, 0.5).normalize();
    planetDir[2] = new PVector(0.3, -0.55, 0.78).normalize();
    for (int i = 0; i < 3; i++) {
      planet[i] = createShape(SPHERE, 1);
      planet[i].setStroke(false);
      planet[i].setTexture(makePlanetTex(256, 128, i));
    }
    ringTex = makeRingBands();
    for (int i = 0; i < 3; i++) rockMesh[i] = makeRock(i);
    for (int i = 0; i < rocks.length; i++) rocks[i] = new Rock(i);
    buildDust();
  }

  void buildStars() {
    stars = createShape();
    stars.beginShape(POINTS);
    for (int i = 0; i < 3200; i++) {
      PVector d = PVector.random3D();
      float k = random(1);
      int c = k < 0.65 ? color(255) : k < 0.82 ? color(175, 200, 255) : k < 0.94 ? color(255, 225, 180) : color(255, 170, 170);
      float w = random(1) < 0.04 ? random(2.6, 3.6) : random(0.9, 2.2);
      stars.stroke(red(c), green(c), blue(c), random(120, 255));
      stars.strokeWeight(w);
      stars.vertex(d.x * SKY, d.y * SKY, d.z * SKY);
    }
    // a faint milky band along a tilted great circle
    PVector a = new PVector(1, 0.35, 0.2).normalize(), b = a.cross(new PVector(0, 0, 1)).normalize();
    for (int i = 0; i < 2600; i++) {
      float t = random(TWO_PI);
      PVector d = PVector.add(PVector.mult(a, cos(t)), PVector.mult(b, sin(t)));
      d.add(PVector.random3D().mult(randomGaussian() * 0.07)).normalize();
      stars.stroke(220, 225, 255, random(60, 170));
      stars.strokeWeight(random(0.8, 1.6));
      stars.vertex(d.x * SKY, d.y * SKY, d.z * SKY);
    }
    stars.endShape();
  }

  void buildDust() {
    dust = createShape();
    dust.beginShape(POINTS);
    for (int i = 0; i < 450; i++) {
      dust.stroke(150, 190, 255, random(40, 110));
      dust.strokeWeight(random(1, 2.2));
      dust.vertex(random(-7000, 7000), random(-4000, 3500), random(-7000, 7000));
    }
    dust.endShape();
  }

  void update(float dt) {
    for (Rock r : rocks) r.update(dt);
  }

  // drawn first, centred on the camera, so it can never be flown past
  void drawSky(PVector eye) {
    pushMatrix();
    translate(eye.x, eye.y, eye.z);
    noLights();
    shape(stars);

    hint(DISABLE_DEPTH_MASK);
    blendMode(ADD);
    for (SkyBill b : bills) b.draw(SKY);
    // a few bright stars with diffraction spikes
    for (int i = 0; i < brightStars.size(); i++) {
      PVector p = PVector.mult(brightStars.get(i), SKY * 0.97);
      float tw = 0.75 + 0.25 * sin(T * (1 + i % 5) + i);
      skyGlow(p, 900 + (i % 4) * 300, i % 3 == 0 ? color(170, 200, 255) : color(255, 235, 210), 230 * tw);
      skySpikes(p, 2600 + (i % 3) * 900, 160 * tw);
    }
    // the nearby star that lights the lab
    PVector s = PVector.mult(sunDir, SKY * 0.98);
    skyGlow(s, 9000, color(255, 220, 170), 255);
    skyGlow(s, 2600, color(255, 250, 235), 255);
    blendMode(BLEND);
    hint(ENABLE_DEPTH_MASK);

    // planets are lit by that star
    lightFalloff(1, 0, 0);
    ambientLight(18, 18, 28);
    directionalLight(255, 245, 230, -sunDir.x, -sunDir.y, -sunDir.z);
    for (int i = 0; i < 3; i++) {
      pushMatrix();
      PVector p = PVector.mult(planetDir[i], SKY * 0.85);
      translate(p.x, p.y, p.z);
      rotateY(T * 0.01 * (i + 1));
      rotateZ(0.3 - i * 0.2);
      scale(planetSize[i]);
      shape(planet[i]);
      if (i == 0) drawRings();
      popMatrix();
    }
    noLights();
    popMatrix();
  }

  void drawRings() {
    noStroke();
    rotateX(0.35);
    beginShape(QUAD_STRIP);
    texture(ringTex);
    for (int i = 0; i <= 64; i++) {
      float a = TWO_PI * i / 64;
      vertex(cos(a) * 1.35, 0, sin(a) * 1.35, 0, 0);
      vertex(cos(a) * 2.3, 0, sin(a) * 2.3, 1, 0);
    }
    endShape();
  }

  void skyGlow(PVector p, float size, int c, float a) {
    PVector d = p.copy().normalize();
    PVector ax = d.cross(new PVector(0, 1, 0));
    if (ax.magSq() < 0.01) ax = d.cross(new PVector(1, 0, 0));
    ax.normalize().mult(size / 2);
    PVector ay = d.cross(ax).normalize().mult(size / 2);
    tint(red(c), green(c), blue(c), a);
    beginShape(QUADS);
    texture(texGlow);
    vertex(p.x - ax.x - ay.x, p.y - ax.y - ay.y, p.z - ax.z - ay.z, 0, 0);
    vertex(p.x + ax.x - ay.x, p.y + ax.y - ay.y, p.z + ax.z - ay.z, 1, 0);
    vertex(p.x + ax.x + ay.x, p.y + ax.y + ay.y, p.z + ax.z + ay.z, 1, 1);
    vertex(p.x - ax.x + ay.x, p.y - ax.y + ay.y, p.z - ax.z + ay.z, 0, 1);
    endShape();
    noTint();
  }

  // thin cross-shaped flare through a bright star
  void skySpikes(PVector p, float len, float a) {
    PVector d = p.copy().normalize();
    PVector ax = d.cross(new PVector(0, 1, 0));
    if (ax.magSq() < 0.01) ax = d.cross(new PVector(1, 0, 0));
    ax.normalize();
    PVector ay = d.cross(ax).normalize();
    stroke(220, 235, 255, a);
    strokeWeight(1.2);
    line(p.x - ax.x * len, p.y - ax.y * len, p.z - ax.z * len, p.x + ax.x * len, p.y + ax.y * len, p.z + ax.z * len);
    line(p.x - ay.x * len, p.y - ay.y * len, p.z - ay.z * len, p.x + ay.x * len, p.y + ay.y * len, p.z + ay.z * len);
    noStroke();
  }

  // asteroids (world space, lit)
  void drawWorld() {
    for (Rock r : rocks) r.draw();
  }

  // cosmic dust (inside the glow pass)
  void drawDust() {
    pushMatrix();
    translate(sin(T * 0.05) * 300, cos(T * 0.04) * 150, T * 25 % 2000);
    shape(dust);
    popMatrix();
  }

  // ---------------------------------------------------------------- textures
  PImage makeGalaxyTex(int s, int seed) {
    randomSeed(100 + seed);
    float[] acc = new float[s * s * 3];
    int arms = 2 + seed % 2;
    float tight = 0.35 + seed * 0.12;
    float[] tintA = { 1, 0.85, 0.7 }, tintB = seed == 1 ? new float[] { 0.7, 0.8, 1 } : new float[] { 0.85, 0.75, 1 };
    for (int i = 0; i < 26000; i++) {
      float r = pow(random(1), 1.7) * s * 0.46;
      int arm = int(random(arms));
      float a = arm * TWO_PI / arms + log(1 + r) / tight + randomGaussian() * 0.32 * (0.3 + r / (s * 0.46));
      float x = s / 2 + cos(a) * r, y = s / 2 + sin(a) * r * 0.62;
      int px = int(x), py = int(y);
      if (px < 0 || py < 0 || px >= s || py >= s) continue;
      float k = r / (s * 0.46);
      for (int c = 0; c < 3; c++) acc[(py * s + px) * 3 + c] += lerp(tintA[c], tintB[c], k) * 0.55;
    }
    PImage img = createImage(s, s, RGB);
    img.loadPixels();
    for (int y = 0; y < s; y++) {
      for (int x = 0; x < s; x++) {
        float dx = (x - s / 2) / (s * 0.5), dy = (y - s / 2) / (s * 0.31);
        float core = exp(-(dx * dx + dy * dy) * 40) * 1.6 + exp(-(dx * dx + dy * dy) * 6) * 0.25;
        int i = (y * s + x) * 3;
        float edge = constrain(1.2 - sqrt(dx * dx * 0.8 + dy * dy * 0.35), 0, 1);
        img.pixels[y * s + x] = color(255 * min(1, (acc[i] + core) * edge), 255 * min(1, (acc[i + 1] + core * 0.95) * edge), 255 * min(1, (acc[i + 2] + core * 0.85) * edge));
      }
    }
    img.updatePixels();
    randomSeed(millis());
    return img;
  }

  // colourful wispy cloud: domain-warped noise, two-colour gradient, soft round edge
  PImage makeNebulaTex(int s, int seed, int[] ca, int[] cb) {
    noiseSeed(7 + seed * 13);
    PImage img = createImage(s, s, RGB);
    img.loadPixels();
    for (int y = 0; y < s; y++) {
      for (int x = 0; x < s; x++) {
        float dx = (x - s / 2) / (s * 0.5), dy = (y - s / 2) / (s * 0.5);
        float fall = constrain(1 - sqrt(dx * dx + dy * dy), 0, 1);
        float wx = x + 60 * (noise(x * 0.01, y * 0.01, seed) - 0.5);
        float wy = y + 60 * (noise(x * 0.01 + 7, y * 0.01, seed) - 0.5);
        float n = 0, amp = 0.55, f = 0.011;
        for (int o = 0; o < 5; o++) {
          n += noise(wx * f, wy * f, seed * 3.1 + o) * amp;
          amp *= 0.5;
          f *= 2.05;
        }
        float v = constrain((n - 0.33) * 2.6, 0, 1) * pow(fall, 1.4);
        float k = constrain((n - 0.4) * 3, 0, 1);
        float r = lerp(ca[0], cb[0], k), g = lerp(ca[1], cb[1], k), b = lerp(ca[2], cb[2], k);
        img.pixels[y * s + x] = color(r * v, g * v, b * v);
      }
    }
    img.updatePixels();
    noiseSeed(millis());
    return img;
  }

  PImage makePlanetTex(int w, int h, int kind) {
    noiseSeed(40 + kind);
    PImage img = createImage(w, h, RGB);
    img.loadPixels();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        float lat = y / (float) h;
        float lon = x / (float) w * TWO_PI;
        float nx = cos(lon) * 1.5, nz = sin(lon) * 1.5;
        int c;
        if (kind == 0) {          // banded gas giant
          float band = sin(lat * 26 + noise(nx, lat * 6, nz) * 5) * 0.5 + 0.5;
          c = lerpColor(color(196, 150, 110), color(235, 214, 180), band);
          c = lerpColor(c, color(150, 90, 70), noise(nx * 2, lat * 14, nz * 2) * 0.5);
        } else if (kind == 1) {   // rusty rock world
          float n = noise(nx * 2, lat * 5, nz * 2);
          c = lerpColor(color(110, 45, 35), color(205, 110, 70), n);
          if (noise(nx * 6, lat * 16, nz * 6) > 0.68) c = lerpColor(c, color(60, 25, 20), 0.6);
        } else {                  // ice world
          float n = noise(nx * 2.5, lat * 6, nz * 2.5);
          c = lerpColor(color(90, 150, 210), color(225, 240, 255), n);
          if (lat < 0.12 || lat > 0.88) c = color(240, 248, 255);
        }
        img.pixels[y * w + x] = c;
      }
    }
    img.updatePixels();
    noiseSeed(millis());
    return img;
  }

  PImage makeRingBands() {
    PImage img = createImage(128, 4, ARGB);
    img.loadPixels();
    for (int x = 0; x < 128; x++) {
      float u = x / 127.0;
      float a = (0.35 + 0.65 * noise(u * 18)) * sin(PI * u);
      if (u > 0.55 && u < 0.6) a *= 0.15;
      for (int y = 0; y < 4; y++) img.pixels[y * 128 + x] = color(225, 200, 170, 200 * a);
    }
    img.updatePixels();
    return img;
  }

  // low-poly rock: icosahedron, subdivided once, pushed around with noise
  PShape makeRock(int seed) {
    noiseSeed(90 + seed);
    float t = (1 + sqrt(5)) / 2;
    ArrayList<PVector> v = new ArrayList<PVector>();
    float[][] base = { { -1, t, 0 }, { 1, t, 0 }, { -1, -t, 0 }, { 1, -t, 0 }, { 0, -1, t }, { 0, 1, t }, { 0, -1, -t }, { 0, 1, -t }, { t, 0, -1 }, { t, 0, 1 }, { -t, 0, -1 }, { -t, 0, 1 } };
    for (float[] p : base) v.add(new PVector(p[0], p[1], p[2]).normalize());
    int[][] f = { { 0, 11, 5 }, { 0, 5, 1 }, { 0, 1, 7 }, { 0, 7, 10 }, { 0, 10, 11 }, { 1, 5, 9 }, { 5, 11, 4 }, { 11, 10, 2 }, { 10, 7, 6 }, { 7, 1, 8 },
      { 3, 9, 4 }, { 3, 4, 2 }, { 3, 2, 6 }, { 3, 6, 8 }, { 3, 8, 9 }, { 4, 9, 5 }, { 2, 4, 11 }, { 6, 2, 10 }, { 8, 6, 7 }, { 9, 8, 1 } };
    ArrayList<PVector[]> tris = new ArrayList<PVector[]>();
    for (int[] tr : f) {
      PVector a = v.get(tr[0]), b = v.get(tr[1]), c = v.get(tr[2]);
      PVector ab = PVector.add(a, b).normalize(), bc = PVector.add(b, c).normalize(), ca = PVector.add(c, a).normalize();
      tris.add(new PVector[] { a, ab, ca });
      tris.add(new PVector[] { b, bc, ab });
      tris.add(new PVector[] { c, ca, bc });
      tris.add(new PVector[] { ab, bc, ca });
    }
    PShape s = createShape();
    s.beginShape(TRIANGLES);
    s.noStroke();
    s.fill(seed == 1 ? color(120, 100, 90) : color(105, 102, 110));
    for (PVector[] tr : tris) {
      PVector[] q = new PVector[3];
      for (int k = 0; k < 3; k++) {
        PVector p = tr[k];
        float d = 0.75 + noise(p.x * 1.7 + 5, p.y * 1.7, p.z * 1.7) * 0.6;
        q[k] = PVector.mult(p, d);
      }
      PVector n = PVector.sub(q[1], q[0]).cross(PVector.sub(q[2], q[0])).normalize();
      if (n.dot(q[0]) < 0) n.mult(-1);
      s.normal(n.x, n.y, n.z);
      for (int k = 0; k < 3; k++) s.vertex(q[k].x, q[k].y, q[k].z);
    }
    s.endShape();
    noiseSeed(millis());
    return s;
  }

  class Rock {
    float orbitR, ang, y, size, spin, orbit;
    PVector axis;
    int mesh;

    Rock(int i) {
      orbitR = random(9000, 24000);
      ang = random(TWO_PI);
      y = random(-3500, 3500);
      size = random(1) < 0.15 ? random(500, 1100) : random(50, 380);
      spin = random(-0.4, 0.4);
      orbit = random(0.003, 0.012) * (random(1) < 0.5 ? 1 : -1);
      axis = PVector.random3D();
      mesh = i % 3;
    }

    void update(float dt) {
      ang += orbit * dt;
    }

    void draw() {
      pushMatrix();
      translate(cos(ang) * orbitR, y, sin(ang) * orbitR);
      rotate(T * spin, axis.x, axis.y, axis.z);
      scale(size);
      shape(rockMesh[mesh]);
      popMatrix();
    }
  }
}

// a big textured quad on the sky sphere facing the viewer
class SkyBill {
  PImage img;
  PVector dir;
  float size, rot, alpha;
  int col;

  SkyBill(PImage img, PVector dir, float size, float rot, int col, float alpha) {
    this.img = img;
    this.dir = dir.normalize();
    this.size = size;
    this.rot = rot;
    this.col = col;
    this.alpha = alpha;
  }

  void draw(float R) {
    PVector p = PVector.mult(dir, R);
    PVector ax = dir.cross(new PVector(0, 1, 0));
    if (ax.magSq() < 0.01) ax = dir.cross(new PVector(1, 0, 0));
    ax.normalize();
    PVector ay = dir.cross(ax).normalize();
    PVector u = PVector.add(PVector.mult(ax, cos(rot)), PVector.mult(ay, sin(rot))).mult(size / 2);
    PVector w = PVector.add(PVector.mult(ax, -sin(rot)), PVector.mult(ay, cos(rot))).mult(size / 2);
    noStroke();
    tint(red(col), green(col), blue(col), alpha);
    beginShape(QUADS);
    texture(img);
    vertex(p.x - u.x - w.x, p.y - u.y - w.y, p.z - u.z - w.z, 0, 0);
    vertex(p.x + u.x - w.x, p.y + u.y - w.y, p.z + u.z - w.z, 1, 0);
    vertex(p.x + u.x + w.x, p.y + u.y + w.y, p.z + u.z + w.z, 1, 1);
    vertex(p.x - u.x + w.x, p.y - u.y + w.y, p.z - u.z + w.z, 0, 1);
    endShape();
    noTint();
  }
}
