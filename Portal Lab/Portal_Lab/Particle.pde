// Particle (one spark), the pooled Particles system (every Particle made once,
// no per-frame allocation) and in-plane shockwave rings. All drawn additively.

// one spark of light
class Particle {
  float x, y, z, vx, vy, vz;
  float life, maxLife, size, grav, drag;
  int col;

  void step(float dt) {
    float k = exp(-drag * dt);
    vx *= k;
    vy = vy * k + grav * dt;
    vz *= k;
    x += vx * dt;
    y += vy * dt;
    z += vz * dt;
  }
}

// the pool: every Particle is made once up front; the live ones are pool[0 .. count-1]
class Particles {
  final int CAP = 1400;
  Particle[] pool = new Particle[CAP];
  int count;

  Particles() {
    for (int i = 0; i < CAP; i++) pool[i] = new Particle();
  }

  void emit(float px, float py, float pz, float pvx, float pvy, float pvz, float plife, float psize, int pcol, float pgrav, float pdrag) {
    Particle q;
    if (count < CAP) q = pool[count++];
    else q = pool[(int) random(CAP)];        // full: overwrite a random one
    q.x = px; q.y = py; q.z = pz;
    q.vx = pvx; q.vy = pvy; q.vz = pvz;
    q.life = q.maxLife = plife;
    q.size = psize;
    q.col = pcol;
    q.grav = pgrav;
    q.drag = pdrag;
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
      Particle q = pool[i];
      q.life -= dt;
      if (q.life <= 0) {
        // swap the dead one past the end of the live range
        count--;
        pool[i] = pool[count];
        pool[count] = q;
        continue;
      }
      q.step(dt);
    }
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
      Particle q = pool[i];
      float a = q.life / q.maxLife;
      float s = q.size * (0.4 + 0.6 * a) * 0.5;
      int c = q.col;
      tint((c >> 16) & 255, (c >> 8) & 255, c & 255, 255 * min(1, a * 1.6));
      float ax = (rx + ux) * s, ay = (ry + uy) * s, az = (rz + uz) * s;
      float bx = (rx - ux) * s, by = (ry - uy) * s, bz = (rz - uz) * s;
      vertex(q.x - ax, q.y - ay, q.z - az, 0, 0);
      vertex(q.x + bx, q.y + by, q.z + bz, 1, 0);
      vertex(q.x + ax, q.y + ay, q.z + az, 1, 1);
      vertex(q.x - bx, q.y - by, q.z - bz, 0, 1);
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
