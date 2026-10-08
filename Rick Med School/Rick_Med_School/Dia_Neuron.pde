// PLACEHOLDER - replaced by the real artwork.

class NeuronDiagram extends Diagram {
  NeuronDiagram() {
    super("neuron", "Neuron");
    add("dendrite", "Dendrite").ellipse(100, 80, 55, 40);
    add("soma", "Soma").ellipse(230, 80, 55, 40);
    add("nucleus", "Nucleus").ellipse(360, 80, 55, 40);
    add("axon_hillock", "Axon Hillock").ellipse(490, 80, 55, 40);
    add("axon", "Axon").ellipse(100, 190, 55, 40);
    add("myelin_sheath", "Myelin Sheath").ellipse(230, 190, 55, 40);
    add("node_of_ranvier", "Node Of Ranvier").ellipse(360, 190, 55, 40);
    add("axon_terminal", "Axon Terminal").ellipse(490, 190, 55, 40);
    add("synapse", "Synapse").ellipse(100, 300, 55, 40);
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
  }
}
