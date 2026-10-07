/*
  RickPartsGenerator  -  draws the Rick sprite parts used by A_Piece_Of_Cake.
  Open in Processing 4 and press Run: it writes the PNGs into
  ../../A_Piece_Of_Cake/data/ and then shows a preview of the assembled rig.

  Every part is drawn in "rig units" (Rick is ~355 units tall) at K pixels
  per unit. The anchor of each part is listed next to it - the main sketch
  uses the same numbers (see HoloRick.pde) to put him back together.
*/

final float K = 2;   // pixels per rig unit in the saved PNGs

// palette
final int SKIN = #F1D6BA, SKIN_SH = #D9B596;
final int HAIR = #AEDDF5, HAIR_SH = #86BEDF, HAIR_DK = #5E93B8;
final int COAT = #F6F8FA, COAT_SH = #C9D3DE;
final int SHIRT = #9ED3EC, SHIRT_SH = #7DB6D2;
final int PANTS = #8C6A48, PANTS_SH = #6E5137;
final int SHOE = #3A2E2B;
final int INK = #1E1C28;

// part canvases (rig units) and anchors (rig units from top-left)
final float HEAD_W = 230, HEAD_H = 215, HEAD_AX = 115, HEAD_AY = 200;   // anchor = top of neck
final float HEAD_SCALE = 1.2;                                          // Rick has a big head
final float BODY_W = 150, BODY_H = 250, BODY_AX = 75, BODY_AY = 244;   // anchor = between the feet
final float UP_W = 90, UP_H = 40, UP_AX = 14, UP_AY = 20;              // anchor = shoulder joint
final float FORE_W = 100, FORE_H = 48, FORE_AX = 14, FORE_AY = 24;     // anchor = elbow joint

PImage pBody, pHead, pHeadTalk, pUpper, pFore;

void settings() {
  size(900, 760, P2D);
  smooth(8);
}

void setup() {
  String out = sketchPath("../../A_Piece_Of_Cake/data/");
  pBody     = render(BODY_W, BODY_H, BODY_AX, BODY_AY, 0, out + "rick_body.png");
  pHead     = render(HEAD_W, HEAD_H, HEAD_AX, HEAD_AY, 1, out + "rick_head.png");
  pHeadTalk = render(HEAD_W, HEAD_H, HEAD_AX, HEAD_AY, 2, out + "rick_head_talk.png");
  pUpper    = render(UP_W, UP_H, UP_AX, UP_AY, 3, out + "rick_arm_upper.png");
  pFore     = render(FORE_W, FORE_H, FORE_AX, FORE_AY, 4, out + "rick_arm_fore.png");
  println("Rick parts written to " + out);
}

PImage render(float w, float h, float ax, float ay, int part, String file) {
  PGraphics g = createGraphics(round(w * K), round(h * K), P2D);
  g.smooth(4);
  g.beginDraw();
  g.clear();
  g.scale(K);
  g.translate(ax, ay);
  g.strokeJoin(ROUND);
  g.strokeCap(ROUND);
  if (part == 0) drawBody(g);
  if (part == 1) drawHead(g, false);
  if (part == 2) drawHead(g, true);
  if (part == 3) drawUpperArm(g);
  if (part == 4) drawForearm(g);
  g.endDraw();
  g.save(file);
  return g.get();
}

