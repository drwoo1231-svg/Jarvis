// Superficial muscles, anterior view (subject's right on the viewer's left).
// Labelled muscles are saturated reds with fibre lines; unlabelled neighbours
// (brachioradialis, serratus, TFL, soleus ...) are a muted tone so the testable
// ones stand out. Each muscle's outline is both its art and its hit polygon.

class MusclesDiagram extends Diagram {
  final int BASE = #8C3A36, BASE_SH = #7A302D;           // deep layer seen in the grooves
  final int FILL = #D4A196, FILL_FIB = #B5837A;          // unlabelled muscles
  final int FIB = #9C3B35, FIB_LT = #EE9A8E;             // fibre lines / sheen

  // limb frames { local axis length, x0, y0, x1, y1 } for the viewer's-left limbs
  final float[] F_UA = { 100, 212, 138, 193, 240 };
  final float[] F_FA = { 82, 193, 240, 171, 322 };
  final float[] F_HD = { 58, 171, 323, 156, 378 };

  float[] head, earL, body, handL, footL, clavL;
  float[] trapL, scmL, deltL, pecL, bicL, flexL, rectus, eoL, eoFleshL, quadL, sartC, sartL, addL, taL, gmedL, glatL;
  ArrayList<float[]> fillers = new ArrayList<float[]>();     // unlabelled muscles (viewer's left)
  ArrayList<float[]> tendons = new ArrayList<float[]>();     // tendons / aponeuroses (viewer's left)
  ArrayList<float[]> bones = new ArrayList<float[]>();       // subcutaneous bone (viewer's left)

  MusclesDiagram() {
    super("muscles", "Major Muscles (front)");
    build();
    add("rectus_abdominis", "Rectus Abdominis").poly(rectus).anchor(300, 245);
    add("external_oblique", "External Oblique").poly(eoL).poly(mir(eoL)).anchor(246, 245);
    add("pectoralis_major", "Pectoralis Major").poly(pecL).poly(mir(pecL)).anchor(265, 165);
    add("trapezius", "Trapezius").poly(trapL).poly(mir(trapL)).anchor(248, 110);
    add("sternocleidomastoid", "Sternocleidomastoid").poly(scmL).poly(mir(scmL)).anchor(287, 100);
    add("deltoid", "Deltoid").poly(deltL).poly(mir(deltL)).anchor(212, 150);
    add("biceps_brachii", "Biceps Brachii").poly(bicL).poly(mir(bicL));
    add("forearm_flexors", "Forearm Flexors").poly(flexL).poly(mir(flexL));
    add("adductors", "Adductors").poly(addL).poly(mir(addL)).anchor(286, 368);
    add("quadriceps_femoris", "Quadriceps Femoris").poly(quadL).poly(mir(quadL)).anchor(246, 385);
    add("sartorius", "Sartorius").poly(sartL).poly(mir(sartL)).anchor(262, 360);
    add("tibialis_anterior", "Tibialis Anterior").poly(taL).poly(mir(taL)).anchor(264, 490);
    add("gastrocnemius", "Gastrocnemius").poly(gmedL).poly(glatL).poly(mir(gmedL)).poly(mir(glatL)).anchor(292, 488);
  }

