// Lungs + respiratory tree, anterior view (subject's right = viewer's left).
// Right lung: 3 lobes (horizontal + oblique fissures). Left lung: 2 lobes, cardiac
// notch with the heart peeking out behind it. Right main bronchus wider, shorter,
// more vertical. Bronchioles branch inside both lungs; alveoli in a magnified inset.

class LungsDiagram extends Diagram {
  final int AIR = #E7EDF4, AIR_SH = #AFC0D4, AIR_RING = #C3CFDE, AIR_LT = #FFFFFF;
  final int LUNG = #F09CAA, LUNG_SH = #D27A8C, LUNG_LT = #F9C9D1;
  final int ALV = #F5B0BC, ALV_SH = #D8818F;

  final float[] RL_C = { 196, 98, 228, 114, 250, 156, 261, 218, 265, 284, 258, 312, 262, 345, 263, 400, 260, 452, 256, 473, 228, 466, 160, 459, 105, 469, 72, 490, 56, 506, 47, 445, 47, 350, 60, 258, 96, 168, 148, 115 };
  final float[] LL_C = { 404, 98, 452, 116, 502, 170, 537, 250, 552, 340, 554, 430, 546, 514, 520, 494, 452, 478, 400, 484, 360, 490, 351, 474, 370, 455, 402, 438, 408, 400, 392, 366, 352, 345, 341, 322, 344, 296, 337, 232, 345, 162, 370, 116 };
  final float[] DIA_TOP = { 30, 566, 48, 520, 90, 483, 160, 465, 230, 474, 300, 494, 370, 491, 452, 484, 522, 499, 556, 530, 572, 572 };
  final float[] RL_HFIS = { 263, 290, 200, 292, 130, 296, 56, 302 };
  final float[] RL_OFIS = { 53, 268, 64, 312, 100, 380, 150, 430, 196, 462 };
  final float[] LL_OFIS = { 537, 262, 532, 320, 496, 390, 456, 446, 428, 481 };
  // airway: trachea x 281..319 down to y 236, then two straight main bronchi
  final float TR_L = 281, TR_R = 319, TR_TOP = 108, TR_BOT = 236;
  final float[] RMB = { 293, 250, 252, 330 };   // wide (30), short, steep
  final float[] LMB = { 309, 250, 392, 318 };   // narrow (23), long, more horizontal
  final float W_RMB = 30, W_LMB = 23;

  float[] rl, ll, diaTop, diaBot, dia, rmb, lmb;
  float[] yOut1, yOut2, yOut3, yPoly;   // airway silhouette (3 open outline runs + filled polygon)
  float carX, carY;
  ArrayList<float[]> segs = new ArrayList<float[]>();   // x0, y0, x1, y1, width, lobe, depth
  final float BUB_X = 524, BUB_Y = 76, BUB_R = 55;

