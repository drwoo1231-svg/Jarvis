// Rick: his face (sober / drunk / burping), his whole drunk body for the
// intro, and the cartoon speech box with a typewriter that actually burps
// when it reaches *burp*.

final int DOCK_CORNER = 0, DOCK_POINT = 1, DOCK_HIDDEN = 2;   // HIDDEN: a scene draws the text itself

class Rick {
  PImage face, faceTalk, drunk, drunkTalk, burpFace;
  String text = "";
  float age;                     // seconds since the line started
  float cps = 42;                // typewriter speed (characters per second)
  boolean showing;
  int lastSoundChar = -1;
  boolean drunkMode;             // half-closed eyes (intro / when you do badly)
  float burpT = -9;              // when the last burp happened (for the face)
  float hicT = -9;               // when the last hiccup happened (for a little hop)
  // where the box goes
  int dock = DOCK_CORNER;
  float px, py;                  // DOCK_POINT: the point the tail points at (e.g. his mouth)
  float boxW = 540;
  int lastInputMs;
  int idleCount;

  Rick() {
    face = makeRickFace(false, false, false);
    faceTalk = makeRickFace(true, false, false);
    drunk = makeRickFace(false, true, false);
    drunkTalk = makeRickFace(true, true, false);
    burpFace = makeRickFace(true, true, true);
    lastInputMs = millis();
  }

  void say(String line) {
    text = line;
    age = 0;
    showing = true;
    lastSoundChar = -1;
  }

  void quiet() {
    showing = false;
  }

  int typed() {
    return min(text.length(), (int) (age * cps));
  }

  boolean done() {
    return !showing || typed() >= text.length();
  }

  boolean talking() {
    return showing && !done() && (int) (T * 9) % 2 == 0;
  }

  // finish the line instantly; true if it was still typing
  boolean finish() {
    if (showing && !done()) {
      age = text.length() / cps + 0.01;
      return true;
    }
    return false;
  }

  String shownText() {
    return showing ? text.substring(0, typed()) : "";
  }

  void clickSkip() {
    lastInputMs = millis();
  }

  boolean burping() {
    return T - burpT < 0.7;
  }

  void burp(boolean big) {
    burpT = T;
    sfx.play(big ? sfx.bigBurp : sfx.burp, big ? 0.9 : 0.7, random(0.92, 1.08));
  }

  void update(float dt) {
    if (!showing) return;
    int before = typed();
    age += dt;
    // corner box: let it go once he's said it and you've had time to read it
    if (dock == DOCK_CORNER && age > text.length() / cps + 7 + text.length() / 25.0) showing = false;
    int now = typed();
    // sounds as the text appears: a soft blip per word, a real burp at *burp*
    for (int i = max(before, lastSoundChar + 1); i < now; i++) {
      lastSoundChar = i;
      if (text.startsWith("*burp*", i) || text.startsWith("*BURP*", i) || text.startsWith("*BUUURP*", i)) burp(text.startsWith("*BUUURP*", i));
      else if (text.startsWith("*hic*", i)) {
        sfx.play(sfx.hic, 0.7, random(0.95, 1.1));
        hicT = T;
      }
      else if (text.charAt(i) == ' ' && random(1) < 0.5) sfx.play(sfx.blip, 0.5, random(0.8, 1.3));
    }
  }

  // idle nag (the user's favourite line). Scenes that allow it call this.
  void idleCheck() {
    if (millis() - lastInputMs > 40000 && done()) {
      idleCount++;
      say(idleCount % 2 == 1 ? "Dazing off? Lazy a**." : "Dazing off? Lazy a**. The body has 206 bones and not one of yours is moving.");
      lastInputMs = millis();
    }
  }

  PImage currentFace() {
    if (burping()) return burpFace;
    boolean t = talking();
    if (drunkMode) return t ? drunkTalk : drunk;
    return t ? faceTalk : face;
  }