  // =============================================================== geometry (viewer's left; mirrored for the right)
  void build() {
    head = sym(new float[] { 300, 12, 285, 15, 276, 25, 273, 40, 275, 55, 279, 66, 287, 76, 300, 81 });
    earL = new float[] { 275, 42, 270, 40, 268, 47, 270, 55, 275, 57 };

    // ---- arm outline (local frames)
    FloatList b = new FloatList();
    addPts(b, new float[] { 300, 74, 284, 74, 284, 84, 272, 92, 254, 99, 236, 106, 221, 113, 211, 121, 204, 128 });
    addPts(b, P(new float[] { -19, 4, -21, 18, -19, 36, -16, 55, -14, 75, -15, 92 }, F_UA));
    addPts(b, P(new float[] { -16, 0, -18, 12, -17, 26, -14, 45, -11, 62, -9, 80 }, F_FA));
    addPts(b, P(new float[] { 8, 80, 10, 62, 13, 42, 16, 22, 16, 6 }, F_FA));
    addPts(b, P(new float[] { 15, 92, 14, 75, 15, 55, 17, 36, 17, 26 }, F_UA));
    // torso, leg, foot (absolute)
    addPts(b, new float[] { 229, 166, 227, 182, 228, 202, 231, 226, 235, 250, 236, 270, 233, 290, 226, 308,
      220, 330, 219, 360, 224, 390, 233, 415, 241, 436, 243, 452, 240, 470, 237, 490, 240, 512, 249, 532, 255, 546,
      251, 558, 249, 572, 251, 581, 256, 586, 263, 589, 271, 590, 280, 590, 287, 587, 291, 579, 291, 563, 287, 547,
      289, 530, 295, 510, 297, 488, 293, 466, 290, 452, 291, 430, 294, 405, 297, 380, 298, 366, 300, 358 });
    body = symClosed(b.array());
    handL = P(new float[] { -9, -2, -13, 8, -18, 16, -24, 26, -26, 31, -22, 32, -14, 26, -12, 36, -12, 50, -11, 58, -7, 60, -4, 52,
      -2, 62, 2, 63, 4, 54, 6, 61, 10, 60, 10, 50, 13, 52, 15, 48, 13, 36, 11, 20, 9, -2 }, F_HD);
    footL = new float[] { 256, 545, 251, 558, 249, 572, 251, 581, 256, 586, 263, 589, 271, 590, 280, 590, 287, 587, 291, 579, 291, 563, 287, 545 };

    clavL = cr(new float[] { 297, 122, 281, 123, 263, 121, 245, 119, 228, 120, 214, 124 }, 4);

    // ---- labelled muscles
    trapL = new float[] { 284, 84, 272, 92, 254, 99, 236, 106, 221, 113, 211, 122, 222, 123, 238, 121, 255, 120, 264, 111, 274, 102, 283, 94 };
    scmL = new float[] { 275, 70, 282, 67, 288, 82, 294, 100, 299, 114, 298, 122, 291, 122, 289, 113, 284, 122, 276, 122, 278, 110, 279, 95, 276, 82 };
    deltL = new float[] { 246, 124, 230, 121, 215, 123, 205, 130, 199, 143, 197, 158, 199, 175, 204, 191, 207, 197, 212, 186, 219, 170, 227, 152, 236, 136 };
    pecL = new float[] { 297, 126, 297, 150, 297, 176, 296, 199, 286, 207, 270, 209, 254, 203, 240, 192, 228, 180, 220, 172, 215, 168,
      222, 160, 229, 148, 238, 134, 247, 126, 262, 125, 280, 126 };
    bicL = P(new float[] { -6, 30, 5, 28, 10, 38, 12, 52, 11, 66, 7, 80, 3, 90, 2, 98, -2, 98, -3, 90, -7, 80, -11, 66, -12, 52, -10, 38 }, F_UA);
    flexL = P(new float[] { 16, -3, 17, 12, 14, 32, 10, 52, 7, 68, 6, 80, -1, 81, -5, 72, -7, 55, -9, 40, -6, 31, -1, 19, 4, 9, 9, 1 }, F_FA);
    rectus = sym(new float[] { 300, 196, 289, 194, 277, 195, 266, 200, 266, 230, 268, 260, 272, 290, 279, 318, 289, 337, 300, 341 });
    eoL = new float[] { 256, 201, 244, 196, 233, 200, 231, 225, 234, 250, 236, 270, 233, 290, 228, 304, 243, 316, 262, 326, 284, 338,
      293, 340, 288, 330, 279, 318, 272, 290, 268, 260, 266, 230, 265, 206 };
    eoFleshL = new float[] { 257, 202, 244, 196, 233, 200, 231, 225, 234, 250, 236, 270, 233, 290, 229, 302, 241, 297, 253, 292, 259, 285, 259, 262, 259, 236, 260, 212 };
    quadL = new float[] { 227, 328, 236, 318, 247, 322, 254, 336, 262, 352, 272, 368, 282, 384, 289, 398, 292, 418, 289, 436, 281, 441,
      270, 431, 260, 433, 251, 437, 243, 428, 233, 408, 225, 385, 222, 360, 222, 342 };
    sartC = cr(new float[] { 230, 306, 241, 328, 256, 350, 271, 370, 283, 390, 290, 412, 292, 436, 289, 458 }, 4);
    sartL = band(sartC, 10, 9);
    addL = new float[] { 289, 338, 296, 352, 298, 366, 296, 384, 293, 402, 285, 390, 277, 374, 269, 362, 263, 352, 271, 346, 280, 341 };
    taL = new float[] { 256, 460, 267, 458, 274, 468, 276, 490, 274, 512, 278, 530, 285, 545, 279, 549, 271, 534, 264, 516, 257, 496, 253, 476 };
    gmedL = new float[] { 288, 456, 294, 464, 298, 478, 299, 494, 296, 508, 290, 516, 286, 506, 285, 488, 284, 470 };
    glatL = new float[] { 246, 458, 252, 462, 253, 478, 251, 496, 247, 506, 241, 500, 238, 488, 239, 472 };

    // ---- unlabelled muscles (muted)
    fillers.add(new float[] { 283, 95, 280, 100, 279, 110, 277, 121, 266, 121, 257, 120, 265, 112, 274, 103 });      // scalenes (posterior triangle)
    fillers.add(new float[] { 300, 84, 292, 84, 296, 100, 299, 114, 300, 114 });                                    // infrahyoid strap
    fillers.add(P(new float[] { -17, 6, -9, 10, -12, 30, -16, 50, -15, 62, -11, 66 }, F_UA));                       // triceps lateral head
    fillers.add(P(new float[] { 12, 30, 17, 28, 17, 45, 15, 62, 14, 80, 11, 76, 12, 62 }, F_UA));                   // triceps medial
    fillers.add(P(new float[] { -13, 62, -8, 70, -6, 86, -10, 98, -15, 94, -15, 78 }, F_UA));                        // brachialis lateral
    fillers.add(P(new float[] { 9, 70, 14, 66, 15, 84, 13, 98, 7, 94 }, F_UA));                                      // brachialis medial
    fillers.add(P(new float[] { -16, -4, -10, -2, -5, 12, -4, 26, -8, 40, -8, 56, -5, 72, -8, 80, -11, 70, -14, 46, -18, 22 }, F_FA)); // brachioradialis + extensors
    fillers.add(new float[] { 228, 182, 238, 191, 246, 196, 240, 200, 232, 204, 229, 200 });                         // serratus anterior
    fillers.add(new float[] { 227, 178, 232, 186, 230, 205, 230, 225, 228, 205 });                                   // latissimus edge
    fillers.add(new float[] { 226, 309, 235, 314, 240, 323, 236, 334, 228, 342, 222, 340, 221, 326 });               // tensor fasciae latae
    fillers.add(new float[] { 244, 318, 262, 327, 284, 338, 276, 344, 266, 351, 259, 343, 250, 330 });               // iliopsoas + pectineus
    fillers.add(new float[] { 243, 462, 252, 462, 256, 476, 260, 500, 266, 522, 262, 530, 252, 520, 246, 500, 242, 480 }); // extensor digitorum / fibularis
    fillers.add(new float[] { 286, 500, 291, 514, 296, 510, 293, 528, 288, 540, 284, 526 });                         // soleus medial
    fillers.add(new float[] { 243, 500, 247, 507, 249, 520, 252, 534, 246, 528, 240, 512 });                         // soleus lateral

    // ---- tendons / aponeuroses
    tendons.add(new float[] { 266, 204, 260, 212, 259, 236, 259, 262, 259, 286, 252, 293, 240, 298, 229, 303, 243, 316, 262, 326, 284, 338,
      279, 318, 272, 290, 268, 260, 266, 230 });                                                                       // external oblique aponeurosis
    tendons.add(new float[] { 246, 438, 258, 433, 270, 431, 282, 440, 289, 450, 286, 462, 276, 468, 262, 468, 249, 461, 244, 450 }); // knee retinacula
    tendons.add(new float[] { 263, 452, 274, 452, 273, 469, 265, 469 });                                             // patellar ligament
    tendons.add(P(new float[] { -3, 90, 3, 90, 6, 100, 12, 104, 12, 108, 1, 104, -3, 100 }, F_UA));                  // biceps tendon + aponeurosis
    bones.add(new float[] { 276, 471, 282, 470, 286, 498, 286, 522, 282, 532, 279, 520, 277, 498 });                 // tibia (subcutaneous)
    bones.add(ellPts(268, 443, 8.5, 10.5));                                                                          // patella
  }

