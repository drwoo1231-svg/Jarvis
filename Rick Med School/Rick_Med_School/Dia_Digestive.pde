// Digestive system, anterior view (subject's right = viewer's left).
// Liver upper viewer-left with the gallbladder beneath it; stomach viewer-right;
// pancreas head in the C of the duodenum, body under the stomach; small intestine
// coiled centrally, framed by the large intestine: cecum + appendix lower left,
// ascending up the left, transverse across, descending down the right, sigmoid
// curving into the rectum.

class DigestiveDiagram extends Diagram {
  final int ESO = #D9827E, ESO_SH = #B35E5B, ESO_LT = #F2B3AD;
  final int STO = D_STOMACH, STO_SH = #C66F6E, STO_LT = #F8C9C4;
  final int LIV = D_LIVER, LIV_SH = #692A20, LIV_LT = #B65E4E;
  final int GB = #6DAE58, GB_SH = #4A873C, GB_LT = #A9D891, BILE = #4E9440;
  final int PAN = #F2C47E, PAN_SH = #CF9A53, PAN_LT = #FAE0B2;
  final int DUO = #EE9E86, DUO_SH = #C9775F, DUO_LT = #F8C7B6;
  final int GUT = D_GUT, GUT_SH = #CF8A74, GUT_LT = #F9D3C5;
  final int COL = D_COLON, COL_SH = #B0664B, COL_LT = #EDB59D;

  final float[] LIVER_C = { 58, 200, 72, 150, 112, 112, 176, 96, 250, 95, 306, 103, 346, 121, 373, 144, 382, 165, 356, 178, 310, 196, 262, 218, 222, 236, 185, 252, 140, 265, 95, 266, 66, 245 };
  final float[] GB_C = { 194, 234, 212, 236, 226, 256, 229, 278, 218, 293, 202, 292, 192, 274, 189, 252 };
  final float[] STO_C = { 352, 160, 356, 134, 380, 114, 418, 107, 458, 121, 488, 151, 501, 198, 495, 246, 469, 284, 424, 305, 378, 305, 340, 293, 316, 281, 305, 266, 315, 251, 341, 251, 367, 237, 379, 210, 378, 182, 374, 162 };
  final float[] PAN_C = { 262, 284, 296, 292, 330, 302, 380, 300, 430, 293, 468, 284, 484, 292, 472, 307, 430, 318, 380, 328, 336, 332, 306, 338, 290, 346, 264, 348, 248, 332, 246, 306 };
  final float[] ESO_C = { 316, 10, 318, 50, 326, 95, 342, 132, 366, 164 };
  final float[] DUO_C = { 314, 266, 286, 265, 258, 271, 238, 287, 229, 311, 238, 334, 266, 346, 300, 347, 326, 342, 340, 340 };
  // large intestine centreline: ascending (from the cecum) -> transverse -> descending -> sigmoid -> rectum
  final float[] LI_C = { 132, 468, 128, 430, 124, 380, 124, 330, 133, 303, 158, 296, 186, 320, 214, 356, 252, 384, 300, 395, 360, 393, 412, 378, 448, 352, 470, 322, 487, 297, 507, 285, 525, 295, 533, 322, 531, 360, 524, 410, 516, 462, 506, 500, 482, 522, 440, 523, 400, 512, 362, 518, 332, 532, 314, 551, 306, 574, 304, 592 };
  final float[] CEC_C = { 112, 462, 132, 458, 152, 462, 168, 480, 162, 503, 140, 515, 116, 508, 104, 484 };
  final float[] APP_C = { 152, 508, 160, 528, 170, 547, 166, 561, 156, 558 };

  float[] liver, gb, sto, pan, eso, duo, li, si, app, cec;
  float sHep, sSpl, sSig, sRect, sEnd;   // arc lengths along the large intestine

