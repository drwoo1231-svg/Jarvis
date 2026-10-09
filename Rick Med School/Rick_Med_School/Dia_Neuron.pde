// Multipolar (motor-type) neuron. Dendrites branch from the soma (top left);
// the axon leaves through the axon hillock, runs right under a chain of myelin
// sheaths (Schwann cells, with nodes of Ranvier between them), curves down the
// right side and splits into axon terminals (bottom). One terminal bouton forms
// a synapse on the long dendrite of a second (lavender) neuron at the lower left,
// whose dendrites, soma and nucleus count as the same parts; the circle in the
// middle is that synapse magnified (vesicles, cleft, receptors).

class NeuronDiagram extends Diagram {
  final float SX = 150, SY = 196;                 // soma centre
  final float ICX = 360, ICY = 360, IR = 100;     // synapse inset
  final float AX_W = 9, MY_W = 28, GAP = 14, INIT = 48, TAIL = 48;
  final int NERVE_DK = #C99A24, NISSL = #B98A2A, POST = #CDB8E8, POST_DK = #8E74B8;
  final int MY_DK = #D8C07A, SCHWANN = #9C88CF, NT = #E2563F, RECEPT = #47A99A;

  ArrayList<float[]> dPts = new ArrayList<float[]>();    // dendrite segments (polyline)
  ArrayList<float[]> dWid = new ArrayList<float[]>();    // {w0, w1}
  float[] axonC, axonS;                                  // axon centre line + cumulative length
  float axonLen, sheathL;
  int NSHEATH = 7;
  float[][] term;                                        // terminal branches
  float[][] bout;                                        // bouton centres {x, y, r}
  float[][] post;                                        // second neuron dendrites
  final float JX = 425, JY = 523;                        // the synapse junction on the main figure

  NeuronDiagram() {
    super("neuron", "Neuron");
    build();
    Part d = add("dendrite", "Dendrites");
    for (int i = 0; i < dPts.size(); i++) d.poly(band(dPts.get(i), max(dWid.get(i)[0], dWid.get(i)[1]) + 10, dWid.get(i)[1] + 11));
    // the second (postsynaptic) neuron's dendrites, soma and nucleus are the same structures
    for (int i = 0; i < post.length; i++) d.poly(band(post[i], POST_SW[i] + 10, POST_EW[i] + 11));
    d.anchor(dPts.get(0)[dPts.get(0).length - 2], dPts.get(0)[dPts.get(0).length - 1]);
    add("soma", "Soma (Cell Body)").poly(somaShape(4)).poly(postSoma(4)).anchor(SX - 22, SY + 24);
    add("nucleus", "Nucleus").poly(ell(SX - 6, SY - 3, 22, 20, 0, 24)).poly(ell(PSX + 1, PSY + 1, 14, 13, 0, 20)).anchor(SX - 6, SY - 3);
    add("axon_hillock", "Axon Hillock").poly(SX + 30, SY - 21, SX + 52, SY - 13, SX + 80, SY - 10, SX + 80, SY + 10, SX + 52, SY + 13, SX + 30, SY + 21).anchor(SX + 60, SY);
    Part a = add("axon", "Axon");
    a.poly(band(sub(1, INIT - 1), 22, 22)).poly(band(sub(axonLen - TAIL + 1, axonLen + 4), 22, 22));
    float[] am = at(INIT * 0.5);
    a.anchor(am[0], am[1]);
    Part m = add("myelin_sheath", "Myelin Sheath");
    for (int k = 0; k < NSHEATH; k++) m.poly(band(sub(sheath0(k) + 1, sheath0(k) + sheathL - 1), MY_W + 6, MY_W + 6));
    float[] mm = at(sheath0(2) + sheathL / 2);
    m.anchor(mm[0], mm[1] - 4);
    Part n = add("node_of_ranvier", "Node of Ranvier");
    for (int k = 0; k < NSHEATH - 1; k++) {
      float s0 = sheath0(k) + sheathL;
      n.poly(band(sub(s0 - 4, s0 + GAP + 4), 36, 36));
    }
    float[] nm = at(sheath0(1) + sheathL + GAP / 2);
    n.anchor(nm[0], nm[1]);
    Part t = add("axon_terminal", "Axon Terminal");
    for (float[] b : term) t.poly(band(b, 18, 18));
    for (float[] b : bout) t.poly(ell(b[0], b[1], b[2] + 5, b[2] + 5, 0, 18));
    t.anchor(bout[2][0], bout[2][1]);
    add("synapse", "Synapse").poly(ell(JX, JY, 17, 16, 0, 22)).poly(ell(ICX, ICY, IR + 3, IR + 3, 0, 40)).anchor(ICX, ICY + 12);
  }

