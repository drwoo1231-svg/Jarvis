// PLACEHOLDER - replaced by the real artwork.

class NephronDiagram extends Diagram {
  NephronDiagram() {
    super("nephron", "Nephron");
    add("afferent_arteriole", "Afferent Arteriole").ellipse(100, 80, 55, 40);
    add("efferent_arteriole", "Efferent Arteriole").ellipse(230, 80, 55, 40);
    add("glomerulus", "Glomerulus").ellipse(360, 80, 55, 40);
    add("bowmans_capsule", "Bowmans Capsule").ellipse(490, 80, 55, 40);
    add("proximal_tubule", "Proximal Tubule").ellipse(100, 190, 55, 40);
    add("descending_limb", "Descending Limb").ellipse(230, 190, 55, 40);
    add("ascending_limb", "Ascending Limb").ellipse(360, 190, 55, 40);
    add("distal_tubule", "Distal Tubule").ellipse(490, 190, 55, 40);
    add("macula_densa", "Macula Densa").ellipse(100, 300, 55, 40);
    add("collecting_duct", "Collecting Duct").ellipse(230, 300, 55, 40);
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
  }
}
