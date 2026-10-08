// Pooled particle system (fixed arrays, no per-frame allocation) and
// in-plane shockwave rings. Everything here is drawn additively.

class Particles {
  final int CAP = 1400;
  float[] x = new float[CAP], y = new float[CAP], z = new float[CAP];
  float[] vx = new float[CAP], vy = new float[CAP], vz = new float[CAP];
  float[] life = new float[CAP], maxLife = new float[CAP], size = new float[CAP];
  float[] grav = new float[CAP], drag = new float[CAP];
  int[] col = new int[CAP];
  int count;

  void emit(float px, float py, float pz, float pvx, float pvy, float pvz, float plife, float psize, int pcol, float pgrav, float pdrag) {
    int i;
    if (count < CAP) i = count++;
    else i = (int) random(CAP);              // full: overwrite a random one
    x[i] = px; y[i] = py; z[i] = pz;
    vx[i] = pvx; vy[i] = pvy; vz[i] = pvz;
    life[i] = maxLife[i] = plife;
    size[i] = psize;
    col[i] = pcol;
    grav[i] = pgrav;
    drag[i] = pdrag;
  }

  void emit(PVector p, PVector v, float plife, float psize, int pcol, float pgrav, float pdrag) {
    emit(p.x, p.y, p.z, v.x, v.y, v.z, plife, psize, pcol, pgrav, pdrag);
  }

  // a ball of sparks
  void burst(PVector p, int n, float speed, int c, float lifeMax, float sizeMax) {
    for (int k = 0; k < n; k++) {
      PVector d = PVector.random3D().mult(speed * random(0.3, 1));
      emit(p, d, random(0.3, lifeMax), random(sizeMax * 0.4, sizeMax), c, 300, 2.2);
    }
  }

  void update(float dt) {
    for (int i = count - 1; i >= 0; i--) {
      life[i] -= dt;
      if (life[i] <= 0) {
        count--;
        copy(count, i);
        continue;
      }
      float k = exp(-drag[i] * dt);
      vx[i] *= k;
      vy[i] = vy[i] * k + grav[i] * dt;
      vz[i] *= k;
      x[i] += vx[i] * dt;
      y[i] += vy[i] * dt;
      z[i] += vz[i] * dt;
    }
  }

  void copy(int from, int to) {
    x[to] = x[from]; y[to] = y[from]; z[to] = z[from];
    vx[to] = vx[from]; vy[to] = vy[from]; vz[to] = vz[from];
    life[to] = life[from]; maxLife[to] = maxLife[from]; size[to] = size[from];
    col[to] = col[from]; grav[to] = grav[from]; drag[to] = drag[from];
  }

  // one batch of camera-facing textured quads
  void draw() {
    if (count == 0) return;
    float rx = cam.right.x, ry = cam.right.y, rz = cam.right.z;
    float ux = cam.up.x, uy = cam.up.y, uz = cam.up.z;
    noStroke();
    beginShape(QUADS);
    texture(texGlow);
    for (int i = 0; i < count; i++) {
      float a = life[i] / maxLife[i];
      float s = size[i] * (0.4 + 0.6 * a) * 0.5;
      int c = col[i];
      tint((c >> 16) & 255, (c >> 8) & 255, c & 255, 255 * min(1, a * 1.6));
      float ax = (rx + ux) * s, ay = (ry + uy) * s, az = (rz + uz) * s;
      float bx = (rx - ux) * s, by = (ry - uy) * s, bz = (rz - uz) * s;
      vertex(x[i] - ax, y[i] - ay, z[i] - az, 0, 0);
      vertex(x[i] + bx, y[i] + by, z[i] + bz, 1, 0);
      vertex(x[i] + ax, y[i] + ay, z[i] + az, 1, 1);
      vertex(x[i] - bx, y[i] - by, z[i] - bz, 0, 1);
    }
    endShape();
    noTint();
  }
}

// expanding ring lying in a plane (portal openings, impacts)
class Shockwave {
  PVector c, a, b;          // centre and the two in-plane axes
  float age, life, maxR;
  int col;

  Shockwave(PVector c, PVector a, PVector b, float maxR, float life, int col) {
    this.c = c.copy();
    this.a = a.copy();
    this.b = b.copy();
    this.maxR = maxR;
    this.life = life;
    this.col = col;
  }

  boolean dead() { return age >= life; }

  void draw() {
    float p = age / life;
    float r = maxR * (1 - pow(1 - p, 3));
    noStroke();
    tint(red(col), green(col), blue(col), 255 * (1 - p));
    beginShape(QUADS);
    texture(texRing);
    shockV(-r, -r, 0, 0);
    shockV(r, -r, 1, 0);
    shockV(r, r, 1, 1);
    shockV(-r, r, 0, 1);
    endShape();
    noTint();
  }

  void shockV(float i, float j, float u, float v) {
    vertex(c.x + a.x * i + b.x * j, c.y + a.y * i + b.y * j, c.z + a.z * i + b.z * j, u, v);
  }
}
