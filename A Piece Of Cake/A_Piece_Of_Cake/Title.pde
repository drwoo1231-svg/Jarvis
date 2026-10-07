// Big text at the top: the DO NOT OPEN warning, the countdown, and
// finally HAPPY BIRTHDAY in bouncing rainbow letters.

class Title {
  final int NONE = 0, WARN = 1, COUNT = 2, BIRTHDAY = 3;
  int mode = NONE;
  String msg = "";
  float t, nopeT = 99;

  void stamp() { mode = WARN; t = 0; }
  void nope() { nopeT = 0; }
  void uhOh() { mode = COUNT; msg = "UH OH."; t = 0; }
  void count(String s) { msg = s; t = 0; }
  void clear() { mode = NONE; }
  void birthday() { mode = BIRTHDAY; t = 0; }

  void update() {
    t += dt;
    nopeT += dt;
  }

  void draw() {
    if (mode == WARN) drawWarning();
    if (mode == COUNT) drawCount();
    if (mode == BIRTHDAY) drawBirthday();
  }

  void drawWarning() {
    String s = "DO NOT OPEN";
    float size = 78;
    if (nopeT < 1.4) {
      s = "I SAID DO NOT OPEN!";
      size = 56;
    } else if (box.hover > 0.5) {
      s = "DON'T EVEN THINK ABOUT IT";
      size = 46;
    }
    float stampK = 1 + 2.2 * (1 - smooth01(t / 0.22));
    float a = constrain(t / 0.12, 0, 1);
    boolean flicker = noise(T * 9) < 0.18;
    float y = 128;
    float jitter = nopeT < 0.4 ? random(-4, 4) : 0;

    blendMode(ADD);
    glowAt(VW / 2, y, 900, color(255, 30, 30), (flicker ? 60 : 130) * a);
    blendMode(BLEND);

    pushMatrix();
    translate(VW / 2 + jitter, y);
    scale(stampK);
    textFont(fStencil, size);
    textAlign(CENTER, CENTER);
    float tw = textWidth(s);
    outlined(s, 0, -size * 0.08, color(255, flicker ? 90 : 45, 45), a, 5);
    sprite(imgWarning, -tw / 2 - 56, 0, 74, -0.08, 255 * a);
    sprite(imgWarning, tw / 2 + 56, 0, 74, 0.08, 255 * a);
    popMatrix();
  }

  void drawCount() {
    float k = 1 + 1.4 * (1 - smooth01(t / 0.18));
    float size = msg.length() > 2 ? 90 : 140;
    blendMode(ADD);
    glowAt(VW / 2, 135, 700, color(255, 30, 30), 200);
    blendMode(BLEND);
    pushMatrix();
    translate(VW / 2, 135);
    scale(k);
    textFont(fStencil, size);
    textAlign(CENTER, CENTER);
    outlined(msg, 0, -size * 0.08, color(255, 60, 50), 1, 6);
    popMatrix();
  }

  void drawBirthday() {
    String name = BIRTHDAY_NAME.trim().toUpperCase();
    String line1 = name.length() > 0 ? "HAPPY BIRTHDAY," : "HAPPY BIRTHDAY!";
    blendMode(ADD);
    glowAt(VW / 2, 105, 1000, color(255, 180, 60), 110 * constrain(t, 0, 1));
    blendMode(BLEND);
    bouncy(line1, VW / 2, 96, 104, 0);
    if (name.length() > 0) bouncy(name + "!", VW / 2, 182, 74, line1.length());
  }

  // each letter pops in, bobs on a wave and cycles through party colours
  void bouncy(String s, float cx, float cy, float size, int offset) {
    textFont(fTitle, size);
    textAlign(CENTER, CENTER);
    float total = textWidth(s);
    float x = cx - total / 2;
    for (int i = 0; i < s.length(); i++) {
      String ch = s.substring(i, i + 1);
      float cw = textWidth(ch);
      float appear = t - (i + offset) * 0.06;
      if (appear > 0 && !ch.equals(" ")) {
        float sc = easeOutBack(appear / 0.3);
        float yy = cy + sin(T * 3.2 - (i + offset) * 0.45) * 7;
        float u = (T * 0.6 + (i + offset) * 0.13) % 1.0 * PARTY_COLORS.length;
        int c = lerpColor(PARTY_COLORS[int(u) % PARTY_COLORS.length], PARTY_COLORS[(int(u) + 1) % PARTY_COLORS.length], u % 1);
        pushMatrix();
        translate(x + cw / 2, yy);
        scale(sc);
        rotate(sin(T * 2.4 + i) * 0.05);
        outlined(ch, 0, -size * 0.06, c, 1, 5);
        popMatrix();
      }
      x += cw;
    }
  }

  // text with a thick dark outline and a drop shadow
  void outlined(String s, float x, float y, int c, float a, float o) {
    fill(10, 5, 25, 150 * a);
    text(s, x + o * 1.4, y + o * 1.6);
    fill(18, 10, 38, 255 * a);
    for (int k = 0; k < 8; k++) {
      float ang = k * TWO_PI / 8;
      text(s, x + cos(ang) * o, y + sin(ang) * o);
    }
    fill(c, 255 * a);
    text(s, x, y);
  }
}
