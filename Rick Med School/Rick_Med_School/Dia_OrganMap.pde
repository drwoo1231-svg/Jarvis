// Organ map: neutral front-view body (head to upper thighs) with the major organs
// in their anatomical places, stylised and slightly spread so each is clickable.
// Subject's right on the viewer's left (liver left, stomach + spleen right).

class OrganMapDiagram extends Diagram {
  final int BODY = #E1E6EE, BODY_SH = #C8D0DC;
  final int THYMUS = #EFBE86, SPLEEN = #8A3A5C, PANCREAS = #F2CC6B, BLADDER = #F3DCA2, AIRWAY = #DCE6EA;

  float[] body, brain, lungR, lungL, heart, liver, stomach, spleen, pancreas, duodC, duod, colonC, colon, smallMass, bladder;
  float[] kidneyR, kidneyL, adrenalR, adrenalL, thyroid, thymus, appendix, appC;

  OrganMapDiagram() {
    super("organ_map", "Organ Map");
    build();
    add("lungs", "Lungs").poly(lungR).poly(lungL).anchor(247, 262);
    add("liver", "Liver").poly(liver).anchor(256, 350);
    add("stomach", "Stomach").poly(stomach).anchor(362, 356);
    add("small_intestine", "Small Intestine").poly(smallMass).poly(duod).anchor(300, 488);
    add("large_intestine", "Large Intestine").poly(colon).poly(appendix).anchor(247, 478);
    add("kidneys", "Kidneys").poly(kidneyR).poly(kidneyL);
    add("brain", "Brain").poly(brain).anchor(300, 50);
    add("heart", "Heart").poly(heart).anchor(318, 278);
    add("spleen", "Spleen").poly(spleen);
    add("pancreas", "Pancreas").poly(pancreas).anchor(330, 401);
    add("thymus", "Thymus").poly(thymus);
    add("thyroid", "Thyroid Gland").poly(thyroid).anchor(300, 159);
    add("adrenal_glands", "Adrenal Glands").poly(ellPts(213, 411, 12, 9, 0)).poly(ellPts(388, 403, 12, 9, 0));
    add("bladder", "Urinary Bladder").poly(bladder);
    add("pituitary", "Pituitary Gland").ellipse(300, 96, 11, 10);
    add("lymph_nodes", "Lymph Nodes").ellipse(280, 131, 9, 14).ellipse(320, 131, 9, 14).ellipse(209, 221, 12, 12).ellipse(391, 221, 12, 12)
      .ellipse(246, 562, 17, 10, 0.5).ellipse(354, 562, 17, 10, -0.5).anchor(209, 221);
  }

