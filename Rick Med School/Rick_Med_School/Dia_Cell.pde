// PLACEHOLDER - replaced by the real artwork.

class CellDiagram extends Diagram {
  CellDiagram() {
    super("cell", "Animal Cell");
    add("cell_membrane", "Cell Membrane").ellipse(100, 80, 55, 40);
    add("cytoplasm", "Cytoplasm").ellipse(230, 80, 55, 40);
    add("nucleus", "Nucleus").ellipse(360, 80, 55, 40);
    add("nucleolus", "Nucleolus").ellipse(490, 80, 55, 40);
    add("mitochondrion", "Mitochondrion").ellipse(100, 190, 55, 40);
    add("rough_er", "Rough Er").ellipse(230, 190, 55, 40);
    add("smooth_er", "Smooth Er").ellipse(360, 190, 55, 40);
    add("golgi", "Golgi").ellipse(490, 190, 55, 40);
    add("ribosome", "Ribosome").ellipse(100, 300, 55, 40);
    add("lysosome", "Lysosome").ellipse(230, 300, 55, 40);
    add("centrosome", "Centrosome").ellipse(360, 300, 55, 40);
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
