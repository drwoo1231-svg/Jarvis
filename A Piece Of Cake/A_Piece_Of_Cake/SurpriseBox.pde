// The gift box: lid + body PNGs, caution tape, the big red button,
// sirens, light leaking out of the lid, and the lid blowing off.

class SurpriseBox {
  final float G = 400;           // drawn size of the gift PNGs
  final float CUT = 0.4688;      // where gift_lid.png ends and gift_body.png begins
  float cx = 640, by = 280;      // top-left of the gift image is (cx - G/2, by)
  float bob;

  float appearT = -1;            // materialize animation clock
  float wob, wobV;               // jiggle spring
  float hover;                   // 0..1 when the mouse is over the button
  float pressT = -1;             // button press clock
  float sirenT = -1;
  float leak;                    // light leaking out of the seam (armed)

  boolean lidOn = true;
  float lx, ly, lvx, lvy, lr, lvr;
  boolean open = false;
  float openT;
  ArrayList<TapePiece> pieces = new ArrayList<TapePiece>();

  float rimY() { return by + bob + G * CUT; }
  float bottomY() { return by + bob + G * 0.934; }
  float centerY() { return by + bob + 230; }
  float buttonY() { return by + bob + 312; }

  void materialize() { appearT = 0; }

  void update() {
    if (appearT >= 0) appearT += dt;
    bob = sin(T * 1.4) * 5;
    // jiggle spring
    wobV += (-wob * 260 - wobV * 9) * dt;
    wob += wobV * dt;
    boolean over = state == IDLE && overButton(mx, my);
    hover += ((over ? 1 : 0) - hover) * min(1, dt * 10);
    if (pressT >= 0) pressT += dt;
    if (sirenT >= 0) sirenT += dt;
    leak = state == ARMED ? smooth01((st - 0.5) / 2.0) : 0;
    if (state == ARMED && frameCount % 3 == 0 && leak > 0.2) {
      fx.spark(random(cx - 150, cx + 150), rimY(), random(-30, 30), random(-140, -60), color(255, 220, 120), 0.6, 9);
    }
    if (!lidOn) {
      lvy += 1500 * dt;
      lx += lvx * dt;
      ly += lvy * dt;
      lr += lvr * dt;
    }
    if (open) openT += dt;
    for (int i = pieces.size() - 1; i >= 0; i--) {
      TapePiece p = pieces.get(i);
      p.update();
      if (p.y > VH + 200) pieces.remove(i);
    }
  }

  boolean visible() { return appearT >= 0; }

  boolean overButton(float px, float py) {
    return visible() && !open && dist(px, py, cx, buttonY()) < 46;
  }

  boolean overBox(float px, float py) {
    return visible() && px > cx - 165 && px < cx + 165 && py > by + bob + 90 && py < bottomY();
  }

  void jiggle() { wobV += 2.2; }

  void press() {
    pressT = 0;
    sirenT = 0;
  }

  void explode() {
    lidOn = false;
    open = true;
    openT = 0;
    lx = cx;
    ly = by + bob + 120;
    lvx = random(-160, 160);
    lvy = -1250;
    lr = 0;
    lvr = random(1) < 0.5 ? -5 : 5;
    // the body tape snaps in two
    float y = by + bob + 225, a = -0.06;
    pieces.add(new TapePiece(cx - 90 * cos(a), y - 90 * sin(a), a, 180, new float[] { 10 }, -260, -380, -2.5));
    pieces.add(new TapePiece(cx + 90 * cos(a), y + 90 * sin(a), a, 180, new float[] { -10 }, 260, -420, 2.8));
    // sirens go flying
    for (int s = -1; s <= 1; s += 2) {
      fx.debris(imgSiren, cx + s * 140, by + bob + 70, 74, s * random(220, 320), random(-700, -500), s * 6);
    }
  }

