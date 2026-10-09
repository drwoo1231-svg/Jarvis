// Human skeleton, anterior view, anatomical position (palms forward).
// The SUBJECT'S RIGHT side is on the VIEWER'S LEFT. Geometry for the viewer's-left
// limbs is built once in local "bone frames" and mirrored across x = 300, so the
// artwork and the clickable polygons always share exactly the same points.

class SkeletonDiagram extends Diagram {
  final int CART = #D9E5E7, CART_SH = #B7CBD0;   // cartilage / discs
  final int HOLE = #43373D;                      // orbits, foramina

  // bone frames: { local axis length, x0, y0, x1, y1 } (viewer's-left limb)
  final float[] F_HUM = { 84, 216, 150, 191, 234 };
  final float[] F_FORE = { 70, 191, 236, 167, 306 };
  final float[] F_HAND = { 75, 166, 307, 146, 368 };
  final float[] F_FEM = { 114, 252, 318, 265, 432 };
  final float[] F_LEG = { 94, 265, 438, 270, 532 };
  final float[] F_FOOT = { 56, 270, 533, 263, 586 };

  // shared geometry (L = viewer's left; the right side is mir(...))
  float[] skull, mandible, orbitL, nasal, sternum, manubrium, xiphoid, scapL, coracL, clavL;
  float[] humL, radL, ulnL, femL, patL, tibL, fibL, sacrum, coccyx, hipL, iliacFossaL, obturatorL, symphysis;
  ArrayList<float[]> carpL = new ArrayList<float[]>(), mcL = new ArrayList<float[]>(), phL = new ArrayList<float[]>();
  ArrayList<float[]> tarsL = new ArrayList<float[]>(), mtL = new ArrayList<float[]>(), phfL = new ArrayList<float[]>();
  ArrayList<float[]> ribL = new ArrayList<float[]>(), cartL = new ArrayList<float[]>();
  ArrayList<float[]> ribHitL = new ArrayList<float[]>();

