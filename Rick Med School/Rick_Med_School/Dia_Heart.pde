// Heart: anterior view of a frontal section, all four chambers open.
// Subject's right = viewer's left. Oxygen-poor blood blue, oxygen-rich red.
// The great arteries twist: the pulmonary trunk leaves the RV outflow and
// crosses IN FRONT of the ascending aorta, splitting under the aortic arch.

class HeartDiagram extends Diagram {
  final int MYO = #E9A28E, MYO_SH = #C7735F, MYO_LT = #F7CDBE;
  final int BB = #7EA0E6, BB_SH = #4F72C2, BB_LT = #B3C8F4;     // oxygen-poor blood
  final int RB = #E0595A, RB_SH = #AE3438, RB_LT = #F4979A;     // oxygen-rich blood
  final int VEIN_LT = #8FB0EE, ART_LT = #F08E8E;
  final int VALVE = #FFF7E6, VALVE_SH = #DCCBA8;

  // control points (closed / open Catmull-Rom splines)
  final float[] OUT_C = { 215, 224, 262, 236, 300, 250, 340, 256, 378, 240, 425, 229, 470, 239, 497, 277, 503, 335, 500, 390, 488, 445, 462, 500, 425, 546, 388, 571, 352, 566, 300, 546, 252, 513, 212, 474, 190, 428, 158, 399, 121, 372, 103, 315, 110, 262, 135, 231, 166, 223 };
  final float[] RA_C = { 150, 247, 190, 243, 238, 249, 257, 276, 259, 325, 251, 368, 222, 385, 176, 384, 141, 362, 124, 316, 128, 272 };
  final float[] RV_C = { 210, 405, 262, 401, 274, 372, 274, 314, 279, 274, 317, 272, 322, 306, 314, 338, 306, 368, 320, 410, 338, 468, 350, 520, 340, 538, 306, 530, 264, 504, 228, 471, 208, 437 };
  final float[] LA_C = { 388, 254, 430, 246, 469, 256, 485, 290, 478, 325, 446, 337, 402, 336, 383, 302 };
  final float[] LV_C = { 333, 306, 373, 303, 390, 336, 396, 351, 458, 352, 467, 395, 457, 450, 433, 500, 401, 527, 383, 521, 368, 465, 352, 400, 341, 350 };
  final float[] AO_C = { 351, 302, 342, 252, 321, 202, 305, 152, 307, 110, 331, 82, 375, 71, 420, 80, 450, 110, 460, 160, 460, 233 };
  final float[] PT_C = { 298, 276, 305, 238, 324, 207, 353, 187, 388, 177 };
  final float[] LPA_C = { 380, 177, 430, 170, 480, 168, 525, 172, 566, 180 };
  final float[] LPA2_C = { 520, 174, 545, 192, 566, 214 };
  final float[] RPA_C = { 386, 179, 330, 176, 260, 176, 190, 179, 120, 183, 42, 189 };
  final float[] RPA2_C = { 92, 186, 70, 202, 46, 216 };
  final float[] SVC_C = { 190, 18, 190, 120, 190, 250 };
  final float[] IVC_C = { 160, 352, 160, 470, 160, 580 };
  final float[] BC_C = { 326, 92, 314, 52, 304, 16 };
  final float[] LCC_C = { 368, 76, 368, 40, 368, 14 };
  final float[] LSC_C = { 410, 82, 422, 46, 432, 16 };
  final float[] PVR1_C = { 140, 246, 90, 240, 40, 238 };
  final float[] PVR2_C = { 132, 288, 85, 288, 38, 292 };
  final float[] PVL1_C = { 470, 268, 520, 258, 566, 254 };
  final float[] PVL2_C = { 478, 312, 525, 318, 568, 326 };

  final float W_AO = 44, W_PT = 46, W_PA = 30, W_PA2 = 16, W_CAVA = 48, W_PV = 22, W_BR = 20;

  float[] outline, raCav, rvCav, laCav, lvCav;
  float[] ao, pt, lpa, lpa2, rpa, rpa2, svc, ivc, bc, lcc, lsc, pvr1, pvr2, pvl1, pvl2;

