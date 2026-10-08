// The look of a portal: a 3D whirlpool of glowing green liquid.
//
//  * a real displaced mesh: a raised donut of liquid with spiral ridges
//    pouring down into a dark eye, wobbling rim, ripples when things pass
//  * per-pixel shading (GLSL): normals from the same height function,
//    glossy highlights that move as you move, fresnel rim light, and two
//    parallax layers "under" the surface so you look down into the vortex
//  * a glossy liquid rim tube and droplets flung off the edge
//
// The shader is written to a temp file at startup (so the sketch still needs
// no data folder) and loaded with loadShader(), which lets Processing adapt
// it to the GPU (macOS core profile included). If it can't compile, the same
// surface is shaded on the CPU instead.

PShader liquidShader;

final float LQ_BOWL = 34, LQ_RIDGE = 6.5, LQ_WOB = 2.5;
final int LQ_RINGS = 26, LQ_SEG = 88;

String[] LIQUID_VERT = {
  "#define PROCESSING_TEXTURE_SHADER",
  "uniform mat4 transformMatrix;",
  "attribute vec4 position;",
  "attribute vec2 texCoord;",
  "varying vec2 vQ;",
  "void main() {",
  "  vQ = texCoord;",
  "  gl_Position = transformMatrix * position;",
  "}"
};

String[] LIQUID_FRAG = {
  "#ifdef GL_ES",
  "precision highp float;",
  "precision mediump int;",
  "#endif",
  "#define PROCESSING_TEXTURE_SHADER",
  "varying vec2 vQ;",
  "uniform float time;",
  "uniform float open;",
  "uniform vec3 camLocal;",
  "uniform vec3 colA;",
  "uniform vec3 colB;",
  "uniform vec3 colC;",
  "uniform vec2 halfSize;",
  "uniform float ripR;",
  "uniform float ripA;",
  "float sstep(float e0, float e1, float x) { float t = clamp((x - e0) / (e1 - e0), 0.0, 1.0); return t * t * (3.0 - 2.0 * t); }",
  "float rimWob(float th) { return 1.0 + 0.03 * sin(5.0 * th + 2.0 * time) + 0.02 * sin(9.0 * th - 3.0 * time); }",
  "float hgt(vec2 q) {",
  "  float r = length(q);",
  "  float th = atan(q.y, q.x);",
  "  float ph = 3.0 * th + 7.0 * log(r + 0.08) + time * 2.6;",
  "  float bowl = 34.0 * sstep(0.0, 0.55, r) * pow(max(1.0 - r * r, 0.0), 0.6);",
  "  float ridge = 6.5 * sin(ph) * sstep(0.06, 0.35, r) * (1.0 - r);",
  "  float wob = 2.5 * sin(5.0 * q.x + 1.3 * time + sin(4.0 * q.y + time)) * sin(5.0 * q.y - 1.1 * time) * (1.0 - r);",
  "  float dr = (r - ripR) * 6.0;",
  "  float rip = ripA * sin(30.0 * (r - ripR)) * exp(-dr * dr);",
  "  return (bowl + ridge + wob + rip) * open + 2.0;",
  "}",
  "void main() {",
  "  float th = atan(vQ.y, vQ.x);",
  "  vec2 q = vQ / rimWob(th);",
  "  float r = length(q);",
  "  if (r > 1.02) discard;",
  "  float e = 0.004;",
  "  float h0 = hgt(q);",
  "  float hx = (hgt(q + vec2(e, 0.0)) - hgt(q - vec2(e, 0.0))) / (2.0 * e * halfSize.x);",
  "  float hy = (hgt(q + vec2(0.0, e)) - hgt(q - vec2(0.0, e))) / (2.0 * e * halfSize.y);",
  "  vec3 N = normalize(vec3(-hx, -hy, 1.0));",
  "  vec3 P = vec3(vQ * halfSize, h0);",
  "  vec3 V = normalize(camLocal - P);",
  "  float ph = 3.0 * th + 7.0 * log(r + 0.08) + time * 2.6;",
  "  float bands = 0.5 + 0.5 * sin(ph);",
  "  float streak = pow(0.5 + 0.5 * sin(ph * 3.0 + r * 18.0 - time * 4.0), 10.0);",
  "  vec3 base = mix(colC, colA, 0.25 + 0.75 * bands);",
  "  base += colB * streak * 0.5 * sstep(0.1, 0.5, r);",
  "  vec2 par = V.xy / max(V.z, 0.3);",
  "  for (int i = 0; i < 2; i++) {",
  "    float fi = float(i);",
  "    vec2 qi = q - par * (18.0 + 30.0 * fi) / halfSize;",
  "    float ri = length(qi);",
  "    float ti = atan(qi.y, qi.x);",
  "    float pk = 3.0 * ti + 6.0 * log(ri + 0.08) + time * (3.6 + 1.5 * fi);",
  "    float li = pow(0.5 + 0.5 * sin(pk), 3.0) * sstep(0.6, 0.0, ri);",
  "    base += colB * li * (0.45 - 0.15 * fi) * (1.0 - sstep(0.15, 0.7, r));",
  "  }",
  "  float eye = exp(-r * r / 0.0035);",
  "  float throat = sstep(0.3, 0.04, r);",
  "  base = mix(base, colC * 0.25, throat * 0.7);",
  "  float er = (r - 0.07) * 28.0;",
  "  base += colB * exp(-er * er) * 0.7;",
  "  vec3 L1 = normalize(vec3(-0.35, 0.55, 0.75));",
  "  vec3 L2 = normalize(vec3(0.6, -0.4, 0.6));",
  "  float diff = max(dot(N, L1), 0.0);",
  "  float spec = pow(max(dot(N, normalize(L1 + V)), 0.0), 90.0);",
  "  float spec2 = pow(max(dot(N, normalize(L2 + V)), 0.0), 40.0);",
  "  float fres = pow(1.0 - max(dot(N, V), 0.0), 3.0);",
  "  vec3 col = base * (0.5 + 0.6 * diff);",
  "  col += vec3(1.0) * spec * 1.1 + colB * spec2 * 0.35 + colB * fres * 0.8;",
  "  col += colB * eye * 1.3;",
  "  col *= 0.9 + 0.1 * sin(time * 5.0);",
  "  float alpha = sstep(1.02, 0.97, r);",
  "  gl_FragColor = vec4(col, alpha);",
  "}"
};