  // ------------------------------------------------------------ geometry
  float hash(float i) {
    float v = sin(i * 12.9898 + 4.1) * 43758.5453;
    return v - floor(v);
  }

  void build() {
    // dendrite tree: six primary dendrites, each forking twice
    float[][] prim = { { 198, 45 }, { 152, 45 }, { 238, 47 }, { 282, 42 }, { 112, 45 }, { 66, 37 } };
    for (int i = 0; i < prim.length; i++) {
      float a = radians(prim[i][0]);
      branch(SX + cos(a) * 30, SY + sin(a) * 30, a, prim[i][1], 14, 8, 0, i * 7 + 1);
    }
    // axon centre line
    float[] c = { SX + 76, SY, 300, SY + 2, 400, SY + 6, 470, SY + 20, 522, SY + 60, 547, SY + 120, 545, SY + 190, 522, SY + 245, 486, SY + 282 };
    axonC = crO(c, 10);
    int n = axonC.length / 2;
    axonS = new float[n];
    for (int i = 1; i < n; i++) axonS[i] = axonS[i - 1] + dist(axonC[i * 2 - 2], axonC[i * 2 - 1], axonC[i * 2], axonC[i * 2 + 1]);
    axonLen = axonS[n - 1];
    sheathL = (axonLen - INIT - TAIL - (NSHEATH - 1) * GAP) / NSHEATH;
    // terminal arborization
    float ex = axonC[(n - 1) * 2], ey = axonC[(n - 1) * 2 + 1];
    term = new float[][] {
      crO(new float[] { ex, ey, ex - 22, ey + 16, JX + 14, JY - 6 }, 6),
      crO(new float[] { ex, ey, ex - 10, ey + 26, ex - 22, ey + 50, ex - 26, ey + 66 }, 6),
      crO(new float[] { ex, ey, ex + 10, ey + 24, ex + 14, ey + 52, ex + 8, ey + 70 }, 6),
      crO(new float[] { ex + 10, ey + 24, ex + 28, ey + 36, ex + 44, ey + 46 }, 6)
    };
    bout = new float[][] { { JX + 9, JY - 3, 9 }, { ex - 26, ey + 70, 9 }, { ex + 8, ey + 74, 9 }, { ex + 48, ey + 49, 8.5 } };
    // second neuron (partial, lower left): a smaller multipolar cell whose longest dendrite reaches right to
    // the synapse; side branches and tapering make it read as a dendrite, not an axon
    post = new float[][] {
      crO(new float[] { 226, 516, 272, 517, 318, 521, 362, 525, 398, 527, JX - 6, JY + 4 }, 6),
      crO(new float[] { 300, 519, 306, 502, 316, 488 }, 6),
      crO(new float[] { 352, 524, 360, 541, 373, 554 }, 6),
      crO(new float[] { 198, 496, 190, 472, 184, 448 }, 6),
      crO(new float[] { 190, 472, 204, 456, 220, 446 }, 6),
      crO(new float[] { 184, 505, 156, 491, 128, 484 }, 6),
      crO(new float[] { 156, 491, 147, 472, 142, 455 }, 6),
      crO(new float[] { 178, 526, 146, 532, 110, 528 }, 6),
      crO(new float[] { 146, 532, 128, 548, 114, 560 }, 6),
      crO(new float[] { 192, 535, 168, 556, 146, 574 }, 6),
      crO(new float[] { 210, 545, 216, 562, 213, 580 }, 6)
    };
  }

  final float[] POST_SW = { 10, 5, 5, 9, 5, 8, 4.5, 8, 4, 7, 7 };
  final float[] POST_EW = { 6, 2.5, 2.5, 4, 2.5, 3.5, 2.2, 3, 2, 3, 3 };
  final float PSX = 205, PSY = 520;                      // second neuron's soma centre

