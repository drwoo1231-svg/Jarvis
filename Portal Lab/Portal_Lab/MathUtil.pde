// Small helpers shared by every tab.

float easeOutBack(float t) {
  t = constrain(t, 0, 1);
  float c1 = 1.70158, c3 = c1 + 1;
  return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2);
}

float smooth01(float t) {
  t = constrain(t, 0, 1);
  return t * t * (3 - 2 * t);
}

String f1(float v) { return nf(v, 0, 1); }

// metres with 2 decimals, never "-0.00"
String fm(float v) {
  if (abs(v) < 0.005) v = 0;
  return nf(v, 0, 2);
}
String f2(float v) { return nf(v, 0, 2); }

// a whole number for display (nf(x, 0, 0) keeps up to three decimals)
String i0(float v) {
  return str(round(v));
}

// rounded rectangle in the current fill / stroke. rect(x, y, w, h, r) sends P3D through its slow
// polygon tessellator every call; a convex fan (fill) plus a closed line loop (outline) does not
void roundBox(float x, float y, float w, float h, float r) {
  r = min(r, min(w, h) / 2);
  if (g.fill) {
    pushStyle();
    noStroke();
    beginShape(TRIANGLE_FAN);
    vertex(x + w / 2, y + h / 2);
    roundBoxPath(x, y, w, h, r);
    vertex(x + w - r, y);              // close the fan
    endShape();
    popStyle();
  }
  if (g.stroke) {
    pushStyle();
    noFill();
    beginShape();
    roundBoxPath(x, y, w, h, r);
    endShape(CLOSE);
    popStyle();
  }
}

void roundBoxPath(float x, float y, float w, float h, float r) {
  for (int c = 0; c < 4; c++) {
    float cx = (c == 0 || c == 1) ? x + w - r : x + r;
    float cy = (c == 1 || c == 2) ? y + h - r : y + r;
    float a0 = -HALF_PI + c * HALF_PI;
    for (int i = 0; i <= 6; i++) {
      float a = a0 + HALF_PI * i / 6;
      vertex(cx + cos(a) * r, cy + sin(a) * r);
    }
  }
}