// ------------------------------------------------------------------ head
void drawHead(PGraphics g, boolean talking) {
  float cx = 0, cy = -50;
  g.scale(HEAD_SCALE);

  // spiky hair (behind the head): alternating tips and valleys around the skull
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
    float vr = 47;                                  // valley radius
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

  // strands of shading in each spike
  g.stroke(HAIR_SH);
  g.strokeWeight(2.4);
  g.noFill();
  for (int i = 0; i < n; i++) {
    float a = a0 + step * i;
    float r0 = 44, r1 = tipR[i] * 0.84;
    g.line(cx + cos(a) * r0, cy + sin(a) * r0 * 1.04,
           cx + cos(a + curl[i] * 0.8) * r1, cy + sin(a + curl[i] * 0.8) * r1 * 1.04);
  }

  // ears
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(SKIN);
  g.ellipse(-31, -46, 13, 20);
  g.ellipse(31, -46, 13, 20);
  g.noFill();
  g.stroke(SKIN_SH);
  g.arc(-31, -46, 6, 11, HALF_PI, PI + HALF_PI);
  g.arc(31, -46, 6, 11, -HALF_PI, HALF_PI);

  // neck stub so the head blends into the body
  g.stroke(INK);
  g.fill(SKIN);
  g.rect(-8.5, -12, 17, 14);

  // face
  g.fill(SKIN);
  g.stroke(INK);
  g.strokeWeight(2.4);
  float[][] face = {
    {0, -94}, {20, -91}, {31, -76}, {33, -56}, {31, -36}, {26, -18}, {14, -6}, {0, -3},
    {-14, -6}, {-26, -18}, {-31, -36}, {-33, -56}, {-31, -76}, {-20, -91}
  };
  g.beginShape();
  for (int i = 0; i < face.length + 3; i++) {
    float[] p = face[i % face.length];
    g.curveVertex(p[0], p[1]);
  }
  g.endShape();

  // soft cheek / jaw shading
  g.noStroke();
  g.fill(SKIN_SH, 120);
  g.beginShape();
  g.vertex(18, -40);
  g.quadraticVertex(30, -30, 24, -16);
  g.quadraticVertex(16, -6, 4, -5);
  g.quadraticVertex(22, -14, 18, -40);
  g.endShape(CLOSE);

  // hair cap with a jagged hairline
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
  g.stroke(HAIR_SH);
  g.strokeWeight(1.8);
  g.line(-14, -92, -10, -80);
  g.line(6, -95, 8, -82);
  g.line(20, -88, 18, -78);

  // forehead wrinkles
  g.noFill();
  g.stroke(SKIN_SH);
  g.strokeWeight(1.5);
  g.bezier(-12, -67, -6, -69, 6, -69, 12, -67);

  // the unibrow
  g.stroke(HAIR_DK);
  g.strokeWeight(5);
  g.beginShape();
  g.vertex(-26, -57);
  g.vertex(-18, -61.5);
  g.vertex(-11, -58);
  g.vertex(-4, -60.5);
  g.vertex(4, -60.5);
  g.vertex(11, -58);
  g.vertex(18, -61.5);
  g.vertex(26, -57);
  g.endShape();

  // eyes: big round whites, tiny pupils
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(255);
  g.ellipse(-11, -46, 22, 22);
  g.ellipse(11, -46, 22, 22);
  g.noStroke();
  g.fill(INK);
  g.ellipse(-8.5, -45, 4.6, 4.6);
  g.ellipse(9.5, -46.5, 4.6, 4.6);
  // eye bags
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
  if (!talking) {
    g.stroke(INK);
    g.strokeWeight(2.4);
    g.beginShape();
    g.vertex(-18, -19);
    g.quadraticVertex(-9, -16, -1, -19.5);
    g.quadraticVertex(8, -16, 18, -19.5);
    g.endShape();
    g.strokeWeight(1.6);
    g.stroke(SKIN_SH);
    g.arc(0, -13, 12, 5, radians(20), radians(160));
    g.stroke(INK);
    g.strokeWeight(1.6);
    g.line(-20, -22, -18, -19);
    g.line(20, -22.5, 18, -19.5);
  } else {
    g.stroke(INK);
    g.strokeWeight(2.4);
    g.fill(#4A1E26);
    g.beginShape();
    g.vertex(-17, -22);
    g.quadraticVertex(0, -19, 17, -22.5);
    g.quadraticVertex(14, -6, 0, -6);
    g.quadraticVertex(-14, -6, -17, -22);
    g.endShape(CLOSE);
    g.noStroke();
    g.fill(255);
    g.beginShape();
    g.vertex(-14, -21);
    g.quadraticVertex(0, -18.5, 14, -21.5);
    g.vertex(13, -17.5);
    g.quadraticVertex(0, -15, -13, -17);
    g.endShape(CLOSE);
    g.fill(#D7616B);
    g.ellipse(2, -9.5, 14, 6);
  }
  // chin crease
  g.noFill();
  g.stroke(SKIN_SH);
  g.strokeWeight(1.4);
  g.arc(0, -6.5, 10, 4, radians(200), radians(340));
}

// ------------------------------------------------------------------ body
void drawBody(PGraphics g) {
  g.strokeWeight(2.4);
  g.stroke(INK);

  // shoes
  g.fill(SHOE);
  g.ellipse(-17, -7, 34, 15);
  g.ellipse(17, -7, 34, 15);
  g.noStroke();
  g.fill(255, 40);
  g.ellipse(-21, -10, 14, 4);
  g.ellipse(13, -10, 14, 4);

  // legs
  g.stroke(INK);
  g.fill(PANTS);
  g.quad(-28, -112, -3, -112, -5, -11, -27, -11);
  g.quad(3, -112, 28, -112, 27, -11, 5, -11);
  g.stroke(PANTS_SH);
  g.strokeWeight(1.8);
  g.line(-16, -96, -16, -18);
  g.line(16, -96, 16, -18);

  // shirt
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(SHIRT);
  g.quad(-17, -214, 17, -214, 21, -104, -21, -104);
  g.stroke(SHIRT_SH);
  g.strokeWeight(1.6);
  g.line(0, -196, 0, -110);
  g.noStroke();
  g.fill(SHIRT_SH);
  g.ellipse(0, -180, 3, 3);
  g.ellipse(0, -160, 3, 3);
  g.ellipse(0, -140, 3, 3);
  g.ellipse(0, -120, 3, 3);
  // waistband
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(PANTS);
  g.quad(-22, -114, 22, -114, 22, -102, -22, -102);

  // coat collar standing up behind the neck
  g.fill(COAT_SH);
  g.quad(-15, -214, 15, -214, 11, -226, -11, -226);

  // neck
  g.fill(SKIN);
  g.rect(-8.5, -234, 17, 24);
  // shirt collar
  g.fill(SHIRT);
  g.triangle(-11, -213, 0, -203, -2, -214);
  g.triangle(11, -213, 0, -203, 2, -214);

  // lab coat halves
  for (int side = -1; side <= 1; side += 2) {
    g.pushMatrix();
    g.scale(side, 1);
    g.stroke(INK);
    g.strokeWeight(2.4);
    g.fill(COAT);
    g.beginShape();
    g.vertex(12, -214);
    g.vertex(32, -214);
    g.quadraticVertex(41, -210, 43, -196);
    g.vertex(46, -150);
    g.vertex(52, -80);
    g.quadraticVertex(34, -76, 15, -79);
    g.vertex(14, -130);
    g.vertex(13, -175);
    g.endShape(CLOSE);
    // side shading
    g.noStroke();
    g.fill(COAT_SH, 170);
    g.beginShape();
    g.vertex(42, -196);
    g.vertex(45.5, -150);
    g.vertex(50.5, -82);
    g.vertex(42, -81);
    g.vertex(38, -150);
    g.endShape(CLOSE);
    // lapel
    g.stroke(INK);
    g.strokeWeight(2.2);
    g.fill(COAT_SH);
    g.triangle(12, -213, 25, -202, 14, -166);
    // pocket
    g.noFill();
    g.strokeWeight(2);
    g.line(24, -118, 42, -118);
    g.line(24, -118, 25, -100);
    g.popMatrix();
  }
}

// ------------------------------------------------------------------ arms
// upper arm: shoulder joint at (0,0) pointing along +x, elbow at x = 58
void drawUpperArm(PGraphics g) {
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(COAT);
  capsule(g, 0, 58, 12, 10.5);
  g.noFill();
  g.stroke(COAT_SH);
  g.strokeWeight(2.2);
  g.line(4, 6, 50, 5.5);
  g.line(40, -4, 52, -2);
}

// forearm: elbow joint at (0,0) pointing along +x, hand centred at x = 57
void drawForearm(PGraphics g) {
  // hand first (sleeve overlaps the wrist)
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(SKIN);
  g.ellipse(53, -11, 14, 10);        // thumb
  g.ellipse(59, 0, 29, 23);          // palm
  g.stroke(SKIN_SH);
  g.strokeWeight(1.5);
  g.line(64, -6, 71, -5);
  g.line(65, 0, 72.5, 0.5);
  g.line(64, 6, 71, 6);

  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(COAT);
  capsule(g, 0, 46, 10.5, 9.5);
  // cuff
  g.fill(COAT_SH);
  g.rect(40, -10.5, 7, 21, 3);
  g.noFill();
  g.stroke(COAT_SH);
  g.strokeWeight(2);
  g.line(4, 5, 36, 5);
}

// rounded sleeve from x0 to x1 along +x with radii r0 -> r1
void capsule(PGraphics g, float x0, float x1, float r0, float r1) {
  g.beginShape();
  for (int i = 0; i <= 12; i++) {
    float a = HALF_PI + PI * i / 12.0;
    g.vertex(x0 + cos(a) * r0, sin(a) * r0);
  }
  for (int i = 0; i <= 12; i++) {
    float a = -HALF_PI + PI * i / 12.0;
    g.vertex(x1 + cos(a) * r1, sin(a) * r1);
  }
  g.endShape(CLOSE);
}

// ------------------------------------------------------------------ preview
void draw() {
  background(24, 26, 40);
  drawRig(170, 720, 1.0, 0);
  drawRig(450, 720, 1.0, 1);
  drawRig(730, 720, 1.0, 2);
  fill(255);
  textAlign(CENTER);
  text("parts saved to A_Piece_Of_Cake/data  -  close this window", width / 2, 30);
}

// pose 0 = arms down, 1 = hands together (clap), 2 = talking gesture
void drawRig(float x, float y, float s, int pose) {
  pushMatrix();
  translate(x, y);
  scale(s);
  imageMode(CORNER);
  image(pBody, -BODY_AX, -BODY_AY, BODY_W, BODY_H);
  image(pose == 2 ? pHeadTalk : pHead, -HEAD_AX, -228 - HEAD_AY, HEAD_W, HEAD_H);
  for (int side = -1; side <= 1; side += 2) {
    if (pose == 0) arm(side, 46 * side, -100, 1, 1);
    if (pose == 1) arm(side, 9 * side, -180, 1, 0.82);
    if (pose == 2) arm(side, side > 0 ? 84 : 42 * side, side > 0 ? -240 : -112, side > 0 ? -1 : 1, 1);
  }
  popMatrix();
}

// two-bone IK. bend = 1 puts the elbow out to the side, -1 tucks it under.
// fore = forearm length factor (< 1 fakes the arm pointing at the camera).
void arm(int side, float hx, float hy, int bend, float fore) {
  float L1 = 58, L2 = 57 * fore;
  float sx = 34 * side, sy = -206;
  float dx = hx - sx, dy = hy - sy;
  float d = constrain(sqrt(dx * dx + dy * dy), abs(L1 - L2) + 0.5, L1 + L2 - 0.5);
  float a = atan2(dy, dx);
  float b = acos(constrain((L1 * L1 + d * d - L2 * L2) / (2 * L1 * d), -1, 1));
  float u = a - b * side * bend;
  float ex = sx + cos(u) * L1, ey = sy + sin(u) * L1;
  float f = atan2(hy - ey, hx - ex);
  pushMatrix();
  translate(sx, sy);
  rotate(u);
  if (side < 0) scale(1, -1);
  image(pUpper, -UP_AX, -UP_AY, UP_W, UP_H);
  popMatrix();
  pushMatrix();
  translate(ex, ey);
  rotate(f);
  scale(fore, side < 0 ? -1 : 1);
  image(pFore, -FORE_AX, -FORE_AY, FORE_W, FORE_H);
  popMatrix();
}