  DigestiveDiagram() {
    super("digestive", "Digestive System");
    liver = cr(LIVER_C, true, 8);
    gb = cr(GB_C, true, 8);
    sto = cr(STO_C, true, 8);
    pan = cr(PAN_C, true, 8);
    eso = cr(ESO_C, false, 10);
    duo = cr(DUO_C, false, 10);
    li = cr(LI_C, false, 10);
    si = coil();
    app = cr(APP_C, false, 8);
    cec = cr(CEC_C, true, 8);
    sEnd = len(li);
    sHep = arcNear(li, 142, 297);        // hepatic flexure
    sSpl = arcNear(li, 512, 286);        // splenic flexure
    sSig = arcAtY(li, 470, false);       // pelvic brim: descending -> sigmoid
    sRect = arcNear(li, 332, 532);       // rectosigmoid junction

    add("liver", "Liver").poly(liver).anchor(170, 170);
    add("pancreas", "Pancreas").poly(pan).anchor(400, 318);
    add("stomach", "Stomach").poly(sto).anchor(440, 210);
    add("duodenum", "Duodenum").poly(tubePoly(sub(duo, 4, 999), 28)).anchor(231, 312);
    Part s = add("small_intestine", "Small Intestine");
    s.poly(150, 430, 200, 410, 300, 416, 400, 402, 470, 404, 496, 440, 496, 492, 460, 512, 360, 528, 300, 532, 240, 530, 190, 522, 168, 500, 150, 462);
    s.poly(tubePoly(sub(si, 0, 60), 28));
    s.anchor(310, 470);
    add("esophagus", "Esophagus").poly(tubePoly(sub(eso, 0, len(eso) - 10), 30)).anchor(320, 60);
    add("gallbladder", "Gallbladder").poly(gb).anchor(212, 272);
    add("ascending_colon", "Ascending Colon").poly(tubePoly(sub(li, 0, sHep), 48)).anchor(124, 380);
    add("transverse_colon", "Transverse Colon").poly(tubePoly(sub(li, sHep, sSpl), 48)).anchor(300, 394);
    add("descending_colon", "Descending Colon").poly(tubePoly(sub(li, sSpl, sSig), 48)).anchor(528, 400);
    add("sigmoid_colon", "Sigmoid Colon").poly(tubePoly(sub(li, sSig, sRect), 40)).anchor(428, 520);
    add("rectum", "Rectum").poly(tubePoly(sub(li, sRect, sEnd), 48)).anchor(312, 560);
    add("cecum", "Cecum").poly(scaled(cec, 136, 480, 1.08, 0, 0)).anchor(136, 484);
    add("appendix", "Appendix").poly(tubePoly(app, 20)).anchor(164, 540);
  }

