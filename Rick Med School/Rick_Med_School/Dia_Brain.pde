// Brain, LEFT lateral view: the front of the brain faces the viewer's LEFT.
// Cerebrum with its four lobes (frontal blue, parietal yellow, temporal green,
// occipital pink), the central sulcus between frontal and parietal, the lateral
// (Sylvian) fissure above the temporal lobe, the precentral (motor) and
// postcentral (sensory) gyri in deeper shades of their lobes, Broca's and
// Wernicke's language areas in orange, the cerebellum tucked under the occipital
// lobe, and the brainstem (pons, medulla) continuing into the spinal cord.
// All geometry is built once in design units, then shifted by (OX, OY) for both
// the art and the hit polygons so they always match.

class BrainDiagram extends Diagram {
  final float OX = 2, OY = -8;

  final int C_FRONT = #A9C7EF, C_PRE = #7C9FE6, C_PARI = #F6DA8C, C_POST = #EDB94F;
  final int C_TEMP = #AEDAA4, C_OCC = #F4AEC1, C_LANG = #F5965F, C_LANG_DK = #B9541F;
  final int C_CBL = #CDB5E8, C_CBL_DK = #8D70B6;
  final int C_PONS = #EDC5A4, C_MED = #E3B290, C_STEM_DK = #A9775A, C_CORD = #F3DDA9, C_CORD_DK = #C9A866;

  float[] OUT, LAT, CEN, CENX, PRE_S, POST_S, PO, PT, STS, ITS;
  float[] frontalP, parietalP, temporalP, occipitalP, preP, postP, brocaP, wernP;
  float[] cblP, ponsP, medP, cordC, cordP;
  float[][] minor;      // secondary sulci (decoration)
  int lAsc;             // LAT index where the anterior ascending ramus leaves

  BrainDiagram() {
    super("brain", "Brain (left side)");
    build();
    add("spinal_cord", "Spinal Cord").poly(band(cordC, 34, 30)).anchor(358, 560);
    add("medulla", "Medulla Oblongata").poly(cp(medP)).anchor(348, 494);
    add("pons", "Pons").poly(cp(ponsP)).anchor(332, 436);
    add("cerebellum", "Cerebellum").poly(cp(cblP)).anchor(474, 428);
    add("frontal_lobe", "Frontal Lobe").poly(cp(frontalP)).anchor(150, 152);
    add("parietal_lobe", "Parietal Lobe").poly(cp(parietalP)).anchor(410, 142);
    add("temporal_lobe", "Temporal Lobe").poly(cp(temporalP)).anchor(236, 352);
    add("occipital_lobe", "Occipital Lobe").poly(cp(occipitalP)).anchor(510, 268);
    // the three neighbouring landmarks get anchors staggered top / middle / lower so their tags don't stack
    float[] a = mid(PRE_S, CEN, 0.28);
    add("precentral_gyrus", "Precentral Gyrus").poly(cp(preP)).anchor(a[0], a[1]);
    float[] b = mid(POST_S, CEN, 0.66);
    add("postcentral_gyrus", "Postcentral Gyrus").poly(cp(postP)).anchor(b[0], b[1]);
    add("broca_area", "Broca's Area").poly(cp(brocaP)).anchor(184, 248);
    add("wernicke_area", "Wernicke's Area").poly(cp(wernP)).anchor(350, 288);
    float[] cs = cat(CEN, new float[] { CENX[CENX.length - 2], CENX[CENX.length - 1] });
    int nc = CEN.length / 2;
    add("central_sulcus", "Central Sulcus").poly(band(extend(CEN, 1, 0), 18, 18)).anchor(CEN[(nc / 2) * 2], CEN[(nc / 2) * 2 + 1]);
    int nl = LAT.length / 2;
    add("lateral_sulcus", "Lateral Sulcus").poly(band(extend(LAT, 0, 3), 18, 16)).anchor(LAT[(nl * 2 / 5) * 2], LAT[(nl * 2 / 5) * 2 + 1]);
    // every hit polygon (and anchor) moves with the artwork
    for (Part p : parts) {
      for (float[] s : p.shapes) for (int i = 0; i < s.length; i += 2) {
        s[i] += OX;
        s[i + 1] += OY;
      }
      if (p.ax >= 0) {
        p.ax += OX;
        p.ay += OY;
      }
    }
  }

