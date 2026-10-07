// Particles and one-off effects: confetti, sparks, smoke, emoji pops,
// shockwaves, fireworks, balloons, party poppers and Rick's portals.

final int[] PARTY_COLORS = {
  #FF4F8B, #FFD23F, #3EE6FF, #8CFF5A, #B78CFF, #FF8A3D, #FFFFFF
};

class FX {
  ArrayList<Particle> back = new ArrayList<Particle>();    // behind the Ricks and the box
  ArrayList<Particle> front = new ArrayList<Particle>();   // in front of everything

  void update() {
    step(back);
    step(front);
  }

  void step(ArrayList<Particle> list) {
    for (int i = list.size() - 1; i >= 0; i--) {
      Particle p = list.get(i);
      p.update();
      if (p.dead()) list.remove(i);
    }
  }

  // normal particles first, then the glowing ones in one additive pass
  void drawLayer(ArrayList<Particle> list) {
    for (Particle p : list) if (!p.additive) p.draw();
    blendMode(ADD);
    for (Particle p : list) if (p.additive) p.draw();
    blendMode(BLEND);
  }

  void spark(float x, float y, float vx, float vy, int c, float life, float size) {
    front.add(new Spark(x, y, vx, vy, c, life, size, 0));
  }

  void burst(float x, float y, int n, int c) {
    for (int i = 0; i < n; i++) {
      float a = random(TWO_PI), v = random(80, 260);
      front.add(new Spark(x, y, cos(a) * v, sin(a) * v, c, random(0.4, 0.9), random(8, 16), 120));
    }
  }

  void ring(float x, float y, int c, float r) {
    front.add(new Ring(x, y, c, r));
  }

  void emoji(PImage img, float x, float y, float size, float life, float rot) {
    front.add(new EmojiPop(img, x, y, size, life, rot, 0, 0, 0, 0));
  }

  void emojiDrift(PImage img, float x, float y, float size, float life, float rot) {
    front.add(new EmojiPop(img, x, y, size, life, rot, random(-15, 15), -60, 0, 0));
  }

  void debris(PImage img, float x, float y, float size, float vx, float vy, float vr) {
    front.add(new EmojiPop(img, x, y, size, 2.5, 0, vx, vy, vr, 1300));
  }

  void confettiBurst(float x, float y, int n, float dir, float spread, float speed) {
    for (int i = 0; i < n; i++) {
      float a = dir + random(-spread / 2, spread / 2);
      float v = random(0.3, 1) * speed;
      front.add(new Confetti(x + random(-30, 30), y, cos(a) * v, sin(a) * v));
    }
  }

  void poppers() {
    EmojiPop l = new EmojiPop(imgPopper, 80, 640, 120, 2.2, 0, 0, 0, 0, 0);
    EmojiPop r = new EmojiPop(imgPopper, VW - 80, 640, 120, 2.2, 0, 0, 0, 0, 0);
    r.flip = true;
    front.add(l);
    front.add(r);
    for (int i = 0; i < 140; i++) {
      float a = radians(-62) + random(-0.35, 0.35), v = random(350, 900);
      front.add(new Confetti(115, 605, cos(a) * v, sin(a) * v));
      front.add(new Confetti(VW - 115, 605, -cos(a) * v, sin(a) * v));
    }
  }

  void smoke(float x, float y) {
    front.add(new Smoke(x, y));
  }

  void puff(float x0, float y, float x1) {
    front.add(new Puff(x0, y, x1));
  }

  void floatText(String s, float x, float y, int c) {
    front.add(new FloatText(s, x, y, c));
  }

  void firework(float tx, float ty) {
    back.add(new Rocket(tx, ty));
  }

  void balloon() {
    if (back.size() > 400) return;
    back.add(new Balloon());
  }
}

// ---------------------------------------------------------------- particles
abstract class Particle {
  float x, y, vx, vy, age, life = 1;
  boolean additive;

  boolean dead() { return age >= life; }

  void update() {
    age += dt;
    x += vx * dt;
    y += vy * dt;
  }

  float fadeOut(float last) {
    return constrain((life - age) / last, 0, 1);
  }

  abstract void draw();
}

class Spark extends Particle {
  int c;
  float size, grav, px, py;

