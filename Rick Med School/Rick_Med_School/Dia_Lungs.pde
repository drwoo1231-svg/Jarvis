// PLACEHOLDER - replaced by the real artwork.

class LungsDiagram extends Diagram {
  LungsDiagram() {
    super("lungs", "Respiratory Tree");
    add("larynx", "Larynx").ellipse(100, 80, 55, 40);
    add("trachea", "Trachea").ellipse(230, 80, 55, 40);
    add("carina", "Carina").ellipse(360, 80, 55, 40);
    add("right_main_bronchus", "Right Main Bronchus").ellipse(490, 80, 55, 40);
    add("left_main_bronchus", "Left Main Bronchus").ellipse(100, 190, 55, 40);
    add("bronchioles", "Bronchioles").ellipse(230, 190, 55, 40);
    add("alveoli", "Alveoli").ellipse(360, 190, 55, 40);
    add("right_lung", "Right Lung").ellipse(490, 190, 55, 40);
    add("left_lung", "Left Lung").ellipse(100, 300, 55, 40);
    add("cardiac_notch", "Cardiac Notch").ellipse(230, 300, 55, 40);
    add("diaphragm", "Diaphragm").ellipse(360, 300, 55, 40);
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
  }
}
