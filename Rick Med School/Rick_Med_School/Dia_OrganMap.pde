// PLACEHOLDER - replaced by the real artwork.

class OrganMapDiagram extends Diagram {
  OrganMapDiagram() {
    super("organ_map", "Organ Map");
    add("brain", "Brain").ellipse(100, 80, 55, 40);
    add("pituitary", "Pituitary").ellipse(230, 80, 55, 40);
    add("thyroid", "Thyroid").ellipse(360, 80, 55, 40);
    add("thymus", "Thymus").ellipse(490, 80, 55, 40);
    add("heart", "Heart").ellipse(100, 190, 55, 40);
    add("lungs", "Lungs").ellipse(230, 190, 55, 40);
    add("liver", "Liver").ellipse(360, 190, 55, 40);
    add("stomach", "Stomach").ellipse(490, 190, 55, 40);
    add("spleen", "Spleen").ellipse(100, 300, 55, 40);
    add("pancreas", "Pancreas").ellipse(230, 300, 55, 40);
    add("adrenal_glands", "Adrenal Glands").ellipse(360, 300, 55, 40);
    add("kidneys", "Kidneys").ellipse(490, 300, 55, 40);
    add("small_intestine", "Small Intestine").ellipse(100, 410, 55, 40);
    add("large_intestine", "Large Intestine").ellipse(230, 410, 55, 40);
    add("bladder", "Bladder").ellipse(360, 410, 55, 40);
    add("lymph_nodes", "Lymph Nodes").ellipse(490, 410, 55, 40);
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
    g.ellipse(360, 410, 110, 80);
    g.ellipse(490, 410, 110, 80);
  }
}
