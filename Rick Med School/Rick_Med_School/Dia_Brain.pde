// PLACEHOLDER - replaced by the real artwork.

class BrainDiagram extends Diagram {
  BrainDiagram() {
    super("brain", "Brain (left side)");
    add("frontal_lobe", "Frontal Lobe").ellipse(100, 80, 55, 40);
    add("parietal_lobe", "Parietal Lobe").ellipse(230, 80, 55, 40);
    add("temporal_lobe", "Temporal Lobe").ellipse(360, 80, 55, 40);
    add("occipital_lobe", "Occipital Lobe").ellipse(490, 80, 55, 40);
    add("cerebellum", "Cerebellum").ellipse(100, 190, 55, 40);
    add("pons", "Pons").ellipse(230, 190, 55, 40);
    add("medulla", "Medulla").ellipse(360, 190, 55, 40);
    add("spinal_cord", "Spinal Cord").ellipse(490, 190, 55, 40);
    add("central_sulcus", "Central Sulcus").ellipse(100, 300, 55, 40);
    add("lateral_sulcus", "Lateral Sulcus").ellipse(230, 300, 55, 40);
    add("precentral_gyrus", "Precentral Gyrus").ellipse(360, 300, 55, 40);
    add("postcentral_gyrus", "Postcentral Gyrus").ellipse(490, 300, 55, 40);
    add("broca_area", "Broca Area").ellipse(100, 410, 55, 40);
    add("wernicke_area", "Wernicke Area").ellipse(230, 410, 55, 40);
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