  // =============================================================== art
  void drawArt(PGraphics g) {
    // body base (deep layer)
    g.stroke(D_INK);
    g.strokeWeight(2.6);
    g.fill(BASE);
    blob(g, body);
    // hands, feet, head in skin
    for (int s = 0; s < 2; s++) {
      skin(g, side(handL, s));
      skin(g, side(footL, s));
      g.stroke(D_SKIN_SH);
      g.strokeWeight(1.1);
      float[] tx = { 257, 264, 271, 279 };
      float[] ty = { 580, 583, 584, 583 };
      for (int k = 0; k < 4; k++) g.line(s == 0 ? tx[k] : DIA - tx[k], ty[k], s == 0 ? tx[k] - 0.3 : DIA - tx[k] + 0.3, ty[k] + 5.5);
    }
    skin(g, earL);
    skin(g, mir(earL));
    skin(g, head);
    g.noFill();
    g.stroke(D_SKIN_SH);
    g.strokeWeight(1.4);
    g.bezier(289, 50, 292, 48, 295, 48, 297, 50);   // closed eyes - he's asleep in Rick's class
    g.bezier(303, 50, 305, 48, 308, 48, 311, 50);
    g.bezier(300, 54, 298, 60, 297, 62, 301, 63);
    g.bezier(294, 70, 298, 72, 302, 72, 306, 70);

    for (int s = 0; s < 2; s++) {
      for (float[] f : fillers) muscle(g, side(f, s), FILL, 1.6);
      for (float[] t : tendons) flat(g, side(t, s), D_TENDON, 1.4);
      for (float[] t : bones) flat(g, side(t, s), D_BONE, 1.6);
    }
    // ---- labelled muscles, back to front
    muscle(g, rectus, #C9544B, 2);
    flat(g, new float[] { 298.5, 198, 301.5, 198, 302, 338, 298, 338 }, D_TENDON, 1);     // linea alba
    g.stroke(D_TENDON);
    g.strokeWeight(3);
    for (int k = 0; k < 3; k++) {                                                           // tendinous intersections
      float y = 224 + k * 28;
      g.line(268 + k * 0.8, y, 298, y + 2);
      g.line(DIA - 268 - k * 0.8, y, 302, y + 2);
    }
    g.stroke(D_INK);
    g.strokeWeight(1.1);
    for (int k = 0; k < 3; k++) {
      float y = 224 + k * 28;
      g.line(268 + k * 0.8, y - 1.5, 298, y + 0.5);
      g.line(268 + k * 0.8, y + 1.5, 298, y + 3.5);
      g.line(DIA - 268 - k * 0.8, y - 1.5, 302, y + 0.5);
      g.line(DIA - 268 - k * 0.8, y + 1.5, 302, y + 3.5);
    }
    g.stroke(FIB, 150);
    g.strokeWeight(0.9);
    float[] fb = { 296, 316, 328, 335 };
    for (int k = 0; k < 4; k++) {
      float x = 274 + k * 6;
      g.line(x, 210, x + 0.3, fb[k]);
      g.line(DIA - x, 210, DIA - x - 0.3, fb[k]);
    }
    g.fill(BASE_SH);
    g.stroke(D_INK);
    g.strokeWeight(1.2);
    g.ellipse(300, 293, 5, 7);                                                              // navel
    for (int s = 0; s < 2; s++) {
      muscle(g, side(eoFleshL, s), #BA4C47, 1.8);
      fibres(g, side(new float[] { 246, 198, 232, 212, 233, 262 }, s), side(new float[] { 259, 215, 258, 262, 238, 297 }, s), 9);
      muscle(g, side(trapL, s), #BE4E4A, 1.8);
      fibres(g, side(new float[] { 283, 87, 282, 92 }, s), side(new float[] { 216, 121, 252, 120 }, s), 7);
      muscle(g, side(scmL, s), #D0605A, 1.8);
      fibres(g, side(new float[] { 277, 72, 282, 70 }, s), side(new float[] { 279, 120, 296, 120 }, s), 4);
      muscle(g, side(pecL, s), #C14A45, 2);
      fibres(g, side(new float[] { 250, 127, 296, 128, 296, 196, 284, 205, 262, 205 }, s), side(new float[] { 225, 158, 220, 168 }, s), 13);
      muscle(g, side(deltL, s), #C9544B, 2);
      fibres(g, side(new float[] { 243, 125, 228, 123, 214, 125, 204, 133, 200, 148 }, s), side(new float[] { 207, 193, 207, 194 }, s), 9);
      muscle(g, side(bicL, s), #CF5A4E, 1.8);
      fibres(g, side(P(new float[] { -7, 36, 8, 34 }, F_UA), s), side(P(new float[] { -2, 90, 2, 90 }, F_UA), s), 5);
      muscle(g, side(flexL, s), #C65A50, 1.8);
      fibres(g, side(P(new float[] { 15, 4, 8, 4, 0, 16 }, F_FA), s), side(P(new float[] { 6, 78, 1, 78, -4, 70 }, F_FA), s), 6);
      flat(g, side(P(new float[] { -1, 64, 1, 64, 2, 81, -1, 81 }, F_FA), s), D_TENDON, 1);
      flat(g, side(P(new float[] { 3, 62, 5, 62, 5.5, 80, 3, 80 }, F_FA), s), D_TENDON, 1);
      muscle(g, side(addL, s), #B8463F, 1.8);
      fibres(g, side(new float[] { 282, 341, 294, 350 }, s), side(new float[] { 271, 364, 292, 398 }, s), 5);
      muscle(g, side(quadL, s), #C9544B, 2);
      g.stroke(D_INK);
      g.strokeWeight(1.3);
      g.noFill();
      line(g, side(new float[] { 246, 325, 252, 360, 258, 400, 262, 430 }, s));                // rectus femoris | vastus lateralis
      line(g, side(new float[] { 276, 380, 278, 400, 276, 420, 273, 432 }, s));                // vastus medialis
      fibres(g, side(new float[] { 238, 322, 246, 324 }, s), side(new float[] { 262, 430, 266, 430 }, s), 3);
      fibres(g, side(new float[] { 225, 345, 235, 330 }, s), side(new float[] { 247, 434, 258, 430 }, s), 4);
      fibres(g, side(new float[] { 280, 386, 289, 402 }, s), side(new float[] { 272, 430, 282, 438 }, s), 3);
      muscle(g, side(sartL, s), #D86A5C, 1.8);
      strapFibres(g, side(sartC, s), 3);
      muscle(g, side(gmedL, s), #B9473F, 1.6);
      muscle(g, side(glatL, s), #B9473F, 1.6);
      fibres(g, side(new float[] { 287, 460, 292, 460 }, s), side(new float[] { 288, 508, 292, 510 }, s), 3);
      muscle(g, side(taL, s), #CC5A4D, 1.8);
      fibres(g, side(new float[] { 257, 464, 268, 462 }, s), side(new float[] { 266, 510, 273, 510 }, s), 4);
      flat(g, side(new float[] { 272, 512, 275, 512, 285, 546, 282, 548 }, s), D_TENDON, 1);
      // clavicle on top
      flat(g, side(band(clavL, 6, 5), s), D_BONE, 1.6);
    }
  }

  // =============================================================== drawing helpers
  void muscle(PGraphics g, float[] p, int c, float sw) {
    g.noStroke();
    g.fill(lerpColor(c, #000000, 0.18));
    blob(g, p);
    g.fill(c);
    blob(g, inner(p, 2.2));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }

  void flat(PGraphics g, float[] p, int c, float sw) {
    g.fill(c);
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }

  void skin(PGraphics g, float[] p) {
    g.noStroke();
    g.fill(D_SKIN_SH);
    blob(g, p);
    g.fill(D_SKIN);
    blob(g, inner(p, 2.5));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2);
    blob(g, p);
  }

  // fibre lines between two edges (origin polyline a, insertion polyline b)
  void fibres(PGraphics g, float[] a, float[] b, int n) {
    g.strokeWeight(0.9);
    for (int i = 1; i < n; i++) {
      float t = i / (float) n;
      float[] pa = along(a, t), pb = along(b, t);
      float x0 = lerp(pa[0], pb[0], 0.07), y0 = lerp(pa[1], pb[1], 0.07), x1 = lerp(pa[0], pb[0], 0.93), y1 = lerp(pa[1], pb[1], 0.93);
      g.stroke(FIB, 140);
      g.line(x0, y0, x1, y1);
      if (i % 2 == 1) {
        g.stroke(FIB_LT, 110);
        g.line(lerp(x0, x1, 0.2), lerp(y0, y1, 0.2), lerp(x0, x1, 0.55), lerp(y0, y1, 0.55));
      }
    }
  }

  void strapFibres(PGraphics g, float[] c, int n) {
    g.noFill();
    g.strokeWeight(0.9);
    g.stroke(FIB, 140);
    for (int k = 0; k < n; k++) {
      float off = (k - (n - 1) / 2.0) * 2.4;
      float[] q = new float[c.length - 8];
      for (int i = 2; i < c.length / 2 - 2; i++) {
        int a = max(0, i - 1), bb = min(c.length / 2 - 1, i + 1);
        float tx = c[bb * 2] - c[a * 2], ty = c[bb * 2 + 1] - c[a * 2 + 1], L = max(1e-3, sqrt(tx * tx + ty * ty));
        q[(i - 2) * 2] = c[i * 2] - ty / L * off;
        q[(i - 2) * 2 + 1] = c[i * 2 + 1] + tx / L * off;
      }
      line(g, q);
    }
  }

  // point at fraction t along a polyline (by length)
  float[] along(float[] p, float t) {
    int n = p.length / 2;
    float total = 0;
    for (int i = 1; i < n; i++) total += dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
    float want = t * total;
    for (int i = 1; i < n; i++) {
      float d = dist(p[i * 2 - 2], p[i * 2 - 1], p[i * 2], p[i * 2 + 1]);
      if (want <= d || i == n - 1) {
        float u = d < 1e-4 ? 0 : constrain(want / d, 0, 1);
        return new float[] { lerp(p[i * 2 - 2], p[i * 2], u), lerp(p[i * 2 - 1], p[i * 2 + 1], u) };
      }
      want -= d;
    }
    return new float[] { p[0], p[1] };
  }

  // =============================================================== geometry helpers (local to this class)
  void addPts(FloatList l, float[] p) {
    for (float v : p) l.append(v);
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

  // half outline from the midline down the viewer's left back to the midline -> full outline
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

  // like sym() but keeps both midline end points
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

  float[] ellPts(float cx, float cy, float rx, float ry) {
    float[] p = new float[32];
    for (int i = 0; i < 16; i++) {
      p[i * 2] = cx + cos(TWO_PI * i / 16) * rx;
      p[i * 2 + 1] = cy + sin(TWO_PI * i / 16) * ry;
    }
    return p;
  }

  float[] P(float[] loc, float[] f) {
    float dx = f[3] - f[1], dy = f[4] - f[2], len = sqrt(dx * dx + dy * dy), s = len / f[0];
    float ux = dx / len, uy = dy / len, px = uy, py = -ux;
    float[] q = new float[loc.length];
    for (int i = 0; i < loc.length; i += 2) {
      q[i] = f[1] + (loc[i + 1] * ux + loc[i] * px) * s;
      q[i + 1] = f[2] + (loc[i + 1] * uy + loc[i] * py) * s;
    }
    return q;
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