  SkeletonDiagram() {
    super("skeleton", "Human Skeleton (front)");
    build();

    // ---- clickable parts: big / behind first, small / in front last
    add("vertebral_column", "Vertebral Column").poly(
      289, 90, 311, 90, 314, 104, 313, 128, 312, 222, 318, 224, 326, 230, 327, 280, 300, 283, 273, 280, 274, 230, 282, 224, 288, 222, 287, 128, 286, 104)
      .anchor(300, 252);
    add("scapula", "Scapula").poly(scapL).poly(mir(scapL)).poly(coracL).poly(mir(coracL)).anchor(229, 160);
    Part ribs = add("ribs", "Ribs");
    for (float[] r : ribHitL) {
      ribs.poly(r);
      ribs.poly(mir(r));
    }
    ribs.anchor(247, 185);
    add("sternum", "Sternum").poly(sternumHit()).anchor(300, 176);
    add("clavicle", "Clavicle").poly(band(clavL, 11, 10)).poly(mir(band(clavL, 11, 10))).anchor(258, 129);
    add("skull", "Skull").poly(skull).anchor(300, 32);
    add("mandible", "Mandible").poly(mandible).anchor(300, 91);
    add("pelvis", "Pelvis (Hip Bones)").poly(hipL).poly(mir(hipL)).anchor(240, 280);
    add("sacrum", "Sacrum").poly(sacrum).anchor(300, 300);
    add("humerus", "Humerus").poly(humL).poly(mir(humL));
    add("radius", "Radius").poly(radL).poly(mir(radL));
    add("ulna", "Ulna").poly(ulnL).poly(mir(ulnL));
    float[] carpHit = P(new float[] { -18, 0, -6, -2, 6, -1, 13, 2, 15, 9, 13, 17, 4, 19, -6, 19, -17, 18, -20, 9 }, F_HAND);
    float[] mcHit = P(new float[] { -18, 15, 13, 16, 17, 25, 19, 37, 9, 42, 0, 44, -11, 43, -14, 36, -21, 35, -29, 31, -22, 18 }, F_HAND);
    float[] phHit = P(new float[] { -15, 42, -4, 44, 5, 42, 14, 38, 21, 38, 24, 51, 23, 65, 14, 75, 1, 79, -13, 76, -17, 60 }, F_HAND);
    float[] thumbHit = P(new float[] { -21, 34, -28, 31, -35, 44, -37, 57, -29, 60, -25, 47 }, F_HAND);
    add("carpals", "Carpals").poly(carpHit).poly(mir(carpHit));
    add("metacarpals", "Metacarpals").poly(mcHit).poly(mir(mcHit));
    add("phalanges_hand", "Phalanges (Hand)").poly(phHit).poly(thumbHit).poly(mir(phHit)).poly(mir(thumbHit))
      .anchor(P(new float[] { 2, 62 }, F_HAND)[0], P(new float[] { 2, 62 }, F_HAND)[1]);
    add("femur", "Femur").poly(femL).poly(mir(femL));
    add("fibula", "Fibula").poly(fibL).poly(mir(fibL)).anchor(P(new float[] { -16, 50 }, F_LEG)[0], P(new float[] { -16, 50 }, F_LEG)[1]);
    add("tibia", "Tibia").poly(tibL).poly(mir(tibL));
    add("patella", "Patella").poly(patL).poly(mir(patL));
    float[] tarsHit = P(new float[] { -15, -5, 0, -4, 10, -3, 14, 7, 13, 23, 3, 23, -7, 22, -15, 19, -18, 8 }, F_FOOT);
    float[] mtHit = P(new float[] { -15, 19, -7, 22, 3, 23, 13, 23, 16, 31, 16, 40, 8, 42, 0, 42, -8, 40, -15, 37, -21, 34 }, F_FOOT);
    float[] phfHit = P(new float[] { -21, 34, -15, 37, -8, 40, 0, 42, 8, 42, 16, 40, 18, 49, 17, 58, 9, 60, 0, 60, -8, 57, -16, 53, -22, 46 }, F_FOOT);
    add("tarsals", "Tarsals").poly(tarsHit).poly(mir(tarsHit));
    add("metatarsals", "Metatarsals").poly(mtHit).poly(mir(mtHit));
    add("phalanges_foot", "Phalanges (Foot)").poly(phfHit).poly(mir(phfHit));
  }

