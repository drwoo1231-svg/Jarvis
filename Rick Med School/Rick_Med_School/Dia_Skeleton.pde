// PLACEHOLDER - replaced by the real artwork.

class SkeletonDiagram extends Diagram {
  SkeletonDiagram() {
    super("skeleton", "Human Skeleton (front)");
    add("skull", "Skull").ellipse(100, 80, 55, 40);
    add("mandible", "Mandible").ellipse(230, 80, 55, 40);
    add("clavicle", "Clavicle").ellipse(360, 80, 55, 40);
    add("scapula", "Scapula").ellipse(490, 80, 55, 40);
    add("sternum", "Sternum").ellipse(100, 190, 55, 40);
    add("ribs", "Ribs").ellipse(230, 190, 55, 40);
    add("humerus", "Humerus").ellipse(360, 190, 55, 40);
    add("radius", "Radius").ellipse(490, 190, 55, 40);
    add("ulna", "Ulna").ellipse(100, 300, 55, 40);
    add("carpals", "Carpals").ellipse(230, 300, 55, 40);
    add("metacarpals", "Metacarpals").ellipse(360, 300, 55, 40);
    add("phalanges_hand", "Phalanges Hand").ellipse(490, 300, 55, 40);
    add("vertebral_column", "Vertebral Column").ellipse(100, 410, 55, 40);
    add("pelvis", "Pelvis").ellipse(230, 410, 55, 40);
    add("sacrum", "Sacrum").ellipse(360, 410, 55, 40);
    add("femur", "Femur").ellipse(490, 410, 55, 40);
    add("patella", "Patella").ellipse(100, 520, 55, 40);
    add("tibia", "Tibia").ellipse(230, 520, 55, 40);
    add("fibula", "Fibula").ellipse(360, 520, 55, 40);
    add("tarsals", "Tarsals").ellipse(490, 520, 55, 40);
    add("metatarsals", "Metatarsals").ellipse(100, 630, 55, 40);
    add("phalanges_foot", "Phalanges Foot").ellipse(230, 630, 55, 40);
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
    g.ellipse(100, 520, 110, 80);
    g.ellipse(230, 520, 110, 80);
    g.ellipse(360, 520, 110, 80);
    g.ellipse(490, 520, 110, 80);
    g.ellipse(100, 630, 110, 80);
    g.ellipse(230, 630, 110, 80);
  }
}