  // arc length where the path first crosses height y (rising = going up the page)
  float arcAtY(float[] p, float y, boolean rising) {
    float acc = 0;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float y0 = p[i + 1], y1 = p[i + 3], d = dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
      if (rising ? (y0 >= y && y1 < y) : (y0 < y && y1 >= y)) return acc + d * (y0 - y) / (y0 - y1);
      acc += d;
    }
    return acc;
  }

  float arcNear(float[] p, float x, float y) {
    float acc = 0, best = 1e9, at = 0;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float d = dist(p[i], p[i + 1], x, y);
      if (d < best) {
        best = d;
        at = acc;
      }
      acc += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    }
    return at;
  }

  // jejunum + ileum: rows of overlapping loops from the duodenojejunal flexure to the cecum
  float[] coil() {
    FloatList p = new FloatList();
    float[] lead = { 340, 340, 352, 356, 372, 384, 410, 406, 446, 424 };
    for (float v : lead) p.append(v);
    coilRow(p, 446, 190, 440, -1);
    coilRow(p, 190, 470, 474, 1);
    coilRow(p, 470, 196, 508, -1);
    float[] tail = { 184, 500, 174, 488, 166, 474 };
    for (float v : tail) p.append(v);
    return p.array();
  }

  void coilRow(FloatList p, float xa, float xb, float yc, int dir) {
    float span = abs(xb - xa), b = 12;
    int loops = max(1, round(span / 48));
    float a = span / (loops * TWO_PI);
    for (int i = 1; i <= loops * 20; i++) {
      float t = i * TWO_PI / 20;
      p.append(xa + dir * (a * t - b * 0.9 * sin(t)));
      p.append(yc - b * cos(t) - 4);
    }
  }

  void drawArt(PGraphics g) {
    // ---- liver
    shaded(g, liver, LIV, LIV_SH, LIV_LT, 0.94, 2.8);
    // falciform ligament + round ligament
    g.noFill();
    g.stroke(LIV_SH);
    g.strokeWeight(2.4);
    g.bezier(292, 98, 296, 140, 286, 180, 276, 210);
    g.stroke(#E8C9A8);
    g.strokeWeight(1.4);
    g.bezier(294, 100, 298, 140, 288, 180, 278, 210);

    // ---- bile ducts (behind the duodenum) and pancreas
    g.stroke(D_INK);
    g.strokeWeight(8);
    g.noFill();
    g.bezier(236, 226, 236, 246, 240, 270, 244, 318);
    g.bezier(206, 240, 214, 250, 226, 252, 236, 252);
    g.stroke(BILE);
    g.strokeWeight(5);
    g.bezier(236, 226, 236, 246, 240, 270, 244, 318);
    g.bezier(206, 240, 214, 250, 226, 252, 236, 252);
    shaded(g, pan, PAN, PAN_SH, PAN_LT, 0.9, 2.4);
    lobules(g, pan, PAN_SH, 11);
    // main pancreatic duct
    g.noFill();
    g.stroke(PAN_SH);
    g.strokeWeight(2.4);
    g.bezier(470, 294, 420, 306, 330, 316, 250, 320);

    // ---- stomach + esophagus
    tube(g, eso, 26, ESO, ESO_SH, ESO_LT, true);
    cutEnd(g, eso, true, 26, ESO_SH);
    // longitudinal muscle lines on the esophagus
    g.stroke(ESO_SH, 140);
    g.strokeWeight(1.2);
    polyline(g, offset(sub(eso, 4, len(eso) - 6), 5));
    shadedPlain(g, sto, STO, STO_SH, 2.8);
    g.noStroke();
    g.fill(STO_LT, 150);
    g.pushMatrix();
    g.translate(436, 170);
    g.rotate(0.5);
    g.ellipse(0, 0, 70, 44);
    g.popMatrix();
    g.fill(255, 120);
    g.ellipse(418, 146, 20, 11);
    // gastric rugae
    g.noFill();
    g.stroke(STO_SH, 170);
    g.strokeWeight(1.8);
    polyline(g, cr(new float[] { 398, 132, 450, 140, 478, 182, 474, 236, 444, 274, 396, 288 }, false, 8));
    polyline(g, cr(new float[] { 392, 156, 436, 168, 455, 206, 448, 246, 420, 270, 380, 278 }, false, 8));
    polyline(g, cr(new float[] { 398, 196, 420, 220, 410, 250, 380, 264, 346, 270 }, false, 8));
    // pyloric sphincter
    g.stroke(STO_SH);
    g.strokeWeight(5);
    g.line(316, 254, 318, 279);
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.line(312, 253, 313, 280);
    g.line(321, 253, 323, 280);

    // ---- duodenum (C around the pancreatic head)
    tube(g, duo, 24, DUO, DUO_SH, DUO_LT, false);
    folds(g, duo, 24, DUO_SH, 9, 6, 6);

    // ---- small intestine coils (jejunum -> ileum -> cecum)
    gutTube(g, si, 24, GUT, GUT_SH, GUT_LT);

    // ---- large intestine: one sacculated tube from cecum to anal canal
    colon(g);
    // appendix
    tube(g, app, 11, COL, COL_SH, COL_LT, true);
    // ---- gallbladder (fundus peeks below the liver edge)
    shaded(g, gb, GB, GB_SH, GB_LT, 0.86, 2.4);
  }

  // the colon: sacculated tube (haustra) with a taenia stripe, cecum pouch at the bottom
  void colon(PGraphics g) {
    float[] body = sub(li, 0, sEnd);
    float L = len(body);
    float[] poly = sacc(body);
    // cecum pouch (blind end) below the ascending colon
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(COL);
    polygon(g, cec);
    g.noStroke();
    g.fill(COL);
    polygon(g, poly);
    g.fill(COL_SH, 120);
    g.beginShape();
    for (int i = 0; i < cec.length; i += 2) if (cec[i + 1] > 470) g.vertex(cec[i], cec[i + 1]);
    g.endShape(CLOSE);
    g.strokeCap(SQUARE);
    g.noFill();
    g.stroke(COL_SH, 150);
    g.strokeWeight(7);
    polyline(g, offset(sub(body, 6, sRect + 6), -11));
    g.stroke(lerpColor(#C97C61, COL_SH, 0.5));
    g.strokeWeight(9);
    polyline(g, offset(sub(body, sRect + 8, L - 14), -10));
    g.strokeCap(ROUND);
    // haustral folds (none on the rectum)
    g.stroke(COL_SH);
    g.strokeWeight(2);
    for (float d = 27; d < sRect; d += 17) {
      float w = widthAt(d);
      float[] a = sub(body, d - 0.5, d + 0.5);
      float x = a[0], y = a[1], dx = a[a.length - 2] - a[0], dy = a[a.length - 1] - a[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
      float nx = -dy / m * w * 0.44, ny = dx / m * w * 0.44;
      g.bezier(x + nx, y + ny, x + nx * 0.4 + dx / m * 4, y + ny * 0.4 + dy / m * 4, x - nx * 0.4 + dx / m * 4, y - ny * 0.4 + dy / m * 4, x - nx, y - ny);
    }
    g.bezier(112, 486, 126, 494, 148, 494, 164, 484);
    // taenia coli
    g.stroke(COL_LT, 220);
    g.strokeWeight(4);
    polyline(g, offset(sub(body, 0, sRect), 6));
    g.line(140, 470, 142, 500);
    // transverse rectal folds + anal opening
    g.stroke(COL_SH);
    g.strokeWeight(2);
    g.noFill();
    g.arc(320, 548, 24, 10, 0.1, PI - 0.3);
    g.arc(310, 566, 22, 9, PI + 0.3, TWO_PI - 0.1);
    g.noStroke();
    g.fill(#8E4A36);
    g.ellipse(304, 591, 12, 4);
    // outlines (open at the top of the cecum so pouch and colon read as one)
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    polyline(g, poly);   // open at the cecum end (first and last points are the two start corners)
    g.beginShape();
    for (int i = 0; i < cec.length; i += 2) if (cec[i + 1] > 468) g.vertex(cec[i], cec[i + 1]);
    g.endShape();
  }

  float widthAt(float acc) {
    if (acc < sSig) return 42;
    if (acc < sRect) return lerp(42, 32, constrain((acc - sSig) / 40, 0, 1));
    if (acc < sEnd - 18) return lerp(32, 42, constrain((acc - sRect) / 22, 0, 1));   // rectal ampulla
    return lerp(42, 14, constrain((acc - (sEnd - 18)) / 18, 0, 1));                 // anal canal
  }

  // tube polygon whose edges bulge between haustral folds; inner-corner loops are dropped
  float[] sacc(float[] p) {
    int n = p.length / 2;
    FloatList l = new FloatList(), r = new FloatList();
    float acc = 0;
    for (int i = 0; i < n; i++) {
      if (i > 0) acc += dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      float bulge = acc < sRect ? 2.2 * abs(sin((acc - 10) / 17 * PI)) : 0;
      float w = widthAt(acc) / 2 + bulge;
      keep(l, p[i * 2] - dy / L * w, p[i * 2 + 1] + dx / L * w, dx, dy);
      keep(r, p[i * 2] + dy / L * w, p[i * 2 + 1] - dx / L * w, dx, dy);
    }
    float[] o = new float[l.size() + r.size()];
    for (int i = 0; i < l.size(); i++) o[i] = l.get(i);
    for (int i = 0; i < r.size() / 2; i++) {
      o[l.size() + i * 2] = r.get(r.size() - 2 - i * 2);
      o[l.size() + i * 2 + 1] = r.get(r.size() - 1 - i * 2);
    }
    return o;
  }

  void keep(FloatList side, float x, float y, float tx, float ty) {
    int k = side.size();
    if (k >= 2 && (x - side.get(k - 2)) * tx + (y - side.get(k - 1)) * ty <= 0) return;
    side.append(x);
    side.append(y);
  }

  // circular folds across a tube
  void folds(PGraphics g, float[] path, float w, int col, float step, float a, float b) {
    float L = len(path);
    g.noFill();
    g.stroke(col, 170);
    g.strokeWeight(1.5);
    for (float d = a; d < L - b; d += step) {
      float[] s = sub(path, d - 0.5, d + 0.5);
      float x = s[0], y = s[1], dx = s[s.length - 2] - s[0], dy = s[s.length - 1] - s[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
      float nx = -dy / m * w * 0.36, ny = dx / m * w * 0.36;
      g.line(x + nx, y + ny, x - nx, y - ny);
    }
  }

  // an overlapping coil drawn in short chunks so later loops lie on top of earlier ones
  void gutTube(PGraphics g, float[] path, float w, int col, int sh, int lt) {
    float L = len(path), step = 26;
    int shO = lerpColor(col, sh, 0.65), ltO = lerpColor(col, lt, 0.9), fold = lerpColor(col, sh, 0.45);
    for (float s = 0; s < L; s += step) {
      float e = min(L, s + step);
      float[] ink = sub(path, s, e);
      float[] fil = sub(path, max(0, s - 12), e);
      g.noFill();
      g.stroke(D_INK);
      g.strokeWeight(w + 5);
      polyline(g, ink);
      g.stroke(col);
      g.strokeWeight(w);
      polyline(g, fil);
      g.stroke(shO);
      g.strokeWeight(w * 0.22);
      polyline(g, offset(fil, -w * 0.28));
      g.stroke(ltO);
      g.strokeWeight(w * 0.16);
      polyline(g, offset(fil, w * 0.2));
      // circular folds (plicae) hint
      g.stroke(fold);
      g.strokeWeight(1.3);
      for (float d = s + 6; d < e - 2; d += 13) {
        float[] q = sub(path, d - 0.5, d + 0.5);
        float x = q[0], y = q[1], dx = q[q.length - 2] - q[0], dy = q[q.length - 1] - q[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
        float nx = -dy / m * w * 0.18, ny = dx / m * w * 0.18;
        g.line(x + nx * 0.2, y + ny * 0.2, x - nx * 1.6, y - ny * 1.6);
      }
    }
  }

  // darker rim + body fill without the offset highlight (for strongly concave shapes)
  void shadedPlain(PGraphics g, float[] p, int base, int sh, float sw) {
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, offsetClosed(p, 7));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  // closed polygon shrunk inward by d (points listed clockwise on screen)
  float[] offsetClosed(float[] p, float d) {
    int n = p.length / 2;
    float[] r = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = (i - 1 + n) % n, b = (i + 1) % n;
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      r[i * 2] = p[i * 2] - dy / L * d;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * d;
    }
    return r;
  }

  // bumpy glandular texture inside a shape
  void lobules(PGraphics g, float[] p, int col, int seed) {
    java.util.Random rnd = new java.util.Random(seed);
    g.noFill();
    g.stroke(col, 140);
    g.strokeWeight(1.2);
    float x0 = minX(p), y0 = minY(p);
    for (int i = 0; i < 90; i++) {
      float x = x0 + rnd.nextFloat() * 260, y = y0 + rnd.nextFloat() * 80;
      if (insideM(p, x, y, 6)) g.arc(x, y, 9, 7, PI * 0.1, PI * 1.1);
    }
  }

  boolean insideM(float[] p, float x, float y, float m) {
    return insidePoly(p, x, y) && insidePoly(p, x + m, y) && insidePoly(p, x - m, y) && insidePoly(p, x, y + m) && insidePoly(p, x, y - m);
  }

  // a vessel-like tube: fill, shade stripe, highlight stripe, ink outline
  void tube(PGraphics g, float[] path, float w, int col, int sh, int lt, boolean hlLeft) {
    float[] poly = tubePoly(path, w);
    g.noStroke();
    g.fill(col);
    polygon(g, poly);
    float L = len(path), trim = min(w * 0.35, L * 0.2);
    float[] inner = sub(path, trim, L - trim);
    float s = hlLeft ? 1 : -1;
    g.noFill();
    g.strokeCap(SQUARE);
    g.stroke(sh, 150);
    g.strokeWeight(w * 0.2);
    polyline(g, offset(inner, -s * w * 0.3));
    g.stroke(lt, 210);
    g.strokeWeight(w * 0.14);
    polyline(g, offset(inner, s * w * 0.2));
    g.strokeCap(ROUND);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    polygon(g, poly);
  }

  void cutEnd(PGraphics g, float[] path, boolean atStart, float w, int sh) {
    int n = path.length / 2;
    int i0 = atStart ? 0 : n - 1, i1 = atStart ? 1 : n - 2;
    float x = path[i0 * 2], y = path[i0 * 2 + 1];
    float ang = atan2(path[i0 * 2 + 1] - path[i1 * 2 + 1], path[i0 * 2] - path[i1 * 2]);
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(ang);
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(sh);
    g.ellipse(0, 0, w * 0.32, w - 1);
    g.popMatrix();
  }

  // ------------------------------------------------------------ helpers
  void shaded(PGraphics g, float[] p, int base, int sh, int lt, float k, float sw) {
    float[] c = centroid(p);
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, scaled(p, c[0], c[1], k, -3, -4));
    g.fill(lt, 80);
    polygon(g, scaled(p, c[0] - 0.25 * (c[0] - minX(p)), c[1] - 0.3 * (c[1] - minY(p)), 0.5, 0, 0));
    g.fill(lt, 90);
    polygon(g, scaled(p, c[0] - 0.3 * (c[0] - minX(p)), c[1] - 0.38 * (c[1] - minY(p)), 0.28, 0, 0));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  void dashed(PGraphics g, float[] p, float on, float off) {
    float acc = 0;
    boolean draw = true;
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3];
      float d = dist(x0, y0, x1, y1), t = 0;
      while (t < d) {
        float lim = (draw ? on : off) - acc, step = min(lim, d - t);
        if (draw) g.line(x0 + (x1 - x0) * t / d, y0 + (y1 - y0) * t / d, x0 + (x1 - x0) * (t + step) / d, y0 + (y1 - y0) * (t + step) / d);
        t += step;
        acc += step;
        if (acc >= (draw ? on : off) - 0.001) {
          acc = 0;
          draw = !draw;
        }
      }
    }
  }

  float[] cr(float[] c, boolean closed, int seg) {
    int n = c.length / 2, segs = closed ? n : n - 1;
    float[] r = new float[(segs * seg + (closed ? 0 : 1)) * 2];
    int k = 0;
    for (int i = 0; i < segs; i++) {
      int i0 = closed ? (i - 1 + n) % n : max(i - 1, 0), i2 = closed ? (i + 1) % n : i + 1, i3 = closed ? (i + 2) % n : min(i + 2, n - 1);
      for (int s = 0; s < seg; s++) {
        float t = s / (float) seg;
        r[k++] = crv(c[i0 * 2], c[i * 2], c[i2 * 2], c[i3 * 2], t);
        r[k++] = crv(c[i0 * 2 + 1], c[i * 2 + 1], c[i2 * 2 + 1], c[i3 * 2 + 1], t);
      }
    }
    if (!closed) {
      r[k++] = c[(n - 1) * 2];
      r[k++] = c[(n - 1) * 2 + 1];
    }
    return r;
  }

  float crv(float p0, float p1, float p2, float p3, float t) {
    return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
  }

  float len(float[] p) {
    float L = 0;
    for (int i = 0; i + 3 < p.length; i += 2) L += dist(p[i], p[i + 1], p[i + 2], p[i + 3]);
    return L;
  }

  float[] sub(float[] p, float a, float b) {
    ArrayList<Float> o = new ArrayList<Float>();
    float acc = 0;
    b = min(b, len(p));
    for (int i = 0; i + 3 < p.length; i += 2) {
      float x0 = p[i], y0 = p[i + 1], x1 = p[i + 2], y1 = p[i + 3], d = dist(x0, y0, x1, y1);
      if (d < 1e-4) continue;
      float s0 = acc, s1 = acc + d;
      if (s1 >= a && s0 <= b) {
        float ta = max(0, (a - s0) / d), tb = min(1, (b - s0) / d);
        if (o.size() == 0) {
          o.add(lerp(x0, x1, ta));
          o.add(lerp(y0, y1, ta));
        }
        o.add(lerp(x0, x1, tb));
        o.add(lerp(y0, y1, tb));
      }
      acc = s1;
    }
    float[] r = new float[o.size()];
    for (int i = 0; i < r.length; i++) r[i] = o.get(i);
    return r;
  }

  float[] offset(float[] p, float d) {
    int n = p.length / 2;
    float[] r = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      r[i * 2] = p[i * 2] - dy / L * d;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * d;
    }
    return r;
  }

  float[] tubePoly(float[] p0, float w) {
    float[] p = clean(p0);
    float[] l = offset(p, w / 2), rr = offset(p, -w / 2);
    int n = p.length / 2;
    float[] r = new float[p.length * 2];
    for (int i = 0; i < n; i++) {
      r[i * 2] = l[i * 2];
      r[i * 2 + 1] = l[i * 2 + 1];
      r[(2 * n - 1 - i) * 2] = rr[i * 2];
      r[(2 * n - 1 - i) * 2 + 1] = rr[i * 2 + 1];
    }
    return r;
  }

  // drop points closer than 1 unit to their neighbour (they make wild normals / miter spikes)
  float[] clean(float[] p) {
    FloatList o = new FloatList();
    for (int i = 0; i < p.length; i += 2) {
      int k = o.size();
      boolean last = i == p.length - 2;
      if (k >= 2 && dist(o.get(k - 2), o.get(k - 1), p[i], p[i + 1]) < 1) {
        if (last && k >= 4) {
          o.set(k - 2, p[i]);
          o.set(k - 1, p[i + 1]);
        }
        continue;
      }
      o.append(p[i]);
      o.append(p[i + 1]);
    }
    return o.array();
  }

  float[] centroid(float[] p) {
    float x = 0, y = 0;
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      x += p[i * 2];
      y += p[i * 2 + 1];
    }
    return new float[] { x / n, y / n };
  }

  float minX(float[] p) {
    float m = 1e9;
    for (int i = 0; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float minY(float[] p) {
    float m = 1e9;
    for (int i = 1; i < p.length; i += 2) m = min(m, p[i]);
    return m;
  }

  float[] scaled(float[] p, float cx, float cy, float k, float dx, float dy) {
    float[] r = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      r[i] = cx + (p[i] - cx) * k + dx;
      r[i + 1] = cy + (p[i + 1] - cy) * k + dy;
    }
    return r;
  }

  void polygon(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void polyline(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }
}
