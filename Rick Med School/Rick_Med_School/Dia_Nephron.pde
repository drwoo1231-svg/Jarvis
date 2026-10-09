// Nephron: classic schematic. Afferent arteriole -> glomerulus inside Bowman's capsule
// -> efferent arteriole. Filtrate: proximal convoluted tubule -> descending limb ->
// (hairpin in the medulla) -> ascending limb -> macula densa where the tubule touches
// its own glomerulus' vascular pole -> distal convoluted tubule -> collecting duct.
// Cortex = upper band, medulla = lower band.

class NephronDiagram extends Diagram {
  final int CORTEX = #F5E4CB, MEDULLA = #F0D5CF;
  final int CAPS = #E7C886, CAPS_SH = #C9A35A, URINE = #FFF5D6;
  final int PCT = #EBC271, DESC = #F4DDA4, ASC = #E2AE5C, DCT = #F0C894, MD = #D99A44;
  final int LUMEN = #FFF8E6;
  final int CD = #7FC6B6, CD_SH = #569F8E, CD_LT = #B9E4D9;
  final int ART_SH = #A72A2E, ART_LT = #F08A86;

  final float GX = 205, GY = 196;               // renal corpuscle centre
  final float R_CAPS = 64, R_SPACE = 55, R_GLOM = 42;
  final float[] RAD_C = { 16, 350, 40, 348, 54, 330, 56, 200, 56, 16 };    // arcuate -> cortical radiate artery
  final float[] AFF_C = { 60, 92, 110, 92, 168, 104, 212, 124, 238, 146 };
  final float[] EFF_C = { 256, 158, 282, 170, 306, 184 };
  final float[] VR_C = { 306, 184, 318, 240, 322, 330, 323, 460, 326, 540, 344, 566, 372, 572, 398, 562, 412, 530, 413, 420, 414, 300, 420, 214, 432, 188 };
  final float[] PCT_C = { 168, 226, 152, 246, 146, 268, 156, 294, 190, 302, 214, 278, 244, 290, 256, 316, 290, 316, 306, 292, 334, 294, 346, 318, 348, 348 };
  final float[] DESC_C = { 348, 342, 348, 440, 349, 506, 354, 532, 368, 546, 382, 536 };
  final float[] DIST_C = { 382, 536, 385, 470, 388, 380, 390, 280, 390, 210, 384, 168, 360, 144, 322, 134, 290, 137, 268, 141, 254, 131, 258, 113, 280, 105, 314, 104, 340, 92, 356, 66, 382, 48, 410, 56, 420, 86, 444, 104, 470, 94, 478, 66, 496, 46, 526, 54 };
  final float[] CD_C = { 540, 16, 540, 200, 538, 400, 534, 586 };

  float[] rad, aff, eff, vr, pct, desc, dist, cdp, tub;
  float sPctEnd, sDescEnd;
  float sAscEnd, sMdEnd, sDescTurn, sThick;