  LungsDiagram() {
    super("lungs", "Respiratory Tree");
    rl = cr(RL_C, true, 8);
    ll = cr(LL_C, true, 8);
    diaTop = cr(DIA_TOP, false, 10);
    diaBot = offset(diaTop, 28);
    dia = new float[diaTop.length * 2];
    int n = diaTop.length / 2;
    for (int i = 0; i < n; i++) {
      dia[i * 2] = diaTop[i * 2];
      dia[i * 2 + 1] = diaTop[i * 2 + 1];
      dia[(2 * n - 1 - i) * 2] = diaBot[i * 2];
      dia[(2 * n - 1 - i) * 2 + 1] = min(DIA - 4, diaBot[i * 2 + 1]);
    }
    rmb = RMB;
    lmb = LMB;
    buildAirway();

    // ---- bronchial tree (lobar -> segmental -> bronchioles), kept inside each lung
    // right lung: upper lobe, middle lobe, lower lobe
    grow(262, 318, radians(-128), 52, 13, 0, 3, rl, 0);
    grow(255, 338, radians(122), 50, 12, 0, 3, rl, 1);
    grow(252, 336, radians(146), 70, 12, 0, 3, rl, 2);
    // left lung: upper lobe, lingula, lower lobe
    grow(390, 318, radians(-62), 58, 11, 0, 3, ll, 3);
    grow(394, 326, radians(52), 70, 11, 0, 3, ll, 5);

    add("right_lung", "Right Lung").poly(rl).anchor(140, 250);
    add("left_lung", "Left Lung").poly(ll).anchor(470, 300);
    add("diaphragm", "Diaphragm").poly(dia).anchor(96, 504);
    add("cardiac_notch", "Cardiac Notch")
      .poly(342, 338, 372, 348, 400, 366, 418, 400, 412, 444, 376, 462, 352, 470, 336, 452, 330, 400, 332, 360)
      .anchor(392, 408);
    Part b = add("bronchioles", "Bronchioles");
    for (int lobe = 0; lobe < 6; lobe++) {
      float[] h = hullOfLobe(lobe, 2, 6);
      if (h != null) b.poly(h);
    }
    b.anchor(176, 228);
    add("trachea", "Trachea").rect(279, 108, 42, 134).anchor(300, 175);
    add("larynx", "Larynx").poly(260, 26, 340, 26, 342, 50, 338, 70, 330, 94, 325, 109, 275, 109, 270, 94, 262, 70, 258, 50).anchor(300, 62);
    add("right_main_bronchus", "Right Main Bronchus").poly(tubePoly(sub(rmb, 4, 999), W_RMB + 6)).anchor(272, 292);
    add("left_main_bronchus", "Left Main Bronchus").poly(tubePoly(sub(lmb, 4, 999), W_LMB + 6)).anchor(352, 286);
    add("carina", "Carina").ellipse(carX, carY - 6, 15, 13);
    add("alveoli", "Alveoli").ellipse(BUB_X, BUB_Y, BUB_R + 2, BUB_R + 2);
  }

  // recursive airway branching; each child is shortened until it stays inside the lung
  void grow(float x, float y, float ang, float L, float w, int depth, int maxD, float[] lung, int lobe) {
    float x1 = 0, y1 = 0;
    int tries = 0;
    for (; tries < 6; tries++) {
      x1 = x + cos(ang) * L;
      y1 = y + sin(ang) * L;
      if (insideM(lung, x1, y1, 9)) break;
      L *= 0.75;
    }
    if (tries >= 6 || L < 7) return;
    segs.add(new float[] { x, y, x1, y1, w, lobe, depth });
    if (depth >= maxD) return;
    float sp = 0.42 + 0.05 * depth;
    grow(x1, y1, ang - sp, L * 0.74, w * 0.62, depth + 1, maxD, lung, lobe);
    grow(x1, y1, ang + sp * 0.85, L * 0.7, w * 0.62, depth + 1, maxD, lung, lobe);
  }

  boolean insideM(float[] p, float x, float y, float m) {
    return insidePoly(p, x, y) && insidePoly(p, x + m, y) && insidePoly(p, x - m, y) && insidePoly(p, x, y + m) && insidePoly(p, x, y - m);
  }

  // convex hull (inflated) around the bronchiole-level segments of one lobe
  float[] hullOfLobe(int lobe, int minDepth, float pad) {
    ArrayList<float[]> pts = new ArrayList<float[]>();
    for (float[] s : segs) {
      if ((int) s[5] != lobe || s[6] < minDepth) continue;
      for (int k = 0; k < 8; k++) {
        float a = TWO_PI * k / 8;
        pts.add(new float[] { s[0] + cos(a) * pad, s[1] + sin(a) * pad });
        pts.add(new float[] { s[2] + cos(a) * pad, s[3] + sin(a) * pad });
      }
    }
    if (pts.size() < 3) return null;
    java.util.Collections.sort(pts, new java.util.Comparator<float[]>() {
      public int compare(float[] a, float[] b) {
        return a[0] != b[0] ? Float.compare(a[0], b[0]) : Float.compare(a[1], b[1]);
      }
    });
    int n = pts.size(), k = 0;
    float[][] h = new float[2 * n][];
    for (int i = 0; i < n; i++) {
      while (k >= 2 && crossZ(h[k - 2], h[k - 1], pts.get(i)) <= 0) k--;
      h[k++] = pts.get(i);
    }
    for (int i = n - 2, t = k + 1; i >= 0; i--) {
      while (k >= t && crossZ(h[k - 2], h[k - 1], pts.get(i)) <= 0) k--;
      h[k++] = pts.get(i);
    }
    float[] r = new float[(k - 1) * 2];
    for (int i = 0; i < k - 1; i++) {
      r[i * 2] = h[i][0];
      r[i * 2 + 1] = h[i][1];
    }
    return r;
  }

