// Draws a diagram on a "whiteboard" panel and turns the mouse into part hits.
// Marks (part -> colour) light parts up; hover outlines the part under the mouse.

class DiagramView {
  Diagram d;
  float x, y, size;
  boolean hoverOn = true, labelsOn;
  Part hover;
  HashMap<String, Integer> marks = new HashMap<String, Integer>();
  String pulse;                 // a part that pulses (lesson focus)
  int pulseCol = C_GOLD;

  void set(Diagram d, float x, float y, float size) {
    if (this.d != d) marks.clear();
    this.d = d;
    this.x = x;
    this.y = y;
    this.size = size;
  }

  float s() {
    return size / DIA;
  }

  boolean mouseIn() {
    return mouseX >= x && mouseX <= x + size && mouseY >= y && mouseY <= y + size;
  }

  void update() {
    hover = null;
    if (d != null && hoverOn && mouseIn()) hover = d.hit((mouseX - x) / s(), (mouseY - y) / s());
  }

  Part hitMouse() {
    if (d == null || !mouseIn()) return null;
    return d.hit((mouseX - x) / s(), (mouseY - y) / s());
  }

  void draw() {
    if (d == null) return;
    float pad = 14;
    noStroke();
    fill(0, 110);
    rect(x - pad + 6, y - pad + 8, size + pad * 2, size + pad * 2, 18);
    fill(C_PAPER);
    stroke(C_PAPER_EDGE);
    strokeWeight(3);
    rect(x - pad, y - pad, size + pad * 2, size + pad * 2, 18);
    // faint grid like a lab notebook
    stroke(#E6DDC6);
    strokeWeight(1);
    for (float gx = x + 30; gx < x + size; gx += 30) line(gx, y - pad + 4, gx, y + size + pad - 4);
    for (float gy = y + 30; gy < y + size; gy += 30) line(x - pad + 4, gy, x + size + pad - 4, gy);
    image(d.art(), x, y, size, size);
    for (String pid : marks.keySet()) {
      Part p = d.part(pid);
      if (p != null) drawPart(p, marks.get(pid), 120, 3.5);
    }
    if (pulse != null) {
      Part p = d.part(pulse);
      if (p != null) drawPart(p, pulseCol, 70 + 70 * (0.5 + 0.5 * sin(T * 5)), 3);
    }
    if (hover != null && !marks.containsKey(hover.id)) drawPart(hover, C_BLUE, 55, 2.5);
    if (labelsOn) drawAllLabels();
  }

  void drawPart(Part p, int c, float fillA, float sw) {
    float s = s();
    for (int pass = 0; pass < 2; pass++) {
      if (pass == 0) {
        noFill();
        stroke(c, 70);
        strokeWeight(sw + 6);
      } else {
        fill(c, fillA);
        stroke(c);
        strokeWeight(sw);
      }
      for (float[] sh : p.shapes) {
        beginShape();
        for (int i = 0; i < sh.length; i += 2) vertex(x + sh[i] * s, y + sh[i + 1] * s);
        endShape(CLOSE);
      }
    }
  }

  // a name tag next to the part, with a leader line
  void tag(Part p, String text, int c) {
    tag(p, text, c, false);
  }

  void tag(Part p, String text, int c, boolean below) {
    float[] a = p.anchorPt();
    float ax = x + a[0] * s(), ay = y + a[1] * s();
    textFont(fBodyB);
    float tw = textWidth(text) + 22;
    float tx = constrain(ax - tw / 2, x - 10, x + size + 10 - tw), ty = below ? ay + 26 : ay - 58;
    if (ty < y - 6) ty = ay + 26;
    stroke(c);
    strokeWeight(2.5);
    line(ax, ay, tx + tw / 2, ty + (ty < ay ? 34 : 0));
    noStroke();
    fill(c);
    ellipse(ax, ay, 9, 9);
    fill(#141824, 235);
    stroke(c);
    strokeWeight(2);
    rect(tx, ty, tw, 34, 10);
    fill(C_TEXT);
    textAlign(CENTER, CENTER);
    text(text, tx + tw / 2, ty + 16);
  }

  // every part labelled, in two columns beside the board (study mode)
  void drawAllLabels() {
    ArrayList<Part> left = new ArrayList<Part>(), right = new ArrayList<Part>();
    for (Part p : d.parts) {
      if (p.anchorPt()[0] < DIA / 2) left.add(p);
      else right.add(p);
    }
    drawLabelColumn(left, true);
    drawLabelColumn(right, false);
  }

  void drawLabelColumn(ArrayList<Part> ps, boolean leftSide) {
    // sort by anchor y, then spread so tags don't overlap
    java.util.Collections.sort(ps, new java.util.Comparator<Part>() {
      public int compare(Part a, Part b) {
        return Float.compare(a.anchorPt()[1], b.anchorPt()[1]);
      }
    });
    textFont(fSmall);
    float gap = 22, prev = -1e9;
    float[] ys = new float[ps.size()];
    for (int i = 0; i < ps.size(); i++) {
      float want = y + ps.get(i).anchorPt()[1] * s();
      ys[i] = max(want, prev + gap);
      prev = ys[i];
    }
    float over = prev - (y + size);
    if (over > 0) for (int i = 0; i < ys.length; i++) ys[i] -= over;
    for (int i = 0; i < ps.size(); i++) {
      Part p = ps.get(i);
      float[] a = p.anchorPt();
      float ax = x + a[0] * s(), ay = y + a[1] * s();
      float lx = leftSide ? x - 24 : x + size + 24;
      boolean hot = hover == p;
      stroke(hot ? C_GOLD : #8B7E5E, hot ? 255 : 170);
      strokeWeight(hot ? 2 : 1.2);
      line(ax, ay, lx + (leftSide ? 6 : -6), ys[i]);
      noStroke();
      fill(hot ? C_GOLD : #5A4E36);
      ellipse(ax, ay, 5, 5);
      fill(hot ? C_GOLD : C_TEXT);
      textAlign(leftSide ? RIGHT : LEFT, CENTER);
      text(partName(d.id, p.id), lx, ys[i]);
    }
  }
}