  Spark(float x, float y, float vx, float vy, int c, float life, float size, float grav) {
    this.x = px = x;
    this.y = py = y;
    this.vx = vx;
    this.vy = vy;
    this.c = c;
    this.life = life;
    this.size = size;
    this.grav = grav;
    additive = true;
  }

  void update() {
    px = x;
    py = y;
    vy += grav * dt;
    vx *= exp(-1.4 * dt);
    vy *= exp(-1.4 * dt);
    super.update();
  }

  void draw() {
    float a = fadeOut(life * 0.6);
    glowAt(x, y, size * 3, c, 230 * a);
    stroke(c, 255 * a);
    strokeWeight(size * 0.22);
    line(px, py, x, y);
    noStroke();
  }
}

class Confetti extends Particle {
  int c;
  float w, h, rot, vr, flip, vflip, phase;

  Confetti(float x, float y, float vx, float vy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    c = PARTY_COLORS[int(random(PARTY_COLORS.length))];
    w = random(6, 11);
    h = random(10, 16);
    rot = random(TWO_PI);
    vr = random(-8, 8);
    vflip = random(6, 14);
    phase = random(TWO_PI);
    life = random(3, 5);
  }

  void update() {
    vy += 420 * dt;
    vx *= exp(-2.2 * dt);
    vy *= exp(-2.2 * dt);
    vx += sin(age * 5 + phase) * 60 * dt;
    rot += vr * dt;
    flip += vflip * dt;
    super.update();
  }

  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(rot);
    scale(1, cos(flip));
    noStroke();
    fill(c, 255 * fadeOut(0.6));
    rect(-w / 2, -h / 2, w, h);
    popMatrix();
  }
}

class Smoke extends Particle {
  float size, phase;

  Smoke(float x, float y) {
    this.x = x;
    this.y = y;
    vx = random(-8, 8);
    vy = random(-55, -35);
    life = random(1.6, 2.4);
    size = random(5, 9);
    phase = random(TWO_PI);
  }

  void update() {
    vx += sin(age * 4 + phase) * 30 * dt;
    super.update();
  }

  void draw() {
    float p = age / life;
    noStroke();
    fill(215, 215, 225, 120 * (1 - p));
    ellipse(x, y, size * (1 + p * 3), size * (1 + p * 3));
  }
}

class Ring extends Particle {
  int c;
  float r;

  Ring(float x, float y, int c, float r) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.r = r;
    life = 0.7;
    additive = true;
  }

  void draw() {
    float p = age / life;
    float rr = r * (1 - pow(1 - p, 3));
    if (rr < 2) return;
    noFill();
    stroke(c, 220 * (1 - p));
    strokeWeight(10 * (1 - p) + 1);
    ellipse(x, y, rr, rr * 0.55);
    noStroke();
  }
}

class EmojiPop extends Particle {
  PImage img;
  float size, rot, vr, grav;
  boolean flip;

  EmojiPop(PImage img, float x, float y, float size, float life, float rot, float vx, float vy, float vr, float grav) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.size = size;
    this.life = life;
    this.rot = rot;
    this.vx = vx;
    this.vy = vy;
    this.vr = vr;
    this.grav = grav;
  }

  void update() {
    vy += grav * dt;
    rot += vr * dt;
    super.update();
  }

  void draw() {
    float sc = easeOutBack(age / 0.18);
    pushMatrix();
    translate(x, y);
    if (flip) scale(-1, 1);
    sprite(img, 0, 0, size * sc, rot, 255 * fadeOut(life * 0.35));
    popMatrix();
  }
}

class Puff extends Particle {
  float x0, x1;

  Puff(float x0, float y, float x1) {
    this.x0 = x0;
    this.x1 = x1;
    this.y = y;
    life = 0.85;
  }

  void draw() {
    float p = age / life;
    float xx = lerp(x0, x1, 1 - pow(1 - p, 2));
    float a = 255 * sin(PI * p);
    sprite(imgPuff, xx, y + sin(p * 9) * 4, 110 + 40 * p, 0, a);
  }
}

class FloatText extends Particle {
  String s;
  int c;

  FloatText(String s, float x, float y, int c) {
    this.s = s;
    this.x = x;
    this.y = y;
    this.c = c;
    vy = -40;
    life = 1.4;
  }