  HeartDiagram() {
    super("heart", "Heart (front view)");
    outline = cr(OUT_C, true, 10);
    raCav = cr(RA_C, true, 10);
    rvCav = cr(RV_C, true, 10);
    laCav = cr(LA_C, true, 10);
    lvCav = cr(LV_C, true, 10);
    ao = cr(AO_C, false, 12);
    pt = cr(PT_C, false, 10);
    lpa = cr(LPA_C, false, 10);
    lpa2 = cr(LPA2_C, false, 10);
    rpa = cr(RPA_C, false, 10);
    rpa2 = cr(RPA2_C, false, 10);
    svc = cr(SVC_C, false, 10);
    ivc = cr(IVC_C, false, 10);
    bc = cr(BC_C, false, 8);
    lcc = cr(LCC_C, false, 8);
    lsc = cr(LSC_C, false, 8);
    pvr1 = cr(PVR1_C, false, 8);
    pvr2 = cr(PVR2_C, false, 8);
    pvl1 = cr(PVL1_C, false, 8);
    pvl2 = cr(PVL2_C, false, 8);

    // chambers first (each = its cavity + surrounding wall)
    add("right_atrium", "Right Atrium")
      .poly(166, 223, 135, 231, 110, 262, 102, 315, 120, 372, 158, 399, 200, 398, 267, 400, 267, 300, 267, 246, 262, 236, 215, 224)
      .anchor(190, 312);
    add("right_ventricle", "Right Ventricle")
      .poly(196, 404, 267, 400, 267, 290, 274, 263, 324, 263, 327, 304, 320, 340, 312, 368, 326, 410, 343, 468, 356, 522, 360, 548, 352, 566, 300, 546, 252, 513, 212, 474, 189, 428)
      .anchor(262, 455);
    add("left_atrium", "Left Atrium")
      .poly(380, 240, 425, 228, 470, 238, 497, 276, 504, 338, 462, 347, 392, 344, 378, 302)
      .anchor(436, 292);
    add("left_ventricle", "Left Ventricle")
      .poly(330, 306, 378, 301, 392, 343, 462, 347, 504, 340, 500, 390, 488, 445, 462, 500, 425, 546, 388, 572, 362, 567, 374, 550, 384, 525, 368, 465, 352, 400, 338, 345)
      .anchor(412, 450);
    add("interventricular_septum", "Interventricular Septum")
      .poly(305, 350, 340, 338, 354, 398, 370, 463, 386, 524, 376, 553, 350, 542, 335, 470, 318, 412, 302, 372)
      .anchor(343, 440);
    // great vessels
    add("superior_vena_cava", "Superior Vena Cava")
      .poly(165, 14, 215, 14, 215, 229, 165, 229)
      .anchor(190, 120);
    add("inferior_vena_cava", "Inferior Vena Cava")
      .poly(135, 386, 160, 400, 185, 419, 185, 582, 135, 582)
      .anchor(160, 510);
    Part a = add("aorta", "Aorta");
    a.poly(tubePoly(sub(ao, 0, 9999), W_AO));
    a.poly(tubePoly(bc, W_BR + 4)).poly(tubePoly(lcc, W_BR + 2)).poly(tubePoly(lsc, W_BR + 4));
    a.anchor(375, 72);
    Part p = add("pulmonary_trunk", "Pulmonary Trunk");
    p.poly(tubePoly(pt, W_PT)).poly(tubePoly(lpa, W_PA)).poly(tubePoly(lpa2, W_PA2 + 4));
    p.poly(tubePoly(sub(rpa, 98, 172), W_PA)); // between SVC and aorta
    p.poly(tubePoly(sub(rpa, 222, 9999), W_PA)).poly(tubePoly(rpa2, W_PA2 + 4)); // left of the SVC
    p.anchor(322, 222);
    add("pulmonary_veins", "Pulmonary Veins")
      .poly(tubePoly(sub(pvr1, len(pvr1) - 78, len(pvr1)), W_PV + 4))
      .poly(tubePoly(sub(pvr2, len(pvr2) - 76, len(pvr2)), W_PV + 4))
      .poly(tubePoly(sub(pvl1, 22, len(pvl1)), W_PV + 4))
      .poly(tubePoly(sub(pvl2, 22, len(pvl2)), W_PV + 4))
      .anchor(528, 259);
    // valves and nodes on top
    add("tricuspid_valve", "Tricuspid Valve")
      .poly(196, 384, 236, 380, 270, 388, 262, 418, 250, 442, 230, 444, 210, 440, 198, 414)
      .anchor(232, 405);
    add("pulmonary_valve", "Pulmonary Valve").ellipse(298, 274, 29, 13);
    add("mitral_valve", "Mitral Valve")
      .poly(392, 332, 430, 330, 466, 336, 458, 370, 448, 398, 428, 402, 410, 400, 396, 372)
      .anchor(428, 360);
    add("aortic_valve", "Aortic Valve").ellipse(351, 302, 29, 13);
    add("sa_node", "SA Node").ellipse(168, 238, 14, 12);
    add("av_node", "AV Node").ellipse(263, 381, 13, 13);
  }