  // ------------------------------------------------------------ geometry (design units)
  void build() {
    OUT = crC(new float[] { 46, 232, 56, 168, 92, 112, 150, 76, 225, 56, 305, 52, 385, 64, 455, 96, 510, 145, 543, 205, 552, 258, 540, 302,
      508, 336, 458, 360, 400, 382, 335, 398, 268, 402, 205, 394, 160, 375, 132, 348, 134, 322, 150, 307, 128, 301, 96, 293, 66, 276 }, 14);
    OUT = bumpy(OUT);
    int iN0 = nearest(OUT, 150, 307), iCT = nearest(OUT, 322, 54), iPreT = nearest(OUT, 282, 53), iPostT = nearest(OUT, 362, 58);
    int iPO0 = nearest(OUT, 478, 106), iPO1 = nearest(OUT, 450, 364);
    LAT = crO(new float[] { OUT[iN0 * 2], OUT[iN0 * 2 + 1], 176, 297, 200, 291, 260, 280, 320, 270, 365, 262, 384, 250, 392, 232 }, 10);
    CEN = wig(crO(new float[] { OUT[iCT * 2], OUT[iCT * 2 + 1], 314, 82, 306, 104, 302, 128, 291, 156, 284, 182, 270, 208, 258, 236, 245, 262 }, 8), 1.4, 44, 0.5);
    int lC2 = nearest(LAT, 241, 283), lPb = nearest(LAT, 200, 291), lQb = nearest(LAT, 284, 276), lL2 = nearest(LAT, 365, 262);
    int lB0 = nearest(LAT, 166, 299), lW0 = nearest(LAT, 300, 273);
    lAsc = nearest(LAT, 182, 295);
    CENX = new float[] { CEN[CEN.length - 2], CEN[CEN.length - 1], LAT[lC2 * 2], LAT[lC2 * 2 + 1] };
    PRE_S = crO(new float[] { OUT[iPreT * 2], OUT[iPreT * 2 + 1], 274, 82, 266, 108, 260, 134, 250, 160, 242, 186, 228, 212, 216, 240, 205, 266,
      LAT[lPb * 2], LAT[lPb * 2 + 1] }, 8);
    PRE_S = wig(PRE_S, 1.2, 38, 2.1);
    POST_S = crO(new float[] { OUT[iPostT * 2], OUT[iPostT * 2 + 1], 354, 84, 347, 110, 342, 136, 332, 162, 324, 188, 311, 214, 299, 240, 289, 262,
      LAT[lQb * 2], LAT[lQb * 2 + 1] }, 8);
    POST_S = wig(POST_S, 1.2, 38, 4.0);
    PO = crO(new float[] { OUT[iPO0 * 2], OUT[iPO0 * 2 + 1], 473, 160, 467, 215, 461, 275, 455, 325, OUT[iPO1 * 2], OUT[iPO1 * 2 + 1] }, 10);
    int jPO = nearest(PO, 461, 276);
    PT = crO(new float[] { LAT[lL2 * 2], LAT[lL2 * 2 + 1], 395, 266, 428, 272, PO[jPO * 2], PO[jPO * 2 + 1] }, 10);
    STS = wig(crO(new float[] { 160, 334, 220, 323, 280, 315, 330, 307, 378, 298, 410, 285, 428, 262 }, 10), 1.3, 34, 1.0);
    ITS = wig(crO(new float[] { 182, 368, 240, 363, 300, 358, 360, 350, 412, 338 }, 8), 1.3, 32, 2.5);
    int nP = PO.length / 2, nT = PT.length / 2, nC = CEN.length / 2, nPre = PRE_S.length / 2, nPost = POST_S.length / 2;

    frontalP = cat(arcF(OUT, iN0, iCT), CEN, CENX, seg(LAT, lC2, 0));
    parietalP = cat(arcF(OUT, iCT, iPO0), seg(PO, 0, jPO), seg(PT, nT - 1, 0), seg(LAT, lL2, lC2), rev(CENX), seg(CEN, nC - 1, 0));
    temporalP = cat(seg(LAT, 0, lL2), PT, seg(PO, jPO, nP - 1), arcF(OUT, iPO1, iN0));
    occipitalP = cat(arcF(OUT, iPO0, iPO1), seg(PO, nP - 1, 0));
    preP = cat(arcF(OUT, iPreT, iCT), CEN, CENX, seg(LAT, lC2, lPb), seg(PRE_S, nPre - 1, 0));
    postP = cat(arcF(OUT, iCT, iPostT), POST_S, seg(LAT, lQb, lC2), rev(CENX), seg(CEN, nC - 1, 0));
    int pTop = nearest(PRE_S, 229, 212);
    brocaP = cat(seg(LAT, lB0, lPb), seg(PRE_S, nPre - 1, pTop), crO(new float[] { 222, 216, 200, 215, 174, 214, 152, 221, 140, 244, 146, 270, 158, 291 }, 4));
    int s1 = nearest(STS, 394, 293), s0 = nearest(STS, 300, 312), t1 = nearest(PT, 396, 266);
    wernP = cat(seg(LAT, lW0, lL2), seg(PT, 0, t1), new float[] { 404, 278 }, seg(STS, s1, s0));

    cblP = crC(new float[] { 370, 414, 386, 384, 420, 360, 470, 344, 515, 326, 542, 318, 556, 344, 556, 396, 534, 440, 496, 464, 450, 474, 410, 466, 384, 446 }, 8);
    ponsP = crC(new float[] { 318, 386, 298, 402, 292, 426, 300, 450, 324, 463, 356, 466, 382, 452, 390, 424, 382, 396, 352, 384 }, 6);
    medP = crC(new float[] { 330, 452, 324, 474, 329, 496, 338, 514, 345, 530, 367, 530, 373, 513, 380, 490, 382, 468, 378, 452 }, 6);
    cordC = new float[] { 356, 518, 359, 552, 362, 584 };
    cordP = band(cordC, 27, 24);

    float[][] mc = {
      // frontal: superior + inferior frontal sulci and their side branches, middle frontal minors, frontal pole, orbital
      { 262, 98, 222, 104, 176, 100, 132, 112, 100, 138 }, { 196, 102, 200, 80 }, { 142, 108, 130, 88 },
      { 230, 201, 192, 206, 152, 201, 112, 212, 84, 236 }, { 168, 203, 172, 184 },
      { 220, 150, 190, 160, 160, 150, 128, 162 }, { 92, 172, 112, 184, 108, 196 }, { 238, 120, 226, 136 },
      { 64, 196, 80, 206, 72, 226 }, { 84, 268, 114, 283 }, { 102, 248, 124, 254 },
      // anterior horizontal + ascending rami of the lateral sulcus (frame Broca's area)
      { LAT[lB0 * 2], LAT[lB0 * 2 + 1], 146, 291, 124, 290 },
      { LAT[lAsc * 2], LAT[lAsc * 2 + 1], 180, 268, 174, 246 },
      // parietal: intraparietal sulcus, superior parietal minors, supramarginal + angular arcs
      { 340, 150, 370, 168, 404, 168, 438, 180, 456, 204 }, { 378, 106, 404, 120, 432, 114 }, { 420, 140, 446, 150 },
      { 366, 228, 388, 212, 412, 218, 420, 240 }, { 436, 214, 452, 236, 446, 258 }, { 404, 86, 428, 98 },
      // temporal: minors between the superior and inferior temporal sulci, inferior surface
      { 196, 346, 236, 341 }, { 290, 338, 330, 332 }, { 368, 330, 396, 324 }, { 230, 384, 270, 386 }, { 330, 382, 360, 376 },
      // occipital
      { 480, 236, 506, 231, 536, 245 }, { 474, 302, 500, 292, 528, 304 }, { 490, 160, 518, 186 }, { 508, 330, 528, 316 }
    };
    minor = new float[mc.length + 4][];
    for (int i = 0; i < mc.length; i++) minor[i] = wig(crO(mc[i], 6), 1.2, 30, i * 1.7);
    minor[mc.length] = STS;
    minor[mc.length + 1] = ITS;
    minor[mc.length + 2] = PRE_S;
    minor[mc.length + 3] = POST_S;
  }