  void draw() {
    float a = fadeOut(0.5);
    float sc = easeOutBack(age / 0.2);
    pushMatrix();
    translate(x, y);
    scale(sc);
    textFont(fComic, 30);
    textAlign(CENTER, CENTER);
    fill(20, 15, 30, 200 * a);
    text(s, 2, 2);
    fill(c, 255 * a);
    text(s, 0, 0);
    popMatrix();
  }
}

class Rocket extends Particle {
  float tx, ty, sx;
  int c;

  Rocket(float tx, float ty) {
    this.tx = tx;
    this.ty = ty;
    sx = tx + random(-60, 60);
    x = sx;
    y = VH + 20;
    life = 0.75;
    c = PARTY_COLORS[int(random(PARTY_COLORS.length - 1))];
    additive = true;
    sfx.play(sfx.launch, 0.25, random(0.9, 1.2));
  }

  void update() {
    age += dt;
    float p = min(1, age / life);
    float e = 1 - pow(1 - p, 2.2);
    x = lerp(sx, tx, e);
    y = lerp(VH + 20, ty, e);
    if (frameCount % 2 == 0) fx.back.add(new Spark(x, y, random(-10, 10), random(20, 60), color(255, 200, 140), 0.35, 7, 0));
    if (age >= life) explode();
  }

  void explode() {
    int n = 70;
    int c2 = PARTY_COLORS[int(random(PARTY_COLORS.length))];
    for (int i = 0; i < n; i++) {
      float a = TWO_PI * i / n + random(-0.05, 0.05);
      float v = random(160, 330);
      fx.back.add(new Spark(x, y, cos(a) * v, sin(a) * v, i % 3 == 0 ? c2 : c, random(0.9, 1.5), random(9, 15), 140));
    }
    fx.back.add(new Ring(x, y, c, 260));
    sfx.play(sfx.crackle, 0.35, random(0.85, 1.15));
  }

  void draw() {
    glowAt(x, y, 34, color(255, 220, 170), 255);
  }
}

class Balloon extends Particle {
  PImage img;
  float size, phase, baseX;

  Balloon() {
    img = imgBalloons[int(random(imgBalloons.length))];
    size = random(70, 115);
    baseX = random(40, VW - 40);
    x = baseX;
    y = VH + size;
    vy = -random(45, 80) * (size / 100);
    phase = random(TWO_PI);
    life = 30;
  }

  boolean dead() { return y < -size * 1.5; }

  void update() {
    age += dt;
    y += vy * dt;
    x = baseX + sin(age * 0.9 + phase) * 22;
  }

  void draw() {
    sprite(img, x, y, size, sin(age * 0.9 + phase) * 0.12, 235);
  }
}

// ---------------------------------------------------------------- portal
// green swirl; open goes 0..1
void drawPortal(float cx, float cy, float rx, float ry, float open, float t) {
  rx *= open;
  ry *= open;
  if (rx < 1) return;
  noStroke();
  fill(20, 90, 25, 230);
  ellipse(cx, cy, rx * 2.1, ry * 2.1);
  blendMode(ADD);
  glowAt(cx, cy, ry * 3.4, color(90, 255, 110), 150 * open);
  fill(60, 200, 60, 200);
  ellipse(cx, cy, rx * 1.9, ry * 1.9);
  noFill();
  for (int k = 0; k < 9; k++) {
    float a0 = -t * 4 + k * TWO_PI / 9;
    stroke(k % 2 == 0 ? color(190, 255, 120) : color(110, 230, 70), 170);
    strokeWeight(3 + (k % 3) * 2);
    beginShape();
    for (int i = 0; i <= 26; i++) {
      float u = i / 26.0;
      float ang = a0 + u * 4.6;
      vertex(cx + cos(ang) * rx * u, cy + sin(ang) * ry * u);
    }
    endShape();
  }
  noStroke();
  fill(230, 255, 200, 200);
  ellipse(cx, cy, rx * 0.5, ry * 0.45);
  blendMode(BLEND);
  noFill();
  stroke(30, 160, 40, 255);
  strokeWeight(5);
  ellipse(cx, cy, rx * 2, ry * 2);
  stroke(170, 255, 120, 220);
  strokeWeight(2);
  ellipse(cx, cy, rx * 1.86, ry * 1.86);
  noStroke();
}