  void drawArt(PGraphics g) {
    // ---- vessels behind the heart
    tube(g, rpa2, W_PA2, BB, BB_SH, VEIN_LT, true);
    tube(g, rpa, W_PA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, rpa, false, W_PA, BB_SH);   // open end at the right lung hilum (its start is hidden under the trunk)
    cutEnd(g, rpa2, false, W_PA2, BB_SH);
    tube(g, pvr1, W_PV, RB, RB_SH, ART_LT, true);
    tube(g, pvr2, W_PV, RB, RB_SH, ART_LT, true);
    tube(g, pvl1, W_PV, RB, RB_SH, ART_LT, true);
    tube(g, pvl2, W_PV, RB, RB_SH, ART_LT, true);
    cutEnd(g, pvr1, false, W_PV, RB_SH);
    cutEnd(g, pvr2, false, W_PV, RB_SH);
    cutEnd(g, pvl1, false, W_PV, RB_SH);
    cutEnd(g, pvl2, false, W_PV, RB_SH);
    tube(g, ivc, W_CAVA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, ivc, false, W_CAVA, BB_SH);
    tube(g, svc, W_CAVA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, svc, true, W_CAVA, BB_SH);
    // aorta: branches, arch, descending (root is redrawn over the heart later)
    tube(g, bc, W_BR, RB, RB_SH, ART_LT, true);
    tube(g, lcc, W_BR - 2, RB, RB_SH, ART_LT, true);
    tube(g, lsc, W_BR, RB, RB_SH, ART_LT, true);
    cutEnd(g, bc, false, W_BR, RB_SH);
    cutEnd(g, lcc, false, W_BR - 2, RB_SH);
    cutEnd(g, lsc, false, W_BR, RB_SH);
    tube(g, ao, W_AO, RB, RB_SH, ART_LT, false);

    // ---- heart wall (myocardium)
    shaded(g, outline, MYO, MYO_SH, MYO_LT, 0.95, 2.8);
    // faint muscle fibre arcs in the thick LV wall and the septum
    g.noFill();
    g.stroke(MYO_SH, 110);
    g.strokeWeight(1.4);
    polyline(g, cr(new float[] { 484, 372, 477, 440, 450, 500, 410, 540 }, false, 8));
    polyline(g, cr(new float[] { 492, 395, 478, 458, 446, 512, 408, 552 }, false, 8));
    polyline(g, cr(new float[] { 326, 372, 340, 430, 356, 490, 366, 532 }, false, 8));
    polyline(g, cr(new float[] { 196, 444, 220, 486, 260, 520, 300, 538 }, false, 8));

    // ---- chambers (blood)
    // openings between atria and ventricles (blood continuous through the valves)
    g.noStroke();
    g.fill(BB);
    quad4(g, 206, 380, 252, 372, 266, 404, 208, 410);
    g.fill(RB);
    quad4(g, 400, 330, 450, 332, 460, 358, 396, 356);
    shaded(g, raCav, BB, BB_SH, BB_LT, 0.9, 2.2);
    shaded(g, rvCav, BB, BB_SH, BB_LT, 0.9, 2.2);
    shaded(g, laCav, RB, RB_SH, RB_LT, 0.9, 2.2);
    shaded(g, lvCav, RB, RB_SH, RB_LT, 0.9, 2.2);
    // repaint the valve openings over the cavity outlines
    g.noStroke();
    g.fill(BB);
    quad4(g, 212, 378, 248, 372, 260, 406, 214, 408);
    g.fill(RB);
    quad4(g, 404, 328, 448, 330, 456, 360, 400, 358);
    // orifices of the venae cavae in the right atrium
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    g.fill(BB_SH);
    g.ellipse(190, 256, 38, 12);
    g.ellipse(165, 372, 36, 12);

    // papillary muscles + chordae tendineae
    papillary(g, 248, 491, 238, 462, 13);
    papillary(g, 335, 456, 308, 442, 12);
    papillary(g, 414, 518, 414, 470, 15);
    papillary(g, 459, 446, 440, 428, 14);
    g.stroke(#FFFBF0);
    g.strokeWeight(1.4);
    g.line(220, 432, 238, 462);
    g.line(232, 434, 238, 462);
    g.line(246, 436, 308, 442);
    g.line(246, 436, 238, 462);
    g.line(416, 392, 414, 470);
    g.line(424, 394, 414, 470);
    g.line(440, 390, 440, 428);
    g.line(446, 388, 440, 428);

    // crisp outline of the heart (before the great arteries, which sit in front)
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(2.8);
    polygon(g, outline);

    // ---- aortic root (in front, opened) + aortic valve
    float[] root = sub(ao, 0, 92);
    tube(g, root, W_AO, RB, RB_SH, ART_LT, false);
    semilunar(g, 351, 302, W_AO - 4, 0);

    // ---- pulmonary trunk + arteries (anterior, crossing the aorta)
    tube(g, lpa2, W_PA2, BB, BB_SH, VEIN_LT, true);
    tube(g, lpa, W_PA, BB, BB_SH, VEIN_LT, true);
    cutEnd(g, lpa, false, W_PA, BB_SH);
    cutEnd(g, lpa2, false, W_PA2, BB_SH);
    tube(g, pt, W_PT, BB, BB_SH, VEIN_LT, true);
    semilunar(g, 298, 274, W_PT - 4, 0);

    // ---- atrioventricular valves (leaflets hang into the ventricles)
    leaflet(g, 206, 386, 234, 384, 220, 434);
    leaflet(g, 236, 384, 264, 392, 246, 438);
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.noFill();
    g.line(203, 384, 266, 392);
    leaflet(g, 398, 333, 430, 332, 418, 396);
    leaflet(g, 430, 332, 460, 338, 444, 390);
    g.stroke(D_INK);
    g.strokeWeight(2.2);
    g.line(396, 333, 462, 338);

    // ---- conduction nodes (with a faint internodal pathway)
    g.noFill();
    g.stroke(D_NERVE, 200);
    g.strokeWeight(2);
    dashed(g, cr(new float[] { 176, 242, 230, 244, 256, 262, 264, 320, 263, 372 }, false, 10), 5, 5);
    node(g, 168, 238, 11, 8);
    node(g, 263, 381, 9, 9);
  }

  // ------------------------------------------------------------ drawing helpers
  void node(PGraphics g, float x, float y, float rx, float ry) {
    g.noStroke();
    g.fill(D_NERVE, 90);
    g.ellipse(x, y, rx * 2 + 9, ry * 2 + 9);
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(D_NERVE);
    g.ellipse(x, y, rx * 2, ry * 2);
    g.noStroke();
    g.fill(255, 240, 190);
    g.ellipse(x - rx * 0.3, y - ry * 0.35, rx * 0.7, ry * 0.6);
  }

  // a papillary muscle growing out of the wall at (bx, by) with its tip at (tx, ty)
  void papillary(PGraphics g, float bx, float by, float tx, float ty, float w) {
    float dx = tx - bx, dy = ty - by, L = sqrt(dx * dx + dy * dy);
    float ux = dx / L, uy = dy / L, nx = -uy * w / 2, ny = ux * w / 2;
    float ex = bx - ux * 7, ey = by - uy * 7;   // base buried in the wall
    g.noStroke();
    g.fill(MYO);
    g.beginShape();
    g.vertex(ex + nx * 1.6, ey + ny * 1.6);
    g.vertex(bx + nx * 1.5, by + ny * 1.5);
    g.bezierVertex(bx + nx * 0.9 + ux * L * 0.4, by + ny * 0.9 + uy * L * 0.4, tx + nx, ty + ny, tx + ux * w * 0.5, ty + uy * w * 0.5);
    g.bezierVertex(tx - nx, ty - ny, bx - nx * 0.9 + ux * L * 0.4, by - ny * 0.9 + uy * L * 0.4, bx - nx * 1.5, by - ny * 1.5);
    g.vertex(ex - nx * 1.6, ey - ny * 1.6);
    g.endShape(CLOSE);
    g.stroke(MYO_LT);
    g.strokeWeight(w * 0.25);
    g.line(bx + ux * L * 0.3 + nx * 0.3, by + uy * L * 0.3 + ny * 0.3, tx - ux * 3 + nx * 0.3, ty - uy * 3 + ny * 0.3);
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.beginShape();
    g.vertex(bx + nx * 1.5, by + ny * 1.5);
    g.bezierVertex(bx + nx * 0.9 + ux * L * 0.4, by + ny * 0.9 + uy * L * 0.4, tx + nx, ty + ny, tx + ux * w * 0.5, ty + uy * w * 0.5);
    g.bezierVertex(tx - nx, ty - ny, bx - nx * 0.9 + ux * L * 0.4, by - ny * 0.9 + uy * L * 0.4, bx - nx * 1.5, by - ny * 1.5);
    g.endShape();
  }

  // an atrioventricular cusp: hinge from (x0,y0)-(x1,y1), free tip at (tx,ty)
  void leaflet(PGraphics g, float x0, float y0, float x1, float y1, float tx, float ty) {
    g.stroke(D_INK);
    g.strokeWeight(1.8);
    g.fill(VALVE);
    g.beginShape();
    g.vertex(x0, y0);
    g.bezierVertex(x0 + 2, y0 + (ty - y0) * 0.5, tx - 6, ty - 8, tx, ty);
    g.bezierVertex(tx + 6, ty - 8, x1 - 2, y1 + (ty - y1) * 0.5, x1, y1);
    g.endShape(CLOSE);
    g.stroke(VALVE_SH);
    g.strokeWeight(1.2);
    g.line((x0 + x1) / 2, (y0 + y1) / 2 + 4, tx, ty - 6);
  }

  // three semilunar cusps across a vessel base centred at (cx, cy)
  void semilunar(PGraphics g, float cx, float cy, float w, float ang) {
    float cw = w / 3;
    g.stroke(D_INK);
    g.strokeWeight(1.6);
    for (int i = 0; i < 3; i++) {
      float x0 = cx - w / 2 + i * cw;
      g.fill(VALVE);
      g.beginShape();
      g.vertex(x0, cy);
      g.bezierVertex(x0 + 1, cy - 12, x0 + cw - 1, cy - 12, x0 + cw, cy);
      g.bezierVertex(x0 + cw * 0.7, cy - 4, x0 + cw * 0.3, cy - 4, x0, cy);
      g.endShape(CLOSE);
    }
    g.strokeWeight(2.4);
    g.line(cx - w / 2 - 2, cy, cx + w / 2 + 2, cy);
  }

  void quad4(PGraphics g, float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3) {
    g.quad(x0, y0, x1, y1, x2, y2, x3, y3);
  }

  // fill a closed shape with a darker rim, lighter body and a soft highlight, then outline it
  void shaded(PGraphics g, float[] p, int base, int sh, int lt, float k, float sw) {
    float[] c = centroid(p);
    g.noStroke();
    g.fill(sh);
    polygon(g, p);
    g.fill(base);
    polygon(g, scaled(p, c[0], c[1], k, -2.5, -3));
    g.fill(lt, 120);
    polygon(g, scaled(p, c[0] - 0.18 * (c[0] - minX(p)), c[1] - 0.2 * (c[1] - minY(p)), 0.45, 0, 0));
    g.noFill();
    g.stroke(D_INK);
    g.strokeWeight(sw);
    polygon(g, p);
  }

  // a vessel: filled tube with a shade stripe, a highlight stripe and an ink outline
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

  // the cut end of a vessel (lumen seen end-on)
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

  // ------------------------------------------------------------ geometry helpers
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

  // the part of a polyline between arc lengths a and b
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
