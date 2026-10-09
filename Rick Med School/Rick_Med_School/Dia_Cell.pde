// Generic animal cell, cross-section. Phospholipid-bilayer membrane around
// blue cytoplasm; nucleus (double envelope with pores, chromatin, nucleolus);
// rough ER cisternae wrapped around the nucleus and studded with ribosomes;
// smooth ER tubules (no ribosomes); a Golgi stack with vesicles; mitochondria
// with cristae; free ribosomes (polysomes); lysosomes; a centrosome (two
// centrioles at right angles). Hit polygons are built from the same geometry.

class CellDiagram extends Diagram {
  final float CX = 300, CY = 302, RX = 266, RY = 250;      // cell outline
  final float NX = 248, NY = 272, NRX = 94, NRY = 84, NA = -0.12;   // nucleus
  final float GX = 446, GY = 262, GA = -0.10;              // golgi centre + tilt
  final float SX = 430, SY = 432;                          // smooth ER centre
  final float CEX = 372, CEY = 136;                        // centrosome

  final int MEM = #F4C49C, MEM_HEAD = #E3895F, MEM_TAIL = #E9B08A;
  final int NUC_IN = #CDC2EC, NUC_ENV = #7462B2, CHROM = #A595D6, NUCLEOLUS = #57438F;
  final int ER_DK = #3E7EAE, RIBO = #2C356E;
  final int SER = #86D0BC, SER_DK = #3F9580;
  final int GOLGI_DK = #B57A22;
  final int MITO_DK = #C2582F, MITO_IN = #F9C2A2;
  final int LYSO = #E58BB0, LYSO_DK = #A9466F;
  final int CENT = #8A97AE, CENT_DK = #4F5B73, PCM = #E7E1F2;

  // geometry
  float[][] rer = new float[3][];          // rough ER centre lines
  float[] rerW = { 11, 12, 11 };
  float[][] serTubes;                      // smooth ER tube centre lines
  float[][] mitos = { { 158, 138, 50, 23, -0.42 }, { 462, 362, 42, 20, 0.22 }, { 262, 499, 48, 22, 0.06 }, { 123, 428, 40, 20, 1.02 } };
  float[][] lysos = { { 268, 104, 17 }, { 366, 503, 15 }, { 184, 474, 15 } };
  float[][] polys = { { 338, 74, 0.1 }, { 384, 332, 0.6 }, { 300, 452, 0.15 }, { 84, 300, 1.4 }, { 458, 162, -0.7 } };

  CellDiagram() {
    super("cell", "Animal Cell");
    build();
    add("cytoplasm", "Cytoplasm").poly(outline(13, 120)).anchor(392, 470);
    add("cell_membrane", "Cell Membrane").poly(ring(-7, 19, 120)).anchor(CX + memX(-0.25, 6), CY + memY(-0.25, 6));
    add("nucleus", "Nucleus").poly(ell(NX, NY, NRX + 3, NRY + 3, NA, 36)).anchor(NX - 40, NY + 30);
    add("rough_er", "Rough ER").poly(rerHit()).anchor(NX + cos(2.35) * (NRX + 38), NY + sin(2.35) * (NRY + 38));
    add("smooth_er", "Smooth ER").poly(serHit()).anchor(SX + 4, SY);
    add("golgi", "Golgi Apparatus").poly(golgiHit()).anchor(GX, GY);
    Part m = add("mitochondrion", "Mitochondrion");
    for (float[] k : mitos) m.poly(ell(k[0], k[1], k[2] + 3, k[3] + 3, k[4], 28));
    m.anchor(mitos[0][0], mitos[0][1]);
    Part l = add("lysosome", "Lysosome");
    for (float[] k : lysos) l.poly(ell(k[0], k[1], k[2] + 4, k[2] + 4, 0, 20));
    l.anchor(lysos[0][0], lysos[0][1]);
    add("centrosome", "Centrosome").poly(ell(CEX, CEY, 30, 25, -0.3, 24)).anchor(CEX, CEY);
    Part r = add("ribosome", "Ribosome");
    for (float[] k : polys) r.poly(ell(k[0], k[1], 22, 13, k[2], 20));
    r.anchor(polys[0][0], polys[0][1]);
    add("nucleolus", "Nucleolus").poly(ell(NX + 16, NY - 8, 33, 28, 0.3, 24)).anchor(NX + 16, NY - 8);
  }