  // ---------------------------------------------------------------- drawing
  // light pillars: the teleport beam that drops the box in, and the glow out of the open box
  void drawBeam() {
    blendMode(ADD);
    noStroke();
    if (state == WARP && st > 0.7 && st < 2.0) {
      float k = sin(PI * constrain((st - 0.7) / 1.3, 0, 1));
      float w = 150 * k;
      float y1 = centerY();
      beginShape(QUADS);
      fill(150, 235, 255, 0);
      vertex(cx - w * 0.5, -40);
      vertex(cx + w * 0.5, -40);
      fill(170, 245, 255, 190 * k);
      vertex(cx + w * 0.5, y1);
      vertex(cx - w * 0.5, y1);
      endShape();
      glowAt(cx, y1, 420 * k, color(160, 240, 255), 220 * k);
    }
    if (open) {
      float k = 0.35 + 0.65 * exp(-openT * 0.8);
      float y0 = rimY() - 6;
      beginShape(QUADS);
      fill(255, 210, 120, 150 * k);
      vertex(cx - 140, y0);
      vertex(cx + 140, y0);
      fill(255, 200, 120, 0);
      vertex(cx + 230, -60);
      vertex(cx - 230, -60);
      endShape();
    }
    // hover pad under the box
    if (visible()) {
      float a = constrain(appearT / 0.6, 0, 1);
      glowAt(cx, bottomY() + 16, 480, color(150, 90, 255), 110 * a);
      noFill();
      stroke(170, 140, 255, 120 * a);
      strokeWeight(2);
      ellipse(cx, bottomY() + 18, 360, 34);
      noStroke();
    }
    blendMode(BLEND);
  }

  // the dark inside of the open box (the cake is drawn on top of this)
  void drawBack() {
    if (!open) return;
    float r = rimY();
    noStroke();
    fill(28, 14, 58);
    quad(cx - 140, r - 13, cx + 140, r - 13, cx + 150, r + 2, cx - 150, r + 2);
    blendMode(ADD);
    glowAt(cx, r - 8, 380, color(255, 200, 110), 120 * (0.5 + 0.5 * exp(-openT)));
    blendMode(BLEND);
  }

  void drawFront() {
    if (!visible()) return;
    float a = easeOutElastic(appearT / 0.9);
    pushMatrix();
    translate(cx, bottomY());
    scale(a * (1 + wob * 0.12), a * (1 - wob * 0.12));
    translate(-cx, -bottomY());

    imageMode(CORNER);
    image(imgBody, cx - G / 2, by + bob, G, G);
    if (!open) {
      drawTape(cx, by + bob + 225, -0.06, 360, 34, new float[] { -82, 82 });
      drawButton(cx, buttonY());
    } else {
      drawSocket(cx, buttonY());
    }
    if (lidOn) drawLid(cx, by + bob + 120, 0);
    if (sirenT >= 0 && lidOn) drawSirens();
    if (leak > 0.01) drawLeaks();

    // materialize flash
    if (appearT < 0.6) {
      blendMode(ADD);
      tint(255, 255 * (1 - appearT / 0.6));
      image(imgBody, cx - G / 2, by + bob, G, G);
      image(imgLid, cx - G / 2, by + bob, G, G);
      noTint();
      blendMode(BLEND);
    }
    popMatrix();

    if (!lidOn) drawLid(lx, ly, lr);
    for (TapePiece p : pieces) p.draw();
  }

  // lid pivot is 120px below the top of the gift image
  void drawLid(float x, float y, float r) {
    pushMatrix();
    translate(x, y);
    rotate(r);
    imageMode(CORNER);
    image(imgLid, -G / 2, -120, G, G);
    drawTape(0, 26, 0.05, 372, 30, new float[] { -88, 88 });
    popMatrix();
  }

  void drawButton(float x, float y) {
    float pulse = 0.5 + 0.5 * sin(T * 4);
    float press = pressT < 0 ? 0 : pressT < 0.12 ? pressT / 0.12 : 0.75;
    float s = 1 + hover * 0.06;
    pushMatrix();
    translate(x, y);
    scale(s);
    // glow
    blendMode(ADD);
    glowAt(0, 0, 210 + 60 * hover, color(255, 40, 40), 110 + 70 * pulse + 60 * hover);
    blendMode(BLEND);
    // hazard ring housing
    noStroke();
    fill(15, 12, 20);
    ellipse(0, 4, 112, 112);
    float spin = state == ARMED ? T * 6 : 0;
    for (int i = 0; i < 16; i++) {
      fill(i % 2 == 0 ? color(255, 205, 0) : color(22, 20, 26));
      arc(0, 0, 104, 104, i * TWO_PI / 16 + spin, (i + 1) * TWO_PI / 16 + spin, PIE);
    }
    fill(35, 32, 44);
    ellipse(0, 0, 82, 82);
    // the dome
    float h = 10 * (1 - press);
    fill(110, 0, 12);
    ellipse(0, h * 0.5 + 2, 72, 72);
    fill(220, 22, 34);
    ellipse(0, -h * 0.5, 70, 70);
    fill(255, 70, 70);
    ellipse(-2, -h * 0.5 - 4, 52, 46);
    fill(255, 255, 255, 170);
    ellipse(-13, -h * 0.5 - 16, 22, 11);
    popMatrix();
  }