  NephronDiagram() {
    super("nephron", "Nephron");
    rad = cr(RAD_C, false, 10);
    aff = cr(AFF_C, false, 10);
    eff = cr(EFF_C, false, 10);
    vr = cr(VR_C, false, 10);
    pct = cr(PCT_C, false, 10);
    desc = cr(DESC_C, false, 10);
    dist = cr(DIST_C, false, 10);
    cdp = cr(CD_C, false, 10);
    sAscEnd = arcNear(dist, 288, 137);   // thick ascending limb ends ...
    sMdEnd = arcNear(dist, 262, 110);    // ... macula densa (the bend touching the vascular pole) ...
    sDescTurn = arcNear(desc, 368, 546); // bottom of the hairpin
    sThick = arcNear(dist, 386, 440);    // thin -> thick ascending limb
    // the whole tubule as one path (for seamless drawing): PCT + descending limb + rest
    float[] dd = sub(desc, 6, 9999);
    tub = new float[pct.length + dd.length + dist.length - 4];
    System.arraycopy(pct, 0, tub, 0, pct.length);
    System.arraycopy(dd, 2, tub, pct.length, dd.length - 2);
    System.arraycopy(dist, 2, tub, pct.length + dd.length - 2, dist.length - 2);
    sPctEnd = len(pct);
    sDescEnd = len(sub(tub, 0, 9999)) - len(dist);

    add("bowmans_capsule", "Bowman's Capsule").poly(ring(GX, GY, R_CAPS + 4, R_GLOM + 1, 32)).anchor(GX - 50, GY + 30);
    add("glomerulus", "Glomerulus").ellipse(GX, GY, R_GLOM + 3, R_GLOM + 3).anchor(GX - 4, GY + 4);
    add("proximal_tubule", "Proximal Tubule").poly(tubePoly(sub(pct, 22, 9999), 32)).anchor(246, 292);
    add("descending_limb", "Descending Limb of Henle").poly(tubePoly(sub(desc, 6, sDescTurn), 28)).anchor(348, 450);
    add("ascending_limb", "Ascending Limb of Henle").poly(tubePoly(sub(dist, 0, sAscEnd), 30)).anchor(389, 360);
    add("distal_tubule", "Distal Convoluted Tubule").poly(tubePoly(sub(dist, sMdEnd, 9999), 30)).anchor(420, 84);
    add("collecting_duct", "Collecting Duct").poly(taperPoly(cdp, 38, 50)).anchor(538, 330);
    add("afferent_arteriole", "Afferent Arteriole").poly(tubePoly(sub(aff, 0, len(aff) - 4), 28)).anchor(140, 98);
    add("efferent_arteriole", "Efferent Arteriole").poly(tubePoly(eff, 24)).anchor(284, 172);
    add("macula_densa", "Macula Densa").ellipse(262, 126, 20, 19).anchor(258, 128);
  }