  // ------------------------------------------------------------ geometry
  float wob(float t) {
    return 1 + 0.03 * sin(3 * t + 0.7) + 0.018 * sin(5 * t + 2.1) + 0.012 * cos(2 * t + 0.4);
  }

  float memX(float t, float d) {
    return (RX * wob(t) - d) * cos(t);
  }

  float memY(float t, float d) {
    return (RY * wob(t) - d) * sin(t);
  }

  // closed outline of the cell, d units inside the outer membrane surface
  float[] outline(float d, int n) {
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n;
      p[i * 2] = CX + memX(t, d);
      p[i * 2 + 1] = CY + memY(t, d);
    }
    return p;
  }

  // a ring polygon (outer loop + inner loop joined by a seam): even-odd fill makes it hollow
  float[] ring(float d0, float d1, int n) {
    float[] p = new float[(n + 1) * 4];
    int k = 0;
    for (int i = 0; i <= n; i++) {
      float t = TWO_PI * i / n;
      p[k++] = CX + memX(t, d0);
      p[k++] = CY + memY(t, d0);
    }
    for (int i = n; i >= 0; i--) {
      float t = TWO_PI * i / n;
      p[k++] = CX + memX(t, d1);
      p[k++] = CY + memY(t, d1);
    }
    return p;
  }

  // a point at polar angle a, "off" units outside the nucleus outline
  float nuX(float a, float off) {
    float x = cos(a) * (NRX + off), y = sin(a) * (NRY + off);
    return NX + x * cos(NA) - y * sin(NA);
  }

  float nuY(float a, float off) {
    float x = cos(a) * (NRX + off), y = sin(a) * (NRY + off);
    return NY + x * sin(NA) + y * cos(NA);
  }

  final float RER_A0 = 0.95, RER_A1 = 3.55;
  final float[] RER_OFF = { 20, 39, 58 };

  void build() {
    for (int c = 0; c < 3; c++) {
      float a0 = RER_A0 + 0.05 * c, a1 = RER_A1 - 0.06 * c;
      int n = 60;
      float[] p = new float[n * 2];
      for (int i = 0; i < n; i++) {
        float a = lerp(a0, a1, i / (float) (n - 1));
        float off = RER_OFF[c] + 3.2 * sin(a * 9 + c * 1.7);   // gently folded sheets
        p[i * 2] = nuX(a, off);
        p[i * 2 + 1] = nuY(a, off);
      }
      if (c == 0) {
        // the innermost sheet bends into the nuclear envelope: the RER lumen is continuous with it
        float[] q = new float[p.length + 4];
        arrayCopy(p, q);
        q[p.length] = nuX(a1 + 0.1, 10);
        q[p.length + 1] = nuY(a1 + 0.1, 10);
        q[p.length + 2] = nuX(a1 + 0.16, 0);
        q[p.length + 3] = nuY(a1 + 0.16, 0);
        p = q;
      }
      rer[c] = p;
    }
    float[][] t = {
      { -62, -22, -40, -30, -16, -22, 6, -32, 30, -22, 54, -30, 70, -18 },
      { -64, 8, -42, 2, -20, 12, 4, 4, 28, 14, 50, 6, 68, 16 },
      { -50, 36, -28, 40, -6, 34, 18, 42, 40, 36 },
      { -40, -30, -42, 2 }, { -16, -22, -20, 12 }, { 6, -32, 4, 4 }, { 30, -22, 28, 14 }, { 54, -30, 50, 6 },
      { -42, 2, -28, 40 }, { 4, 4, -6, 34 }, { 28, 14, 18, 42 }, { 50, 6, 40, 36 },
      { -64, 8, -92, 2, -118, -14 }
    };
    serTubes = new float[t.length][];
    for (int i = 0; i < t.length; i++) {
      float[] q = t[i].length > 4 ? crO(t[i], 6) : t[i];
      float[] w = new float[q.length];
      for (int k = 0; k < q.length; k += 2) {
        w[k] = SX + q[k];
        w[k + 1] = SY + q[k + 1];
      }
      serTubes[i] = w;
    }
  }

  float[] rerHit() {
    int n = 40;
    float[] p = new float[n * 4];
    for (int i = 0; i < n; i++) {
      float a = lerp(RER_A0 - 0.06, RER_A1 + 0.05, i / (float) (n - 1));
      p[i * 2] = nuX(a, 9);
      p[i * 2 + 1] = nuY(a, 9);
      float b = lerp(RER_A1 + 0.05, RER_A0 - 0.06, i / (float) (n - 1));
      p[n * 2 + i * 2] = nuX(b, 70);
      p[n * 2 + i * 2 + 1] = nuY(b, 70);
    }
    return p;
  }

  float[] serHit() {
    float[] q = { -76, -36, -40, -44, 0, -46, 40, -40, 78, -30, 84, 0, 80, 22, 60, 46, 20, 56, -20, 54, -60, 50, -76, 26, -96, 14, -126, -2, -128, -22, -110, -22, -88, -12 };
    for (int k = 0; k < q.length; k += 2) {
      q[k] += SX;
      q[k + 1] += SY;
    }
    return q;
  }

  // golgi cisterna i in local coordinates: an arc concave toward +x (the trans face)
  final float[] G_LEN = { 66, 82, 92, 86, 70 };

  float[] golgiArc(int i) {
    float x0 = -30 + 14 * i, R = 78;
    float h = G_LEN[i] / (2 * R);
    int n = 18;
    float[] p = new float[n * 2];
    for (int k = 0; k < n; k++) {
      float f = lerp(-h, h, k / (float) (n - 1));
      float lx = x0 + R - R * cos(f), ly = R * sin(f);
      p[k * 2] = GX + lx * cos(GA) - ly * sin(GA);
      p[k * 2 + 1] = GY + lx * sin(GA) + ly * cos(GA);
    }
    return p;
  }

  float[] golgiHit() {
    float[] q = { -44, -10, -40, -36, -24, -50, 2, -56, 26, -54, 48, -46, 66, -34, 70, -6, 70, 18, 64, 40, 46, 52, 22, 58, -2, 56, -26, 48, -40, 32 };
    return loc(q, GX, GY, GA);
  }

  float[] loc(float[] q, float x, float y, float a) {
    float[] p = new float[q.length];
    for (int k = 0; k < q.length; k += 2) {
      p[k] = x + q[k] * cos(a) - q[k + 1] * sin(a);
      p[k + 1] = y + q[k] * sin(a) + q[k + 1] * cos(a);
    }
    return p;
  }

  // ------------------------------------------------------------ art
  void drawArt(PGraphics g) {
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    drawCellBody(g);
    drawSER(g);
    drawRER(g);
    drawNucleus(g);
    for (float[] m : mitos) drawMito(g, m[0], m[1], m[2], m[3], m[4]);
    drawGolgi(g);
    for (float[] l : lysos) drawLyso(g, l[0], l[1], l[2]);
    drawCentrosome(g);
    for (float[] p : polys) drawPolysome(g, p[0], p[1], p[2]);
  }

  void drawCellBody(PGraphics g) {
    // soft drop shadow
    g.noStroke();
    g.fill(0, 0, 0, 22);
    float[] sh = outline(-2, 120);
    for (int k = 0; k < sh.length; k += 2) {
      sh[k] += 5;
      sh[k + 1] += 7;
    }
    shp(g, sh);
    // membrane band (lipid tails)
    g.fill(MEM);
    shp(g, outline(-1, 160));
    // cytoplasm with a slightly deeper rim
    g.fill(lerpColor(D_CYTO, #7FB6CF, 0.35));
    shp(g, outline(13, 160));
    for (int i = 0; i < 6; i++) {
      g.fill(lerpColor(lerpColor(D_CYTO, #7FB6CF, 0.35), D_CYTO, (i + 1) / 6.0));
      shp(g, outline(16 + i * 4.5, 160));
    }
    // faint cytoskeleton filaments
    g.noFill();
    g.stroke(#9CC9DD);
    g.strokeWeight(1.1);
    float[][] fil = { { 70, 210, 110, 240, 136, 300 }, { 372, 318, 400, 330, 420, 318 }, { 220, 440, 200, 470, 216, 510 },
      { 410, 96, 436, 116, 470, 112 }, { 330, 180, 350, 196, 352, 214 }, { 70, 360, 76, 396 }, { 438, 492, 466, 484, 490, 466 } };
    for (float[] f : fil) pl(g, crO(f, 6));
    // bilayer: tails between two rows of heads
    int n = 330;
    g.stroke(MEM_TAIL);
    g.strokeWeight(0.9);
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * (i + 0.5) / n;
      g.line(CX + memX(t, 2.5), CY + memY(t, 2.5), CX + memX(t, 5.6), CY + memY(t, 5.6));
      g.line(CX + memX(t, 7.4), CY + memY(t, 7.4), CX + memX(t, 10.5), CY + memY(t, 10.5));
    }
    g.noStroke();
    g.fill(MEM_HEAD);
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n;
      g.ellipse(CX + memX(t, 1.4), CY + memY(t, 1.4), 4.4, 4.4);
      g.ellipse(CX + memX(t, 11.6), CY + memY(t, 11.6), 4.4, 4.4);
    }
    // a few transmembrane proteins
    float[] prot = { -2.2, -0.9, 0.35, 1.25, 2.55 };
    for (float t : prot) {
      float x = CX + memX(t, 6.5), y = CY + memY(t, 6.5);
      g.pushMatrix();
      g.translate(x, y);
      g.rotate(atan2(memY(t + 0.01, 6.5) - memY(t - 0.01, 6.5), memX(t + 0.01, 6.5) - memX(t - 0.01, 6.5)));
      g.stroke(D_INK);
      g.strokeWeight(1.4);
      g.fill(#9F8FD8);
      g.rect(-9, -11, 8, 22, 4);
      g.rect(1, -11, 8, 22, 4);
      g.popMatrix();
    }
    // outer + inner membrane edges
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    shp(g, outline(-1.2, 160));
    g.stroke(lerpColor(D_INK, MEM, 0.45));
    g.strokeWeight(1.2);
    shp(g, outline(13.2, 160));
  }

  void drawSER(PGraphics g) {
    g.noFill();
    for (int pass = 0; pass < 3; pass++) {
      g.stroke(pass == 0 ? D_INK : pass == 1 ? SER_DK : SER);
      g.strokeWeight(pass == 0 ? 11.5 : pass == 1 ? 8.6 : 5.4);
      for (float[] t : serTubes) pl(g, t);
    }
    g.stroke(255, 255, 255, 120);
    g.strokeWeight(1.6);
    for (float[] t : serTubes) {
      float[] q = new float[t.length];
      for (int k = 0; k < t.length; k += 2) {
        q[k] = t[k] - 0.8;
        q[k + 1] = t[k + 1] - 1.4;
      }
      pl(g, q);
    }
  }

  void drawRER(PGraphics g) {
    // connection from the inner cisterna to the nuclear envelope
    g.noFill();
    for (int c = 2; c >= 0; c--) {
      float[] p = rer[c];
      float w = rerW[c];
      g.stroke(D_INK);
      g.strokeWeight(w + 3.4);
      pl(g, p);
      g.stroke(ER_DK);
      g.strokeWeight(w);
      pl(g, p);
      g.stroke(D_ER);
      g.strokeWeight(w * 0.55);
      pl(g, p);
      g.stroke(255, 255, 255, 90);
      g.strokeWeight(1.4);
      pl(g, p);
    }
    // ribosomes studding both faces
    g.noStroke();
    g.fill(RIBO);
    for (int c = 0; c < 3; c++) {
      float[] p = rer[c];
      int n = p.length / 2;
      for (int i = 1; i < n - 1; i++) {
        float tx = p[(i + 1) * 2] - p[(i - 1) * 2], ty = p[(i + 1) * 2 + 1] - p[(i - 1) * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        float nx = -ty / L, ny = tx / L, o = rerW[c] / 2 + 3.6;
        if (i % 2 == 0) g.ellipse(p[i * 2] + nx * o, p[i * 2 + 1] + ny * o, 4.4, 4.4);
        else g.ellipse(p[i * 2] - nx * o, p[i * 2 + 1] - ny * o, 4.4, 4.4);
      }
    }
  }

  void drawNucleus(PGraphics g) {
    g.noStroke();
    g.fill(0, 0, 0, 25);
    shp(g, ell(NX + 4, NY + 6, NRX + 2, NRY + 2, NA, 60));
    // envelope (double membrane)
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(NUC_ENV);
    shp(g, ell(NX, NY, NRX, NRY, NA, 72));
    g.noStroke();
    g.fill(lerpColor(NUC_ENV, NUC_IN, 0.55));
    shp(g, ell(NX, NY, NRX - 3.2, NRY - 3.2, NA, 72));
    g.stroke(lerpColor(NUC_ENV, D_INK, 0.2));
    g.strokeWeight(1.6);
    g.fill(NUC_IN);
    shp(g, ell(NX, NY, NRX - 6.5, NRY - 6.5, NA, 72));
    // nuclear pores: gaps through the envelope
    g.strokeWeight(2.2);
    for (int i = 0; i < 14; i++) {
      float a = TWO_PI * i / 14 + 0.2;
      g.stroke(NUC_IN);
      g.line(nuX(a, -7.5), nuY(a, -7.5), nuX(a, 1.2), nuY(a, 1.2));
      g.stroke(D_INK);
      g.strokeWeight(1.3);
      g.line(nuX(a - 0.035, -6.5), nuY(a - 0.035, -6.5), nuX(a - 0.035, 0.5), nuY(a - 0.035, 0.5));
      g.line(nuX(a + 0.035, -6.5), nuY(a + 0.035, -6.5), nuX(a + 0.035, 0.5), nuY(a + 0.035, 0.5));
      g.strokeWeight(2.2);
    }
    // soft highlight
    g.noStroke();
    g.fill(255, 255, 255, 50);
    shp(g, ell(NX - 26, NY - 30, 42, 24, NA - 0.3, 30));
    // chromatin threads
    g.noFill();
    g.stroke(CHROM);
    g.strokeWeight(2.2);
    float[][] ch = { { -60, 10, -44, -6, -50, -24, -34, -40, -16, -46 }, { -62, 34, -40, 30, -30, 46, -10, 52, 6, 40 },
      { 24, 36, 42, 46, 58, 30, 66, 10, 54, -6 }, { -14, 14, -2, 2, -20, -10 }, { 40, -40, 56, -30, 62, -46 }, { 18, 58, 34, 62 } };
    for (float[] c : ch) pl(g, crO(loc(c, NX, NY, NA), 5));
    g.noStroke();
    g.fill(CHROM);
    float[] dots = { -36, -8, -26, 22, 30, 52, -48, 50, 70, -18, -4, -60, 50, 12, 12, -28 };
    for (int k = 0; k < dots.length; k += 2) {
      float[] q = loc(new float[] { dots[k], dots[k + 1] }, NX, NY, NA);
      g.ellipse(q[0], q[1], 5, 5);
    }
    // nucleolus
    float ox = NX + 16, oy = NY - 8;
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(NUCLEOLUS);
    shp(g, crC(new float[] { ox - 26, oy - 4, ox - 16, oy - 22, ox + 4, oy - 26, ox + 22, oy - 16, ox + 28, oy + 4, ox + 18, oy + 20, ox - 2, oy + 24, ox - 20, oy + 16 }, 5));
    g.noStroke();
    g.fill(lerpColor(NUCLEOLUS, #FFFFFF, 0.25));
    for (int i = 0; i < 9; i++) g.ellipse(ox - 12 + (i % 3) * 11 + (i / 3) * 2, oy - 10 + (i / 3) * 10, 5, 5);
    g.fill(255, 255, 255, 70);
    g.ellipse(ox - 9, oy - 13, 14, 7);
  }

  void drawMito(PGraphics g, float x, float y, float rx, float ry, float a) {
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(a);
    g.noStroke();
    g.fill(0, 0, 0, 25);
    g.ellipse(3, 5, rx * 2, ry * 2);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    g.fill(D_MITO);
    g.ellipse(0, 0, rx * 2, ry * 2);
    g.noStroke();
    g.fill(MITO_IN);
    g.ellipse(0, 0, rx * 2 - 9, ry * 2 - 9);
    // cristae: folds of the inner membrane, alternating from each side
    g.noFill();
    g.stroke(MITO_DK);
    g.strokeWeight(2.4);
    int n = max(4, round(rx / 9));
    for (int i = 0; i < n; i++) {
      float fx = -rx + 12 + (2 * rx - 24) * i / (float) (n - 1);
      float edge = (ry - 4.5) * sqrt(max(0, 1 - sq(fx / (rx - 4.5))));
      float s = i % 2 == 0 ? -1 : 1;
      g.beginShape();
      g.vertex(fx - 2.5, s * edge);
      g.vertex(fx - 2.5, s * (edge - ry * 1.05));
      g.vertex(fx + 2.5, s * (edge - ry * 1.05));
      g.vertex(fx + 2.5, s * edge);
      g.endShape();
    }
    g.stroke(lerpColor(MITO_DK, D_MITO, 0.3));
    g.strokeWeight(1.3);
    g.ellipse(0, 0, rx * 2 - 8, ry * 2 - 8);
    g.noStroke();
    g.fill(255, 255, 255, 70);
    g.ellipse(-rx * 0.3, -ry * 0.55, rx * 0.8, ry * 0.3);
    g.popMatrix();
  }

  void drawGolgi(PGraphics g) {
    g.noFill();
    for (int i = 0; i < 5; i++) {
      float[] p = golgiArc(i);
      float w = 8.5;
      g.stroke(D_INK);
      g.strokeWeight(w + 3.4);
      pl(g, p);
      int n = p.length / 2;
      g.fill(D_INK);
      g.noStroke();
      g.ellipse(p[0], p[1], w + 7.5, w + 7.5);
      g.ellipse(p[(n - 1) * 2], p[(n - 1) * 2 + 1], w + 7.5, w + 7.5);
      g.noFill();
      g.stroke(GOLGI_DK);
      g.strokeWeight(w);
      pl(g, p);
      g.noStroke();
      g.fill(GOLGI_DK);
      g.ellipse(p[0], p[1], w + 4, w + 4);
      g.ellipse(p[(n - 1) * 2], p[(n - 1) * 2 + 1], w + 4, w + 4);
      g.noFill();
      g.stroke(D_GOLGI);
      g.strokeWeight(w * 0.55);
      pl(g, p);
      g.noStroke();
      g.fill(D_GOLGI);
      g.ellipse(p[0], p[1], w, w);
      g.ellipse(p[(n - 1) * 2], p[(n - 1) * 2 + 1], w, w);
      g.noFill();
    }
    // vesicles: small transport vesicles on the cis face, bigger secretory ones on the trans face
    float[] v = { -46, -22, 4.6, -48, 6, 4.2, -42, 30, 4.4, 70, -42, 6.5, 74, -14, 7.5, 76, 16, 6.8, 64, 42, 6, 92, -30, 8, 100, 4, 8.5, 96, 34, 7.5,
      28, -60, 5.5, 30, 58, 5.5 };
    for (int k = 0; k < v.length; k += 3) {
      float[] q = loc(new float[] { v[k], v[k + 1] }, GX, GY, GA);
      vesicle(g, q[0], q[1], v[k + 2], k / 3 == 6 || k / 3 == 7 || k / 3 == 8 ? D_GOLGI : D_GOLGI);
    }
    // a secretory vesicle fusing with the plasma membrane (exocytosis)
    float t = -0.02;
    float ex = CX + memX(t, 16), ey = CY + memY(t, 16);
    vesicle(g, ex, ey, 8, D_GOLGI);
  }

  void vesicle(PGraphics g, float x, float y, float r, int c) {
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(c);
    g.ellipse(x, y, r * 2, r * 2);
    g.noStroke();
    g.fill(255, 255, 255, 110);
    g.ellipse(x - r * 0.3, y - r * 0.35, r * 0.7, r * 0.5);
  }

  void drawLyso(PGraphics g, float x, float y, float r) {
    g.noStroke();
    g.fill(0, 0, 0, 25);
    g.ellipse(x + 2, y + 4, r * 2, r * 2);
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.fill(LYSO);
    g.ellipse(x, y, r * 2, r * 2);
    g.noStroke();
    g.fill(LYSO_DK);
    float[] d = { -0.4, -0.2, 0.3, -0.45, 0.45, 0.15, -0.1, 0.45, -0.5, 0.35, 0.05, 0.05, 0.2, -0.05 };
    for (int k = 0; k < d.length; k += 2) g.ellipse(x + d[k] * r, y + d[k + 1] * r, r * 0.22, r * 0.22);
    g.fill(255, 255, 255, 90);
    g.ellipse(x - r * 0.35, y - r * 0.45, r * 0.7, r * 0.4);
  }

  void drawCentrosome(PGraphics g) {
    g.pushMatrix();
    g.translate(CEX, CEY);
    g.rotate(-0.3);
    // pericentriolar material
    g.noStroke();
    g.fill(PCM);
    g.ellipse(0, 0, 54, 42);
    g.stroke(lerpColor(PCM, CENT_DK, 0.35));
    g.strokeWeight(1.2);
    g.noFill();
    g.ellipse(0, 0, 54, 42);
    // centriole 1: side view, a barrel with microtubule stripes
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(CENT);
    g.rect(-20, -13, 26, 13, 3);
    g.stroke(CENT_DK);
    g.strokeWeight(1.3);
    for (int i = 0; i < 3; i++) g.line(-17, -10 + i * 3.6, 3, -10 + i * 3.6);
    // centriole 2: end-on, nine microtubule triplets in a ring, at right angles to the first
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(CENT);
    g.ellipse(8, 9, 22, 22);
    g.noStroke();
    g.fill(CENT_DK);
    for (int i = 0; i < 9; i++) {
      float a = TWO_PI * i / 9;
      g.pushMatrix();
      g.translate(8 + cos(a) * 7, 9 + sin(a) * 7);
      g.rotate(a + 0.5);
      g.rect(-1, -2.6, 2.2, 5.2);
      g.popMatrix();
    }
    g.fill(PCM);
    g.ellipse(8, 9, 6, 6);
    g.popMatrix();
  }

  void drawPolysome(PGraphics g, float x, float y, float a) {
    g.pushMatrix();
    g.translate(x, y);
    g.rotate(a);
    g.noFill();
    g.stroke(#7E7AA8);
    g.strokeWeight(1.1);
    g.beginShape();
    for (int i = 0; i <= 12; i++) g.vertex(-17 + i * 34 / 12.0, 4 * sin(i * 0.9));
    g.endShape();
    g.noStroke();
    g.fill(RIBO);
    for (int i = 0; i < 6; i++) {
      float px = -15 + i * 6, py = 4 * sin((px + 17) / (34 / 12.0) * 0.9);
      g.ellipse(px, py, 5.4, 5.4);
      g.ellipse(px + 1, py - 3, 3.6, 3.6);
    }
    g.popMatrix();
  }

  // ------------------------------------------------------------ helpers (local to this class)
  float[] ell(float cx, float cy, float rx, float ry, float ang, int n) {
    float[] p = new float[n * 2];
    float ca = cos(ang), sa = sin(ang);
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n, x = cos(t) * rx, y = sin(t) * ry;
      p[i * 2] = cx + x * ca - y * sa;
      p[i * 2 + 1] = cy + x * sa + y * ca;
    }
    return p;
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

  // open Catmull-Rom through the points
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

  // closed Catmull-Rom through the points
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