  // ---------------------------------------------------------------- the speech box
  void drawBox() {
    if (!showing || dock == DOCK_HIDDEN) return;
    float pop = min(1, age / 0.18);
    pop = 1 - pow(1 - pop, 3);
    textFont(fRick);
    String shown = text.substring(0, typed());
    ArrayList<String> lines = wrapText(text, boxW - 44);       // wrap the full line so words don't jump
    float lh = 28;
    float w = boxW, h = lines.size() * lh + 62;
    float bx, by, tx, ty;
    if (dock == DOCK_CORNER) {
      float cx = W - 102, cy = H - 104;
      // portrait
      pushMatrix();
      translate(cx, cy + sin(T * 3) * 2);
      scale(pop);
      noStroke();
      fill(0, 120);
      ellipse(4, 6, 172, 172);
      fill(#13233A);
      stroke(C_GREEN);
      strokeWeight(3);
      ellipse(0, 0, 166, 166);
      imageMode(CENTER);
      image(currentFace(), 0, 4, 158, 158);
      imageMode(CORNER);
      popMatrix();
      bx = cx - 100 - w;
      by = H - 22 - h;
      tx = cx - 78;
      ty = by + h * 0.62;
    } else {
      // beside the point (his mouth), on whichever side has room
      tx = px;
      ty = py;
      bx = px + 80;
      if (bx + w > W - 16) bx = px - 80 - w;
      by = constrain(py - h * 0.7, 12, H - h - 12);
    }
    boolean tailRight = tx > bx + w / 2;
    float ex = tailRight ? bx + w - 8 : bx + 8;
    float ya = constrain(ty - 22, by + 16, by + h - 52), yb = ya + 34;
    pushMatrix();
    translate(tx, ty);
    scale(pop);
    translate(-tx, -ty);
    noStroke();
    fill(0, 110);
    rect(bx + 6, by + 8, w, h, 22);
    fill(#FFFCF2);
    stroke(#1E1C28);
    strokeWeight(4);
    triangle(ex, ya, ex, yb, tx, ty);
    rect(bx, by, w, h, 22);
    noStroke();
    float ix = tailRight ? -3 : 3;
    triangle(ex + ix, ya + 3, ex + ix, yb - 3, tx + (tailRight ? -7 : 7), ty);
    textFont(fH2);
    fill(#2E8B3A);
    textAlign(LEFT, TOP);
    text("RICK:", bx + 22, by + 12);
    textFont(fRick);
    int left = shown.length();
    for (int i = 0; i < lines.size() && left > 0; i++) {
      String ln = lines.get(i);
      String part = ln.substring(0, min(ln.length(), left));
      left -= ln.length() + 1;
      richLine(part, bx + 22, by + 46 + i * lh, #1E1C28, #2E9A30);
    }
    popMatrix();
  }

  // ---------------------------------------------------------------- whole Rick (intro / big moments)
  // feet at (x, y); sway = lean in radians; flask = arm raise 0..1; tilt = head tilt
  void drawBody(float x, float y, float s, float sway, float flask, float tilt) {
    pushMatrix();
    float hop = T - hicT < 0.3 ? sin((T - hicT) / 0.3 * PI) * 16 : 0;
    translate(x, y - hop);
    scale(s);
    rotate(sway);
    strokeJoin(ROUND);
    strokeCap(ROUND);
    stroke(#1E1C28);
    strokeWeight(3);
    // shoes + legs (wobbly knees)
    float knee = sin(T * 2.3) * 4;
    fill(#6E4F33);
    quad(-30, -128, -6, -128, -8 + knee, -10, -30 + knee, -10);
    quad(6, -128, 30, -128, 30 - knee, -10, 8 - knee, -10);
    fill(#2A2A30);
    ellipse(-21 + knee, -6, 40, 16);
    ellipse(21 - knee, -6, 40, 16);
    // shirt (light blue) under the open coat
    fill(#A8D8EA);
    quad(-24, -252, 24, -252, 26, -126, -26, -126);
    // lab coat: two halves, open at the front
    fill(#F4F7FA);
    beginShape();
    vertex(-24, -254);
    vertex(-52, -246);
    vertex(-60, -170);
    vertex(-62, -96);
    vertex(-22, -92);
    vertex(-16, -170);
    endShape(CLOSE);
    beginShape();
    vertex(24, -254);
    vertex(52, -246);
    vertex(60, -170);
    vertex(62, -96);
    vertex(22, -92);
    vertex(16, -170);
    endShape(CLOSE);
    // coat shading + pocket
    noFill();
    stroke(#C5D0DA);
    strokeWeight(2.5);
    line(-44, -230, -50, -110);
    line(44, -230, 50, -110);
    stroke(#1E1C28);
    strokeWeight(2);
    rect(28, -150, 20, 16, 3);
    // lapels
    strokeWeight(3);
    line(-24, -254, -12, -214);
    line(24, -254, 12, -214);
    // left arm (hangs, swings a bit)
    float swing = sin(T * 1.9) * 0.12;
    pushMatrix();
    translate(-50, -240);
    rotate(0.12 + swing);
    fill(#F4F7FA);
    quad(-12, 0, 12, 0, 10, 96, -12, 96);
    fill(#F1D6BA);
    ellipse(-1, 104, 22, 24);
    popMatrix();
    // right arm with the flask
    pushMatrix();
    translate(50, -240);
    rotate(-0.12 - flask * 2.2 + swing * 0.5);
    fill(#F4F7FA);
    quad(-12, 0, 12, 0, 12, 96, -10, 96);
    fill(#F1D6BA);
    ellipse(1, 104, 22, 24);
    // flask
    pushMatrix();
    translate(4, 112);
    rotate(flask * 2.0);
    fill(#B9C2CC);
    rect(-11, -14, 22, 30, 6);
    fill(#8C96A3);
    rect(-5, -22, 10, 9, 2);
    noStroke();
    fill(255, 140);
    rect(-7, -10, 4, 20, 2);
    stroke(#1E1C28);
    popMatrix();
    popMatrix();
    // head
    pushMatrix();
    translate(0, -250);
    rotate(tilt);
    imageMode(CORNER);
    float hs = 1.15;
    image(currentFace(), -128 * hs, -236 * hs, 256 * hs, 256 * hs);
    popMatrix();
    popMatrix();
  }
}

// ====================================================================
// Rick's head, drawn with shapes (same design as A Piece Of Cake / Portal Lab),
// plus drunk eyelids and a burp mouth.

PImage makeRickFace(boolean talking, boolean drunk, boolean burp) {
  PGraphics g = createGraphics(256, 256);
  g.beginDraw();
  g.clear();
  g.translate(128, 232);
  g.scale(1.02);
  g.strokeJoin(ROUND);
  g.strokeCap(ROUND);
  drawRickHead(g, talking, drunk, burp);
  g.endDraw();
  return g.get();
}

void drawRickHead(PGraphics g, boolean talking, boolean drunk, boolean burp) {
  int SKIN = #F1D6BA, SKIN_SH = #D9B596, HAIR = #AEDDF5, HAIR_SH = #86BEDF, HAIR_DK = #5E93B8, INK = #1E1C28;
  g.scale(1.2);
  float cx = 0, cy = -50;
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(HAIR);
  float[] tipR = { 58, 72, 80, 78, 84, 80, 84, 78, 80, 72, 58 };
  float[] curl = { -0.16, -0.14, -0.12, -0.08, -0.04, 0, 0.04, 0.08, 0.12, 0.14, 0.16 };
  int n = tipR.length;
  float a0 = radians(166), a1 = radians(374);
  float step = (a1 - a0) / (n - 1);
  g.beginShape();
  g.vertex(cx + cos(a0 - step * 0.6) * 30, cy + sin(a0 - step * 0.6) * 42);
  for (int i = 0; i < n; i++) {
    float a = a0 + step * i;
    float vr = 47;
    float va = a - step * 0.5, vb = a + step * 0.5;
    float tx = cx + cos(a + curl[i]) * tipR[i];
    float ty = cy + sin(a + curl[i]) * tipR[i] * 1.04;
    if (i == 0) g.vertex(cx + cos(va) * vr * 0.8, cy + sin(va) * vr);
    g.quadraticVertex(cx + cos(a - step * 0.12) * (vr + 10), cy + sin(a - step * 0.12) * (vr + 10) * 1.04, tx, ty);
    g.quadraticVertex(cx + cos(a + step * 0.2) * (vr + 8), cy + sin(a + step * 0.2) * (vr + 8) * 1.04,
                      cx + cos(vb) * vr, cy + sin(vb) * vr * 1.04);
  }
  g.vertex(cx + cos(a1 + step * 0.6) * 30, cy + sin(a1 + step * 0.6) * 42);
  g.endShape(CLOSE);
  g.stroke(HAIR_SH);
  g.noFill();
  for (int i = 0; i < n; i++) {
    float a = a0 + step * i;
    float r1 = tipR[i] * 0.84;
    g.line(cx + cos(a) * 44, cy + sin(a) * 44 * 1.04, cx + cos(a + curl[i] * 0.8) * r1, cy + sin(a + curl[i] * 0.8) * r1 * 1.04);
  }
  // ears + neck
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(SKIN);
  g.ellipse(-31, -46, 13, 20);
  g.ellipse(31, -46, 13, 20);
  g.rect(-8.5, -12, 17, 14);
  // face
  g.strokeWeight(2.4);
  float[][] face = { { 0, -94 }, { 20, -91 }, { 31, -76 }, { 33, -56 }, { 31, -36 }, { 26, -18 }, { 14, -6 }, { 0, -3 },
    { -14, -6 }, { -26, -18 }, { -31, -36 }, { -33, -56 }, { -31, -76 }, { -20, -91 } };
  g.beginShape();
  for (int i = 0; i < face.length + 3; i++) g.curveVertex(face[i % face.length][0], face[i % face.length][1]);
  g.endShape();
  // drunk flush
  if (drunk) {
    g.noStroke();
    g.fill(#E8848A, 120);
    g.ellipse(-20, -30, 16, 9);
    g.ellipse(20, -30, 16, 9);
    g.fill(#E8848A, 160);
    g.ellipse(2, -31, 9, 7);
  }
  // hair cap
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(HAIR);
  g.beginShape();
  g.vertex(-32, -64);
  g.bezierVertex(-32, -88, -18, -100, 0, -100);
  g.bezierVertex(18, -100, 32, -88, 32, -64);
  g.vertex(26, -76);
  g.vertex(19, -71);
  g.vertex(12, -79);
  g.vertex(4, -73);
  g.vertex(-4, -80);
  g.vertex(-12, -73);
  g.vertex(-19, -79);
  g.vertex(-26, -72);
  g.endShape(CLOSE);
  // unibrow
  g.noFill();
  g.stroke(HAIR_DK);
  g.strokeWeight(5);
  g.beginShape();
  if (burp) {
    g.vertex(-26, -60);
    g.vertex(-18, -63.5);
    g.vertex(-11, -61);
    g.vertex(-4, -62.5);
    g.vertex(4, -62.5);
    g.vertex(11, -61);
    g.vertex(18, -63.5);
    g.vertex(26, -60);
  } else {
    g.vertex(-26, -57);
    g.vertex(-18, -61.5);
    g.vertex(-11, -58);
    g.vertex(-4, -60.5);
    g.vertex(4, -60.5);
    g.vertex(11, -58);
    g.vertex(18, -61.5);
    g.vertex(26, -57);
  }
  g.endShape();
  // eyes
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(255);
  g.ellipse(-11, -46, 22, 22);
  g.ellipse(11, -46, 22, 22);
  g.noStroke();
  g.fill(INK);
  if (burp) {
    // squeezed shut
    g.stroke(INK);
    g.strokeWeight(2.4);
    g.noFill();
    g.line(-19, -46, -4, -46);
    g.line(4, -46, 19, -46);
  } else if (drunk) {
    // pupils drifting apart, eyelids at half mast
    g.ellipse(-12.5, -42.5, 4.6, 4.6);
    g.ellipse(12.5, -43.5, 4.6, 4.6);
    g.fill(SKIN);
    g.stroke(INK);
    g.strokeWeight(2.2);
    g.arc(-11, -46, 22, 22, PI, TWO_PI, CHORD);
    g.arc(11, -46, 22, 22, PI, TWO_PI, CHORD);
  } else {
    g.ellipse(-8.5, -45, 4.6, 4.6);
    g.ellipse(9.5, -46.5, 4.6, 4.6);
  }
  g.noFill();
  g.stroke(SKIN_SH);
  g.strokeWeight(1.6);
  g.arc(-11, -40, 22, 16, radians(25), radians(155));
  g.arc(11, -40, 22, 16, radians(25), radians(155));
  // nose
  g.stroke(INK);
  g.strokeWeight(2);
  g.beginShape();
  g.vertex(1, -36);
  g.quadraticVertex(7, -30, 1.5, -27.5);
  g.endShape();
  // mouth
  g.strokeWeight(2.4);
  if (burp) {
    g.fill(#4A1E26);
    g.ellipse(0, -15, 26, 18);
    g.noStroke();
    g.fill(#D7616B);
    g.ellipse(1, -10, 14, 6);
  } else if (!talking) {
    g.beginShape();
    g.vertex(-18, -19);
    g.quadraticVertex(-9, -16, -1, -19.5);
    g.quadraticVertex(8, -16, 18, -19.5);
    g.endShape();
    if (drunk) {
      // a little drool
      g.noStroke();
      g.fill(#BFE6FF, 220);
      g.ellipse(14, -14, 4, 7);
    }
  } else {
    g.fill(#4A1E26);
    g.beginShape();
    g.vertex(-17, -22);
    g.quadraticVertex(0, -19, 17, -22.5);
    g.quadraticVertex(14, -6, 0, -6);
    g.quadraticVertex(-14, -6, -17, -22);
    g.endShape(CLOSE);
    g.noStroke();
    g.fill(255);
    g.rect(-12, -21.5, 24, 4, 2);
    g.fill(#D7616B);
    g.ellipse(2, -9.5, 14, 6);
  }
}