void setupLiquidShader() {
  try {
    java.io.File v = java.io.File.createTempFile("portal_liquid_vert", ".glsl");
    java.io.File f = java.io.File.createTempFile("portal_liquid_frag", ".glsl");
    v.deleteOnExit();
    f.deleteOnExit();
    saveStrings(v.getAbsolutePath(), LIQUID_VERT);
    saveStrings(f.getAbsolutePath(), LIQUID_FRAG);
    liquidShader = loadShader(f.getAbsolutePath(), v.getAbsolutePath());
    liquidShader.init();            // compile now so a failure is caught here
  } catch (Exception e) {
    println("Liquid portal shader not available (" + e.getMessage() + ") - shading portals on the CPU.");
    liquidShader = null;
  }
}

// ---------------------------------------------------------------- shared math (matches the GLSL)
float lqStep(float e0, float e1, float x) {
  float t = constrain((x - e0) / (e1 - e0), 0, 1);
  return t * t * (3 - 2 * t);
}

float lqRimWob(float th, float t) {
  return 1 + 0.03 * sin(5 * th + 2 * t) + 0.02 * sin(9 * th - 3 * t);
}

float lqHeight(float qx, float qy, float t, float open, float ripR, float ripA) {
  float r = sqrt(qx * qx + qy * qy);
  float th = atan2(qy, qx);
  float ph = 3 * th + 7 * log(r + 0.08) + t * 2.6;
  float bowl = LQ_BOWL * lqStep(0, 0.55, r) * pow(max(1 - r * r, 0), 0.6);
  float ridge = LQ_RIDGE * sin(ph) * lqStep(0.06, 0.35, r) * (1 - r);
  float wob = LQ_WOB * sin(5 * qx + 1.3 * t + sin(4 * qy + t)) * sin(5 * qy - 1.1 * t) * (1 - r);
  float dr = (r - ripR) * 6;
  float rip = ripA * sin(30 * (r - ripR)) * exp(-dr * dr);
  return (bowl + ridge + wob + rip) * open + 2;
}