  float[] mid(float[] a, float[] b, float f) {
    float[] p = ptAt(a, f), q = ptAt(b, f);
    return new float[] { (p[0] + q[0]) / 2, (p[1] + q[1]) / 2 };
  }

  float[] ptAt(float[] a, float f) {
    int i = round(f * (a.length / 2 - 1));
    return new float[] { a[i * 2], a[i * 2 + 1] };
  }

  // ------------------------------------------------------------ art
  void drawArt(PGraphics g) {
    g.pushMatrix();
    g.translate(OX, OY);
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    // soft drop shadow of the whole brain
    g.noStroke();
    g.fill(0, 0, 0, 22);
    g.pushMatrix();
    g.translate(5, 7);
    shp(g, OUT);
    shp(g, cblP);
    shp(g, ponsP);
    shp(g, medP);
    shp(g, cordP);
    g.popMatrix();
    drawStem(g);
    drawCerebellum(g);
    drawCerebrum(g);
    g.popMatrix();
  }

  void drawStem(PGraphics g) {
    // spinal cord
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_CORD);
    shp(g, cordP);
    g.noStroke();
    g.fill(255, 255, 255, 80);
    shp(g, band(shiftP(cordC, -5, 0), 6, 5));
    g.noFill();
    g.stroke(C_CORD_DK);
    g.strokeWeight(1.3);
    pl(g, shiftP(cordC, 6, 0));
    // cut end of the cord with its butterfly of grey matter
    float ex = cordC[4], ey = cordC[5];
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(lerpColor(C_CORD, #FFFFFF, 0.35));
    g.ellipse(ex, ey, 25, 9);
    g.noStroke();
    g.fill(#D9B9A6);
    g.ellipse(ex - 4.5, ey, 7, 5);
    g.ellipse(ex + 4.5, ey, 7, 5);
    g.rect(ex - 4, ey - 1, 8, 2);
    // medulla, with its olive bulge
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_MED);
    shp(g, medP);
    rim(g, medP, 8, 60, 70);
    g.stroke(C_STEM_DK);
    g.strokeWeight(1.4);
    g.fill(lerpColor(C_MED, #FFFFFF, 0.28));
    g.ellipse(358, 486, 14, 32);
    g.noFill();
    pl(g, crO(new float[] { 340, 458, 337, 480, 340, 502, 346, 522 }, 6));
    // pons: a rounded anterior bulge with transverse fibres
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_PONS);
    shp(g, ponsP);
    g.stroke(lerpColor(C_PONS, C_STEM_DK, 0.55));
    g.strokeWeight(1.3);
    for (float y = 398; y < 462; y += 8) {
      float[] xs = spanAt(ponsP, y);
      if (xs == null) continue;
      g.beginShape();
      for (int i = 0; i <= 10; i++) {
        float x = lerp(xs[0] + 4, xs[1] - 4, i / 10.0);
        g.vertex(x, y + 3 * sin(PI * i / 10.0));
      }
      g.endShape();
    }
    rim(g, ponsP, 9, 60, 80);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    shp(g, ponsP);
  }

  void drawCerebellum(PGraphics g) {
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(C_CBL);
    shp(g, cblP);
    // folia: thin leaves converging toward the anterior tip (the peduncle side) and fanning out to meet the
    // posterior margin, the horizontal fissure the deepest of them
    int iA = nearest(cblP, 370, 414), iB = nearest(cblP, 542, 318), iC = nearest(cblP, 548, 424);
    float[] top = resample(arcF(cblP, iA, iB), 70), bot = resample(rev(arcF(cblP, iC, iA)), 70);
    float[] back = resample(arcF(cblP, iB, iC), 40);
    for (float f = 0.12; f < 0.95; f += 0.075) {
      boolean fissure = abs(f - 0.42) < 0.03;    // the horizontal fissure
      float[] ln = new float[140], hi = new float[140];
      int bi = constrain(round(f * 39), 0, 39);
      for (int i = 0; i < 70; i++) {
        float t = i / 69.0, e = t * t * (3 - 2 * t);
        float cx = lerp(top[138], bot[138], f), cy = lerp(top[139], bot[139], f);
        float ex = (back[bi * 2] - cx) * e, ey = (back[bi * 2 + 1] - cy) * e;
        ln[i * 2] = lerp(top[i * 2], bot[i * 2], f) + ex;
        ln[i * 2 + 1] = lerp(top[i * 2 + 1], bot[i * 2 + 1], f) + ey;
        hi[i * 2] = lerp(top[i * 2], bot[i * 2], f - 0.022) + ex;
        hi[i * 2 + 1] = lerp(top[i * 2 + 1], bot[i * 2 + 1], f - 0.022) + ey;
      }
      g.noFill();
      g.stroke(255, 255, 255, 85);
      g.strokeWeight(1.3);
      pl(g, seg(hi, 3, 65));
      g.stroke(fissure ? lerpColor(C_CBL_DK, D_INK, 0.45) : C_CBL_DK);
      g.strokeWeight(fissure ? 2.6 : 1.4);
      pl(g, seg(ln, 3, 65));
    }
    rim(g, cblP, 10, 70, 60);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    shp(g, cblP);
  }

  // n points evenly spaced by arc length along an open polyline
  float[] resample(float[] p, int n) {
    int m = p.length / 2;
    float[] cum = new float[m];
    for (int i = 1; i < m; i++) cum[i] = cum[i - 1] + dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
    float[] q = new float[n * 2];
    int k = 1;
    for (int i = 0; i < n; i++) {
      float s = cum[m - 1] * i / (n - 1);
      while (k < m - 1 && cum[k] < s) k++;
      float f = (s - cum[k - 1]) / max(1e-4, cum[k] - cum[k - 1]);
      q[i * 2] = lerp(p[k * 2 - 2], p[k * 2], constrain(f, 0, 1));
      q[i * 2 + 1] = lerp(p[k * 2 - 1], p[k * 2 + 1], constrain(f, 0, 1));
    }
    return q;
  }

  void drawCerebrum(PGraphics g) {
    g.noStroke();
    g.fill(C_FRONT);
    shp(g, frontalP);
    g.fill(C_PARI);
    shp(g, parietalP);
    g.fill(C_TEMP);
    shp(g, temporalP);
    g.fill(C_OCC);
    shp(g, occipitalP);
    g.fill(C_PRE);
    shp(g, preP);
    g.fill(C_POST);
    shp(g, postP);
    // language areas: orange, stippled
    for (float[] p : new float[][] { brocaP, wernP }) {
      g.noStroke();
      g.fill(C_LANG);
      shp(g, p);
      stipple(g, p, lerpColor(C_LANG, C_LANG_DK, 0.6));
    }
    // volume: light from the upper left, shade toward the lower right
    rim(g, OUT, 12, 80, 90);
    // the opercula overhang the temporal lobe: shadow under the lateral fissure
    g.noFill();
    g.stroke(0, 0, 0, 34);
    g.strokeWeight(9);
    pl(g, shiftP(seg(LAT, 0, nearest(LAT, 372, 258)), 0, 5));
    // secondary sulci: groove + gyral highlight
    for (float[] s : minor) sulcus(g, s, 1.8, 4.6);
    // imaginary lobe boundaries (parieto-occipital line, parieto-temporal line): dashed
    g.stroke(D_INK);
    g.strokeWeight(1.5);
    dashedPl(g, PO, 7, 5);
    dashedPl(g, PT, 7, 5);
    // the two big landmarks: central sulcus and lateral (Sylvian) fissure
    sulcus(g, CEN, 3.0, 8);
    sulcus(g, LAT, 3.4, 9);
    // language areas: dashed borders
    g.stroke(C_LANG_DK);
    g.strokeWeight(1.8);
    dashedPl(g, closeP(brocaP), 5, 4);
    dashedPl(g, closeP(wernP), 5, 4);
    // outline
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.8);
    shp(g, OUT);
  }

  void sulcus(PGraphics g, float[] p, float w, float shadow) {
    g.noFill();
    g.stroke(0, 0, 0, 30);
    g.strokeWeight(shadow);
    pl(g, shiftP(p, 0.8, 1.6));
    g.stroke(255, 255, 255, 72);
    g.strokeWeight(min(2.2, w * 0.8));
    pl(g, shiftP(p, -w * 0.6 - 0.8, -w * 0.7 - 1));
    g.stroke(lerpColor(D_INK, #3B3550, 0.4));
    g.strokeWeight(w);
    pl(g, p);
  }

  void stipple(PGraphics g, float[] p, int col) {
    g.noStroke();
    g.fill(col, 150);
    float x0 = 1e9, x1 = -1e9, y0 = 1e9, y1 = -1e9;
    for (int i = 0; i < p.length; i += 2) {
      x0 = min(x0, p[i]);
      x1 = max(x1, p[i]);
      y0 = min(y0, p[i + 1]);
      y1 = max(y1, p[i + 1]);
    }
    int row = 0;
    for (float y = y0 + 3; y < y1; y += 6.5, row++) {
      for (float x = x0 + 3 + (row % 2) * 3.5; x < x1; x += 7) {
        if (insidePoly(p, x, y) && edgeDist(p, x, y) > 3.5) g.ellipse(x, y, 2.2, 2.2);
      }
    }
  }

  // shade a band just inside a closed outline: dark where it faces down-right, light where it faces up-left
  void rim(PGraphics g, float[] p, float depth, float dark, float light) {
    int n = p.length / 2;
    float area = 0;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += p[i * 2] * p[j * 2 + 1] - p[j * 2] * p[i * 2 + 1];
    }
    float sgn = area > 0 ? 1 : -1;
    float[] nx = new float[n], ny = new float[n];
    for (int i = 0; i < n; i++) {
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      // inward normal
      nx[i] = -ty / L * sgn;
      ny[i] = tx / L * sgn;
    }
    g.noStroke();
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      float ox = -(nx[i] + nx[j]) / 2, oy = -(ny[i] + ny[j]) / 2;
      float d = ox * 0.55 + oy * 0.83;     // outward normal vs the shade direction (down-right)
      if (d > 0) g.fill(0, 0, 0, dark * d);
      else g.fill(255, 255, 255, light * -d);
      for (int s = 0; s < 3; s++) {
        float d0 = 1.5 + depth * s / 3.0, d1 = 1.5 + depth * (s + 1) / 3.0;
        float k = 1 - s / 3.0;
        if (d > 0) g.fill(0, 0, 0, dark * d * k * 0.6);
        else g.fill(255, 255, 255, light * -d * k * 0.6);
        g.beginShape();
        g.vertex(p[i * 2] + nx[i] * d0, p[i * 2 + 1] + ny[i] * d0);
        g.vertex(p[j * 2] + nx[j] * d0, p[j * 2 + 1] + ny[j] * d0);
        g.vertex(p[j * 2] + nx[j] * d1, p[j * 2 + 1] + ny[j] * d1);
        g.vertex(p[i * 2] + nx[i] * d1, p[i * 2 + 1] + ny[i] * d1);
        g.endShape(CLOSE);
      }
    }
  }

  // ------------------------------------------------------------ helpers (local to this class)
  // ripple an open polyline sideways (ends stay put): makes sulci look hand-drawn and organic
  float[] wig(float[] p, float amp, float period, float ph) {
    int n = p.length / 2;
    float[] s = new float[n];
    for (int i = 1; i < n; i++) s[i] = s[i - 1] + dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
    float L = max(1e-3, s[n - 1]);
    float[] q = new float[p.length];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], T = max(1e-3, sqrt(tx * tx + ty * ty));
      float env = min(1, min(s[i], L - s[i]) / 8);
      float o = amp * env * sin(TWO_PI * s[i] / period + ph);
      q[i * 2] = p[i * 2] - ty / T * o;
      q[i * 2 + 1] = p[i * 2 + 1] + tx / T * o;
    }
    return q;
  }

  // gentle gyral bumps along a closed outline
  float[] bumpy(float[] p) {
    int n = p.length / 2;
    float[] q = new float[p.length];
    float s = 0;
    for (int i = 0; i < n; i++) {
      if (i > 0) s += dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
      int a = (i + n - 1) % n, b = (i + 1) % n;
      float tx = p[b * 2] - p[a * 2], ty = p[b * 2 + 1] - p[a * 2 + 1], T = max(1e-3, sqrt(tx * tx + ty * ty));
      float o = 1.5 * sin(TWO_PI * s / 46) + 0.5 * sin(TWO_PI * s / 27 + 1.3);
      q[i * 2] = p[i * 2] - ty / T * o;
      q[i * 2 + 1] = p[i * 2 + 1] + tx / T * o;
    }
    return q;
  }

  float[] spanAt(float[] p, float y) {
    float lo = 1e9, hi = -1e9;
    int n = p.length / 2;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      float yi = p[i * 2 + 1], yj = p[j * 2 + 1];
      if ((yi > y) != (yj > y)) {
        float x = p[i * 2] + (y - yi) / (yj - yi) * (p[j * 2] - p[i * 2]);
        lo = min(lo, x);
        hi = max(hi, x);
      }
    }
    return lo < hi ? new float[] { lo, hi } : null;
  }

  float edgeDist(float[] p, float x, float y) {
    float best = 1e9;
    int n = p.length / 2;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      float ax = p[j * 2], ay = p[j * 2 + 1], bx = p[i * 2], by = p[i * 2 + 1];
      float dx = bx - ax, dy = by - ay, L2 = dx * dx + dy * dy;
      float t = L2 < 1e-6 ? 0 : constrain(((x - ax) * dx + (y - ay) * dy) / L2, 0, 1);
      best = min(best, dist(x, y, ax + dx * t, ay + dy * t));
    }
    return best;
  }

  void dashedPl(PGraphics g, float[] p, float on, float off) {
    float acc = 0;
    boolean draw = true;
    int n = p.length / 2;
    for (int i = 0; i < n - 1; i++) {
      float x0 = p[i * 2], y0 = p[i * 2 + 1], x1 = p[i * 2 + 2], y1 = p[i * 2 + 3];
      float L = dist(x0, y0, x1, y1), t = 0;
      while (t < L) {
        float lim = draw ? on : off;
        float step = min(lim - acc, L - t);
        if (draw) g.line(lerp(x0, x1, t / L), lerp(y0, y1, t / L), lerp(x0, x1, (t + step) / L), lerp(y0, y1, (t + step) / L));
        t += step;
        acc += step;
        if (acc >= lim - 1e-4) {
          acc = 0;
          draw = !draw;
        }
      }
    }
  }

  float[] closeP(float[] p) {
    float[] q = new float[p.length + 2];
    arrayCopy(p, q);
    q[p.length] = p[0];
    q[p.length + 1] = p[1];
    return q;
  }

  float[] cp(float[] p) {
    return p.clone();
  }

  int nearest(float[] p, float x, float y) {
    int best = 0;
    float bd = 1e9;
    for (int i = 0; i < p.length / 2; i++) {
      float d = sq(p[i * 2] - x) + sq(p[i * 2 + 1] - y);
      if (d < bd) {
        bd = d;
        best = i;
      }
    }
    return best;
  }

  // closed polyline: points i .. j going forward (wrapping)
  float[] arcF(float[] p, int i, int j) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    int k = i;
    while (true) {
      q.append(p[k * 2]);
      q.append(p[k * 2 + 1]);
      if (k == j) break;
      k = (k + 1) % n;
    }
    return q.array();
  }

  // open polyline: points i .. j (reversed when j < i)
  float[] seg(float[] p, int i, int j) {
    int st = j >= i ? 1 : -1;
    FloatList q = new FloatList();
    for (int k = i; ; k += st) {
      q.append(p[k * 2]);
      q.append(p[k * 2 + 1]);
      if (k == j) break;
    }
    return q.array();
  }

  float[] rev(float[] p) {
    return seg(p, p.length / 2 - 1, 0);
  }

  float[] cat(float[]... a) {
    FloatList q = new FloatList();
    for (float[] p : a) for (float v : p) q.append(v);
    return q.array();
  }

  // lengthen an open polyline by e0 units at its start and e1 at its end
  float[] extend(float[] p, float e0, float e1) {
    int n = p.length / 2;
    float dx0 = p[0] - p[2], dy0 = p[1] - p[3], L0 = max(1e-3, sqrt(dx0 * dx0 + dy0 * dy0));
    float dx1 = p[n * 2 - 2] - p[n * 2 - 4], dy1 = p[n * 2 - 1] - p[n * 2 - 3], L1 = max(1e-3, sqrt(dx1 * dx1 + dy1 * dy1));
    return cat(new float[] { p[0] + dx0 / L0 * e0, p[1] + dy0 / L0 * e0 }, p, new float[] { p[n * 2 - 2] + dx1 / L1 * e1, p[n * 2 - 1] + dy1 / L1 * e1 });
  }

  float[] shiftP(float[] p, float dx, float dy) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = p[i] + dx;
      q[i + 1] = p[i + 1] + dy;
    }
    return q;
  }

  float[] band(float[] c, float w0, float w1) {
    int n = c.length / 2;
    float[] q = new float[n * 4];
    for (int i = 0; i < n; i++) {
      int a = max(0, i - 1), b = min(n - 1, i + 1);
      float tx = c[b * 2] - c[a * 2], ty = c[b * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float w = lerp(w0, w1, i / (float) max(1, n - 1)) / 2;
      float nx = -ty / L * w, ny = tx / L * w;
      q[i * 2] = c[i * 2] + nx;
      q[i * 2 + 1] = c[i * 2 + 1] + ny;
      q[(2 * n - 1 - i) * 2] = c[i * 2] - nx;
      q[(2 * n - 1 - i) * 2 + 1] = c[i * 2 + 1] - ny;
    }
    return q;
  }

  void shp(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape(CLOSE);
  }

  void pl(PGraphics g, float[] p) {
    g.beginShape();
    for (int i = 0; i < p.length; i += 2) g.vertex(p[i], p[i + 1]);
    g.endShape();
  }

  float crv(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  float[] crO(float[] p, int per) {
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

  float[] crC(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n; i++) {
      int i0 = (i + n - 1) % n, i2 = (i + 1) % n, i3 = (i + 2) % n;
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(crv(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(crv(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    return q.array();
  }
}
