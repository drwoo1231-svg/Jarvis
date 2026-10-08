// Anatomy diagrams: procedural artwork + clickable parts.
//
// Every diagram lives in its own DIA x DIA box (600 x 600 "diagram units",
// origin top-left, y down). drawArt() paints the artwork once into a cached
// image. Parts are polygons in the same units: they are what the mouse hits
// and what lights up (hover / correct / wrong / lesson highlight).
// Parts added LATER sit ON TOP: add containers first, small details last.

final float DIA = 600;

// shared palette for a consistent textbook-cartoon look on a light panel
final int D_INK = #1E1C28;          // outlines
final int D_BONE = #F1E6CC, D_BONE_SH = #D3BF96;
final int D_MUSCLE = #C9544B, D_MUSCLE_LT = #E68579, D_TENDON = #EDE3D0;
final int D_SKIN = #F2D2B6, D_SKIN_SH = #D9AE8C;
final int D_ARTERY = #D63A3A, D_VEIN = #3F6FD1, D_HEART = #C7343E;
final int D_NERVE = #F2C94C, D_MYELIN = #F6E7B0;
final int D_LIVER = #8E3B2E, D_STOMACH = #E89A97, D_GUT = #F0B19D, D_COLON = #D98C6F;
final int D_LUNG = #F09CAA, D_KIDNEY = #A3473C, D_GLAND = #9B7FD1, D_LYMPH = #6CC08A;
final int D_CYTO = #CFE8F2, D_NUCLEUS = #8E7CC3, D_MITO = #F08A5D, D_ER = #6FB3D9, D_GOLGI = #F2B84B;
final int D_BRAIN = #F2B6B9, D_BRAIN_SH = #D98F97;

HashMap<String, Diagram> DIAGRAMS = new HashMap<String, Diagram>();
final String[] DIAGRAM_ORDER = { "cell", "skeleton", "muscles", "neuron", "brain", "heart", "lungs", "digestive", "nephron", "organ_map" };

void registerDiagrams() {
  addDiagram(new CellDiagram());
  addDiagram(new SkeletonDiagram());
  addDiagram(new MusclesDiagram());
  addDiagram(new NeuronDiagram());
  addDiagram(new BrainDiagram());
  addDiagram(new HeartDiagram());
  addDiagram(new LungsDiagram());
  addDiagram(new DigestiveDiagram());
  addDiagram(new NephronDiagram());
  addDiagram(new OrganMapDiagram());
}

void addDiagram(Diagram d) {
  DIAGRAMS.put(d.id, d);
}

Diagram diagram(String id) {
  return DIAGRAMS.get(id);
}

// ---------------------------------------------------------------- one clickable part
class Part {
  String id, name;
  ArrayList<float[]> shapes = new ArrayList<float[]>();   // polygons: x0, y0, x1, y1, ... in diagram units
  float ax = -1, ay = -1;                                 // where a label's leader line points

  Part(String id, String name) {
    this.id = id;
    this.name = name;
  }

  Part poly(float... xy) {
    shapes.add(xy);
    return this;
  }

  Part ellipse(float cx, float cy, float rx, float ry) {
    return poly(ellipsePts(cx, cy, rx, ry, 0, 28));
  }

  // ellipse rotated by angle (radians)
  Part ellipse(float cx, float cy, float rx, float ry, float angle) {
    return poly(ellipsePts(cx, cy, rx, ry, angle, 28));
  }

  Part rect(float x, float y, float w, float h) {
    return poly(x, y, x + w, y, x + w, y + h, x, y + h);
  }

  // a thick segment from (x0, y0) to (x1, y1), e.g. a long bone or a muscle belly
  Part bar(float x0, float y0, float x1, float y1, float thick) {
    float dx = x1 - x0, dy = y1 - y0, L = max(1e-3, sqrt(dx * dx + dy * dy));
    float nx = -dy / L * thick / 2, ny = dx / L * thick / 2;
    return poly(x0 + nx, y0 + ny, x1 + nx, y1 + ny, x1 - nx, y1 - ny, x0 - nx, y0 - ny);
  }

  Part anchor(float x, float y) {
    ax = x;
    ay = y;
    return this;
  }

  boolean contains(float x, float y) {
    for (float[] s : shapes) if (insidePoly(s, x, y)) return true;
    return false;
  }

  // label anchor: explicit, or the centre of the biggest shape
  float[] anchorPt() {
    if (ax >= 0) return new float[] { ax, ay };
    float best = -1, bx = 0, by = 0;
    for (float[] s : shapes) {
      float minx = 1e9, maxx = -1e9, miny = 1e9, maxy = -1e9;
      for (int i = 0; i < s.length; i += 2) {
        minx = min(minx, s[i]);
        maxx = max(maxx, s[i]);
        miny = min(miny, s[i + 1]);
        maxy = max(maxy, s[i + 1]);
      }
      float a = (maxx - minx) * (maxy - miny);
      if (a > best) {
        best = a;
        bx = (minx + maxx) / 2;
        by = (miny + maxy) / 2;
      }
    }
    return new float[] { bx, by };
  }
}

float[] ellipsePts(float cx, float cy, float rx, float ry, float ang, int n) {
  float[] p = new float[n * 2];
  float ca = cos(ang), sa = sin(ang);
  for (int i = 0; i < n; i++) {
    float t = TWO_PI * i / n;
    float x = cos(t) * rx, y = sin(t) * ry;
    p[i * 2] = cx + x * ca - y * sa;
    p[i * 2 + 1] = cy + x * sa + y * ca;
  }
  return p;
}

boolean insidePoly(float[] p, float x, float y) {
  boolean in = false;
  int n = p.length / 2;
  for (int i = 0, j = n - 1; i < n; j = i++) {
    float xi = p[i * 2], yi = p[i * 2 + 1], xj = p[j * 2], yj = p[j * 2 + 1];
    if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) in = !in;
  }
  return in;
}

// ---------------------------------------------------------------- a diagram
abstract class Diagram {
  String id, title;
  ArrayList<Part> parts = new ArrayList<Part>();
  PImage art, thumb;

  Diagram(String id, String title) {
    this.id = id;
    this.title = title;
  }

  Part add(String id, String name) {
    Part p = new Part(id, name);
    parts.add(p);
    return p;
  }

  Part part(String pid) {
    for (Part p : parts) if (p.id.equals(pid)) return p;
    return null;
  }

  // paint the artwork into g, in diagram units (0..DIA); g's background is transparent
  abstract void drawArt(PGraphics g);

  // the cached artwork (drawn once at high resolution)
  PImage art() {
    if (art == null) {
      int px = 1200;
      PGraphics g = createGraphics(px, px);
      g.beginDraw();
      g.clear();
      g.scale(px / DIA);
      g.strokeJoin(ROUND);
      g.strokeCap(ROUND);
      drawArt(g);
      g.endDraw();
      art = g;
    }
    return art;
  }

  PImage thumb() {
    if (thumb == null) {
      PImage a = art().copy();
      a.resize(160, 160);
      thumb = a;
    }
    return thumb;
  }

  // the top-most part under a point (diagram units)
  Part hit(float ux, float uy) {
    for (int i = parts.size() - 1; i >= 0; i--) if (parts.get(i).contains(ux, uy)) return parts.get(i);
    return null;
  }
}