  // annulus as one polygon: outer circle one way, inner circle back the other way (a hole for
  // both the even-odd hit test and non-zero filling)
  float[] ring(float cx, float cy, float ro, float ri, int n) {
    float[] r = new float[(n + 1) * 4];
    for (int i = 0; i <= n; i++) {
      float a = TWO_PI * i / n;
      r[i * 2] = cx + ro * cos(a);
      r[i * 2 + 1] = cy + ro * sin(a);
      r[(2 * n + 1 - i) * 2] = cx + ri * cos(a);
      r[(2 * n + 1 - i) * 2 + 1] = cy + ri * sin(a);
    }
    return r;
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

  void drawArt(PGraphics g) {
    // ---- kidney zones: cortex (top) and medulla (bottom, striated)
    g.noStroke();
    g.fill(CORTEX);
    g.beginShape();
    g.vertex(16, 30);
    g.bezierVertex(16, 20, 22, 14, 32, 14);
    g.vertex(568, 14);
    g.bezierVertex(578, 14, 584, 20, 584, 30);
    g.vertex(584, 332);
    for (float x = 584; x >= 16; x -= 8) g.vertex(x, 336 + 5 * sin(x * 0.045));
    g.endShape(CLOSE);
    g.fill(MEDULLA);
    g.beginShape();
    for (float x = 16; x <= 584; x += 8) g.vertex(x, 336 + 5 * sin(x * 0.045));
    g.vertex(584, 570);
    g.bezierVertex(584, 580, 578, 586, 568, 586);
    g.vertex(32, 586);
    g.bezierVertex(22, 586, 16, 580, 16, 570);
    g.endShape(CLOSE);
    g.stroke(#E3BFB8);
    g.strokeWeight(1.4);
    for (float x = 40; x < 580; x += 26) g.line(x, 352 + 5 * sin(x * 0.045), x + (x - 300) * 0.04, 574);
    g.stroke(#C9A98A);
    g.strokeWeight(1.6);
    g.noFill();
    dashedWave(g);

    // ---- context vessels (no parts): arcuate -> cortical radiate artery, vasa recta
    tube(g, rad, 22, #B9343A, ART_SH, ART_LT, true);
    cutEnd(g, rad, true, 22, ART_SH);
    cutEnd(g, rad, false, 22, ART_SH);
    vasaRecta(g);

    // ---- collecting duct (distinct teal), widening as it descends
    float[] cdPoly = taperPoly(cdp, 30, 42);
    g.noStroke();
    g.fill(CD);
    polygon(g, cdPoly);
    g.strokeCap(SQUARE);
    g.stroke(CD_SH, 160);
    g.strokeWeight(7);
    g.line(551, 22, 549, 580);
    g.strokeCap(ROUND);
    g.stroke(#E8F6F2);
    g.strokeWeight(7);
    g.line(538, 22, 532, 578);
    g.stroke(D_INK);
    g.strokeWeight(2.4);
    g.noFill();
    polygon(g, cdPoly);
    cutEnd(g, cdp, true, 30, CD_SH);
    cutEnd(g, cdp, false, 42, CD_SH);

    // ---- tubule: descending limb (thin), PCT (thick), ascending limb (thin -> thick) -> macula densa -> DCT
    wholeTubule(g);
    brushBorder(g, sub(pct, 30, len(pct) - 4), 22);

    // ---- Bowman's capsule: parietal wall + urinary space
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(CAPS);
    g.ellipse(GX, GY, R_CAPS * 2, R_CAPS * 2);
    g.noStroke();
    g.fill(CAPS_SH, 140);
    g.arc(GX, GY, R_CAPS * 2 - 3, R_CAPS * 2 - 3, 0.1, PI - 0.1);
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(URINE);
    g.ellipse(GX, GY, R_SPACE * 2, R_SPACE * 2);
    // neck: the urinary space opens into the PCT at the urinary pole
    g.strokeCap(SQUARE);
    g.stroke(PCT);
    g.strokeWeight(22);
    polyline(g, sub(pct, 4, 30));
    g.strokeCap(ROUND);
    g.stroke(LUMEN);
    g.strokeWeight(7);
    polyline(g, sub(pct, 0, 30));

    // ---- glomerulus: knot of capillary loops
    glomerulus(g);

    // ---- arterioles at the vascular pole (afferent wider than efferent)
    tube(g, aff, 18, D_ARTERY, ART_SH, ART_LT, true);
    cutEnd(g, aff, true, 18, ART_SH);
    tube(g, eff, 12, #C7383C, ART_SH, ART_LT, false);
    // juxtaglomerular (granular) cells in the afferent wall
    g.noStroke();
    g.fill(#F6D7A0);
    float[] jg = sub(aff, len(aff) - 34, len(aff) - 10);
    for (int i = 0; i < jg.length; i += 4) g.ellipse(jg[i] + 4, jg[i + 1] - 5, 4, 4);

    // ---- macula densa: crowded tall cells on the tubule wall facing the pole
    float[] mdp = sub(dist, sAscEnd + 2, sMdEnd);
    float[] wall = offset(mdp, -6);
    g.stroke(D_INK);
    g.strokeWeight(1);
    g.fill(#7A4A1C);
    for (int i = 0; i < wall.length; i += 2) g.ellipse(wall[i], wall[i + 1], 4.2, 4.2);

    // ---- flow chevrons
    g.stroke(#FFFFFF, 220);
    g.strokeWeight(2);
    chevron(g, pct, 120, 4.5);
    chevron(g, desc, 80, 4);
    chevron(g, desc, 150, 4);
    chevron(g, dist, 60, 3.5);
    chevron(g, dist, 250, 4.5);
    chevron(g, dist, sMdEnd + 150, 4.5);
    chevron(g, cdp, 300, 7);
    chevron(g, cdp, 440, 7);
  }

  // the tubule in three passes (ink, colour, lumen) so segments join without seams
  float tubW(float s) {
    if (s < sPctEnd - 10) return 22;
    if (s < sDescEnd) return lerp(22, 13, constrain((s - (sPctEnd - 10)) / 30, 0, 1));
    float d = s - sDescEnd;
    if (d < sAscEnd) return lerp(13, 19, constrain((d - (sThick - 18)) / 36, 0, 1));
    if (d < sMdEnd) return 19;
    return 18;
  }

  int tubCol(float s) {
    if (s < sPctEnd - 4) return PCT;
    if (s < sPctEnd + 16) return lerpColor(PCT, DESC, (s - (sPctEnd - 4)) / 20);
    float d = s - sDescEnd;
    if (d < 0) return DESC;
    if (d < 14) return lerpColor(DESC, ASC, d / 14);
    if (d < sAscEnd) return ASC;
    if (d < sMdEnd) return MD;
    return DCT;
  }

  void wholeTubule(PGraphics g) {
    float L = len(tub), st = 4;
    g.noFill();
    for (int pass = 0; pass < 4; pass++) {
      for (float s = 8; s < L; s += st) {
        float[] seg = sub(tub, s, min(L, s + st + 1));
        float w = tubW(s);
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(w + 4.6);
        } else if (pass == 1) {
          g.stroke(tubCol(s));
          g.strokeWeight(w);
        } else if (pass == 2) {
          g.stroke(lerpColor(tubCol(s), #FFFFFF, 0.3));
          g.strokeWeight(w * 0.2);
          seg = offset(seg, w * 0.26);
        } else {
          g.stroke(LUMEN);
          g.strokeWeight(max(2.5, w * 0.3));
          seg = offset(seg, -w * 0.06);
        }
        polyline(g, seg);
      }
    }
  }

  // vasa recta: thin capillary hairpin from the efferent arteriole (red -> blue)
  void vasaRecta(PGraphics g) {
    float L = len(vr);
    g.noFill();
    g.stroke(D_INK, 200);
    g.strokeWeight(7.4);
    polyline(g, vr);
    g.strokeWeight(5);
    for (float s = 0; s < L; s += 6) {
      g.stroke(lerpColor(#D9474B, #5A7FD6, constrain((s - L * 0.35) / (L * 0.35), 0, 1)));
      polyline(g, sub(vr, s, min(L, s + 7)));
    }
    cutEnd(g, vr, false, 6, #3E5FAE);
  }

  // stroke tube whose width ramps from w0 to w1 around arc length sMid
  void strokeTubeVar(PGraphics g, float[] p, float a, float b, float w0, float w1, float sMid, int col) {
    for (int pass = 0; pass < 3; pass++) {
      for (float s = a; s < b; s += 4) {
        float w = lerp(w0, w1, constrain((s - (sMid - 18)) / 36, 0, 1));
        float[] seg = sub(p, s, min(b, s + 5));
        g.noFill();
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(w + 4.6);
        } else if (pass == 1) {
          g.stroke(col);
          g.strokeWeight(w);
        } else {
          g.stroke(LUMEN);
          g.strokeWeight(max(2.5, w * 0.3));
          seg = offset(seg, -w * 0.06);
        }
        polyline(g, seg);
      }
    }
  }

  void dashedWave(PGraphics g) {
    boolean on = true;
    for (float x = 16; x < 584; x += 8) {
      if (on) g.line(x, 336 + 5 * sin(x * 0.045), x + 8, 336 + 5 * sin((x + 8) * 0.045));
      on = !on;
    }
  }

  // small chevron inside a tube at arc length d pointing along the flow
  void chevron(PGraphics g, float[] p, float d, float s) {
    float[] a = sub(p, d - 1, d + 1);
    float x = a[0], y = a[1], dx = a[a.length - 2] - a[0], dy = a[a.length - 1] - a[1], m = max(1e-4, sqrt(dx * dx + dy * dy));
    dx /= m;
    dy /= m;
    g.noFill();
    g.line(x - dx * s - dy * s, y - dy * s + dx * s, x, y);
    g.line(x - dx * s + dy * s, y - dy * s - dx * s, x, y);
  }

  // glomerulus: a tangled knot of capillary loops fed by the afferent and drained by the efferent
  void glomerulus(PGraphics g) {
    g.noStroke();
    g.fill(#EFA3A0);
    g.ellipse(GX, GY, R_GLOM * 2 - 6, R_GLOM * 2 - 6);
    FloatList k = new FloatList();
    k.append(GX + 40);
    k.append(GY - 50);
    k.append(GX + 26);
    k.append(GY - 30);
    for (float t = 0; t < TWO_PI * 3; t += 0.09) {
      float r = 25 + 12 * sin(2.55 * t + 0.6);
      k.append(GX + r * cos(t - 1.2));
      k.append(GY + r * sin(t - 1.2) * 0.96);
    }
    k.append(GX + 30);
    k.append(GY - 28);
    k.append(GX + 48);
    k.append(GY - 44);
    float[] p = k.array();
    float L = len(p), step = 22;
    for (float s = 0; s < L; s += step) {
      float e = min(L, s + step);
      g.noFill();
      g.stroke(D_INK);
      g.strokeWeight(12.5);
      polyline(g, sub(p, s, e));
      g.stroke(#D5454A);
      g.strokeWeight(9);
      polyline(g, sub(p, max(0, s - 8), e));
      g.stroke(#F6A3A0);
      g.strokeWeight(2.4);
      polyline(g, offset(sub(p, max(0, s - 8), e), 2));
    }
  }

  // tubule drawn as a stroke: ink outline, colour, pale lumen line
  void strokeTube(PGraphics g, float[] p, float w, int col) {
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(w + 4.6);
    polyline(g, p);
    g.stroke(col);
    g.strokeWeight(w);
    polyline(g, p);
    g.stroke(lerpColor(col, #FFFFFF, 0.25));
    g.strokeWeight(w * 0.22);
    polyline(g, offset(p, w * 0.24));
    g.stroke(LUMEN);
    g.strokeWeight(max(2.5, w * 0.3));
    polyline(g, offset(p, -w * 0.06));
  }

  // fuzzy brush-border ticks along the PCT lumen
  void brushBorder(PGraphics g, float[] p, float w) {
    g.stroke(lerpColor(PCT, #8A5A1E, 0.35));
    g.strokeWeight(1);
    for (int i = 0; i + 3 < p.length; i += 2) {
      float dx = p[i + 2] - p[i], dy = p[i + 3] - p[i + 1], m = max(1e-4, sqrt(dx * dx + dy * dy));
      float nx = -dy / m, ny = dx / m;
      float x = p[i] - nx * w * 0.06, y = p[i + 1] - ny * w * 0.06;
      g.line(x + nx * 3, y + ny * 3, x + nx * 5.5, y + ny * 5.5);
      g.line(x - nx * 3, y - ny * 3, x - nx * 5.5, y - ny * 5.5);
    }
  }

  float[] taperPoly(float[] p, float w0, float w1) {
    int n = p.length / 2;
    float[] r = new float[p.length * 2];
    for (int i = 0; i < n; i++) {
      int a = max(i - 1, 0), b = min(i + 1, n - 1);
      float dx = p[b * 2] - p[a * 2], dy = p[b * 2 + 1] - p[a * 2 + 1], L = max(1e-4, sqrt(dx * dx + dy * dy));
      float w = lerp(w0, w1, i / (float) (n - 1)) / 2;
      r[i * 2] = p[i * 2] - dy / L * w;
      r[i * 2 + 1] = p[i * 2 + 1] + dx / L * w;
      r[(2 * n - 1 - i) * 2] = p[i * 2] + dy / L * w;
      r[(2 * n - 1 - i) * 2 + 1] = p[i * 2 + 1] - dx / L * w;
    }
    return r;
  }

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
