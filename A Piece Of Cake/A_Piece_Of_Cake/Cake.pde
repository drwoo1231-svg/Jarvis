// The birthday cake that rises out of the open box. The flames on the
// PNG were removed (tools/prepare_assets.py) so they can be drawn live,
// flicker, and be blown out.

class Cake {
  final float C = 270;                                    // drawn size of cake.png
  final float[] candleX = { 0.2959, 0.499, 0.7021 };      // candle tips, as fractions of cake.png
  final float candleY = 0.1914;
  final float BASE = 0.934;                               // bottom of the cake in the PNG

  float riseT = -1;
  float[] flame = new float[3];
  boolean[] lit = new boolean[3];
  float blowT = -1;
  float lean;

  void rise() { riseT = 0; }

  float progress() { return constrain((riseT - 0.35) / 1.1, 0, 1); }
  boolean visible() { return riseT >= 0.35; }
  boolean settled() { return riseT > 1.5; }

  float scaleNow() { return lerp(0.45, 1, easeOutBack(progress())); }
  float bottom() { return lerp(box.rimY() + 160, box.rimY() + 14, easeOutBack(progress())); }

  float candleWX(int i) { return box.cx + (candleX[i] - 0.5) * C * scaleNow(); }
  float candleWY() { return bottom() - (BASE - candleY) * C * scaleNow(); }

  boolean allLit() { return lit[0] && lit[1] && lit[2]; }
  boolean canBlow() { return state == PARTY && settled() && allLit() && blowT < 0; }

  boolean over(float px, float py) {
    if (!visible()) return false;
    return px > box.cx - C * 0.45 && px < box.cx + C * 0.45 && py > candleWY() - 40 && py < bottom();
  }

  void update() {
    if (riseT < 0) return;
    riseT += dt;
    if (riseT > 0.4 && riseT < 1.5 && frameCount % 2 == 0) {
      fx.spark(box.cx + random(-C / 2, C / 2), bottom() - random(C * 0.8), random(-40, 40), random(-90, -30), color(255, 230, 150), 0.9, 12);
    }
    // light the candles one by one once the cake has landed
    for (int i = 0; i < 3; i++) {
      if (!lit[i] && blowT < 0 && riseT > 1.55 + i * 0.2 && riseT - dt <= 1.55 + i * 0.2) light(i);
    }
    if (blowT >= 0) {
      blowT += dt;
      lean = 9 * sin(PI * constrain(blowT / 0.75, 0, 1));
      for (int i = 0; i < 3; i++) {
        if (lit[i] && blowT > 0.28 + i * 0.13) snuff(i);
      }
      if (blowT > 0.9 && blowT - dt <= 0.9) party.wish();
      for (int i = 0; i < 3; i++) {
        float t = 9 + i * 0.3;
        if (!lit[i] && blowT > t && blowT - dt <= t) light(i);
      }
      if (blowT > 10.2) {
        blowT = -1;
        party.relit();
      }
    } else {
      lean *= 0.9;
    }
    for (int i = 0; i < 3; i++) {
      flame[i] += ((lit[i] ? 1 : 0) - flame[i]) * min(1, dt * (lit[i] ? 6 : 14));
    }
  }

  void light(int i) {
    lit[i] = true;
    flame[i] = 0;
    sfx.play(sfx.pop, 0.5, 1.4 + i * 0.15);
    fx.burst(candleWX(i), candleWY() - 10, 10, color(255, 220, 120));
    fx.emojiDrift(imgSparkles, candleWX(i), candleWY() - 34, 34, 0.6, 0);
  }

  void snuff(int i) {
    lit[i] = false;
    for (int k = 0; k < 7; k++) fx.smoke(candleWX(i) + random(-3, 3), candleWY() - 8 - k * 3);
  }

  void blow() {
    if (!canBlow()) return;
    blowT = 0;
    sfx.play(sfx.blow, 0.9, 1);
    fx.puff(box.cx - C * 0.75, candleWY() - 14, box.cx + C * 0.7);
  }

  void draw() {
    if (!visible()) return;
    float s = scaleNow();
    float a = constrain((riseT - 0.35) / 0.25, 0, 1);
    imageMode(CORNER);
    tint(255, 255 * a);
    image(imgCake, box.cx - C * s / 2, bottom() - BASE * C * s, C * s, C * s);
    noTint();
  }

  void drawFlames() {
    if (!visible()) return;
    float s = scaleNow();
    float y = candleWY();
    for (int i = 0; i < 3; i++) {
      float x = candleWX(i);
      stroke(45, 35, 30);
      strokeWeight(2.2 * s);
      line(x, y + 1, x + lean * 0.15, y - 5 * s);
      if (flame[i] > 0.08) drawFlame(x, y - 3 * s, s * flame[i], i);
    }
    noStroke();
  }

  void drawFlame(float x, float y, float s, int i) {
    float n = noise(T * 7 + i * 10);
    float h = (26 + 10 * n) * s;
    float w = 12 * s;
    float sway = (noise(T * 4 + i * 3 + 100) - 0.5) * 6 * s + lean * s;
    blendMode(ADD);
    glowAt(x, y - h * 0.45, 110 * s, color(255, 140, 40), 150);
    glowAt(x, y - h * 0.45, 40 * s, color(255, 220, 150), 160);
    blendMode(BLEND);
    noStroke();
    fill(255, 120, 20, 225);
    teardrop(x, y, w, h, sway);
    fill(255, 205, 70, 240);
    teardrop(x, y - 1 * s, w * 0.68, h * 0.74, sway * 0.8);
    fill(255, 255, 225);
    teardrop(x, y - 1.5 * s, w * 0.36, h * 0.42, sway * 0.5);
    fill(90, 130, 255, 140);
    ellipse(x, y - 2.5 * s, w * 0.45, 4.5 * s);
  }

  // flame shape: round bottom at (x, y), pointy tip h above, tip pushed sideways by sway
  void teardrop(float x, float y, float w, float h, float sway) {
    float r = w * 0.5;
    beginShape();
    vertex(x + sway, y - h);
    bezierVertex(x + sway * 0.4 + r * 0.3, y - h * 0.6, x + r * 1.15, y - r * 1.9, x + r, y - r);
    bezierVertex(x + r * 0.9, y + r * 0.1, x - r * 0.9, y + r * 0.1, x - r, y - r);
    bezierVertex(x - r * 1.15, y - r * 1.9, x + sway * 0.4 - r * 0.3, y - h * 0.6, x + sway, y - h);
    endShape(CLOSE);
  }
}