  float crossZ(float[] o, float[] a, float[] b) {
    return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  }

  void drawArt(PGraphics g) {
    // ---- heart peeking out behind the cardiac notch (no part: context only)
    g.stroke(D_INK, 110);
    g.strokeWeight(2);
    g.fill(D_HEART, 80);
    g.beginShape();
    g.vertex(282, 384);
    g.bezierVertex(300, 360, 340, 350, 372, 352);
    g.bezierVertex(398, 352, 418, 372, 424, 404);
    g.bezierVertex(430, 440, 436, 470, 440, 492);
    g.bezierVertex(400, 500, 330, 500, 290, 494);
    g.bezierVertex(268, 470, 266, 414, 282, 384);
    g.endShape(CLOSE);
    g.noFill();
    g.stroke(D_HEART, 120);
    g.strokeWeight(2.4);
    g.bezier(352, 356, 360, 400, 392, 450, 430, 488);
    // ---- diaphragm
    g.noStroke();
    g.fill(D_MUSCLE);
    polygon(g, dia);
    // central tendon
    g.fill(D_TENDON);
    g.beginShape();
    for (int i = 0; i < diaTop.length; i += 2) if (diaTop[i] > 215 && diaTop[i] < 395) g.vertex(diaTop[i], diaTop[i + 1]);
    for (int i = diaBot.length - 2; i >= 0; i -= 2) if (diaBot[i] > 235 && diaBot[i] < 375) g.vertex(diaBot[i], diaBot[i + 1]);
    g.endShape(CLOSE);
    // muscle fibres
    g.stroke(#A8423B, 150);
    g.strokeWeight(1.3);
    for (int i = 0; i < diaTop.length; i += 6) {
      float x = diaTop[i];
      if (x > 205 && x < 400) continue;
      g.line(diaTop[i], diaTop[i + 1] + 3, diaBot[i], diaBot[i + 1] - 3);
    }
    g.stroke(D_MUSCLE_LT, 200);
    g.strokeWeight(3);
    g.noFill();
    polyline(g, sub(offset(diaTop, 6), 8, len(diaTop) - 8));
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.noFill();
    polygon(g, dia);

    // ---- lungs
    shaded(g, rl, LUNG, LUNG_SH, LUNG_LT, 0.93, 2.8);
    shaded(g, ll, LUNG, LUNG_SH, LUNG_LT, 0.93, 2.8);
    // lobule texture
    g.noStroke();
    g.fill(LUNG_SH, 60);
    java.util.Random rnd = new java.util.Random(7);   // local RNG: never touch the sketch's random()
    for (int i = 0; i < 260; i++) {
      float x = 40 + rnd.nextFloat() * 520, y = 90 + rnd.nextFloat() * 420;
      if ((insideM(rl, x, y, 6) || insideM(ll, x, y, 6)) && !(x > BUB_X - BUB_R - 10 && y < BUB_Y + BUB_R + 10)) g.ellipse(x, y, 3.2, 3.2);
    }

    // ---- bronchial tree inside the lungs
    g.stroke(D_INK);
    for (float[] s : segs) {
      g.strokeWeight(s[4] + 2.6);
      g.line(s[0], s[1], s[2], s[3]);
    }
    for (float[] s : segs) {
      g.stroke(s[6] >= 2 ? #F4F0F7 : AIR);
      g.strokeWeight(s[4]);
      g.line(s[0], s[1], s[2], s[3]);
    }
    g.stroke(AIR_LT, 200);
    for (float[] s : segs) {
      if (s[4] < 5) continue;
      g.strokeWeight(s[4] * 0.28);
      g.line(lerp(s[0], s[2], 0.15) - 1, lerp(s[1], s[3], 0.15) - 1, lerp(s[0], s[2], 0.85) - 1, lerp(s[1], s[3], 0.85) - 1);
    }

    // ---- fissures (drawn on the lung surface)
    g.noFill();
    g.stroke(#8E3F52);
    g.strokeWeight(2.6);
    polyline(g, cr(RL_HFIS, false, 8));
    polyline(g, cr(RL_OFIS, false, 8));
    polyline(g, cr(LL_OFIS, false, 8));
    g.stroke(LUNG_LT);
    g.strokeWeight(1.2);
    polyline(g, offset(cr(RL_HFIS, false, 8), 2.5));
    polyline(g, offset(cr(RL_OFIS, false, 8), 2.5));
    polyline(g, offset(cr(LL_OFIS, false, 8), 2.5));

    // ---- airway: trachea + main bronchi as one Y, then the larynx on top
    airwayY(g);
    larynx(g);

    // ---- alveoli: magnified inset
    alveoliInset(g);
  }

  // offset line of a straight segment: {x0, y0, x1, y1} shifted along its left normal
  float[] edge(float[] seg, float off) {
    float dx = seg[2] - seg[0], dy = seg[3] - seg[1], L = sqrt(dx * dx + dy * dy);
    float nx = -dy / L * off, ny = dx / L * off;
    return new float[] { seg[0] + nx, seg[1] + ny, seg[2] + nx, seg[3] + ny };
  }

  float[] intersect(float[] a, float[] b) {
    float x1 = a[0], y1 = a[1], x2 = a[2], y2 = a[3], x3 = b[0], y3 = b[1], x4 = b[2], y4 = b[3];
    float d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / d;
    return new float[] { x1 + t * (x2 - x1), y1 + t * (y2 - y1) };
  }

  void buildAirway() {
    float[] rLat = edge(RMB, W_RMB / 2), rMed = edge(RMB, -W_RMB / 2);   // RMB runs down-left: +normal = lateral
    float[] lMed = edge(LMB, W_LMB / 2), lLat = edge(LMB, -W_LMB / 2);   // LMB runs down-right: +normal = medial
    float[] c = intersect(rMed, lMed);
    carX = c[0];
    carY = c[1];
    yOut1 = new float[] { TR_L, TR_TOP, TR_L, TR_BOT - 6, TR_L - 0.5, TR_BOT, rLat[0] + 0.5, rLat[1] - 2, rLat[2], rLat[3] };
    yOut2 = new float[] { rMed[2], rMed[3], carX - 3, carY + 5, carX, carY, carX + 3, carY + 4, lMed[2], lMed[3] };
    yOut3 = new float[] { lLat[2], lLat[3], lLat[0] - 0.5, lLat[1] - 2, TR_R + 0.5, TR_BOT, TR_R, TR_BOT - 6, TR_R, TR_TOP };
    yPoly = new float[yOut1.length + yOut2.length + yOut3.length];
    System.arraycopy(yOut1, 0, yPoly, 0, yOut1.length);
    System.arraycopy(yOut2, 0, yPoly, yOut1.length, yOut2.length);
    System.arraycopy(yOut3, 0, yPoly, yOut1.length + yOut2.length, yOut3.length);
  }

  // rings across a straight airway between arc lengths a..b
  void rings(PGraphics g, float[] seg, float w, float a, float b, float step) {
    float dx = seg[2] - seg[0], dy = seg[3] - seg[1], L = sqrt(dx * dx + dy * dy);
    float ux = dx / L, uy = dy / L, nx = -uy * w * 0.4, ny = ux * w * 0.4;
    for (float d = a; d < min(b, L - 3); d += step) {
      float x = seg[0] + ux * d, y = seg[1] + uy * d;
      g.line(x + nx, y + ny, x - nx, y - ny);
    }
  }

  void airwayY(PGraphics g) {
    g.noStroke();
    g.fill(AIR);
    polygon(g, yPoly);
    // shading on the subject's-left side of each tube, highlight on the other
    g.strokeCap(SQUARE);
    g.stroke(AIR_SH, 160);
    g.strokeWeight(7);
    g.line(TR_R - 5, TR_TOP + 2, TR_R - 5, TR_BOT - 4);
    float[] rs = edge(RMB, -W_RMB * 0.3), ls = edge(LMB, -W_LMB * 0.3);
    g.strokeWeight(W_RMB * 0.2);
    g.line(lerp(rs[0], rs[2], 0.25), lerp(rs[1], rs[3], 0.25), rs[2], rs[3]);
    g.strokeWeight(W_LMB * 0.2);
    g.line(lerp(ls[0], ls[2], 0.15), lerp(ls[1], ls[3], 0.15), ls[2], ls[3]);
    // cartilage rings
    g.stroke(AIR_RING);
    g.strokeWeight(3.2);
    for (float y = TR_TOP + 8; y < TR_BOT - 2; y += 10) g.line(TR_L + 3, y, TR_R - 3, y);
    rings(g, RMB, W_RMB, 22, 999, 10);
    rings(g, LMB, W_LMB, 20, 999, 10);
    g.strokeCap(ROUND);
    g.stroke(AIR_LT, 230);
    g.strokeWeight(4);
    g.line(TR_L + 7, TR_TOP + 4, TR_L + 7, TR_BOT - 6);
    // carina: the keel-shaped ridge seen through the wall at the split
    g.noStroke();
    g.fill(AIR_SH, 200);
    g.beginShape();
    g.vertex(carX - 9, carY - 1);
    g.bezierVertex(carX - 5, carY - 12, carX + 5, carY - 12, carX + 9, carY - 1);
    g.bezierVertex(carX + 4, carY - 5, carX - 4, carY - 5, carX - 9, carY - 1);
    g.endShape(CLOSE);
    // outline (bronchus ends left open: they continue into the lungs)
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    polyline(g, yOut1);
    polyline(g, yOut2);
    polyline(g, yOut3);
  }

  void larynx(PGraphics g) {
    // hyoid bone (context, above the larynx)
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.fill(D_BONE);
    g.beginShape();
    g.vertex(254, 14);
    g.bezierVertex(272, 23, 328, 23, 346, 14);
    g.vertex(349, 21);
    g.bezierVertex(330, 31, 270, 31, 251, 21);
    g.endShape(CLOSE);
    // thyrohyoid membrane
    g.fill(#D9E1EA);
    g.strokeWeight(1.8);
    g.quad(266, 26, 334, 26, 337, 40, 263, 40);
    // cricothyroid membrane
    g.rect(284, 84, 32, 14);
    // cricoid cartilage ring
    g.strokeWeight(2.4);
    g.fill(AIR);
    g.beginShape();
    g.vertex(278, 95);
    g.bezierVertex(290, 92, 310, 92, 322, 95);
    g.vertex(323, TR_TOP + 1);
    g.bezierVertex(310, TR_TOP - 2, 290, TR_TOP - 2, 277, TR_TOP + 1);
    g.endShape(CLOSE);
    g.stroke(AIR_SH);
    g.strokeWeight(2);
    g.line(282, 103, 318, 103);
    // thyroid cartilage: shield of two laminae meeting at the laryngeal prominence
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(AIR);
    g.beginShape();
    g.vertex(264, 36);
    g.vertex(291, 35);
    g.vertex(300, 48);          // superior thyroid notch
    g.vertex(309, 35);
    g.vertex(336, 36);
    g.bezierVertex(339, 52, 338, 66, 330, 78);
    g.vertex(327, 92);          // inferior horn
    g.vertex(321, 90);
    g.vertex(320, 84);
    g.bezierVertex(312, 87, 306, 88, 300, 88);
    g.bezierVertex(294, 88, 288, 87, 280, 84);
    g.vertex(279, 90);
    g.vertex(273, 92);          // inferior horn
    g.vertex(270, 78);
    g.bezierVertex(262, 66, 261, 52, 264, 36);
    g.endShape(CLOSE);
    // shade the far lamina, highlight the near one, ridge of the prominence
    g.noStroke();
    g.fill(AIR_SH, 150);
    g.beginShape();
    g.vertex(302, 50);
    g.vertex(310, 39);
    g.vertex(333, 40);
    g.bezierVertex(335, 54, 333, 66, 326, 76);
    g.bezierVertex(316, 83, 308, 85, 302, 85);
    g.endShape(CLOSE);
    g.fill(AIR_LT, 220);
    g.ellipse(276, 56, 8, 22);
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.line(300, 50, 300, 86);
  }

  void alveoliInset(PGraphics g) {
    // zoom leader from a bronchiole tip in the left upper lobe
    float zx = 470, zy = 205;
    g.stroke(#7D6F52, 200);
    g.strokeWeight(1.5);
    dashed(g, new float[] { zx - 8, zy - 6, BUB_X - BUB_R * 0.95, BUB_Y + BUB_R * 0.3 }, 5, 4);
    dashed(g, new float[] { zx + 9, zy - 4, BUB_X + BUB_R * 0.2, BUB_Y + BUB_R * 0.98 }, 5, 4);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.ellipse(zx, zy, 22, 22);
    // bubble
    g.noStroke();
    g.fill(0, 30);
    g.ellipse(BUB_X + 3, BUB_Y + 4, BUB_R * 2, BUB_R * 2);
    g.fill(#FFF8F5);
    g.ellipse(BUB_X, BUB_Y, BUB_R * 2, BUB_R * 2);
    // terminal bronchiole -> alveolar ducts
    g.stroke(D_INK);
    g.strokeWeight(12);
    g.line(BUB_X - 46, BUB_Y + 30, BUB_X - 18, BUB_Y + 10);
    g.strokeWeight(8);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 8, BUB_Y - 14);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X + 14, BUB_Y + 4);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 2, BUB_Y + 30);
    g.stroke(AIR);
    g.strokeWeight(9);
    g.line(BUB_X - 46, BUB_Y + 30, BUB_X - 18, BUB_Y + 10);
    g.strokeWeight(5);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 8, BUB_Y - 14);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X + 14, BUB_Y + 4);
    g.line(BUB_X - 18, BUB_Y + 10, BUB_X - 2, BUB_Y + 30);
    // grape-like alveolar sacs
    sac(g, BUB_X - 6, BUB_Y - 28, 10);
    sac(g, BUB_X + 26, BUB_Y + 2, 10);
    sac(g, BUB_X + 6, BUB_Y + 32, 9.5);
    // capillary net
    g.noFill();
    g.strokeWeight(1.6);
    g.stroke(D_ARTERY, 190);
    g.bezier(BUB_X - 30, BUB_Y - 30, BUB_X - 10, BUB_Y - 50, BUB_X + 20, BUB_Y - 20, BUB_X + 42, BUB_Y - 6);
    g.bezier(BUB_X + 40, BUB_Y + 20, BUB_X + 20, BUB_Y + 30, BUB_X + 20, BUB_Y + 46, BUB_X - 6, BUB_Y + 50);
    g.stroke(D_VEIN, 190);
    g.bezier(BUB_X - 26, BUB_Y - 14, BUB_X - 2, BUB_Y - 4, BUB_X + 10, BUB_Y - 46, BUB_X + 30, BUB_Y - 36);
    g.bezier(BUB_X + 8, BUB_Y + 12, BUB_X + 34, BUB_Y + 18, BUB_X + 46, BUB_Y + 30, BUB_X + 30, BUB_Y + 44);
    // rim
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(3);
    g.ellipse(BUB_X, BUB_Y, BUB_R * 2, BUB_R * 2);
    g.stroke(255, 160);
    g.strokeWeight(2);
    g.arc(BUB_X, BUB_Y, BUB_R * 2 - 9, BUB_R * 2 - 9, PI * 1.05, PI * 1.45);
  }

  // a cluster of alveoli around (cx, cy)
  void sac(PGraphics g, float cx, float cy, float r) {
    float[][] o = { { 0, 0 }, { -1.5, -0.6 }, { -0.3, -1.6 }, { 1.4, -0.9 }, { 1.6, 0.8 }, { 0.2, 1.6 }, { -1.4, 1.0 } };
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    for (int i = o.length - 1; i >= 0; i--) {
      float x = cx + o[i][0] * r, y = cy + o[i][1] * r;
      g.fill(i == 0 ? ALV_SH : ALV);
      g.ellipse(x, y, r * 1.9, r * 1.9);
    }
    g.noStroke();
    g.fill(255, 150);
    for (int i = 1; i < o.length; i++) g.ellipse(cx + o[i][0] * r - r * 0.3, cy + o[i][1] * r - r * 0.3, r * 0.6, r * 0.5);
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