// ---------------------------------------------------------------- one portal's liquid
class LiquidSurface {
  float[][] px = new float[LQ_RINGS + 1][LQ_SEG + 1];
  float[][] py = new float[LQ_RINGS + 1][LQ_SEG + 1];
  float[][] pz = new float[LQ_RINGS + 1][LQ_SEG + 1];
  float[][] qu = new float[LQ_RINGS + 1][LQ_SEG + 1];
  float[][] qv = new float[LQ_RINGS + 1][LQ_SEG + 1];
  float[] rimX = new float[LQ_SEG + 1], rimY = new float[LQ_SEG + 1];

  // rebuild the height field for this frame
  void build(float t, float open, float ripR, float ripA) {
    for (int j = 0; j <= LQ_SEG; j++) {
      float th = TWO_PI * j / LQ_SEG;
      float w = lqRimWob(th, t);
      float ct = cos(th), st = sin(th);
      for (int i = 0; i <= LQ_RINGS; i++) {
        float rr = pow(i / (float) LQ_RINGS, 0.85);
        float qx = ct * rr, qy = st * rr;
        qu[i][j] = qx * w;
        qv[i][j] = qy * w;
        px[i][j] = qx * w * PORTAL_HW;
        py[i][j] = qy * w * PORTAL_HH;
        pz[i][j] = lqHeight(qx, qy, t, open, ripR, ripA);
      }
      rimX[j] = ct * w * PORTAL_HW;
      rimY[j] = st * w * PORTAL_HH;
    }
  }

  // GPU path: positions + (q.x, q.y) in the texture channel; the shader does the rest
  void drawGPU() {
    noStroke();
    for (int i = 0; i < LQ_RINGS; i++) {
      beginShape(TRIANGLE_STRIP);
      texture(texGlow);           // any texture: it just routes q through texCoord
      for (int j = 0; j <= LQ_SEG; j++) {
        vertex(px[i + 1][j], py[i + 1][j], pz[i + 1][j], qu[i + 1][j], qv[i + 1][j]);
        vertex(px[i][j], py[i][j], pz[i][j], qu[i][j], qv[i][j]);
      }
      endShape();
    }
  }

  // CPU path: the same look, lit per vertex
  void drawCPU(Portal p, PVector camL, float t) {
    noStroke();
    for (int i = 0; i < LQ_RINGS; i++) {
      beginShape(TRIANGLE_STRIP);
      for (int j = 0; j <= LQ_SEG; j++) {
        cpuVertex(p, camL, t, i + 1, j);
        cpuVertex(p, camL, t, i, j);
      }
      endShape();
    }
  }

