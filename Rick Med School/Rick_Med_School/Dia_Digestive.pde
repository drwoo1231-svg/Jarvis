// PLACEHOLDER - replaced by the real artwork.

class DigestiveDiagram extends Diagram {
  DigestiveDiagram() {
    super("digestive", "Digestive System");
    add("esophagus", "Esophagus").ellipse(100, 80, 55, 40);
    add("stomach", "Stomach").ellipse(230, 80, 55, 40);
    add("liver", "Liver").ellipse(360, 80, 55, 40);
    add("gallbladder", "Gallbladder").ellipse(490, 80, 55, 40);
    add("pancreas", "Pancreas").ellipse(100, 190, 55, 40);
    add("duodenum", "Duodenum").ellipse(230, 190, 55, 40);
    add("small_intestine", "Small Intestine").ellipse(360, 190, 55, 40);
    add("cecum", "Cecum").ellipse(490, 190, 55, 40);
    add("appendix", "Appendix").ellipse(100, 300, 55, 40);
    add("ascending_colon", "Ascending Colon").ellipse(230, 300, 55, 40);
    add("transverse_colon", "Transverse Colon").ellipse(360, 300, 55, 40);
    add("descending_colon", "Descending Colon").ellipse(490, 300, 55, 40);
    add("sigmoid_colon", "Sigmoid Colon").ellipse(100, 410, 55, 40);
    add("rectum", "Rectum").ellipse(230, 410, 55, 40);
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
    g.ellipse(230, 410, 110, 80);
  }
}