  // =============================================================== geometry
  void build() {
    body = symClosed(new float[] { 300, 11, 279, 14, 262, 24, 251, 40, 248, 60, 250, 80, 255, 97, 263, 110, 272, 119,
      271, 128, 270, 148, 268, 166, 254, 174, 232, 181, 210, 187, 194, 195,
      184, 210, 178, 232, 174, 262, 170, 295, 165, 330, 159, 362, 154, 395, 150, 428, 147, 456,
      142, 468, 137, 486, 136, 504, 141, 520, 151, 525, 159, 516, 162, 500, 160, 486, 164, 472,
      166, 456, 170, 428, 175, 396, 180, 364, 186, 330, 191, 296, 195, 262, 198, 240, 203, 226,
      204, 250, 203, 290, 200, 330, 198, 370, 196, 410, 194, 450, 193, 490, 194, 530, 196, 566, 198, 606, 300, 606 });
    brain = sym(new float[] { 300, 22, 283, 17, 267, 22, 256, 33, 251, 48, 251, 64, 255, 77, 263, 86, 274, 90, 283, 87, 291, 82, 297, 84, 300, 85 });
    thyroid = new float[] { 280, 147, 291, 147, 300, 153, 309, 147, 320, 147, 322, 160, 318, 172, 306, 171, 300, 167, 294, 171, 282, 172, 278, 160 };
    thymus = new float[] { 293, 187, 300, 190, 307, 187, 316, 194, 318, 210, 314, 226, 305, 230, 300, 226, 295, 230, 286, 226, 282, 210, 284, 194 };
    lungR = new float[] { 268, 190, 280, 193, 288, 204, 290, 228, 291, 256, 292, 286, 290, 312, 272, 310, 252, 309, 234, 313, 222, 317,
      217, 296, 218, 264, 221, 234, 229, 212, 243, 198, 256, 191 };
    lungL = new float[] { 332, 190, 320, 193, 312, 204, 310, 228, 312, 246, 324, 254, 336, 266, 342, 286, 343, 304, 349, 314, 366, 311,
      378, 316, 383, 296, 382, 264, 379, 234, 371, 212, 357, 198, 344, 191 };
    heart = new float[] { 290, 248, 304, 240, 320, 241, 334, 248, 344, 262, 349, 280, 349, 298, 342, 307, 322, 312, 302, 310, 290, 302,
      285, 284, 286, 264 };
    liver = new float[] { 212, 330, 232, 323, 258, 320, 282, 322, 300, 328, 318, 330, 334, 331, 339, 336, 334, 343, 318, 350, 296, 360,
      272, 370, 250, 378, 230, 380, 216, 374, 208, 358, 207, 342 };
    stomach = new float[] { 345, 330, 352, 324, 364, 322, 375, 328, 381, 342, 381, 360, 376, 376, 362, 387, 343, 391, 325, 389, 313, 384,
      309, 377, 316, 374, 328, 373, 340, 367, 347, 356, 349, 343 };
    spleen = ellPts(391, 350, 9.5, 21, 0.3);
    pancreas = new float[] { 258, 395, 270, 392, 283, 394, 300, 397, 322, 397, 344, 396, 361, 392, 372, 385, 378, 381, 381, 385, 376, 393,
      364, 400, 346, 405, 322, 407, 300, 408, 285, 411, 272, 415, 261, 411, 256, 403 };
    duodC = cr(new float[] { 309, 380, 294, 383, 274, 385, 257, 389, 249, 401, 252, 415, 265, 423, 285, 425, 304, 421, 318, 415 }, 4);
    duod = band(duodC, 11, 10);
    colonC = cr(new float[] { 248, 514, 248, 498, 247, 474, 248, 456, 253, 444, 263, 437, 278, 437, 300, 444, 322, 441, 337, 436, 348, 440,
      354, 452, 356, 478, 355, 503, 348, 519, 331, 527, 316, 531, 307, 540, 304, 552 }, 4);
    colon = band(colonC, 24, 16);
    appC = cr(new float[] { 244, 520, 240, 532, 236, 541, 240, 547 }, 3);
    appendix = band(appC, 9, 8);
    smallMass = new float[] { 262, 456, 285, 452, 300, 457, 318, 452, 340, 456, 344, 472, 343, 492, 338, 512, 322, 520, 300, 518, 280, 522,
      262, 515, 258, 496, 259, 474 };
    kidneyR = new float[] { 212, 417, 220, 418, 224, 426, 222, 434, 225, 442, 223, 452, 214, 459, 205, 456, 200, 444, 199, 430, 203, 420 };
    kidneyL = mir(new float[] { 212, 409, 220, 410, 224, 418, 222, 426, 225, 434, 223, 444, 214, 451, 205, 448, 200, 436, 199, 422, 203, 412 });
    adrenalR = new float[] { 204, 418, 210, 405, 216, 402, 222, 410, 222, 418, 213, 415 };
    adrenalL = new float[] { 377, 410, 381, 400, 389, 395, 396, 400, 398, 410, 389, 407 };
    bladder = new float[] { 300, 547, 312, 549, 321, 556, 322, 566, 316, 575, 306, 579, 294, 579, 284, 575, 278, 566, 279, 556, 288, 549 };
  }