  // empty housing left behind once the box is open
  void drawSocket(float x, float y) {
    noStroke();
    fill(15, 12, 20);
    ellipse(x, y + 4, 112, 112);
    for (int i = 0; i < 16; i++) {
      fill(i % 2 == 0 ? color(255, 205, 0) : color(22, 20, 26));
      arc(x, y, 104, 104, i * TWO_PI / 16, (i + 1) * TWO_PI / 16, PIE);
    }
    fill(110, 0, 12);
    ellipse(x, y + 2, 72, 72);
    fill(200, 20, 30);
    ellipse(x, y, 70, 70);
  }

  void drawSirens() {
    float pop = easeOutBack(sirenT / 0.35);
    for (int s = -1; s <= 1; s += 2) {
      float x = cx + s * 140, y = by + bob + 70;
      boolean on = (int)(T * 6 + (s > 0 ? 1 : 0)) % 2 == 0;
      blendMode(ADD);
      glowAt(x, y - 8, on ? 240 : 140, color(255, 30, 30), on ? 220 : 90);
      float ang = T * 7 * s;
      noStroke();
      for (int k = 0; k < 2; k++) {
        float b = ang + k * PI;
        fill(255, 40, 40, 45);
        triangle(x, y - 12, x + cos(b - 0.2) * 260, y - 12 + sin(b - 0.2) * 110, x + cos(b + 0.2) * 260, y - 12 + sin(b + 0.2) * 110);
      }
      blendMode(BLEND);
      sprite(imgSiren, x, y, 74 * pop, s * 0.08 * sin(T * 20), 255);
    }
  }

  void drawLeaks() {
    float r = rimY();
    blendMode(ADD);
    noStroke();
    for (int i = 0; i < 9; i++) {
      float x = cx - 150 + i * 37.5;
      float flick = 0.6 + 0.4 * noise(i * 3, T * 6);
      float len = (90 + 140 * leak) * flick;
      float spread = (x - cx) / 150.0;
      fill(255, 215, 130, 120 * leak * flick);
      triangle(x - 6, r, x + 6, r, x + spread * len * 0.7, r - len);
    }
    stroke(255, 230, 150, 255 * leak);
    strokeWeight(3 + 3 * leak);
    line(cx - 152, r, cx + 152, r);
    noStroke();
    glowAt(cx, r, 520, color(255, 200, 110), 200 * leak);
    blendMode(BLEND);
  }
}

// yellow-and-black caution tape with DO NOT OPEN printed on it
void drawTape(float x, float y, float ang, float len, float w, float[] words) {
  pushMatrix();
  translate(x, y);
  rotate(ang);
  noStroke();
  fill(0, 70);
  rect(-len / 2 + 3, -w / 2 + 5, len, w);
  fill(255, 206, 22);
  rect(-len / 2, -w / 2, len, w);
  fill(22, 20, 26);
  rect(-len / 2, -w / 2 + 2.5, len, 2.5);
  rect(-len / 2, w / 2 - 5, len, 2.5);
  textFont(fStencilSmall, w * 0.56);
  textAlign(CENTER, CENTER);
  for (float wx : words) text("DO NOT OPEN", wx, -w * 0.07);
  popMatrix();
}

class TapePiece {
  float x, y, a, len, vx, vy, vr;
  float[] words;

  TapePiece(float x, float y, float a, float len, float[] words, float vx, float vy, float vr) {
    this.x = x;
    this.y = y;
    this.a = a;
    this.len = len;
    this.words = words;
    this.vx = vx;
    this.vy = vy;
    this.vr = vr;
  }

  void update() {
    vy += 1300 * dt;
    x += vx * dt;
    y += vy * dt;
    a += vr * dt;
  }

  void draw() {
    drawTape(x, y, a, len, 34, words);
  }
}
