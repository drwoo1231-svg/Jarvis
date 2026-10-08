// Look and feel: colours, fonts, buttons, text wrapping, the space backdrop.

final int C_BG = #070B16, C_PANEL = #121A2E, C_PANEL2 = #1B2540, C_EDGE = #2E3E66;
final int C_GREEN = #7CFF6B, C_GREEN_DK = #2E8B3A, C_TEXT = #EAF2FF, C_DIM = #8EA0C2;
final int C_GOLD = #FFD25A, C_RED = #FF5A5F, C_BLUE = #6FD3FF, C_PAPER = #F6F1E4, C_PAPER_EDGE = #D8CDB2;

PFont fTitle, fH1, fH2, fBody, fBodyB, fSmall, fMono, fRick, fExplain, fRickSmall;

void setupFonts() {
  fTitle = createFont("SansSerif.bold", 60, true);
  fH1 = createFont("SansSerif.bold", 38, true);
  fH2 = createFont("SansSerif.bold", 26, true);
  fBody = createFont("SansSerif.plain", 22, true);
  fBodyB = createFont("SansSerif.bold", 22, true);
  fSmall = createFont("SansSerif.plain", 16, true);
  fMono = createFont("Monospaced.bold", 16, true);
  fRick = createFont("SansSerif.bold", 21, true);
  fExplain = createFont("SansSerif.plain", 19, true);
  fRickSmall = createFont("SansSerif.bold", 18, true);
}

// ---------------------------------------------------------------- text helpers
// split into lines that fit width w with the CURRENT font/size
ArrayList<String> wrapText(String s, float w) {
  ArrayList<String> out = new ArrayList<String>();
  for (String para : s.split("\n")) {
    String line = "";
    for (String word : para.split(" ")) {
      if (word.length() == 0) continue;
      String t = line.length() == 0 ? word : line + " " + word;
      if (textWidth(t) > w && line.length() > 0) {
        out.add(line);
        line = word;
      } else line = t;
    }
    out.add(line);
  }
  return out;
}

// draws wrapped text top-left at (x, y); returns the height used
float textBlock(String s, float x, float y, float w, float lh) {
  ArrayList<String> ls = wrapText(s, w);
  textAlign(LEFT, TOP);
  for (int i = 0; i < ls.size(); i++) text(ls.get(i), x, y + i * lh);
  return ls.size() * lh;
}

float textBlockHeight(String s, float w, float lh) {
  return wrapText(s, w).size() * lh;
}

// one line where *burp* / *hic* style words are drawn in another colour
void richLine(String line, float x, float y, int base, int special) {
  textAlign(LEFT, TOP);
  float cx = x;
  for (String w : line.split(" ")) {
    boolean sp = w.startsWith("*");
    fill(sp ? special : base);
    text(w, cx, y);
    cx += textWidth(w + " ");
  }
}

String ellipsize(String s, float w) {
  if (textWidth(s) <= w) return s;
  while (s.length() > 1 && textWidth(s + "...") > w) s = s.substring(0, s.length() - 1);
  return s + "...";
}

// ---------------------------------------------------------------- panels
void panel(float x, float y, float w, float h, int fillC, int edge, float r) {
  noStroke();
  fill(0, 90);
  rect(x + 5, y + 7, w, h, r);
  fill(fillC);
  stroke(edge);
  strokeWeight(2);
  rect(x, y, w, h, r);
}

boolean over(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}

// ---------------------------------------------------------------- buttons
class Button {
  String id, label, sub, hotkey;
  float x, y, w, h;
  float hov;                 // hover animation 0..1
  int col = C_GREEN;
  boolean enabled = true, visible = true, showKey = true;
  PFont font;

  Button(String id, String label, float x, float y, float w, float h) {
    this.id = id;
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    font = fBodyB;
  }

  Button key(String k) {
    hotkey = k;
    return this;
  }

  Button colour(int c) {
    col = c;
    return this;
  }

  boolean over() {
    return visible && enabled && mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void draw() {
    if (!visible) return;
    hov += ((over() ? 1 : 0) - hov) * min(1, dt * 14);
    float lift = hov * 3;
    noStroke();
    fill(0, 110);
    rect(x + 4, y + 6, w, h, 14);
    int bg = enabled ? lerpColor(C_PANEL2, col, 0.18 + 0.22 * hov) : C_PANEL;
    fill(bg);
    stroke(enabled ? lerpColor(col, #FFFFFF, hov * 0.4) : C_EDGE);
    strokeWeight(2 + hov);
    rect(x, y - lift, w, h, 14);
    textFont(font);
    textAlign(CENTER, CENTER);
    fill(enabled ? C_TEXT : C_DIM);
    float cy = y - lift + h / 2 - (sub != null ? 11 : 2);
    text(label, x + w / 2, cy);
    if (sub != null) {
      textFont(fSmall);
      fill(enabled ? C_DIM : #55617A);
      text(sub, x + w / 2, cy + 26);
    }
    if (hotkey != null && showKey && hotkey.trim().length() > 0) {
      textFont(fMono);
      textAlign(LEFT, TOP);
      fill(enabled ? col : C_EDGE);
      text(hotkey, x + 10, y - lift + 7);
    }
  }
}

// ---------------------------------------------------------------- the space backdrop
class SpaceBg {
  PGraphics img;
  float[] sx = new float[90], sy = new float[90], sp = new float[90];

  SpaceBg() {
    img = createGraphics(W, H);
    img.beginDraw();
    img.noStroke();
    for (int y = 0; y < H; y += 4) {
      float k = y / (float) H;
      img.fill(lerpColor(#0A1024, #04060D, k));
      img.rect(0, y, W, 4);
    }
    randomSeed(7);
    // soft nebula blobs
    for (int i = 0; i < 26; i++) {
      float x = random(W), y = random(H), r = random(120, 320);
      int c = i % 3 == 0 ? #2B7A4B : (i % 3 == 1 ? #3B2B7A : #1E4F7A);
      for (int k = 8; k >= 1; k--) {
        img.fill(c, 5);
        img.ellipse(x, y, r * k / 4, r * k / 5);
      }
    }
    for (int i = 0; i < 700; i++) {
      float b = random(80, 255);
      img.fill(b, b, 255, random(90, 230));
      float s = random(1) < 0.94 ? random(0.8, 1.8) : random(2, 3.2);
      img.ellipse(random(W), random(H), s, s);
    }
    img.endDraw();
    for (int i = 0; i < sx.length; i++) {
      sx[i] = random(W);
      sy[i] = random(H);
      sp[i] = random(0.5, 3);
    }
    randomSeed(millis());
  }

  void draw() {
    image(img, 0, 0);
    noStroke();
    for (int i = 0; i < sx.length; i++) {
      float a = 120 + 120 * sin(T * sp[i] + i);
      fill(220, 235, 255, a);
      ellipse(sx[i], sy[i], 2.4, 2.4);
    }
  }
}