  // =============================================================== geometry
  void build() {
    // ---- skull (cranium + face, maxilla down to the upper teeth)
    skull = sym(new float[] { 300, 13, 286, 15, 274, 20, 266, 29, 263, 40, 264, 52, 266, 58, 264, 63, 268, 68, 274, 72, 279, 77, 285, 81, 300, 81 });
    mandible = new float[] { 268, 61, 266, 70, 268, 80, 273, 88, 285, 94, 300, 97, 315, 94, 327, 88, 332, 80, 334, 70, 332, 61,
      326, 62, 323, 72, 317, 79, 308, 82, 300, 82, 292, 82, 283, 79, 277, 72, 274, 62 };
    orbitL = new float[] { 276, 42, 283, 38, 292, 39, 297, 45, 297, 53, 292, 58, 282, 58, 276, 54, 274, 47 };
    nasal = sym(new float[] { 300, 58, 296, 61, 294, 67, 296, 72, 300, 73 });

    // ---- sternum
    manubrium = sym(new float[] { 300, 130, 295, 129, 289, 127, 286, 131, 287, 138, 290, 146, 291, 149, 300, 149 });
    sternum = sym(new float[] { 300, 149, 290, 149, 289, 160, 289, 175, 288, 190, 290, 203, 293, 207, 300, 207 });
    xiphoid = sym(new float[] { 300, 207, 295, 207, 296, 214, 299, 221, 300, 222 });

    // ---- clavicle (centre line) and scapula
    clavL = cr(new float[] { 291, 130, 280, 132, 266, 130, 250, 127, 235, 125, 221, 127, 210, 132 }, 4);
    scapL = new float[] { 203, 134, 210, 128, 222, 125, 240, 123, 257, 122, 271, 124, 274, 133, 271, 152, 265, 176, 255, 199, 243, 215,
      236, 214, 228, 201, 222, 185, 218, 169, 218, 161, 223, 156, 226, 147, 223, 141, 214, 139, 206, 139 };
    coracL = new float[] { 236, 129, 243, 133, 241, 140, 234, 146, 227, 148, 225, 143, 231, 139, 233, 134 };

    // ---- ribs: lateral apex (dx, y), front end of the bone (dx, y), cartilage end (dx, y), dx from the midline
    float[] aDx = { 36, 48, 56, 61, 64, 66, 67, 66, 64, 61, 55, 47 };
    float[] aY = { 127, 136, 147, 158, 170, 182, 194, 206, 218, 229, 240, 250 };
    float[] cDx = { 24, 30, 35, 38, 40, 42, 43, 46, 51, 55, 51, 42 };
    float[] cY = { 139, 152, 165, 178, 191, 204, 217, 230, 241, 251, 259, 264 };
    float[] sDx = { 12, 12, 11, 11, 11, 10, 9, 29, 39, 47 };
    float[] sY = { 136, 149, 161, 173, 184, 195, 205, 220, 231, 242 };
    for (int i = 0; i < 12; i++) {
      float ax = 300 - aDx[i], cx = 300 - cDx[i];
      float[] front = cr(new float[] { ax + 3.5, aY[i] - 5, ax, aY[i] + 1, (ax + cx) / 2 - 2, (aY[i] + cY[i]) / 2 + 3.5, cx, cY[i] }, 6);
      ribL.add(front);
      float w = i < 2 ? 6.5 : (i > 9 ? 5.5 : 7);
      ribHitL.add(band(front, w + 1, w + 1));
      if (i < 10) {
        float sx = 300 - sDx[i];
        float[] cart;
        if (i < 7) cart = cr(new float[] { cx + 1, cY[i], (cx + sx) / 2, (cY[i] + sY[i]) / 2 + (i > 3 ? 3 : 1), sx, sY[i] }, 5);
        else cart = cr(new float[] { cx + 1, cY[i], (cx + sx) / 2 + 2, (cY[i] + sY[i]) / 2 + 1, sx, sY[i] }, 5);
        cartL.add(cart);
        ribHitL.add(band(cart, 9, 9));
      }
    }

    // ---- limbs (local bone frames)
    humL = P(new float[] { -3, -11, 5, -11, 11, -6, 13, 1, 11, 8, 6, 13, 4, 20, 4, 40, 5, 60, 8, 70, 13, 77, 11, 83, 5, 86, 0, 85,
      -5, 87, -10, 84, -13, 78, -10, 70, -6, 55, -6, 35, -7, 20, -11, 12, -13, 4, -11, -5 }, F_HUM);
    radL = P(new float[] { -12, 2, -4, 2, -4, 7, -5, 10, -3, 15, -5, 24, -6, 40, -4, 56, -1, 64, 1, 70, -1, 74, -8, 75, -15, 74, -16, 68,
      -14, 58, -12, 40, -10, 24, -9, 13, -11, 9, -13, 6 }, F_FORE);
    ulnL = P(new float[] { -1, -2, 4, -7, 10, -5, 12, 2, 9, 9, 6, 15, 5, 30, 5, 50, 5, 62, 7, 68, 8, 73, 6, 77, 2, 76, 1, 70, 1, 60,
      0, 45, -1, 30, -2, 18, -3, 10, -2, 4 }, F_FORE);
    float[][] carp = { { -10, 4, 5, 3.6 }, { -1.5, 3.5, 4.2, 3.5 }, { 6.5, 4.5, 3.6, 3.4 }, { -12.5, 12, 4.2, 3.8 }, { -5.5, 12.5, 3.4, 3.6 },
      { 1, 12.5, 3.6, 4.8 }, { 8, 11.5, 4, 4.2 }, { 10.5, 7, 2.6, 2.6 } };
    for (float[] c : carp) carpL.add(P(ell(c[0], c[1], c[2], c[3]), F_HAND));
    float[][] mc = { { -15, 15, -24, 31, 5, 3.4 }, { -6, 17, -8.5, 40, 4.6, 3 }, { 0, 18, 0.5, 41, 4.6, 3 }, { 6, 17, 7.5, 39, 4.4, 2.9 },
      { 11, 15, 14.5, 36, 4.2, 2.8 } };
    for (float[] m : mc) mcL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_HAND));
    float[][] ph = { { -25, 33, -29.5, 45, 4.6, 3.2 }, { -30, 47, -32, 55, 4, 3 },
      { -9, 42, -10.5, 56, 4, 2.8 }, { -10.7, 58, -11.5, 65, 3.6, 2.6 }, { -11.6, 67, -12, 72, 3.2, 2.4 },
      { 0.6, 43, 1, 58, 4.2, 2.9 }, { 1, 60, 1.2, 68, 3.7, 2.7 }, { 1.2, 70, 1.3, 75, 3.3, 2.5 },
      { 8, 41, 9.5, 55, 4, 2.8 }, { 9.7, 57, 10.5, 65, 3.6, 2.6 }, { 10.6, 67, 11, 72, 3.2, 2.4 },
      { 15, 38, 17.5, 49, 3.6, 2.6 }, { 17.7, 51, 18.7, 57, 3.3, 2.4 }, { 18.8, 59, 19.3, 64, 3, 2.2 } };
    for (float[] m : ph) phL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_HAND));

    femL = P(new float[] { -3, -10, 4, -9.5, 9, -5, 10.5, 1, 8, 7, 3, 10.5, -2, 13, -4, 18, -2, 23, -3, 28, -7, 31, -6, 50, -3, 72, 0, 88,
      4, 99, 9, 105, 11, 111, 8, 117, 2, 118, -2, 114, -6, 118, -12, 117, -15, 111, -14, 104, -11, 97, -13, 84, -18, 60, -22, 40,
      -25, 26, -28, 14, -28, 5, -24, -1, -19, 1, -13, -3, -8, -7 }, F_FEM);
    patL = P(ell(-2, 103, 8.5, 10.5), F_FEM);
    tibL = P(new float[] { -14, 2, -6, 0, 3, 0, 12, 1, 14, 6, 11, 13, 6, 22, 4, 40, 3, 60, 4, 78, 6, 86, 8, 94, 5, 99, 0, 97, -6, 96,
      -8, 90, -6, 80, -5, 60, -5, 40, -6, 24, -10, 15, -14, 9 }, F_LEG);
    fibL = P(new float[] { -21, 6, -17, 3, -13, 5, -13, 10, -16, 14, -15, 40, -13, 70, -11, 86, -9, 96, -12, 101, -16, 98, -16, 86, -18, 70,
      -20, 40, -20, 15, -22, 10 }, F_LEG);
    float[][] tars = { { -9, 1, 5, 5 }, { 0, 3, 9, 5.5 }, { 5, 11, 6, 3.6 }, { -7, 13, 5.5, 5 }, { 8.5, 18.5, 3.8, 4 }, { 3, 18.5, 2.8, 3.5 },
      { -2.5, 18.5, 3, 3.6 } };
    for (float[] c : tars) tarsL.add(P(ell(c[0], c[1], c[2], c[3]), F_FOOT));
    float[][] mt = { { 9, 22.5, 12, 38, 6.4, 4.6 }, { 3, 22.5, 4, 40, 4.4, 3 }, { -2, 22.5, -3, 39, 4.3, 3 }, { -6, 21, -9, 37, 4.2, 2.9 },
      { -10, 19, -15, 34, 4.6, 3 } };
    for (float[] m : mt) mtL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_FOOT));
    float[][] phf = { { 12.5, 40.5, 13.5, 48, 5.8, 4.4 }, { 13.6, 50, 14, 56, 5.2, 4 },
      { 4.2, 42, 4.7, 48.5, 3.8, 2.8 }, { 4.8, 50.5, 5, 54, 3.4, 2.6 }, { 5, 55.6, 5.1, 58, 3.1, 2.5 },
      { -3.1, 41, -3.6, 47, 3.7, 2.7 }, { -3.7, 49, -3.9, 52.5, 3.3, 2.5 }, { -4, 54.1, -4, 56.5, 3, 2.4 },
      { -9.3, 39, -10.6, 45, 3.6, 2.6 }, { -10.7, 47, -11.2, 50.5, 3.2, 2.4 }, { -11.3, 52.1, -11.5, 54.5, 2.9, 2.3 },
      { -15.5, 36, -17.2, 41, 3.4, 2.5 }, { -17.4, 43, -18, 46, 3, 2.3 }, { -18.1, 47.6, -18.4, 50, 2.8, 2.2 } };
    for (float[] m : phf) phfL.add(P(stick(m[0], m[1], m[2], m[3], m[4], m[5]), F_FOOT));

    // ---- pelvis
    hipL = new float[] { 280, 270, 271, 260, 258, 255, 245, 257, 234, 264, 227, 276, 224, 289, 227, 296, 229, 302, 235, 310, 237, 324,
      240, 338, 243, 350, 249, 358, 257, 360, 264, 357, 273, 351, 285, 346, 296, 343, 297, 327, 288, 323, 276, 321, 266, 316, 264, 305,
      269, 293, 277, 284, 281, 277 };
    iliacFossaL = new float[] { 277, 272, 262, 262, 248, 263, 238, 271, 233, 284, 238, 296, 250, 303, 263, 305, 268, 293, 276, 282 };
    obturatorL = ell(266, 339, 11, 7, 0.95);
    symphysis = new float[] { 296, 326, 304, 326, 304, 343, 296, 343 };
    sacrum = new float[] { 275, 283, 288, 280, 300, 279, 312, 280, 325, 283, 323, 293, 317, 306, 309, 318, 303, 327, 297, 327, 291, 318,
      283, 306, 277, 293 };
    coccyx = new float[] { 296, 327, 304, 327, 303, 333, 301, 338, 299, 338, 297, 333 };
  }

  float[] sternumHit() {
    return sym(new float[] { 300, 127, 290, 125, 284, 130, 286, 140, 289, 149, 287, 165, 287, 190, 289, 205, 294, 210, 297, 223, 300, 224 });
  }

  // =============================================================== art
  void drawArt(PGraphics g) {
    // scapulae (behind the rib cage)
    for (int s = 0; s < 2; s++) {
      bone(g, side(scapL, s), lerpColor(D_BONE, D_BONE_SH, 0.2), D_BONE_SH, 2, 3);
      g.stroke(D_BONE_SH);
      g.strokeWeight(1.6);
      g.noFill();
      line(g, side(new float[] { 226, 132, 248, 129, 268, 131 }, s));
    }
    drawSpine(g);
    // ribs + costal cartilage
    for (int s = 0; s < 2; s++) {
      for (int i = 0; i < cartL.size(); i++) bone(g, side(band(cartL.get(i), 6, 5.5), s), CART, CART_SH, 1.6, 1.4);
      for (int i = ribL.size() - 1; i >= 0; i--) {
        float w = i < 2 ? 6.5 : (i > 9 ? 5.5 : 7);
        bone(g, side(band(ribL.get(i), w * 0.75, w), s), D_BONE, D_BONE_SH, 1.5, 1.8);
      }
    }
    // sternum
    bone(g, sternum, D_BONE, D_BONE_SH, 2, 2);
    bone(g, manubrium, D_BONE, D_BONE_SH, 2, 2);
    bone(g, xiphoid, D_BONE, D_BONE_SH, 1.8, 1.2);
    g.stroke(D_BONE_SH);
    g.strokeWeight(1.2);
    for (int k = 0; k < 3; k++) g.line(292, 163 + k * 14, 308, 163 + k * 14);     // fused sternebrae
    // pelvis + sacrum
    bone(g, sacrum, D_BONE, D_BONE_SH, 2, 3);
    bone(g, coccyx, D_BONE, D_BONE_SH, 1.5, 1);
    g.noStroke();
    g.fill(HOLE);
    for (int k = 0; k < 4; k++) {
      float y = 289 + k * 8.5, dx = 9.5 - k * 1.6, r = 2.6 - k * 0.3;
      g.ellipse(300 - dx, y, r * 2, r * 1.6);
      g.ellipse(300 + dx, y, r * 2, r * 1.6);
    }
    g.stroke(D_BONE_SH);
    g.strokeWeight(1.2);
    for (int k = 0; k < 4; k++) {
      float y = 293.5 + k * 8.5, dx = 8 - k * 1.6;
      g.line(300 - dx, y, 300 + dx, y);
    }
    for (int s = 0; s < 2; s++) {
      bone(g, side(hipL, s), D_BONE, D_BONE_SH, 2, 3);
      g.noStroke();
      g.fill(D_BONE_SH, 150);
      blob(g, side(iliacFossaL, s));
      g.fill(HOLE);
      g.stroke(D_INK);
      g.strokeWeight(1.6);
      blob(g, side(obturatorL, s));
    }
    bone(g, symphysis, CART, CART_SH, 1.5, 1);
    // legs
    for (int s = 0; s < 2; s++) {
      bone(g, side(femL, s), D_BONE, D_BONE_SH, 2, 3);
      shaftLine(g, side(P(new float[] { -15, 35, -9, 70, -5, 90 }, F_FEM), s));
      bone(g, side(fibL, s), D_BONE, D_BONE_SH, 1.8, 2);
      bone(g, side(tibL, s), D_BONE, D_BONE_SH, 2, 3);
      shaftLine(g, side(P(new float[] { 0, 25, -1, 50, 0, 80 }, F_LEG), s));
      g.stroke(D_BONE_SH);
      g.strokeWeight(1.3);
      g.noFill();
      line(g, side(P(new float[] { -4, 14, -1, 19, 2, 14 }, F_LEG), s));   // tibial tuberosity
      bone(g, side(patL, s), D_BONE, D_BONE_SH, 2, 2.2);
      for (float[] b : tarsL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.3, 1);
      for (float[] b : mtL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.3, 0.9);
      for (float[] b : phfL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.2, 0.7);
    }
    // arms
    for (int s = 0; s < 2; s++) {
      bone(g, side(humL, s), D_BONE, D_BONE_SH, 2, 3);
      shaftLine(g, side(P(new float[] { -3, 22, -2, 45, -1, 65 }, F_HUM), s));
      bone(g, side(ulnL, s), D_BONE, D_BONE_SH, 1.8, 2);
      bone(g, side(radL, s), D_BONE, D_BONE_SH, 1.8, 2);
      for (float[] b : carpL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.2, 0.9);
      for (float[] b : mcL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.2, 0.8);
      for (float[] b : phL) bone(g, side(b, s), D_BONE, D_BONE_SH, 1.1, 0.6);
    }
    // clavicles + coracoid (in front of the shoulder joint)
    for (int s = 0; s < 2; s++) {
      bone(g, side(coracL, s), lerpColor(D_BONE, D_BONE_SH, 0.2), D_BONE_SH, 1.6, 1.2);
      bone(g, side(band(clavL, 7.5, 6.5), s), D_BONE, D_BONE_SH, 2, 2);
    }
    drawSkull(g);
  }

  void drawSpine(PGraphics g) {
    // cervical C2-C7 (y 86..128), thoracic T1-T12 (128..222), lumbar L1-L5 (222..282)
    g.strokeWeight(1.4);
    for (int i = 0; i < 6; i++) {
      float y = 86 + i * 7, w = 8.5 + i * 0.4;
      g.stroke(D_INK);
      g.fill(D_BONE_SH);
      g.rect(300 - w - 5, y + 1.5, (w + 5) * 2, 3.2, 1.5);                 // transverse processes
      g.fill(D_BONE);
      g.rect(300 - w, y, w * 2, 5.4, 1.8);
      g.fill(CART);
      g.rect(300 - w + 1, y + 5.4, w * 2 - 2, 1.6);
    }
    for (int i = 0; i < 12; i++) {
      float y = 128 + i * 7.8, w = 9.5 + i * 0.25;
      g.stroke(D_INK);
      g.fill(D_BONE_SH);
      g.rect(300 - w - 6, y + 1.5, (w + 6) * 2, 3, 1.5);
      g.fill(D_BONE);
      g.rect(300 - w, y, w * 2, 6.2, 2);
      g.fill(CART);
      g.rect(300 - w + 1, y + 6.2, w * 2 - 2, 1.6);
    }
    for (int i = 0; i < 5; i++) {
      float y = 222.5 + i * 12, w = 12.5 + i * 0.8, tp = 22 + (i == 2 ? 3 : 0) - (i == 4 ? 2 : 0);
      g.stroke(D_INK);
      g.fill(D_BONE_SH);
      g.beginShape();
      g.vertex(300 - tp, y + 3);
      g.vertex(300 + tp, y + 3);
      g.vertex(300 + tp - 1, y + 7);
      g.vertex(300 - tp + 1, y + 7);
      g.endShape(CLOSE);
      g.fill(D_BONE);
      g.beginShape();
      g.vertex(300 - w, y);
      g.bezierVertex(300 - w / 2, y + 1.5, 300 + w / 2, y + 1.5, 300 + w, y);
      g.vertex(300 + w - 1, y + 9.3);
      g.bezierVertex(300 + w / 2, y + 8, 300 - w / 2, y + 8, 300 - w + 1, y + 9.3);
      g.endShape(CLOSE);
      g.noStroke();
      g.fill(D_BONE_SH, 150);
      g.rect(300 + w * 0.35, y + 1.5, w * 0.55, 7);
      g.stroke(D_INK);
      g.fill(CART);
      if (i < 4) g.rect(300 - w + 1.5, y + 9.4, w * 2 - 3, 2.4, 1);
    }
  }

  void drawSkull(PGraphics g) {
    // mandible behind the cheekbones, then the cranium
    bone(g, mandible, D_BONE, D_BONE_SH, 2, 2.5);
    g.stroke(D_INK);
    g.strokeWeight(1);
    g.fill(#FBF7EC);
    for (int i = 0; i < 8; i++) {                      // lower teeth
      float x = 286 + i * 3.6;
      g.rect(x, 81.5 + abs(i - 3.5) * 0.35, 3.4, 4.6, 1.2);
    }
    bone(g, skull, D_BONE, D_BONE_SH, 2.2, 3.5);
    g.noStroke();
    g.fill(D_BONE_SH, 140);
    blob(g, new float[] { 266, 58, 271, 56, 276, 60, 274, 66, 268, 66 });  // cheek shadows
    blob(g, mir(new float[] { 266, 58, 271, 56, 276, 60, 274, 66, 268, 66 }));
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(HOLE);
    blob(g, orbitL);
    blob(g, mir(orbitL));
    blob(g, nasal);
    g.noStroke();
    g.fill(#6B5A60);
    g.ellipse(287, 50, 8, 6);
    g.ellipse(313, 50, 8, 6);
    g.stroke(D_INK);
    g.strokeWeight(1);
    g.fill(#FBF7EC);
    for (int i = 0; i < 8; i++) {                      // upper teeth
      float x = 285.5 + i * 3.6;
      g.rect(x, 76.2 - abs(i - 3.5) * 0.3, 3.4, 5, 1.2);
    }
    g.noFill();
    g.stroke(D_BONE_SH);
    g.strokeWeight(1.3);
    g.bezier(268, 30, 276, 23, 286, 21, 293, 21);       // temporal lines
    g.bezier(332, 30, 324, 23, 314, 21, 307, 21);
    g.bezier(298, 61, 299, 50, 301, 50, 302, 61);
  }

  // =============================================================== helpers (local to this class)
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

  // half outline (midline -> viewer's left side -> midline) to a full symmetric outline
  float[] sym(float[] half) {
    int n = half.length / 2;
    float[] q = new float[(2 * n - 2) * 2];
    int k = 0;
    for (int i = 0; i < n; i++) {
      q[k++] = half[i * 2];
      q[k++] = half[i * 2 + 1];
    }
    for (int i = n - 2; i >= 1; i--) {
      q[k++] = DIA - half[i * 2];
      q[k++] = half[i * 2 + 1];
    }
    return q;
  }

  // local bone frame -> diagram units
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

  float[] ell(float cx, float cy, float rx, float ry) {
    return ell(cx, cy, rx, ry, 0);
  }

  float[] ell(float cx, float cy, float rx, float ry, float a) {
    int n = 16;
    float[] p = new float[n * 2];
    for (int i = 0; i < n; i++) {
      float t = TWO_PI * i / n, x = cos(t) * rx, y = sin(t) * ry;
      p[i * 2] = cx + x * cos(a) - y * sin(a);
      p[i * 2 + 1] = cy + x * sin(a) + y * cos(a);
    }
    return p;
  }

  // small long bone (phalanx, metacarpal): knobby ends, slim waist
  float[] stick(float x0, float y0, float x1, float y1, float wEnd, float wMid) {
    float dx = x1 - x0, dy = y1 - y0, L = sqrt(dx * dx + dy * dy);
    float ux = dx / L, uy = dy / L, nx = -uy, ny = ux, r = wEnd / 2;
    FloatList q = new FloatList();
    float[] ts = { 0.22, 0.5, 0.78 };
    float[] ws = { r * 0.92, wMid / 2, r * 0.92 };
    for (int i = 0; i < 3; i++) {
      q.append(x0 + dx * ts[i] + nx * ws[i]);
      q.append(y0 + dy * ts[i] + ny * ws[i]);
    }
    for (int i = 0; i <= 4; i++) {                       // far cap
      float a = HALF_PI - PI * i / 4;
      q.append(x1 - ux * r * 0.2 + (nx * sin(a) + ux * cos(a)) * r);
      q.append(y1 - uy * r * 0.2 + (ny * sin(a) + uy * cos(a)) * r);
    }
    for (int i = 2; i >= 0; i--) {
      q.append(x0 + dx * ts[i] - nx * ws[i]);
      q.append(y0 + dy * ts[i] - ny * ws[i]);
    }
    for (int i = 0; i <= 4; i++) {                       // near cap
      float a = -HALF_PI - PI * i / 4;
      q.append(x0 + ux * r * 0.2 + (nx * sin(a) + ux * cos(a)) * r);
      q.append(y0 + uy * r * 0.2 + (ny * sin(a) + uy * cos(a)) * r);
    }
    return q.array();
  }

  // Catmull-Rom path through points (open), sampled
  float[] cr(float[] p, int per) {
    int n = p.length / 2;
    FloatList q = new FloatList();
    for (int i = 0; i < n - 1; i++) {
      int i0 = max(0, i - 1), i2 = i + 1, i3 = min(n - 1, i + 2);
      for (int k = 0; k < per; k++) {
        float t = k / (float) per;
        q.append(g_cr(p[i0 * 2], p[i * 2], p[i2 * 2], p[i3 * 2], t));
        q.append(g_cr(p[i0 * 2 + 1], p[i * 2 + 1], p[i2 * 2 + 1], p[i3 * 2 + 1], t));
      }
    }
    q.append(p[(n - 1) * 2]);
    q.append(p[(n - 1) * 2 + 1]);
    return q.array();
  }

  float g_cr(float a, float b, float c, float d, float t) {
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
  }

  // thick band around an open centre line, width w0 -> w1, rounded ends
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

  // smooth closed curve through the points
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

  void shaftLine(PGraphics g, float[] p) {
    g.noFill();
    g.stroke(255, 255, 255, 150);
    g.strokeWeight(1.6);
    line(g, p);
  }

  // shape pushed inward, more on the lower-right (light from the upper left)
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
      float nx = ty / L * sg, ny = -tx / L * sg;           // outward normal
      float k = d * (0.25 + 0.75 * max(0, nx * 0.55 + ny * 0.83));
      q[i * 2] = p[i * 2] - nx * k;
      q[i * 2 + 1] = p[i * 2 + 1] - ny * k;
    }
    return q;
  }

  // a bone: shadow fill, lighter inner fill, ink outline
  void bone(PGraphics g, float[] p, int fillC, int shadeC, float sw, float shade) {
    g.noStroke();
    g.fill(shadeC);
    blob(g, p);
    g.fill(fillC);
    blob(g, inner(p, shade));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    blob(g, p);
  }
}
