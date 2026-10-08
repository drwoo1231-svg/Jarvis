// PLACEHOLDER - replaced by the real artwork.

class HeartDiagram extends Diagram {
  HeartDiagram() {
    super("heart", "Heart (front view)");
    add("right_atrium", "Right Atrium").ellipse(100, 80, 55, 40);
    add("right_ventricle", "Right Ventricle").ellipse(230, 80, 55, 40);
    add("left_atrium", "Left Atrium").ellipse(360, 80, 55, 40);
    add("left_ventricle", "Left Ventricle").ellipse(490, 80, 55, 40);
    add("superior_vena_cava", "Superior Vena Cava").ellipse(100, 190, 55, 40);
    add("inferior_vena_cava", "Inferior Vena Cava").ellipse(230, 190, 55, 40);
    add("aorta", "Aorta").ellipse(360, 190, 55, 40);
    add("pulmonary_trunk", "Pulmonary Trunk").ellipse(490, 190, 55, 40);
    add("pulmonary_veins", "Pulmonary Veins").ellipse(100, 300, 55, 40);
    add("tricuspid_valve", "Tricuspid Valve").ellipse(230, 300, 55, 40);
    add("pulmonary_valve", "Pulmonary Valve").ellipse(360, 300, 55, 40);
    add("mitral_valve", "Mitral Valve").ellipse(490, 300, 55, 40);
    add("aortic_valve", "Aortic Valve").ellipse(100, 410, 55, 40);
    add("interventricular_septum", "Interventricular Septum").ellipse(230, 410, 55, 40);
    add("sa_node", "Sa Node").ellipse(360, 410, 55, 40);
    add("av_node", "Av Node").ellipse(490, 410, 55, 40);
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
