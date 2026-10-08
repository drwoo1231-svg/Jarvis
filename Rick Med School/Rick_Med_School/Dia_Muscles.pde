// PLACEHOLDER - replaced by the real artwork.

class MusclesDiagram extends Diagram {
  MusclesDiagram() {
    super("muscles", "Major Muscles (front)");
    add("sternocleidomastoid", "Sternocleidomastoid").ellipse(100, 80, 55, 40);
    add("trapezius", "Trapezius").ellipse(230, 80, 55, 40);
    add("deltoid", "Deltoid").ellipse(360, 80, 55, 40);
    add("pectoralis_major", "Pectoralis Major").ellipse(490, 80, 55, 40);
    add("biceps_brachii", "Biceps Brachii").ellipse(100, 190, 55, 40);
    add("forearm_flexors", "Forearm Flexors").ellipse(230, 190, 55, 40);
    add("rectus_abdominis", "Rectus Abdominis").ellipse(360, 190, 55, 40);
    add("external_oblique", "External Oblique").ellipse(490, 190, 55, 40);
    add("quadriceps_femoris", "Quadriceps Femoris").ellipse(100, 300, 55, 40);
    add("adductors", "Adductors").ellipse(230, 300, 55, 40);
    add("sartorius", "Sartorius").ellipse(360, 300, 55, 40);
    add("tibialis_anterior", "Tibialis Anterior").ellipse(490, 300, 55, 40);
    add("gastrocnemius", "Gastrocnemius").ellipse(100, 410, 55, 40);
  }

  void drawArt(PGraphics g) {
    g.stroke(D_INK);
    g.strokeWeight(2);
    g.fill(#DDDDDD);
    g.ellipse(100, 80, 110, 80);
    g.ellipse(230, 80, 110, 80);
    g.ellipse(360, 80, 110, 80);
    g.ellipse(490, 80, 110, 80);
    g.ellipse(100, 190, 110, 80);
    g.ellipse(230, 190, 110, 80);
    g.ellipse(360, 190, 110, 80);
    g.ellipse(490, 190, 110, 80);
    g.ellipse(100, 300, 110, 80);
    g.ellipse(230, 300, 110, 80);
    g.ellipse(360, 300, 110, 80);
    g.ellipse(490, 300, 110, 80);
    g.ellipse(100, 410, 110, 80);
  }
}