  float[] postSoma(float grow) {
    float[] ang = { 0, 40, 80, 120, 160, 200, 240, 280, 320 };
    float[] rad = { 27, 22, 26, 22, 27, 23, 27, 22, 25 };
    float[] p = new float[ang.length * 2];
    for (int i = 0; i < ang.length; i++) {
      float a = radians(ang[i]);
      p[i * 2] = PSX + cos(a) * (rad[i] + grow);
      p[i * 2 + 1] = PSY + sin(a) * (rad[i] + grow) * 0.9;
    }
    return crC(p, 4);
  }

  void branch(float x, float y, float a, float len, float w0, float w1, int depth, float seed) {
    float ex = x + cos(a) * len, ey = y + sin(a) * len;
    float bend = (hash(seed) - 0.5) * 0.5 * len;
    float mx = (x + ex) / 2 - sin(a) * bend, my = (y + ey) / 2 + cos(a) * bend;
    dPts.add(crO(new float[] { x, y, mx, my, ex, ey }, 6));
    dWid.add(new float[] { w0, w1 });
    if (depth >= 2) return;
    float spread = depth == 0 ? 0.5 : 0.42;
    float j = (hash(seed + 3) - 0.5) * 0.3;
    branch(ex, ey, a - spread + j, len * (0.74 + 0.12 * hash(seed + 5)), w1, w1 * 0.55, depth + 1, seed * 3 + 1);
    branch(ex, ey, a + spread + j, len * (0.70 + 0.12 * hash(seed + 9)), w1 * 0.9, w1 * 0.5, depth + 1, seed * 3 + 2);
  }

  float sheath0(int k) {
    return INIT + k * (sheathL + GAP);
  }

  // point on the axon at arc length s
  float[] at(float s) {
    int n = axonS.length;
    s = constrain(s, 0, axonLen);
    for (int i = 1; i < n; i++) {
      if (axonS[i] >= s) {
        float f = (s - axonS[i - 1]) / max(1e-3, axonS[i] - axonS[i - 1]);
        return new float[] { lerp(axonC[i * 2 - 2], axonC[i * 2], f), lerp(axonC[i * 2 - 1], axonC[i * 2 + 1], f) };
      }
    }
    return new float[] { axonC[(n - 1) * 2], axonC[(n - 1) * 2 + 1] };
  }

  // the axon centre line between arc lengths s0 and s1 (extrapolated past the ends if needed)
  float[] sub(float s0, float s1) {
    int k = max(2, ceil((s1 - s0) / 3));
    float[] p = new float[(k + 1) * 2];
    for (int i = 0; i <= k; i++) {
      float s = lerp(s0, s1, i / (float) k);
      float[] q;
      if (s > axonLen) {
        float[] e = at(axonLen), e2 = at(axonLen - 4);
        float dx = e[0] - e2[0], dy = e[1] - e2[1], L = max(1e-3, sqrt(dx * dx + dy * dy));
        q = new float[] { e[0] + dx / L * (s - axonLen), e[1] + dy / L * (s - axonLen) };
      } else q = at(s);
      p[i * 2] = q[0];
      p[i * 2 + 1] = q[1];
    }
    return p;
  }

  // soma outline: a rounded star, swelling toward each primary dendrite and the hillock
  float[] somaShape(float grow) {
    float[] ang = { 0, 32, 66, 90, 112, 132, 152, 175, 198, 218, 238, 260, 282, 310, 336 };
    float[] rad = { 40, 36, 41, 34, 42, 34, 41, 34, 42, 34, 42, 35, 41, 34, 36 };
    float[] p = new float[ang.length * 2];
    for (int i = 0; i < ang.length; i++) {
      float a = radians(ang[i]);
      p[i * 2] = SX + cos(a) * (rad[i] + grow);
      p[i * 2 + 1] = SY + sin(a) * (rad[i] + grow) * 0.92;
    }
    return crC(p, 4);
  }

  // ------------------------------------------------------------ art
  void drawArt(PGraphics g) {
    g.strokeJoin(ROUND);
    g.strokeCap(ROUND);
    drawPostNeuron(g);
    drawNeuronBody(g);
    drawMyelin(g);
    drawCallout(g);
    drawInset(g);
  }

