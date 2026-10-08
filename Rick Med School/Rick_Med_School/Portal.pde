// The green portal: a swirling ellipse of goo (intro, scene wipes, flourishes).

final int[] PORTAL_RINGS = { #145E18, #23862A, #3DBB3C, #7CFF6B, #C8FF9C, #74E46A, #2F9C31, #176A1B, #0C3F0F };

void drawPortal(float cx, float cy, float rx, float ry, float spin, float a) {
  if (rx < 1) return;
  noStroke();
  // glow
  for (int i = 7; i >= 1; i--) {
    fill(120, 255, 90, a * 0.045);
    ellipse(cx, cy, rx * 2 * (1 + i * 0.07), ry * 2 * (1 + i * 0.07));
  }
  // wobbling rim
  fill(PORTAL_RINGS[0], a);
  beginShape();
  for (int i = 0; i < 48; i++) {
    float t = TWO_PI * i / 48;
    float w = 1 + 0.045 * sin(t * 5 + spin * 2) + 0.03 * sin(t * 9 - spin * 3);
    vertex(cx + cos(t) * rx * w, cy + sin(t) * ry * w);
  }
  endShape(CLOSE);
  // liquid layers, each a little off-centre so it churns
  for (int i = 1; i < PORTAL_RINGS.length; i++) {
    float k = 1 - i / (float) PORTAL_RINGS.length;
    float ox = sin(spin * 1.3 + i) * rx * 0.03, oy = cos(spin * 1.1 + i * 2) * ry * 0.03;
    fill(PORTAL_RINGS[i], a);
    ellipse(cx + ox, cy + oy, rx * 2 * k, ry * 2 * k);
  }
  // spiral arms
  noFill();
  for (int arm = 0; arm < 6; arm++) {
    stroke(arm % 2 == 0 ? #D8FFB8 : #2E8B30, a * (arm % 2 == 0 ? 0.75 : 0.6));
    strokeWeight(max(1, rx * 0.025));
    beginShape();
    for (float t = 0.06; t <= 0.95; t += 0.03) {
      float ang = spin * 1.6 + arm * TWO_PI / 6 + t * 5.5;
      vertex(cx + cos(ang) * rx * t, cy + sin(ang) * ry * t);
    }
    endShape();
  }
  noStroke();
  fill(#E9FFD6, a * 0.8);
  ellipse(cx, cy, rx * 0.16, ry * 0.16);
}

// a portal that opens / closes over time (used in the intro)
class PortalFx {
  float x, y, rx, ry, open, target;

  PortalFx(float x, float y, float rx, float ry) {
    this.x = x;
    this.y = y;
    this.rx = rx;
    this.ry = ry;
  }

  void update(float dt) {
    open += (target - open) * min(1, dt * 6);
  }

  void draw() {
    float k = open < 0.01 ? 0 : open * (1 + 0.04 * sin(T * 9));
    drawPortal(x, y, rx * k, ry * k, T * 2.2, 255);
  }
}