  void cpuVertex(Portal p, PVector camL, float t, int i, int j) {
    int jp = j == LQ_SEG ? 1 : j + 1, jm = j == 0 ? LQ_SEG - 1 : j - 1;
    int ip = min(i + 1, LQ_RINGS), im = max(i - 1, 0);
    PVector a = new PVector(px[i][jp] - px[i][jm], py[i][jp] - py[i][jm], pz[i][jp] - pz[i][jm]);
    PVector b = new PVector(px[ip][j] - px[im][j], py[ip][j] - py[im][j], pz[ip][j] - pz[im][j]);
    PVector nrm = b.cross(a);
    if (nrm.z < 0) nrm.mult(-1);
    if (nrm.magSq() < 1e-6) nrm.set(0, 0, 1);
    nrm.normalize();
    PVector v = new PVector(camL.x - px[i][j], camL.y - py[i][j], camL.z - pz[i][j]).normalize();
    float r = i / (float) LQ_RINGS;
    float th = TWO_PI * j / LQ_SEG;
    float ph = 3 * th + 7 * log(r + 0.08) + t * 2.6;
    float bands = 0.5 + 0.5 * sin(ph);
    PVector L1 = new PVector(-0.35, 0.55, 0.75).normalize();
    float diff = max(nrm.dot(L1), 0);
    float spec = pow(max(nrm.dot(PVector.add(L1, v).normalize()), 0), 40);
    float fres = pow(1 - max(nrm.dot(v), 0), 3);
    float eye = exp(-r * r / 0.0035);
    float k = 0.5 + 0.6 * diff;
    float dark = lqStep(0.3, 0.04, r) * 0.7;
    float cr = lerp(red(p.colDark), red(p.col), 0.25 + 0.75 * bands) * (1 - dark) + red(p.colDark) * 0.35 * dark;
    float cg = lerp(green(p.colDark), green(p.col), 0.25 + 0.75 * bands) * (1 - dark) + green(p.colDark) * 0.35 * dark;
    float cb = lerp(blue(p.colDark), blue(p.col), 0.25 + 0.75 * bands) * (1 - dark) + blue(p.colDark) * 0.35 * dark;
    fill(cr * k + 255 * spec + red(p.colLight) * (fres * 0.8 + eye * 1.3),
         cg * k + 255 * spec + green(p.colLight) * (fres * 0.8 + eye * 1.3),
         cb * k + 255 * spec + blue(p.colLight) * (fres * 0.8 + eye * 1.3));
    vertex(px[i][j], py[i][j], pz[i][j]);
  }

  // glossy tube of liquid running round the edge
  void drawRim(Portal p, PVector camL, float t, float open) {
    final int SIDES = 9;
    float tube = 8.5 * open;
    PVector L1 = new PVector(-0.35, 0.55, 0.75).normalize();
    noStroke();
    for (int k = 0; k < SIDES; k++) {
      float f0 = TWO_PI * k / SIDES, f1 = TWO_PI * (k + 1) / SIDES;
      beginShape(QUAD_STRIP);
      for (int j = 0; j <= LQ_SEG; j++) {
        float th = TWO_PI * j / LQ_SEG;
        PVector out = new PVector(cos(th) * PORTAL_HH, sin(th) * PORTAL_HW, 0).normalize();   // ellipse outward normal
        float flow = 0.5 + 0.5 * sin(th * 6 - t * 7);
        for (int s = 0; s < 2; s++) {
          float f = s == 0 ? f0 : f1;
          PVector nrm = new PVector(out.x * cos(f), out.y * cos(f), sin(f));
          float x = rimX[j] + nrm.x * tube, y = rimY[j] + nrm.y * tube, z = 4 + nrm.z * tube;
          PVector v = new PVector(camL.x - x, camL.y - y, camL.z - z).normalize();
          float diff = max(nrm.dot(L1), 0);
          float spec = pow(max(nrm.dot(PVector.add(L1, v).normalize()), 0), 50);
          float fres = pow(1 - max(nrm.dot(v), 0), 2.5);
          float kk = 0.45 + 0.6 * diff + 0.25 * flow;
          fill(red(p.col) * kk + 255 * spec + red(p.colLight) * fres * 0.6,
               green(p.col) * kk + 255 * spec + green(p.colLight) * fres * 0.6,
               blue(p.col) * kk + 255 * spec + blue(p.colLight) * fres * 0.6);
          vertex(x, y, z);
        }
      }
      endShape();
    }
  }
}