  void taper(PGraphics g, float[] p, float w0, float w1, float add, int col) {
    g.stroke(col);
    g.noFill();
    int n = p.length / 2;
    for (int i = 0; i < n - 1; i++) {
      g.strokeWeight(lerp(w0, w1, i / (float) max(1, n - 2)) + add);
      g.line(p[i * 2], p[i * 2 + 1], p[i * 2 + 2], p[i * 2 + 3]);
    }
  }

  void drawNeuronBody(PGraphics g) {
    float[] ax = sub(0, axonLen);
    // soft shadow
    g.pushMatrix();
    g.translate(4, 6);
    for (int i = 0; i < dPts.size(); i++) taper(g, dPts.get(i), dWid.get(i)[0], dWid.get(i)[1], 4, g.color(0, 0, 0, 18));
    g.noStroke();
    g.fill(0, 0, 0, 18);
    shp(g, somaShape(2));
    g.popMatrix();
    // pass 1: ink silhouette; pass 2: body colour; pass 3: highlight
    for (int pass = 0; pass < 3; pass++) {
      int col = pass == 0 ? D_INK : pass == 1 ? D_NERVE : g.color(255, 255, 255, 80);
      float add = pass == 0 ? 4.6 : 0;
      for (int i = 0; i < dPts.size(); i++) {
        float[] p = dPts.get(i);
        if (pass < 2) taper(g, p, dWid.get(i)[0], dWid.get(i)[1], add, col);
        else taper(g, shift(p, -0.8, -1.2), dWid.get(i)[0] * 0.3, dWid.get(i)[1] * 0.25, 0, col);
      }
      float aw = pass == 2 ? AX_W * 0.3 : AX_W + add;
      g.stroke(col);
      g.strokeWeight(aw);
      g.noFill();
      pl(g, pass == 2 ? shift(ax, -0.6, -1.4) : ax);
      for (float[] t : term) {
        g.strokeWeight(pass == 2 ? 2 : 6.5 + add);
        pl(g, pass == 2 ? shift(t, -0.5, -1) : t);
      }
      g.noStroke();
      if (pass < 2) {
        g.fill(col);
        for (float[] b : bout) g.ellipse(b[0], b[1], b[2] * 2 + add, b[2] * 2 + add);
        // the hillock cone
        float[] hill = { SX + 26, SY - 22, SX + 50, SY - 12, SX + 78, SY - AX_W / 2, SX + 78, SY + AX_W / 2, SX + 50, SY + 12, SX + 26, SY + 22 };
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(add);
        }
        shp(g, crO(hill, 4));
        g.noStroke();
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(add);
        }
        shp(g, somaShape(0));
      } else {
        for (float[] b : bout) g.ellipse(b[0] - b[2] * 0.3, b[1] - b[2] * 0.35, b[2] * 0.8, b[2] * 0.6);
      }
    }
    // soma shading + Nissl bodies
    g.noStroke();
    g.fill(lerpColor(D_NERVE, #FFFFFF, 0.35));
    shp(g, ell(SX - 14, SY - 16, 22, 13, -0.4, 24));
    g.fill(NISSL);
    float[] nis = { -28, 14, -20, 26, -2, 26, 14, 20, 24, 6, 22, -14, 8, -26, -24, -20, -32, -4, 30, -6, -12, 30 };
    for (int k = 0; k < nis.length; k += 2) g.ellipse(SX + nis[k], SY + nis[k + 1], 4.2, 3.2);
    // hillock: subtle lighter tone (no Nissl bodies there)
    g.fill(lerpColor(D_NERVE, #FFF6D8, 0.45));
    shp(g, crO(new float[] { SX + 34, SY - 13, SX + 52, SY - 8, SX + 70, SY - 3, SX + 70, SY + 2, SX + 52, SY + 7, SX + 34, SY + 12 }, 4));
    // nucleus + nucleolus
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.fill(D_NUCLEUS);
    g.ellipse(SX - 6, SY - 3, 38, 35);
    g.noStroke();
    g.fill(lerpColor(D_NUCLEUS, #FFFFFF, 0.3));
    g.ellipse(SX - 11, SY - 9, 16, 9);
    g.fill(#4E3C86);
    g.ellipse(SX - 1, SY + 1, 11, 11);
    // a few dendritic spines on the outer branches
    g.stroke(D_INK);
    g.strokeWeight(1.3);
    g.fill(D_NERVE);
    for (int i = 0; i < dPts.size(); i++) {
      if (dWid.get(i)[0] > 7) continue;
      float[] p = dPts.get(i);
      int n = p.length / 2;
      for (int k = 3; k < n - 2; k += 4) {
        float tx = p[k * 2 + 2] - p[k * 2 - 2], ty = p[k * 2 + 3] - p[k * 2 - 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        float s = (k / 4) % 2 == 0 ? 1 : -1, w = lerp(dWid.get(i)[0], dWid.get(i)[1], k / (float) n) / 2;
        float bx = p[k * 2] - ty / L * s * (w + 3.5), by = p[k * 2 + 1] + tx / L * s * (w + 3.5);
        g.line(p[k * 2] - ty / L * s * w, p[k * 2 + 1] + tx / L * s * w, bx, by);
        g.ellipse(bx, by, 3.4, 3.4);
      }
    }
  }

  void drawMyelin(PGraphics g) {
    for (int k = 0; k < NSHEATH; k++) {
      float s0 = sheath0(k), s1 = s0 + sheathL, r = MY_W / 2;
      float[] c = sub(s0 + r, s1 - r);
      g.noFill();
      g.stroke(0, 0, 0, 20);
      g.strokeWeight(MY_W);
      pl(g, shift(c, 3, 5));
      g.stroke(D_INK);
      g.strokeWeight(MY_W + 4.6);
      pl(g, c);
      g.stroke(MY_DK);
      g.strokeWeight(MY_W);
      pl(g, c);
      g.stroke(D_MYELIN);
      g.strokeWeight(MY_W * 0.62);
      pl(g, shift(c, -1, -2.4));
      g.stroke(255, 255, 255, 120);
      g.strokeWeight(MY_W * 0.18);
      pl(g, shift(c, -2, -6));
      // wrapped lamellae
      g.stroke(lerpColor(MY_DK, D_INK, 0.25));
      g.strokeWeight(1.2);
      for (float s = s0 + 7; s < s1 - 5; s += 6.5) {
        float[] p = at(s), q = at(s + 1);
        float tx = q[0] - p[0], ty = q[1] - p[1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        float nx = -ty / L, ny = tx / L;
        float h = r - 2.6;
        if (s < s0 + 12 || s > s1 - 12) h *= 0.72;
        g.line(p[0] + nx * h + tx / L * 2, p[1] + ny * h + ty / L * 2, p[0] - nx * h - tx / L * 2, p[1] - ny * h - ty / L * 2);
      }
      // Schwann cell nucleus on the outer side
      float[] mid = at(s0 + sheathL * 0.55), mq = at(s0 + sheathL * 0.55 + 1);
      float tx = mq[0] - mid[0], ty = mq[1] - mid[1], L = max(1e-3, sqrt(tx * tx + ty * ty));
      float side = k < 3 ? -1 : 1;
      float nx = -ty / L * side, ny = tx / L * side;
      g.pushMatrix();
      g.translate(mid[0] + nx * (r - 1), mid[1] + ny * (r - 1));
      g.rotate(atan2(ty, tx));
      g.stroke(D_INK);
      g.strokeWeight(1.8);
      g.fill(SCHWANN);
      g.ellipse(0, 0, 20, 9);
      g.noStroke();
      g.fill(255, 255, 255, 80);
      g.ellipse(-3, -1.5, 8, 3);
      g.popMatrix();
    }
  }

  void drawPostNeuron(PGraphics g) {
    // soft shadow
    g.pushMatrix();
    g.translate(4, 6);
    for (int i = 0; i < post.length; i++) taper(g, post[i], POST_SW[i], POST_EW[i], 3, g.color(0, 0, 0, 18));
    g.noStroke();
    g.fill(0, 0, 0, 18);
    shp(g, postSoma(1));
    g.popMatrix();
    for (int pass = 0; pass < 3; pass++) {
      int col = pass == 0 ? D_INK : pass == 1 ? POST : g.color(255, 255, 255, 80);
      float add = pass == 0 ? 4.4 : 0;
      for (int i = 0; i < post.length; i++) {
        if (pass < 2) taper(g, post[i], POST_SW[i], POST_EW[i], add, col);
        else taper(g, shift(post[i], -0.6, -1), POST_SW[i] * 0.3, POST_EW[i] * 0.3, 0, col);
      }
      g.noStroke();
      if (pass < 2) {
        g.fill(col);
        if (pass == 0) {
          g.stroke(D_INK);
          g.strokeWeight(add);
        }
        shp(g, postSoma(0));
        g.noStroke();
        // spine head facing the bouton
        g.ellipse(JX - 4, JY + 4, 13 + add, 13 + add);
      }
    }
    // soma shading, nucleus + nucleolus
    g.noStroke();
    g.fill(lerpColor(POST, #FFFFFF, 0.35));
    shp(g, ell(PSX - 9, PSY - 9, 13, 7, -0.4, 20));
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(POST_DK);
    g.ellipse(PSX + 1, PSY + 1, 22, 20);
    g.noStroke();
    g.fill(#5B4790);
    g.ellipse(PSX + 4, PSY + 3, 7, 7);
  }

  void drawCallout(PGraphics g) {
    // dashed ring around the junction + two dashed lines to the magnified view
    g.noFill();
    g.stroke(#6B6250);
    g.strokeWeight(1.6);
    dashedEll(g, JX + 2, JY, 20, 18);
    float a1 = radians(52), a2 = radians(100);
    dashed(g, JX + 2 + cos(-0.4) * 20, JY + sin(-0.4) * 18 - 4, ICX + cos(a1) * IR, ICY + sin(a1) * IR);
    dashed(g, JX + 2 + cos(-2.6) * 20, JY + sin(-2.6) * 18, ICX + cos(a2) * IR, ICY + sin(a2) * IR);
  }

  void drawInset(PGraphics g) {
    float R = IR;
    g.noStroke();
    g.fill(0, 0, 0, 26);
    g.ellipse(ICX + 4, ICY + 6, R * 2, R * 2);
    g.fill(#FFFCF4);
    g.ellipse(ICX, ICY, R * 2, R * 2);
    // presynaptic terminal (top) and postsynaptic membrane (bottom), parabolic faces
    float[] pre = cap(R - 1.5, -2, 0.0062, true);
    float[] postR = cap(R - 1.5, 16, 0.0062, false);
    g.fill(D_NERVE);
    shp(g, loc(pre));
    g.fill(lerpColor(D_NERVE, #FFFFFF, 0.3));
    shp(g, loc(cap(R - 14, -40, 0.0062, true)));
    g.fill(POST);
    shp(g, loc(postR));
    g.fill(lerpColor(POST, #FFFFFF, 0.3));
    shp(g, loc(cap(R - 14, 50, 0.0062, false)));
    // membranes
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    pl(g, loc(parab(-2, 0.0062, R - 1.5)));
    pl(g, loc(parab(16, 0.0062, R - 1.5)));
    // postsynaptic density
    g.stroke(POST_DK);
    g.strokeWeight(5);
    pl(g, loc(parab(21, 0.0062, 44)));
    // receptors straddling the postsynaptic membrane
    for (int i = -3; i <= 3; i++) {
      float x = i * 13, y = 16 - 0.0062 * x * x;
      float ang = atan(-2 * 0.0062 * x);
      g.pushMatrix();
      g.translate(ICX + x, ICY + y);
      g.rotate(ang);
      g.stroke(D_INK);
      g.strokeWeight(1.4);
      g.fill(RECEPT);
      g.rect(-4.5, -4.5, 4, 10, 1.5);
      g.rect(0.5, -4.5, 4, 10, 1.5);
      g.popMatrix();
    }
    // mitochondrion in the bouton
    g.pushMatrix();
    g.translate(ICX - 48, ICY - 56);
    g.rotate(-0.35);
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(D_MITO);
    g.ellipse(0, 0, 44, 20);
    g.noFill();
    g.stroke(#C2582F);
    g.strokeWeight(1.6);
    for (int i = -1; i <= 1; i++) g.line(i * 10, -6 * (i % 2 == 0 ? 1 : -1), i * 10, 2 * (i % 2 == 0 ? 1 : -1));
    g.popMatrix();
    // synaptic vesicles full of neurotransmitter
    float[] v = { -22, -38, 4, -46, 30, -40, 52, -54, -2, -64, 26, -70, 58, -26, -36, -14, -10, -18, 22, -20, 8, -36 };
    for (int k = 0; k < v.length; k += 2) vesicle(g, ICX + v[k], ICY + v[k + 1], 7.5);
    // a vesicle fusing with the membrane (exocytosis), spilling transmitter into the cleft
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(#FFF6CF);
    g.arc(ICX + 2, ICY - 3, 17, 17, PI + 0.35, TWO_PI - 0.35);
    g.noStroke();
    g.fill(NT);
    float[] nt = { -10, 8, -2, 11, 8, 7, 14, 10, 20, 6, -18, 9, 2, 4, -4, 5, 26, 10, -26, 11, 12, 3 };
    for (int k = 0; k < nt.length; k += 2) g.ellipse(ICX + nt[k], ICY + nt[k + 1], 3.6, 3.6);
    // border
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(3);
    g.ellipse(ICX, ICY, R * 2, R * 2);
    g.stroke(#B8AC90);
    g.strokeWeight(1.2);
    g.ellipse(ICX, ICY, R * 2 + 8, R * 2 + 8);
  }

  void vesicle(PGraphics g, float x, float y, float r) {
    g.stroke(D_INK);
    g.strokeWeight(1.5);
    g.fill(#FFF6CF);
    g.ellipse(x, y, r * 2, r * 2);
    g.noStroke();
    g.fill(NT);
    g.ellipse(x - 2, y - 1.5, 3, 3);
    g.ellipse(x + 2.2, y - 0.5, 3, 3);
    g.ellipse(x, y + 2.4, 3, 3);
  }

  // parabola y = a - b x^2 (inset-local), x within the circle of radius R
  float[] parab(float a, float b, float R) {
    float xi = capX(R, a, b);
    int n = 30;
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float x = lerp(-xi, xi, i / (float) (n - 1));
      p[i * 2] = x;
      p[i * 2 + 1] = a - b * x * x;
    }
    return p;
  }

  float capX(float R, float a, float b) {
    float lo = 0, hi = R;
    for (int i = 0; i < 40; i++) {
      float m = (lo + hi) / 2, y = a - b * m * m;
      if (m * m + y * y < R * R) lo = m;
      else hi = m;
    }
    return lo;
  }

  // the part of the circle above (top = true) or below the parabola
  float[] cap(float R, float a, float b, boolean top) {
    float xi = capX(R, a, b), yi = a - b * xi * xi, ai = atan2(yi, xi);
    FloatList q = new FloatList();
    int n = 30;
    if (top) {
      for (int i = 0; i < n; i++) {
        float x = lerp(-xi, xi, i / (float) (n - 1));
        q.append(x);
        q.append(a - b * x * x);
      }
      for (int i = 1; i < n; i++) {
        float t = lerp(ai, -PI - ai, i / (float) n);
        q.append(cos(t) * R);
        q.append(sin(t) * R);
      }
    } else {
      for (int i = 0; i < n; i++) {
        float x = lerp(xi, -xi, i / (float) (n - 1));
        q.append(x);
        q.append(a - b * x * x);
      }
      for (int i = 1; i < n; i++) {
        float t = lerp(PI - ai, ai, i / (float) n);
        q.append(cos(t) * R);
        q.append(sin(t) * R);
      }
    }
    return q.array();
  }

  float[] loc(float[] p) {
    float[] q = new float[p.length];
    for (int i = 0; i < p.length; i += 2) {
      q[i] = p[i] + ICX;
      q[i + 1] = p[i + 1] + ICY;
    }
    return q;
  }

  void dashed(PGraphics g, float x0, float y0, float x1, float y1) {
    float L = dist(x0, y0, x1, y1);
    int n = max(1, round(L / 9));
    for (int i = 0; i < n; i += 2) {
      float f0 = i / (float) n, f1 = min(1, (i + 1) / (float) n);
      g.line(lerp(x0, x1, f0), lerp(y0, y1, f0), lerp(x0, x1, f1), lerp(y0, y1, f1));
    }
  }

  void dashedEll(PGraphics g, float cx, float cy, float rx, float ry) {
    int n = 22;
    for (int i = 0; i < n; i += 2) {
      float t0 = TWO_PI * i / n, t1 = TWO_PI * (i + 1) / n;
      g.line(cx + cos(t0) * rx, cy + sin(t0) * ry, cx + cos(t1) * rx, cy + sin(t1) * ry);
    }
  }

  // ------------------------------------------------------------ helpers (local to this class)
  float[] shift(float[] p, float dx, float dy) {
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
