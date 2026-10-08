// Procedurally generated textures - the sketch needs no data folder.

PImage texFloor, texPanel, texMetal, texHazard, texGlow, texRing;

void makeTextures() {
  texFloor = makePlate(256, color(92, 99, 112), true);
  texPanel = makePanel(256);
  texMetal = makePlate(256, color(58, 62, 74), false);
  texHazard = makeHazard(128);
  texGlow = makeGlowTex(64);
  texRing = makeRingTex(128);
}

// metal floor plate: seams, bolts, diamond tread, brushed noise
PImage makePlate(int s, int base, boolean tread) {
  PImage img = createImage(s, s, RGB);
  img.loadPixels();
  float br = red(base), bg = green(base), bb = blue(base);
  for (int y = 0; y < s; y++) {
    for (int x = 0; x < s; x++) {
      float k = 1 + (noise(x * 0.6, y * 0.02) - 0.5) * 0.18 + random(-0.03, 0.03);
      int cx = x % (s / 2), cy = y % (s / 2);
      if (tread) {
        int dx = (x + (y / 16) % 2 * 8) % 16, dy = y % 16;
        if (abs(dx - 8) + abs(dy - 8) < 4) k += 0.16;
      } else {
        if (x % 32 == 0) k -= 0.05;
      }
      if (cx < 3 || cy < 3) k *= 0.55;                  // seams
      if (cx == 3 || cy == 3) k *= 1.25;                // bevel highlight
      float bx = abs(cx - 14), by = abs(cy - 14);       // bolts
      if (bx * bx + by * by < 9) k *= 1.35;
      img.pixels[y * s + x] = color(br * k, bg * k, bb * k);
    }
  }
  img.updatePixels();
  return img;
}

// light test-chamber panel (portals stick to these)
PImage makePanel(int s) {
  PImage img = createImage(s, s, RGB);
  img.loadPixels();
  for (int y = 0; y < s; y++) {
    for (int x = 0; x < s; x++) {
      int cx = x % s, cy = y % (s / 2);
      float k = 0.9 + (noise(x * 0.05, y * 0.05) - 0.5) * 0.1 + random(-0.015, 0.015);
      if (cx < 3 || cy < 3) k = 0.32;                                   // deep seams
      else if (cx < 7 || cy < 7) k *= 1.08;                             // bevel
      else if (cx > s - 7 || cy > s / 2 - 7) k *= 0.82;
      if (cy > 40 && cy < 44 && cx > 20 && cx < s - 20) k *= 0.86;      // inset line
      boolean light = cx > s / 2 - 20 && cx < s / 2 + 20 && cy > s / 4 - 3 && cy < s / 4 + 3;
      if (light) { img.pixels[y * s + x] = color(140, 255, 210); continue; }
      img.pixels[y * s + x] = color(186 * k, 194 * k, 206 * k);
    }
  }
  img.updatePixels();
  return img;
}

PImage makeHazard(int s) {
  PImage img = createImage(s, s, RGB);
  img.loadPixels();
  for (int y = 0; y < s; y++) {
    for (int x = 0; x < s; x++) {
      boolean yellow = ((x + y) / (s / 4)) % 2 == 0;
      float k = 0.9 + random(0.1);
      img.pixels[y * s + x] = yellow ? color(235 * k, 190 * k, 20 * k) : color(28 * k, 26 * k, 30 * k);
    }
  }
  img.updatePixels();
  return img;
}

// soft round glow, white with alpha
PImage makeGlowTex(int s) {
  PImage img = createImage(s, s, ARGB);
  img.loadPixels();
  for (int y = 0; y < s; y++) {
    for (int x = 0; x < s; x++) {
      float d = dist(x + 0.5, y + 0.5, s / 2.0, s / 2.0) / (s / 2.0);
      float a = pow(max(0, 1 - d), 2.0);
      img.pixels[y * s + x] = color(255, 255 * a);
    }
  }
  img.updatePixels();
  return img;
}

// thin bright ring (for shockwaves)
PImage makeRingTex(int s) {
  PImage img = createImage(s, s, ARGB);
  img.loadPixels();
  for (int y = 0; y < s; y++) {
    for (int x = 0; x < s; x++) {
      float d = dist(x + 0.5, y + 0.5, s / 2.0, s / 2.0) / (s / 2.0);
      float a = exp(-sq((d - 0.85) * 12));
      img.pixels[y * s + x] = color(255, 255 * a);
    }
  }
  img.updatePixels();
  return img;
}

// text sign rendered once into an image, drawn additively (black = invisible)
PImage makeSign(String title, String sub, int c) {
  PGraphics g = createGraphics(512, sub == null ? 96 : 140);
  g.beginDraw();
  g.background(0);
  g.textFont(createFont("SansSerif.bold", 40, true));
  g.textAlign(CENTER, CENTER);
  for (int i = 4; i >= 1; i--) {               // soft glow
    g.fill(red(c), green(c), blue(c), 40);
    g.textSize(40 + i * 0.8);
    g.text(title, g.width / 2, 46);
  }
  g.textSize(40);
  g.fill(255);
  g.text(title, g.width / 2, 46);
  g.fill(c);
  g.text(title, g.width / 2, 46);
  if (sub != null) {
    g.textFont(createFont("Monospaced.bold", 22, true));
    g.fill(red(c) * 0.8, green(c) * 0.8, blue(c) * 0.8);
    g.text(sub, g.width / 2, 106);
  }
  g.noFill();
  g.stroke(c);
  g.strokeWeight(3);
  g.rect(6, 6, g.width - 12, g.height - 12, 14);
  g.endDraw();
  return g.get();
}

// camera-facing glow sprite (call inside the glow pass)
void glowSprite(float x, float y, float z, float size, int c, float a) {
  PVector r = PVector.mult(cam.right, size * 0.5), u = PVector.mult(cam.up, size * 0.5);
  noStroke();
  tint(red(c), green(c), blue(c), a);
  beginShape(QUADS);
  texture(texGlow);
  vertex(x - r.x - u.x, y - r.y - u.y, z - r.z - u.z, 0, 0);
  vertex(x + r.x - u.x, y + r.y - u.y, z + r.z - u.z, 1, 0);
  vertex(x + r.x + u.x, y + r.y + u.y, z + r.z + u.z, 1, 1);
  vertex(x - r.x + u.x, y - r.y + u.y, z - r.z + u.z, 0, 1);
  endShape();
  noTint();
}