  // =============================================================== art
  void drawArt(PGraphics g) {
    // body
    g.noStroke();
    g.fill(BODY_SH);
    blob(g, body);
    g.fill(BODY);
    blob(g, inner(body, 6));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    blob(g, body);
    // airway + oesophagus (context, behind)
    g.stroke(D_INK);
    g.strokeWeight(1.4);
    g.fill(AIRWAY);
    g.rect(294, 140, 12, 60, 3);
    g.stroke(#AFC0C6);
    for (int k = 0; k < 9; k++) g.line(295, 149 + k * 5.5, 305, 149 + k * 5.5);
    g.stroke(D_INK);
    g.fill(AIRWAY);
    blob(g, new float[] { 290, 130, 300, 127, 310, 130, 309, 141, 300, 146, 291, 141 });           // larynx
    // ureters
    g.noFill();
    g.stroke(#C9A23A);
    g.strokeWeight(2.4);
    g.bezier(222, 438, 236, 470, 262, 520, 286, 556);
    g.bezier(378, 430, 364, 470, 338, 520, 314, 556);
    // kidneys + adrenals (behind the gut)
    organ(g, kidneyR, D_KIDNEY, 2);
    organ(g, kidneyL, D_KIDNEY, 2);
    g.noStroke();
    g.fill(#E7B7A8);
    blob(g, new float[] { 218, 430, 223, 432, 223, 440, 218, 441 });
    blob(g, mir(new float[] { 218, 422, 223, 424, 223, 432, 218, 433 }));
    organ(g, adrenalR, D_GLAND, 1.6);
    organ(g, adrenalL, D_GLAND, 1.6);
    // lungs
    organ(g, lungR, D_LUNG, 2.2);
    organ(g, lungL, D_LUNG, 2.2);
    g.noFill();
    g.stroke(#C9707F);
    g.strokeWeight(1.6);
    g.bezier(219, 258, 240, 255, 265, 254, 290, 255);                                              // horizontal fissure
    g.bezier(219, 262, 236, 280, 252, 296, 266, 310);                                              // oblique fissures
    g.bezier(381, 246, 370, 270, 360, 292, 352, 312);
    g.stroke(#E7808F);
    g.strokeWeight(1.1);
    for (int s = 0; s < 2; s++) {                                                                 // bronchial tree hint
      float[] t = { 288, 236, 270, 246, 252, 262, 236, 280 };
      line(g, s == 0 ? t : mir(t));
      float[] t2 = { 270, 246, 262, 226, 250, 214 };
      line(g, s == 0 ? t2 : mir(t2));
      float[] t3 = { 262, 256, 268, 282, 262, 298 };
      line(g, s == 0 ? t3 : mir(t3));
    }
    // great vessels + heart
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(D_VEIN);
    g.rect(287, 216, 9, 36, 3);                                                                     // superior vena cava
    g.fill(D_ARTERY);
    g.beginShape();                                                                                 // aortic arch
    g.vertex(300, 250);
    g.bezierVertex(298, 230, 304, 214, 318, 214);
    g.bezierVertex(328, 214, 333, 222, 332, 236);
    g.vertex(324, 236);
    g.bezierVertex(325, 226, 322, 222, 317, 222);
    g.bezierVertex(310, 222, 308, 232, 309, 250);
    g.endShape(CLOSE);
    g.fill(#5B86DD);
    g.beginShape();                                                                                 // pulmonary trunk
    g.vertex(312, 252);
    g.bezierVertex(311, 240, 316, 232, 326, 230);
    g.vertex(331, 236);
    g.bezierVertex(324, 238, 321, 244, 321, 254);
    g.endShape(CLOSE);
    organ(g, heart, D_HEART, 2.2);
    g.noFill();
    g.stroke(#8E1F2A);
    g.strokeWeight(1.5);
    g.bezier(322, 246, 330, 266, 334, 288, 336, 308);                                              // interventricular groove
    g.stroke(#F2C94C);
    g.strokeWeight(1.3);
    g.bezier(321, 247, 329, 266, 333, 288, 335, 306);
    g.stroke(#E9707A);
    g.strokeWeight(1.2);
    g.bezier(296, 258, 292, 272, 292, 290, 300, 304);
    // thymus in front of the great vessels
    organ(g, thymus, THYMUS, 1.8);
    g.stroke(#C98F5A);
    g.strokeWeight(1.2);
    g.line(300, 192, 300, 224);
    // diaphragm
    g.noFill();
    g.stroke(#B45049);
    g.strokeWeight(4);
    g.beginShape();
    g.curveVertex(212, 326);
    g.curveVertex(212, 326);
    g.curveVertex(234, 318);
    g.curveVertex(260, 315);
    g.curveVertex(284, 318);
    g.curveVertex(300, 324);
    g.curveVertex(318, 319);
    g.curveVertex(345, 316);
    g.curveVertex(370, 318);
    g.curveVertex(390, 326);
    g.curveVertex(390, 326);
    g.endShape();
    // abdominal oesophagus
    g.stroke(D_INK);
    g.strokeWeight(1.4);
    g.fill(lerpColor(D_STOMACH, #000000, 0.08));
    g.beginShape();
    g.vertex(334, 318);
    g.vertex(342, 318);
    g.vertex(352, 330);
    g.vertex(344, 334);
    g.endShape(CLOSE);
    // abdomen
    organ(g, pancreas, PANCREAS, 1.8);
    g.stroke(#C9A040);
    g.strokeWeight(1);
    for (int k = 0; k < 7; k++) {
      float x = 272 + k * 15;
      g.line(x, 398 - k * 1.5, x + 4, 407 - k * 1.5);
    }
    organ(g, spleen, SPLEEN, 2);
    organ(g, stomach, D_STOMACH, 2.2);
    g.noFill();
    g.stroke(#C97575);
    g.strokeWeight(1.2);
    g.bezier(356, 332, 366, 345, 368, 362, 360, 378);                                              // rugae hints
    g.bezier(346, 374, 352, 372, 360, 372, 366, 368);
    organ(g, liver, D_LIVER, 2.4);
    g.stroke(#6E2A20);
    g.strokeWeight(1.5);
    g.bezier(298, 330, 299, 340, 298, 350, 295, 360);                                              // falciform ligament
    g.noStroke();
    g.fill(#B25646, 120);
    blob(g, new float[] { 222, 334, 250, 327, 280, 327, 260, 334, 232, 342 });                   // sheen
    // small intestine coils
    tube(g, duodC, 11, D_GUT);
    g.noStroke();
    g.fill(lerpColor(D_GUT, #000000, 0.22));
    blob(g, smallMass);
    FloatList sp = new FloatList();                                                                 // jejunum + ileum loops
    float[] rows = { 463, 479, 495, 511 };
    for (int r = 0; r < rows.length; r++) {
      boolean ltr = r % 2 == 0;
      for (int k = 0; k <= 5; k++) {
        float x = ltr ? 272 + k * 12.8 : 336 - k * 12.8;
        sp.append(x);
        sp.append(rows[r] + (((ltr ? k : 5 - k) % 2) == 0 ? -2 : 2));
      }
      if (r < rows.length - 1) {
        sp.append(ltr ? 341 : 267);
        sp.append(rows[r] + 7.5);
      }
    }
    sp.append(260);
    sp.append(512);
    sp.append(251);
    sp.append(507);
    tube(g, sp.array(), 9, D_GUT);
    // large intestine frame (haustra)
    tube(g, colonC, 22, D_COLON);
    tube(g, appC, 6.5, D_COLON);
    g.stroke(#B56A50);
    g.strokeWeight(1.4);
    int n = colonC.length / 2;
    for (int i = 3; i < n - 6; i += 3) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = colonC[b * 2] - colonC[a * 2], ty = colonC[b * 2 + 1] - colonC[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float nx = -ty / L * 8, ny = tx / L * 8, cx = colonC[i * 2], cy = colonC[i * 2 + 1];
      g.line(cx - nx, cy - ny, cx + nx, cy + ny);
    }
    organ(g, bladder, BLADDER, 2);
    // head: brain + pituitary
    organ(g, brain, D_BRAIN, 2.2);
    g.noFill();
    g.stroke(D_BRAIN_SH);
    g.strokeWeight(1.6);
    g.line(300, 24, 300, 82);
    for (int s = 0; s < 2; s++) {
      line(g, side(new float[] { 296, 30, 284, 28, 276, 36, 284, 42, 294, 40 }, s));
      line(g, side(new float[] { 263, 42, 272, 48, 270, 58, 280, 60, 290, 54 }, s));
      line(g, side(new float[] { 259, 64, 268, 68, 278, 72, 288, 70, 295, 74 }, s));
      line(g, side(new float[] { 270, 26, 266, 34, 260, 38 }, s));
      line(g, side(new float[] { 280, 78, 272, 80, 264, 76 }, s));
    }
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(D_GLAND);
    g.rect(298.5, 84, 3, 9);
    organ(g, ellPts(300, 98, 7, 5.5, 0), D_GLAND, 1.8);
    // thyroid
    organ(g, new float[] { 283, 150, 291, 148, 296, 156, 304, 156, 309, 148, 317, 150, 320, 160, 316, 170, 308, 170, 300, 165, 292, 170,
      284, 170, 280, 160 }, D_GLAND, 1.8);
    // lymph nodes + vessels
    float[][] nodes = { { 281, 122, 4, 3 }, { 278, 131, 4.5, 3.5 }, { 281, 140, 4, 3 }, { 205, 213, 4.5, 3.5 }, { 213, 219, 5, 4 },
      { 206, 225, 4.5, 3.5 }, { 215, 229, 4, 3.2 }, { 235, 555, 4.5, 3.2 }, { 245, 561, 5, 3.5 }, { 255, 567, 4.5, 3.2 }, { 247, 571, 3.8, 3 } };
    g.noFill();
    g.stroke(#4E9E6C);
    g.strokeWeight(1.2);
    for (int s = 0; s < 2; s++) {
      line(g, side(new float[] { 281, 118, 278, 131, 281, 140, 284, 150 }, s));
      line(g, side(new float[] { 196, 208, 205, 213, 213, 219, 215, 229, 219, 238 }, s));
      line(g, side(new float[] { 228, 550, 235, 555, 245, 561, 255, 567, 264, 574 }, s));
    }
    for (int s = 0; s < 2; s++) for (float[] q : nodes) organ(g, side(ellPts(q[0], q[1], q[2], q[3], 0), s), D_LYMPH, 1.3);
  }

  // =============================================================== helpers (local to this class)
  void organ(PGraphics g, float[] p, int c, float sw) {
    g.noStroke();
    g.fill(lerpColor(c, #000000, 0.16));
    blob(g, p);
    g.fill(c);
    blob(g, inner(p, 3));
    g.fill(255, 255, 255, 45);
    blob(g, shrink(p, 0.55, -0.12));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }

  // a soft tube along a centre line: ink rim, body colour, highlight
  void tube(PGraphics g, float[] c, float w, int col) {
    g.noFill();
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    g.stroke(D_INK);
    g.strokeWeight(w + 3.6);
    line(g, c);
    g.stroke(lerpColor(col, #000000, 0.14));
    g.strokeWeight(w);
    line(g, c);
    g.stroke(col);
    g.strokeWeight(w * 0.62);
    float[] q = new float[c.length];
    for (int i = 0; i < c.length; i += 2) {
      q[i] = c[i] - w * 0.1;
      q[i + 1] = c[i + 1] - w * 0.12;
    }
    line(g, q);
    g.stroke(255, 255, 255, 60);
    g.strokeWeight(w * 0.2);
    for (int i = 0; i < c.length; i += 2) {
      q[i] = c[i] - w * 0.2;
      q[i + 1] = c[i + 1] - w * 0.24;
    }
    line(g, q);
  }

  // scaled copy about the centroid, nudged up-left (a soft highlight)
  float[] shrink(float[] p, float k, float off) {
    float cx = 0, cy = 0, minx = 1e9, maxx = -1e9, miny = 1e9, maxy = -1e9;
    int n = p.length / 2;
    for (int i = 0; i < n; i++) {
      cx += p[i * 2] / n;
      cy += p[i * 2 + 1] / n;
      minx = min(minx, p[i * 2]);
      maxx = max(maxx, p[i * 2]);
      miny = min(miny, p[i * 2 + 1]);
      maxy = max(maxy, p[i * 2 + 1]);
    }
    cx += (maxx - minx) * off;
    cy += (maxy - miny) * off;
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      q[i * 2] = cx + (p[i * 2] - cx) * k;
      q[i * 2 + 1] = cy + (p[i * 2 + 1] - cy) * k;
    }
    return q;
  }

  float[] ellPts(float cx, float cy, float rx, float ry, float a) {
    int n = 18;
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n, x = cos(t) * rx, y = sin(t) * ry;
      p[i * 2] = cx + x * cos(a) - y * sin(a);
      p[i * 2 + 1] = cy + x * sin(a) + y * cos(a);
    }
    return p;
  }

  float[] mir(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = DIA - p[i];
      q[i + 1] = p[i + 1];
    }
    return q;
  }

  float[] side(float[] p, int s) {
    return s == 0 ? p : mir(p);
  }

  float[] sym(float[] half) {
    int n = half.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    for (int i = n - 2; i >= 1; i--) {
      q.append(DIA - half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    return q.array();
  }

  float[] symClosed(float[] half) {
    int n = half.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    for (int i = n - 1; i >= 0; i--) {
      q.append(DIA - half[i * 2]);
      q.append(half[i * 2 + 1]);
    }
    return q.array();
  }

  float[] cr(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  float crv(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  float[] band(float[] c, float w0, float w1) {
    int n = c.length / 2;
    float[] lx = new float[n], ly = new float[n], rx = new float[n], ry = new float[n];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = c[b * 2] - c[a * 2], ty = c[b * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float w = lerp(w0, w1, i / (float) (n - 1)) / 2;
      float nx = -ty / L * w, ny = tx / L * w;
      lx[i] = c[i * 2] + nx;
      ly[i] = c[i * 2 + 1] + ny;
      rx[i] = c[i * 2] - nx;
      ry[i] = c[i * 2 + 1] - ny;
    }
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      q.append(lx[i]);
      q.append(ly[i]);
    }
    float ex = c[(n - 1) * 2] - c[(n - 2) * 2], ey = c[(n - 1) * 2 + 1] - c[(n - 2) * 2 + 1], eL = max(1e-3, sqrt(ex * ex + ey * ey));
    q.append(c[(n - 1) * 2] + ex / eL * w1 * 0.4);
    q.append(c[(n - 1) * 2 + 1] + ey / eL * w1 * 0.4);
    for (int i = n - 1; i >= 0; i--) {
      q.append(rx[i]);
      q.append(ry[i]);
    }
    float sx = c[0] - c[2], sy = c[1] - c[3], sL = max(1e-3, sqrt(sx * sx + sy * sy));
    q.append(c[0] + sx / sL * w0 * 0.4);
    q.append(c[1] + sy / sL * w0 * 0.4);
    return q.array();
  }

  void blob(PGraphics g, float[] p) {
    int n = p.length / 2;
    g.beginShape();
    for (int i = 0; i <= n + 2; i++) {
      int k = (i + n - 1) % n;
      g.curveVertex(p[k * 2], p[k * 2 + 1]);
    }
    g.endShape(CLOSE);
  }

  void line(PGraphics g, float[] p) {
    g.beginShape();
    g.curveVertex(p[0], p[1]);
    for (int i = 0; i < p.length; i += 2) g.curveVertex(p[i], p[i + 1]);
    g.curveVertex(p[p.length - 2], p[p.length - 1]);
    g.endShape();
  }

  float[] inner(float[] p, float d) {
    int n = p.length / 2;
    float area = 0;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += p[i * 2] * p[j * 2 + 1] - p[j * 2] * p[i * 2 + 1];
    }
    float sg = area > 0 ? 1 : -1;
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float nx = ty / L * sg, ny = -tx / L * sg;
      float k = d * (0.25 + 0.75 * max(0, nx * 0.55 + ny * 0.83));
      q[i * 2] = p[i * 2] - nx * k;
      q[i * 2 + 1] = p[i * 2 + 1] - ny * k;
    }
    return q;
  }
}
