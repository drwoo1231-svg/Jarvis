// PORTAL LAB - single-file edition (generated from the tabbed sketch by
// tools/make_single_file.py). Paste this whole file into an empty Processing
// 4.5.6 sketch (Java mode) and press Run. No libraries, no data folder.

import javax.sound.sampled.*;

// ======================================================================
// TAB: Portal_Lab.pde
// ======================================================================
/*
  PORTAL LAB
  a Rick-and-Morty-inspired portal physics sandbox floating in deep space
  ---------------------------------------------------------------------
  Processing 4.5.6  -  Java mode  -  P3D.  No libraries, no data folder.

  WASD move   SPACE up   CTRL down   SHIFT fast   MOUSE look   ESC release mouse
  (click the window to capture the mouse; arrow keys also look around)

  World units are centimetres: 100 units = 1 metre. Processing's Y axis
  points DOWN, so "up" in this file is always negative Y.
*/

final float M = 100;              // units per metre

PlayerCamera cam;
Laboratory lab;
Galaxy galaxy;
Particles parts;
PortalPair portals;
PortalGun gun;
PortalManipulator manip;
ObjectLab objects;
PortalPhysics physics;
ResearchTerminal terminal;
RickDialogue rick;
HUD hud;
Sfx sfx;

int lastActionMs;                 // for Rick's idle timer (millis based)

float T;                          // seconds since start
float dt = 1 / 60.0;
int lastMs;

// held keys
boolean kW, kA, kS, kD, kUp, kDown, kDown2, kFast, kLookL, kLookR, kLookU, kLookD, kRotL, kRotR;

void settings() {
  size(1280, 720, P3D);
  smooth(4);
}

void setup() {
  frameRate(60);
  surface.setTitle("PORTAL LAB  -  click to look around, ESC to release the mouse");
  textureMode(NORMAL);
  textureWrap(REPEAT);
  makeTextures();
  setupLiquidShader();
  sfx = new Sfx();
  galaxy = new Galaxy();
  lab = new Laboratory();
  parts = new Particles();
  portals = new PortalPair();
  gun = new PortalGun();
  manip = new PortalManipulator();
  physics = new PortalPhysics();
  hud = new HUD();
  sphereDetail(12);
  objects = new ObjectLab();
  terminal = new ResearchTerminal();
  rick = new RickDialogue();
  cam = new PlayerCamera(0, -180, 1750);
  lastMs = millis();
}

void draw() {
  int now = millis();
  dt = constrain((now - lastMs) / 1000.0, 0.0005, 0.05);
  lastMs = now;
  T += dt;

  cam.update(dt);
  galaxy.update(dt);
  lab.update(dt);
  gun.update(dt);
  manip.update(dt);
  portals.update(dt);
  physics.update(dt);
  objects.update(dt);
  parts.update(dt);
  terminal.update(dt);
  hud.update(dt);
  if (windowAway) markAction();
  rick.update(dt);
  if (cam.movedThisFrame) markAction();

  // ---- 3D
  background(0);
  hint(ENABLE_DEPTH_TEST);
  cam.apply();
  galaxy.drawSky(cam.pos);
  lab.lightsOn();
  portals.lights();
  lab.drawSolid();
  objects.draw();
  galaxy.drawWorld();
  noLights();
  portals.drawSolid();
  beginGlowPass();
  lab.drawGlow();
  galaxy.drawDust();
  portals.drawGlow();
  objects.drawGlow();
  manip.drawGlow();
  terminal.drawGlow();
  rick.drawHologram();
  gun.draw();
  parts.draw();
  endGlowPass();
  hud.capturePortalTags();

  // ---- 2D overlay
  begin2D();
  hud.draw();
  rick.draw();
  end2D();
}

// additive, no depth writes: glows, holograms, particles
void beginGlowPass() {
  noLights();
  hint(DISABLE_DEPTH_MASK);
  blendMode(ADD);
}

void endGlowPass() {
  blendMode(BLEND);
  hint(ENABLE_DEPTH_MASK);
}

void begin2D() {
  hint(DISABLE_DEPTH_TEST);
  noLights();
  camera();
  perspective();
}

void end2D() {
  hint(ENABLE_DEPTH_TEST);
}

// ------------------------------------------------------------------ input
void keyPressed() {
  if (key == ESC) {
    key = 0;                        // don't quit the sketch, just free the mouse
    cam.capture(false);
    return;
  }
  setKey(true);
  char k = plainKey();
  if (k == 'e') interact();
  if (key == TAB) {
    hud.terminalOpen = !hud.terminalOpen;
    markAction();
    if (hud.terminalOpen) onTerminalOpened();
  }
  // F3 (NEWT reports it as code 99; 114 is the AWT code) - the ` key works too
  if ((key == CODED && (keyCode == 99 || keyCode == 114)) || key == '`') { hud.debug = !hud.debug; onDebugToggled(hud.debug); }
  if (k == 'h') hud.showControls = !hud.showControls;
  if (k == 'n' && hud.debug) { cam.noclip = !cam.noclip; onNoclipToggled(cam.noclip); }
  if (k == 'm') { sfx.muted = !sfx.muted; onMuteToggled(sfx.muted); }
  if (k == 'r' && !manip.active()) {
    if (objects.heldObj != null) markAction();
    objects.release();
  }
}

// E: grab the object you're looking at, select the portal you're looking at,
// or use the machine you're looking at
void interact() {
  markAction();
  if (manip.active()) {
    manip.confirm();
    return;
  }
  if (objects.heldObj != null) {
    objects.release();
    return;
  }
  ThrowableObject o = objects.pick(1200);
  Portal q = portals.rayPick(cam.pos, cam.fwd, 4000);
  float to = o != null ? PVector.dist(cam.pos, o.pos) : 1e9;
  float tq = q != null ? PVector.dist(cam.pos, q.c) : 1e9;
  if (o != null && to <= tq) {
    objects.grab(o);
    return;
  }
  if (q != null) {
    manip.select(q);
    return;
  }
  RayHit h = lab.raycast(cam.pos, cam.fwd, 900);
  if (h.hit() && h.box.name.equals("MATTER DISPENSER")) {
    objects.dispense();
    return;
  }
  hud.toast("NOTHING TO GRAB THERE", color(170, 190, 200));
}

void markAction() {
  lastActionMs = millis();
}

// seconds since you last did something useful (or Rick last complained)
float idleSeconds() {
  int since = max(lastActionMs, rick != null ? rick.lastIdleMs : 0);
  return (millis() - since) / 1000.0;
}

void keyReleased() {
  setKey(false);
}

// the key as a plain lower-case letter. While CTRL (our "down" key) is held, Windows and Linux deliver
// letters as control characters / CODED keys - but keyCode is still the plain key
char plainKey() {
  if (key == CODED || key < 32) {
    if (keyCode >= 'A' && keyCode <= 'Z') return (char) (keyCode + ('a' - 'A'));
    if (keyCode == ' ') return ' ';
  }
  return Character.toLowerCase(key);
}

void setKey(boolean down) {
  char k = plainKey();
  if (k == 'w') kW = down;
  if (k == 'a') kA = down;
  if (k == 's') kS = down;
  if (k == 'd') kD = down;
  if (k == ' ') kUp = down;
  if (k == 'c') kDown2 = down;                // C descends too (CTRL clashes with macOS shortcuts)
  if (k == 'q') kRotL = down && manip.active();
  if (k == 'r') kRotR = down && manip.active();
  if (down && (kRotL || kRotR)) markAction();
  if (key == CODED) {
    if (keyCode == CONTROL) kDown = down;
    if (keyCode == SHIFT) kFast = down;
    if (keyCode == LEFT) kLookL = down;
    if (keyCode == RIGHT) kLookR = down;
    if (keyCode == UP) kLookU = down;
    if (keyCode == DOWN) kLookD = down;
  }
}

void mousePressed() {
  if (!cam.captured) {
    cam.capture(true);
    return;
  }
  markAction();
  mouseButton = realButton();
  if (mouseButton == LEFT) {
    if (manip.active()) manip.confirm();
    else if (objects.heldObj != null) objects.throwHeld();
    else gun.fire();
  }
  if (mouseButton == RIGHT) {
    if (manip.active()) manip.cancel();
    else if (objects.heldObj != null) objects.release();
  }
}

// the physical button: on macOS Processing turns CTRL+left-click into RIGHT, but CTRL is our "down" key
int realButton() {
  Object n = mouseEvent != null ? mouseEvent.getNative() : null;
  if (n instanceof com.jogamp.newt.event.MouseEvent) {
    short b = ((com.jogamp.newt.event.MouseEvent) n).getButton();
    if (b == com.jogamp.newt.event.MouseEvent.BUTTON1) return LEFT;
    if (b == com.jogamp.newt.event.MouseEvent.BUTTON3) return RIGHT;
  }
  return mouseButton;
}

int lastWheelMs;
float wheelAcc;
boolean wheelPixels;
void mouseWheel(processing.event.MouseEvent e) {
  // notched wheels send +-1 per notch; macOS trackpads / Magic Mouse send pixel deltas (3-50) dozens of
  // times per swipe, momentum included - those step once per ~60 px of finger travel, not once per event
  int now = millis();
  int c = e.getCount();
  if (c == 0) return;
  boolean fresh = now - lastWheelMs > 180;        // first event of a new swipe / burst of notches
  if (fresh) {
    wheelAcc = 0;
    wheelPixels = false;
  }
  lastWheelMs = now;
  if (abs(c) >= 3) wheelPixels = true;
  float step = Math.signum(c);
  if (wheelPixels && !fresh) {
    wheelAcc += c;
    if (abs(wheelAcc) < 60) return;
    step = Math.signum(wheelAcc);
    wheelAcc = 0;
  }
  markAction();
  if (manip.active()) {
    manip.rotateStep(radians(15) * step);
  } else {
    objects.throwPower = constrain(objects.throwPower - step, 2, 40);
    hud.toast("THROW POWER " + i0(objects.throwPower) + " m/s", color(170, 255, 220));
  }
}

void mouseMoved() {
  cam.mouseMovedTo(mouseX, mouseY);
}

void mouseDragged() {
  cam.mouseMovedTo(mouseX, mouseY);
}

// while the window is in the background Rick doesn't count you as idle (and doesn't pop up every 20 s)
boolean windowAway;

void focusLost() {
  windowAway = true;
  kW = kA = kS = kD = kUp = kDown = kDown2 = kFast = kLookL = kLookR = kLookU = kLookD = kRotL = kRotR = false;
  if (cam != null) cam.capture(false);
}

void focusGained() {
  windowAway = false;
  markAction();
}


// ======================================================================
// TAB: Assets.pde
// ======================================================================
// Procedurally generated textures - the sketch needs no data folder.

PImage texFloor, texPanel, texMetal, texHazard, texGlow, texRing, texRingDash;

void makeTextures() {
  texFloor = makePlate(256, color(92, 99, 112), true);
  texPanel = makePanel(256);
  texMetal = makePlate(256, color(58, 62, 74), false);
  texHazard = makeHazard(128);
  texGlow = makeGlowTex(64);
  texRing = makeRingTex(128);
  texRingDash = makeDashRing(256);
}

// ring broken into dashes, so you can see it spin
PImage makeDashRing(int s) {
  PImage img = createImage(s, s, ARGB);
  img.loadPixels();
  for (int y = 0; y < s; y++) {
    for (int x = 0; x < s; x++) {
      float dx = x + 0.5 - s / 2.0, dy = y + 0.5 - s / 2.0;
      float d = sqrt(dx * dx + dy * dy) / (s / 2.0);
      float ang = atan2(dy, dx);
      float dash = 0.5 + 0.5 * sin(ang * 7);
      float a = exp(-sq((d - 0.86) * 22)) * (0.25 + 0.75 * smooth01((dash - 0.3) * 3));
      a += exp(-sq((d - 0.95) * 40)) * 0.5;
      img.pixels[y * s + x] = color(255, 255 * min(1, a));
    }
  }
  img.updatePixels();
  return img;
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
  // shrink long titles so they fit inside the frame
  float maxW = g.width - 40;
  g.textSize(40);
  float ts = min(40, 40 * maxW / max(1, g.textWidth(title)));
  for (int i = 4; i >= 1; i--) {               // soft glow
    g.fill(red(c), green(c), blue(c), 40);
    g.textSize(ts + i * 0.8);
    g.text(title, g.width / 2, 46);
  }
  g.textSize(ts);
  g.fill(255);
  g.text(title, g.width / 2, 46);
  g.fill(c);
  g.text(title, g.width / 2, 46);
  if (sub != null) {
    g.textFont(createFont("Monospaced.bold", 22, true));
    g.textSize(22);
    g.textSize(min(22, 22 * maxW / max(1, g.textWidth(sub))));
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


// ======================================================================
// TAB: Galaxy.pde
// ======================================================================
// The universe outside: a camera-centred sky (stars, galaxies, nebulae,
// planets) that never moves when you fly - only rotates when you look -
// plus world-space asteroids and cosmic dust that do give parallax.

class Galaxy {
  final float SKY = 45000;              // sky sphere radius (inside the far plane)
  PShape stars, dust;
  ArrayList<PVector> brightStars = new ArrayList<PVector>();
  PImage[] galTex = new PImage[3], nebTex = new PImage[6];
  ArrayList<SkyBill> bills = new ArrayList<SkyBill>();
  PShape[] planet = new PShape[3];
  PVector[] planetDir = new PVector[3];
  float[] planetSize = { 5200, 2600, 1500 };
  PImage ringTex;
  PVector sunDir = new PVector(0.55, -0.35, -0.75);
  PShape[] rockMesh = new PShape[3];
  PShape rockQuantum, rockSmall;      // the lab's own rocks (their colour is baked in)
  Rock[] rocks = new Rock[70];

  Galaxy() {
    sunDir.normalize();
    buildStars();
    for (int i = 0; i < 3; i++) galTex[i] = makeGalaxyTex(256, i);
    int[][][] pal = {
      { { 140, 40, 200 }, { 255, 90, 160 } }, { { 30, 90, 200 }, { 80, 230, 255 } }, { { 200, 50, 80 }, { 255, 170, 90 } },
      { { 20, 140, 120 }, { 120, 255, 200 } }, { { 90, 50, 220 }, { 170, 140, 255 } }, { { 180, 70, 30 }, { 255, 220, 140 } }
    };
    for (int i = 0; i < 6; i++) nebTex[i] = makeNebulaTex(256, i, pal[i][0], pal[i][1]);
    randomSeed(5);
    for (int i = 0; i < 12; i++) {
      PVector d = PVector.random3D();
      bills.add(new SkyBill(nebTex[i % 6], d, random(26000, 52000), random(TWO_PI), color(255), random(170, 255)));
    }
    // the milky band: a chain of soft clouds along a great circle
    PVector ba = new PVector(1, 0.35, 0.2).normalize(), bb = ba.cross(new PVector(0, 0, 1)).normalize();
    for (int i = 0; i < 16; i++) {
      float t = TWO_PI * i / 16 + random(-0.1, 0.1);
      PVector d = PVector.add(PVector.mult(ba, cos(t)), PVector.mult(bb, sin(t)));
      bills.add(new SkyBill(nebTex[i % 2 == 0 ? 1 : 4], d, random(20000, 30000), random(TWO_PI), color(200, 210, 255), random(90, 140)));
    }
    for (int i = 0; i < 10; i++) {
      PVector d = PVector.random3D();
      bills.add(new SkyBill(galTex[i % 3], d, random(4500, 11000), random(TWO_PI), color(255), random(190, 255)));
    }
    // one big spiral galaxy hanging near the horizon
    bills.add(new SkyBill(galTex[0], new PVector(-0.2, 0.05, 1).normalize(), 26000, 0.5, color(255), 255));
    for (int i = 0; i < 40; i++) brightStars.add(PVector.random3D());
    randomSeed(millis());
    planetDir[0] = new PVector(-0.75, -0.18, -0.65).normalize();
    planetDir[1] = new PVector(0.82, 0.25, 0.5).normalize();
    planetDir[2] = new PVector(0.3, -0.55, 0.78).normalize();
    for (int i = 0; i < 3; i++) {
      planet[i] = createShape(SPHERE, 1);
      planet[i].setStroke(false);
      planet[i].setTexture(makePlanetTex(256, 128, i));
    }
    ringTex = makeRingBands();
    for (int i = 0; i < 3; i++) rockMesh[i] = makeRock(i);
    rockQuantum = makeRock(1, color(120, 100, 150));
    rockSmall = makeRock(0, color(110, 100, 92));
    for (int i = 0; i < rocks.length; i++) rocks[i] = new Rock(i);
    buildDust();
  }

  void buildStars() {
    stars = createShape();
    stars.beginShape(POINTS);
    for (int i = 0; i < 3200; i++) {
      PVector d = PVector.random3D();
      float k = random(1);
      int c = k < 0.65 ? color(255) : k < 0.82 ? color(175, 200, 255) : k < 0.94 ? color(255, 225, 180) : color(255, 170, 170);
      float w = random(1) < 0.04 ? random(2.6, 3.6) : random(0.9, 2.2);
      stars.stroke(red(c), green(c), blue(c), random(120, 255));
      stars.strokeWeight(w);
      stars.vertex(d.x * SKY, d.y * SKY, d.z * SKY);
    }
    // a faint milky band along a tilted great circle
    PVector a = new PVector(1, 0.35, 0.2).normalize(), b = a.cross(new PVector(0, 0, 1)).normalize();
    for (int i = 0; i < 2600; i++) {
      float t = random(TWO_PI);
      PVector d = PVector.add(PVector.mult(a, cos(t)), PVector.mult(b, sin(t)));
      d.add(PVector.random3D().mult(randomGaussian() * 0.07)).normalize();
      stars.stroke(220, 225, 255, random(60, 170));
      stars.strokeWeight(random(0.8, 1.6));
      stars.vertex(d.x * SKY, d.y * SKY, d.z * SKY);
    }
    stars.endShape();
  }

  void buildDust() {
    dust = createShape();
    dust.beginShape(POINTS);
    for (int i = 0; i < 450; i++) {
      dust.stroke(150, 190, 255, random(40, 110));
      dust.strokeWeight(random(1, 2.2));
      dust.vertex(random(-7000, 7000), random(-4000, 3500), random(-7000, 7000));
    }
    dust.endShape();
  }

  void update(float dt) {
    for (Rock r : rocks) r.update(dt);
  }

  // drawn first, centred on the camera, so it can never be flown past
  void drawSky(PVector eye) {
    pushMatrix();
    translate(eye.x, eye.y, eye.z);
    noLights();
    shape(stars);

    hint(DISABLE_DEPTH_MASK);
    blendMode(ADD);
    for (SkyBill b : bills) b.draw(SKY);
    // a few bright stars with diffraction spikes
    for (int i = 0; i < brightStars.size(); i++) {
      PVector p = PVector.mult(brightStars.get(i), SKY * 0.97);
      float tw = 0.75 + 0.25 * sin(T * (1 + i % 5) + i);
      skyGlow(p, 900 + (i % 4) * 300, i % 3 == 0 ? color(170, 200, 255) : color(255, 235, 210), 230 * tw);
      skySpikes(p, 2600 + (i % 3) * 900, 160 * tw);
    }
    // the nearby star that lights the lab
    PVector s = PVector.mult(sunDir, SKY * 0.98);
    skyGlow(s, 9000, color(255, 220, 170), 255);
    skyGlow(s, 2600, color(255, 250, 235), 255);
    blendMode(BLEND);
    hint(ENABLE_DEPTH_MASK);

    // planets are lit by that star
    lightFalloff(1, 0, 0);
    ambientLight(18, 18, 28);
    directionalLight(255, 245, 230, -sunDir.x, -sunDir.y, -sunDir.z);
    for (int i = 0; i < 3; i++) {
      pushMatrix();
      PVector p = PVector.mult(planetDir[i], SKY * 0.85);
      translate(p.x, p.y, p.z);
      rotateY(T * 0.01 * (i + 1));
      rotateZ(0.3 - i * 0.2);
      scale(planetSize[i]);
      shape(planet[i]);
      if (i == 0) drawRings();
      popMatrix();
    }
    noLights();
    popMatrix();
  }

  void drawRings() {
    noStroke();
    rotateX(0.35);
    beginShape(QUAD_STRIP);
    texture(ringTex);
    for (int i = 0; i <= 64; i++) {
      float a = TWO_PI * i / 64;
      vertex(cos(a) * 1.35, 0, sin(a) * 1.35, 0, 0);
      vertex(cos(a) * 2.3, 0, sin(a) * 2.3, 1, 0);
    }
    endShape();
  }

  void skyGlow(PVector p, float size, int c, float a) {
    PVector d = p.copy().normalize();
    PVector ax = d.cross(new PVector(0, 1, 0));
    if (ax.magSq() < 0.01) ax = d.cross(new PVector(1, 0, 0));
    ax.normalize().mult(size / 2);
    PVector ay = d.cross(ax).normalize().mult(size / 2);
    tint(red(c), green(c), blue(c), a);
    beginShape(QUADS);
    texture(texGlow);
    vertex(p.x - ax.x - ay.x, p.y - ax.y - ay.y, p.z - ax.z - ay.z, 0, 0);
    vertex(p.x + ax.x - ay.x, p.y + ax.y - ay.y, p.z + ax.z - ay.z, 1, 0);
    vertex(p.x + ax.x + ay.x, p.y + ax.y + ay.y, p.z + ax.z + ay.z, 1, 1);
    vertex(p.x - ax.x + ay.x, p.y - ax.y + ay.y, p.z - ax.z + ay.z, 0, 1);
    endShape();
    noTint();
  }

  // thin cross-shaped flare through a bright star
  void skySpikes(PVector p, float len, float a) {
    PVector d = p.copy().normalize();
    PVector ax = d.cross(new PVector(0, 1, 0));
    if (ax.magSq() < 0.01) ax = d.cross(new PVector(1, 0, 0));
    ax.normalize();
    PVector ay = d.cross(ax).normalize();
    stroke(220, 235, 255, a);
    strokeWeight(1.2);
    line(p.x - ax.x * len, p.y - ax.y * len, p.z - ax.z * len, p.x + ax.x * len, p.y + ax.y * len, p.z + ax.z * len);
    line(p.x - ay.x * len, p.y - ay.y * len, p.z - ay.z * len, p.x + ay.x * len, p.y + ay.y * len, p.z + ay.z * len);
    noStroke();
  }

  // asteroids (world space, lit)
  void drawWorld() {
    for (Rock r : rocks) r.draw();
  }

  // cosmic dust (inside the glow pass)
  void drawDust() {
    pushMatrix();
    translate(sin(T * 0.05) * 300, cos(T * 0.04) * 150, T * 25 % 2000);
    shape(dust);
    popMatrix();
  }

  // ---------------------------------------------------------------- textures
  PImage makeGalaxyTex(int s, int seed) {
    randomSeed(100 + seed);
    float[] acc = new float[s * s * 3];
    int arms = 2 + seed % 2;
    float tight = 0.35 + seed * 0.12;
    float[] tintA = { 1, 0.85, 0.7 }, tintB = seed == 1 ? new float[] { 0.7, 0.8, 1 } : new float[] { 0.85, 0.75, 1 };
    for (int i = 0; i < 26000; i++) {
      float r = pow(random(1), 1.7) * s * 0.46;
      int arm = int(random(arms));
      float a = arm * TWO_PI / arms + log(1 + r) / tight + randomGaussian() * 0.32 * (0.3 + r / (s * 0.46));
      float x = s / 2 + cos(a) * r, y = s / 2 + sin(a) * r * 0.62;
      int px = int(x), py = int(y);
      if (px < 0 || py < 0 || px >= s || py >= s) continue;
      float k = r / (s * 0.46);
      for (int c = 0; c < 3; c++) acc[(py * s + px) * 3 + c] += lerp(tintA[c], tintB[c], k) * 0.55;
    }
    PImage img = createImage(s, s, RGB);
    img.loadPixels();
    for (int y = 0; y < s; y++) {
      for (int x = 0; x < s; x++) {
        float dx = (x - s / 2) / (s * 0.5), dy = (y - s / 2) / (s * 0.31);
        float core = exp(-(dx * dx + dy * dy) * 40) * 1.6 + exp(-(dx * dx + dy * dy) * 6) * 0.25;
        int i = (y * s + x) * 3;
        float edge = constrain(1.2 - sqrt(dx * dx * 0.8 + dy * dy * 0.35), 0, 1);
        img.pixels[y * s + x] = color(255 * min(1, (acc[i] + core) * edge), 255 * min(1, (acc[i + 1] + core * 0.95) * edge), 255 * min(1, (acc[i + 2] + core * 0.85) * edge));
      }
    }
    img.updatePixels();
    randomSeed(millis());
    return img;
  }

  // colourful wispy cloud: domain-warped noise, two-colour gradient, soft round edge
  PImage makeNebulaTex(int s, int seed, int[] ca, int[] cb) {
    noiseSeed(7 + seed * 13);
    PImage img = createImage(s, s, RGB);
    img.loadPixels();
    for (int y = 0; y < s; y++) {
      for (int x = 0; x < s; x++) {
        float dx = (x - s / 2) / (s * 0.5), dy = (y - s / 2) / (s * 0.5);
        float fall = constrain(1 - sqrt(dx * dx + dy * dy), 0, 1);
        float wx = x + 60 * (noise(x * 0.01, y * 0.01, seed) - 0.5);
        float wy = y + 60 * (noise(x * 0.01 + 7, y * 0.01, seed) - 0.5);
        float n = 0, amp = 0.55, f = 0.011;
        for (int o = 0; o < 5; o++) {
          n += noise(wx * f, wy * f, seed * 3.1 + o) * amp;
          amp *= 0.5;
          f *= 2.05;
        }
        float v = constrain((n - 0.33) * 2.6, 0, 1) * pow(fall, 1.4);
        float k = constrain((n - 0.4) * 3, 0, 1);
        float r = lerp(ca[0], cb[0], k), g = lerp(ca[1], cb[1], k), b = lerp(ca[2], cb[2], k);
        img.pixels[y * s + x] = color(r * v, g * v, b * v);
      }
    }
    img.updatePixels();
    noiseSeed(millis());
    return img;
  }

  PImage makePlanetTex(int w, int h, int kind) {
    noiseSeed(40 + kind);
    PImage img = createImage(w, h, RGB);
    img.loadPixels();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        float lat = y / (float) h;
        float lon = x / (float) w * TWO_PI;
        float nx = cos(lon) * 1.5, nz = sin(lon) * 1.5;
        int c;
        if (kind == 0) {          // banded gas giant
          float band = sin(lat * 26 + noise(nx, lat * 6, nz) * 5) * 0.5 + 0.5;
          c = lerpColor(color(196, 150, 110), color(235, 214, 180), band);
          c = lerpColor(c, color(150, 90, 70), noise(nx * 2, lat * 14, nz * 2) * 0.5);
        } else if (kind == 1) {   // rusty rock world
          float n = noise(nx * 2, lat * 5, nz * 2);
          c = lerpColor(color(110, 45, 35), color(205, 110, 70), n);
          if (noise(nx * 6, lat * 16, nz * 6) > 0.68) c = lerpColor(c, color(60, 25, 20), 0.6);
        } else {                  // ice world
          float n = noise(nx * 2.5, lat * 6, nz * 2.5);
          c = lerpColor(color(90, 150, 210), color(225, 240, 255), n);
          if (lat < 0.12 || lat > 0.88) c = color(240, 248, 255);
        }
        img.pixels[y * w + x] = c;
      }
    }
    img.updatePixels();
    noiseSeed(millis());
    return img;
  }

  PImage makeRingBands() {
    PImage img = createImage(128, 4, ARGB);
    img.loadPixels();
    for (int x = 0; x < 128; x++) {
      float u = x / 127.0;
      float a = (0.35 + 0.65 * noise(u * 18)) * sin(PI * u);
      if (u > 0.55 && u < 0.6) a *= 0.15;
      for (int y = 0; y < 4; y++) img.pixels[y * 128 + x] = color(225, 200, 170, 200 * a);
    }
    img.updatePixels();
    return img;
  }

  // low-poly rock: icosahedron, subdivided once, pushed around with noise
  PShape makeRock(int seed) {
    return makeRock(seed, seed == 1 ? color(120, 100, 90) : color(105, 102, 110));
  }

  PShape makeRock(int seed, int fillC) {
    noiseSeed(90 + seed);
    float t = (1 + sqrt(5)) / 2;
    ArrayList<PVector> v = new ArrayList<PVector>();
    float[][] base = { { -1, t, 0 }, { 1, t, 0 }, { -1, -t, 0 }, { 1, -t, 0 }, { 0, -1, t }, { 0, 1, t }, { 0, -1, -t }, { 0, 1, -t }, { t, 0, -1 }, { t, 0, 1 }, { -t, 0, -1 }, { -t, 0, 1 } };
    for (float[] p : base) v.add(new PVector(p[0], p[1], p[2]).normalize());
    int[][] f = { { 0, 11, 5 }, { 0, 5, 1 }, { 0, 1, 7 }, { 0, 7, 10 }, { 0, 10, 11 }, { 1, 5, 9 }, { 5, 11, 4 }, { 11, 10, 2 }, { 10, 7, 6 }, { 7, 1, 8 },
      { 3, 9, 4 }, { 3, 4, 2 }, { 3, 2, 6 }, { 3, 6, 8 }, { 3, 8, 9 }, { 4, 9, 5 }, { 2, 4, 11 }, { 6, 2, 10 }, { 8, 6, 7 }, { 9, 8, 1 } };
    ArrayList<PVector[]> tris = new ArrayList<PVector[]>();
    for (int[] tr : f) {
      PVector a = v.get(tr[0]), b = v.get(tr[1]), c = v.get(tr[2]);
      PVector ab = PVector.add(a, b).normalize(), bc = PVector.add(b, c).normalize(), ca = PVector.add(c, a).normalize();
      tris.add(new PVector[] { a, ab, ca });
      tris.add(new PVector[] { b, bc, ab });
      tris.add(new PVector[] { c, ca, bc });
      tris.add(new PVector[] { ab, bc, ca });
    }
    PShape s = createShape();
    s.beginShape(TRIANGLES);
    s.noStroke();
    s.fill(fillC);
    for (PVector[] tr : tris) {
      PVector[] q = new PVector[3];
      for (int k = 0; k < 3; k++) {
        PVector p = tr[k];
        float d = 0.75 + noise(p.x * 1.7 + 5, p.y * 1.7, p.z * 1.7) * 0.6;
        q[k] = PVector.mult(p, d);
      }
      PVector n = PVector.sub(q[1], q[0]).cross(PVector.sub(q[2], q[0])).normalize();
      if (n.dot(q[0]) < 0) n.mult(-1);
      s.normal(n.x, n.y, n.z);
      for (int k = 0; k < 3; k++) s.vertex(q[k].x, q[k].y, q[k].z);
    }
    s.endShape();
    noiseSeed(millis());
    return s;
  }

  class Rock {
    float orbitR, ang, y, size, spin, orbit;
    PVector axis;
    int mesh;

    Rock(int i) {
      orbitR = random(9000, 24000);
      ang = random(TWO_PI);
      y = random(-3500, 3500);
      size = random(1) < 0.15 ? random(500, 1100) : random(50, 380);
      spin = random(-0.4, 0.4);
      orbit = random(0.003, 0.012) * (random(1) < 0.5 ? 1 : -1);
      axis = PVector.random3D();
      mesh = i % 3;
    }

    void update(float dt) {
      ang += orbit * dt;
    }

    void draw() {
      pushMatrix();
      translate(cos(ang) * orbitR, y, sin(ang) * orbitR);
      rotate(T * spin, axis.x, axis.y, axis.z);
      scale(size);
      shape(rockMesh[mesh]);
      popMatrix();
    }
  }
}

// a big textured quad on the sky sphere facing the viewer
class SkyBill {
  PImage img;
  PVector dir;
  float size, rot, alpha;
  int col;

  SkyBill(PImage img, PVector dir, float size, float rot, int col, float alpha) {
    this.img = img;
    this.dir = dir.normalize();
    this.size = size;
    this.rot = rot;
    this.col = col;
    this.alpha = alpha;
  }

  void draw(float R) {
    PVector p = PVector.mult(dir, R);
    PVector ax = dir.cross(new PVector(0, 1, 0));
    if (ax.magSq() < 0.01) ax = dir.cross(new PVector(1, 0, 0));
    ax.normalize();
    PVector ay = dir.cross(ax).normalize();
    PVector u = PVector.add(PVector.mult(ax, cos(rot)), PVector.mult(ay, sin(rot))).mult(size / 2);
    PVector w = PVector.add(PVector.mult(ax, -sin(rot)), PVector.mult(ay, cos(rot))).mult(size / 2);
    noStroke();
    tint(red(col), green(col), blue(col), alpha);
    beginShape(QUADS);
    texture(img);
    vertex(p.x - u.x - w.x, p.y - u.y - w.y, p.z - u.z - w.z, 0, 0);
    vertex(p.x + u.x - w.x, p.y + u.y - w.y, p.z + u.z - w.z, 1, 0);
    vertex(p.x + u.x + w.x, p.y + u.y + w.y, p.z + u.z + w.z, 1, 1);
    vertex(p.x - u.x + w.x, p.y - u.y + w.y, p.z - u.z + w.z, 0, 1);
    endShape();
    noTint();
  }
}


// ======================================================================
// TAB: HUD.pde
// ======================================================================
// Screen overlay: holographic research panel, crosshair + what you're aiming
// at, portal tags, controls, F3 debug, TAB terminal, toasts and flashes.

class HUD {
  ArrayList<Toast> toasts = new ArrayList<Toast>();
  PFont mono, monoSmall, sans, sansBig;
  boolean showControls = true, debug, terminalOpen;
  float terminalAnim;
  float lastJumpToast = -99;
  float[] tagX = new float[2], tagY = new float[2];
  boolean[] tagOn = new boolean[2];
  String aimText = "", aimSub = "";
  int aimCol;

  HUD() {
    mono = createFont("Monospaced.bold", 26, true);
    monoSmall = createFont("Monospaced", 22, true);
    sans = createFont("SansSerif.bold", 32, true);
    sansBig = createFont("SansSerif.bold", 48, true);
  }

  void toast(String s, int c) {
    toasts.add(0, new Toast(s, c));
    if (toasts.size() > 4) toasts.remove(toasts.size() - 1);
  }

  void update(float dt) {
    for (int i = toasts.size() - 1; i >= 0; i--) {
      toasts.get(i).age += dt;
      if (toasts.get(i).age > 2.6) toasts.remove(i);
    }
    terminalAnim += ((terminalOpen ? 1 : 0) - terminalAnim) * min(1, dt * 10);
    updateAim();
  }

  // what's under the crosshair
  void updateAim() {
    aimText = "";
    aimSub = "";
    if (objects.heldObj != null || manip.active()) return;
    ThrowableObject o = objects.pick(1200);
    Portal q = portals.rayPick(cam.pos, cam.fwd, 4000);
    float to = o != null ? PVector.dist(cam.pos, o.pos) : 1e9, tq = q != null ? PVector.dist(cam.pos, q.c) : 1e9;
    if (o != null && to <= tq) {
      aimText = o.name + "   [E] GRAB";
      aimSub = o.massLabel() + "   " + o.status;
      aimCol = color(170, 255, 230);
      return;
    }
    if (q != null) {
      aimText = "PORTAL " + q.label() + "   [E] SELECT / MOVE";
      aimSub = "on " + q.box.name;
      aimCol = q.colLight;
      return;
    }
    RayHit h = gun.aimRay();
    if (h.hit()) {
      float d = h.t / M;
      if (h.box.name.equals("MATTER DISPENSER") && d < 9) {
        aimText = "MATTER DISPENSER   [E] DISPENSE";
        aimSub = "results not guaranteed";
        aimCol = color(120, 255, 200);
      } else if (h.box.portalable(h.face)) {
        aimSub = h.box.name + "  -  PORTAL SURFACE  -  " + nf(d, 0, 1) + " m";
        aimCol = color(140, 255, 170);
      } else {
        aimSub = h.box.name + "  -  REJECTS PORTALS  -  " + nf(d, 0, 1) + " m";
        aimCol = color(255, 150, 120);
      }
    }
  }

  // called while the 3D camera is still active: where to put the A/B tags
  void capturePortalTags() {
    for (int i = 0; i < 2; i++) {
      Portal q = portals.p[i];
      tagOn[i] = false;
      if (!q.active) continue;
      PVector p = PVector.add(q.c, PVector.mult(q.u, PORTAL_HH * 1.35));
      p.add(PVector.mult(q.n, 20));
      if (PVector.sub(p, cam.pos).dot(cam.fwd) < 10) continue;
      tagX[i] = screenX(p.x, p.y, p.z);
      tagY[i] = screenY(p.x, p.y, p.z);
      tagOn[i] = true;
    }
  }

  void draw() {
    // camera teleport flash
    if (cam.teleportFlash > 0.01) {
      noStroke();
      fill(140, 255, 160, 160 * cam.teleportFlash);
      rect(0, 0, width, height);
      cam.teleportFlash *= 0.86;
    }
    // stability warning vignette
    if (physics.linked && physics.stability < 0.5) {
      float a = 70 * (0.5 - physics.stability) * 2 * (0.6 + 0.4 * sin(T * 8));
      noFill();
      for (int i = 0; i < 6; i++) {
        stroke(255, 60, 40, a * (1 - i / 6.0));
        strokeWeight(14);
        rect(i * 12, i * 12, width - i * 24, height - i * 24);
      }
      noStroke();
    }
    drawTags();
    boolean clean = terminalAnim > 0.5;          // the TAB computer takes over the screen
    if (!clean) drawPanel();
    drawAim();
    if (showControls && !clean) drawControls();
    if (debug && !clean) drawDebug();
    drawToasts();
    if (objects.heldObj != null) drawHolding();
    if (manip.active()) drawManip();
    if (terminalAnim > 0.02) drawTerminalOverlay();
    if (!cam.captured) {
      textFont(sans, 18);
      textAlign(CENTER, CENTER);
      fill(170, 255, 200, 150 + 100 * sin(T * 4));
      text("CLICK TO CONTROL THE CAMERA   (ESC RELEASES THE MOUSE)", width / 2, height - 22);
    } else if (cam.warpBroken) {
      textFont(monoSmall, 13);
      textAlign(CENTER, CENTER);
      fill(255, 220, 120, 210);
      text("MOUSE CAN'T BE RE-CENTRED: push it to the window edge to keep turning (or use the arrow keys)", width / 2, height - 30);
      text(platform == MACOS ? "macOS fix: System Settings > Privacy & Security > Accessibility > allow Processing, then restart the sketch" : "", width / 2, height - 13);
    }
    cam.drawCrosshair();
  }

  void holoBox(float x, float y, float w, float h) {
    noStroke();
    fill(0, 30, 28, 150);
    roundBox(x, y, w, h, 6);
    stroke(80, 255, 200, 170);
    strokeWeight(1.2);
    noFill();
    roundBox(x, y, w, h, 6);
    stroke(80, 255, 200, 255);
    strokeWeight(2.5);
    line(x, y + 14, x, y);
    line(x, y, x + 14, y);
    line(x + w, y + h - 14, x + w, y + h);
    line(x + w, y + h, x + w - 14, y + h);
    noStroke();
  }

  void drawPanel() {
    float x = 14, y = 14, w = 300, h = 236;
    holoBox(x, y, w, h);
    textFont(mono, 15);
    textAlign(LEFT, TOP);
    fill(120, 255, 200);
    text("PORTAL RESEARCH SYSTEM", x + 14, y + 10);
    stroke(80, 255, 200, 90);
    line(x + 12, y + 32, x + w - 12, y + 32);
    noStroke();
    float ly = y + 42;
    for (int i = 0; i < 2; i++) {
      Portal q = portals.p[i];
      fill(q.active ? q.col : color(80));
      ellipse(x + 22, ly + 8, 10, 10);
      fill(q.active ? color(220, 255, 240) : color(140));
      textFont(mono, 14);
      text("PORTAL " + q.label() + ": " + (q.active ? "ACTIVE" : "OFFLINE"), x + 34, ly);
      ly += 20;
    }
    ly += 6;
    textFont(monoSmall, 14);
    fill(200, 240, 255);
    text("DISTANCE:  " + (physics.linked ? nf(physics.D, 0, 1) + " m" : "-"), x + 16, ly);
    ly += 19;
    text("ENERGY:    " + (physics.linked ? nf(physics.Ereq, 0, 1) + " PJ" : "-"), x + 16, ly);
    ly += 19;
    int sc = physics.stability >= 1 ? color(140, 255, 170) : physics.stability >= 0.5 ? color(255, 220, 120) : color(255, 110, 90);
    fill(sc);
    text("STABILITY: " + (physics.linked ? nf(physics.stability * 100, 0, 1) + " %" : "-"), x + 16, ly);
    ly += 19;
    fill(200, 240, 255);
    text("ANGLE:     " + (physics.linked ? nf(physics.theta, 0, 1) + " deg" : "-"), x + 16, ly);
    ly += 25;
    text("OBJECTS: " + objects.list.size() + "     FPS: " + i0(frameRate), x + 16, ly);
    ly += 19;
    fill(170, 255, 220);
    text("NEXT SHOT: PORTAL " + (gun.next == 0 ? "A" : "B") + "   THROW " + i0(objects.throwPower) + " m/s", x + 16, ly);
  }

  void drawTags() {
    textFont(sans, 22);
    textAlign(CENTER, CENTER);
    for (int i = 0; i < 2; i++) {
      if (!tagOn[i]) continue;
      Portal q = portals.p[i];
      fill(0, 120);
      ellipse(tagX[i], tagY[i], 30, 30);
      fill(q.colLight);
      text(q.label(), tagX[i], tagY[i] - 2);
    }
  }

  void drawAim() {
    textAlign(CENTER, TOP);
    if (aimText.length() > 0) {
      textFont(sans, 17);
      fill(0, 140);
      text(aimText, width / 2 + 1, height / 2 + 26 + 1);
      fill(aimCol);
      text(aimText, width / 2, height / 2 + 26);
    }
    if (aimSub.length() > 0) {
      textFont(monoSmall, 13);
      fill(aimCol, 200);
      text(aimSub, width / 2, height / 2 + (aimText.length() > 0 ? 48 : 26));
    }
  }

  void drawHolding() {
    ThrowableObject o = objects.heldObj;
    String s = "HOLDING " + o.name + "  (" + o.massLabel() + ")";
    String t = "LEFT CLICK THROW  -  R / RIGHT CLICK RELEASE  -  WHEEL POWER " + i0(objects.throwPower) + " m/s";
    textAlign(CENTER, TOP);
    textFont(sans, 17);
    fill(170, 255, 230);
    text(s, width / 2, height / 2 + 30);
    textFont(monoSmall, 13);
    fill(170, 255, 230, 200);
    text(t, width / 2, height / 2 + 54);
  }

  void drawManip() {
    Portal q = manip.sel;
    float w = 330, h = 128, x = 14, y = 262;            // left column: clear of Rick's speech box
    holoBox(x, y, w, h);
    textAlign(LEFT, TOP);
    textFont(mono, 16);
    fill(q.colLight);
    text("PORTAL " + q.label() + " SELECTED", x + 14, y + 10);
    textFont(monoSmall, 14);
    fill(200, 240, 255);
    text("MOVE / REPOSITION   aim at a surface", x + 14, y + 36);
    text("ROTATE              Q / R  (or wheel)", x + 14, y + 54);
    text("CONFIRM             LEFT CLICK", x + 14, y + 72);
    text("CANCEL              RIGHT CLICK", x + 14, y + 90);
    fill(manip.valid ? color(140, 255, 170) : color(255, 120, 100));
    text(manip.status, x + 14, y + 108);
  }

  void drawControls() {
    String[][] rows = {
      { "WASD", "MOVE" }, { "SPACE", "UP" }, { "C / CTRL", "DOWN" }, { "SHIFT", "SPEED BOOST" }, { "MOUSE", "LOOK" },
      { "M1", "FIRE PORTAL / THROW" }, { "E", "INTERACT / GRAB / SELECT" }, { "R", "RELEASE OBJECT" }, { "Q/R", "ROTATE PORTAL" },
      { "WHEEL", "THROW POWER" }, { "TAB", "PORTAL COMPUTER" }, { "F3 / `", "DEBUG" }, { "H", "HIDE CONTROLS" }, { "ESC", "RELEASE MOUSE" }
    };
    float w = 300, h = rows.length * 17 + 18, x = 14, y = height - h - 14;
    holoBox(x, y, w, h);
    textAlign(LEFT, TOP);
    textFont(monoSmall, 13);
    for (int i = 0; i < rows.length; i++) {
      fill(120, 255, 200);
      text(rows[i][0], x + 14, y + 9 + i * 17);
      fill(200, 240, 255);
      text(rows[i][1], x + 100, y + 9 + i * 17);
    }
  }

  void drawDebug() {
    Portal a = portals.p[0], b = portals.p[1];
    String[] lines = {
      "DEBUG (F3)",
      "FPS            " + nf(frameRate, 0, 1) + "   frame " + nf(dt * 1000, 0, 1) + " ms",
      "CAMERA XYZ     " + v3(cam.pos),
      "CAMERA DIR     " + nf(cam.fwd.x, 0, 2) + ", " + nf(cam.fwd.y, 0, 2) + ", " + nf(cam.fwd.z, 0, 2) + "  yaw " + i0(degrees(cam.yaw) % 360) + " pitch " + i0(degrees(cam.pitch)),
      "PORTAL A XYZ   " + (a.active ? v3(a.c) : "-"),
      "PORTAL B XYZ   " + (b.active ? v3(b.c) : "-"),
      "PORTAL DIST    " + (physics.linked ? nf(physics.D, 0, 2) + " m" : "-"),
      "STABILITY      " + (physics.linked ? nf(physics.S, 0, 3) + "  (" + nf(physics.stability * 100, 0, 1) + " %)" : "-"),
      "OBJECTS        " + objects.list.size() + (objects.heldObj != null ? "  holding " + objects.heldObj.name : ""),
      "PARTICLES      " + parts.count + " / " + parts.CAP,
      "IDLE TIMER     " + nf(idleSeconds(), 0, 1) + " s  (Rick at 20)",
      "LIQUID SHADER  " + (liquidShader != null ? "GPU" : "CPU fallback"),
      "NOCLIP (N)     " + (cam.noclip ? "ON" : "OFF"),
      "MOUSE          " + (cam.captured ? "captured" : "free") + (cam.win == null ? "  (no NEWT window)" : "")
    };
    float w = 470, h = lines.length * 17 + 18, x = width - w - 14, y = 14;
    holoBox(x, y, w, h);
    textAlign(LEFT, TOP);
    textFont(monoSmall, 13);
    for (int i = 0; i < lines.length; i++) {
      fill(i == 0 ? color(255, 220, 120) : color(200, 240, 255));
      text(lines[i], x + 14, y + 9 + i * 17);
    }
  }

  String v3(PVector p) {
    return fm(p.x / M) + ", " + fm(-p.y / M) + ", " + fm(p.z / M) + " m";
  }

  // toasts go top-centre, in the gap between the research panel and the debug panel, so they never end up
  // underneath Rick's speech box or the holding / portal-move panels
  void drawToasts() {
    textAlign(CENTER, CENTER);
    float left = 14 + 300 + 16;
    float right = debug ? width - 470 - 14 - 16 : width - left;
    float cx = (left + right) / 2, maxW = right - left;
    for (int i = 0; i < toasts.size(); i++) {
      Toast t = toasts.get(i);
      float a = 255 * min(1, (2.6 - t.age) / 0.5) * min(1, t.age / 0.12);
      textFont(sans, 19);
      float tw = textWidth(t.s);
      if (tw > maxW) textSize(19 * maxW / tw);
      float y = 34 + i * 28;
      fill(0, a * 0.6);
      text(t.s, cx + 2, y + 2);
      fill(red(t.c), green(t.c), blue(t.c), a);
      text(t.s, cx, y);
    }
  }

  void drawTerminalOverlay() {
    float k = terminalAnim;
    noStroke();
    fill(0, 10, 12, 210 * k);
    rect(0, 0, width, height);
    float w = 1100 * (0.9 + 0.1 * k), h = w * 640 / 1024.0;
    imageMode(CENTER);
    blendMode(ADD);
    tint(255, 255 * k);
    image(terminal.img, width / 2, height / 2 - 10, w, h);
    noTint();
    blendMode(BLEND);
    imageMode(CORNER);
    textFont(mono, 14);
    textAlign(CENTER, CENTER);
    fill(170, 255, 220, 220 * k);
    text("TAB TO CLOSE", width / 2, height / 2 + h / 2 + 6);
  }
}

class Toast {
  String s;
  int c;
  float age;

  Toast(String s, int c) {
    this.s = s;
    this.c = c;
  }
}


// ======================================================================
// TAB: Laboratory.pde
// ======================================================================
// The laboratory: every solid thing is an axis-aligned Box. The same boxes
// are used for drawing, collisions and portal raycasts, so what you see is
// exactly what you can hit. Light panels / floors take portals, dark metal
// and hazard surfaces don't.

final int FACE_NX = 0, FACE_PX = 1, FACE_NY = 2, FACE_PY = 3, FACE_NZ = 4, FACE_PZ = 5;
final int K_FLOOR = 0, K_PANEL = 1, K_METAL = 2, K_HAZARD = 3;

PVector faceNormal(int f) {
  switch (f) {
  case FACE_NX: return new PVector(-1, 0, 0);
  case FACE_PX: return new PVector(1, 0, 0);
  case FACE_NY: return new PVector(0, -1, 0);
  case FACE_PY: return new PVector(0, 1, 0);
  case FACE_NZ: return new PVector(0, 0, -1);
  default:      return new PVector(0, 0, 1);
  }
}

class Box {
  float x0, y0, z0, x1, y1, z1;
  int[] kind = new int[6];          // texture per face
  String name;
  boolean hidden;                   // collider only - drawn by custom code

  Box(String name, float x0, float y0, float z0, float x1, float y1, float z1, int allKind) {
    this.name = name;
    this.x0 = min(x0, x1); this.x1 = max(x0, x1);
    this.y0 = min(y0, y1); this.y1 = max(y0, y1);
    this.z0 = min(z0, z1); this.z1 = max(z0, z1);
    for (int i = 0; i < 6; i++) kind[i] = allKind;
  }

  Box face(int f, int k) { kind[f] = k; return this; }

  Box hide() { hidden = true; return this; }

  boolean portalable(int f) { return kind[f] == K_FLOOR || kind[f] == K_PANEL; }

  // the face rectangle in its two in-plane axes (for fitting portals)
  float[] faceRect(int f) {
    if (f == FACE_NX || f == FACE_PX) return new float[] { y0, y1, z0, z1 };   // axes y,z
    if (f == FACE_NY || f == FACE_PY) return new float[] { x0, x1, z0, z1 };   // axes x,z
    return new float[] { x0, x1, y0, y1 };                                     // axes x,y
  }

  float facePlane(int f) {
    switch (f) {
    case FACE_NX: return x0;
    case FACE_PX: return x1;
    case FACE_NY: return y0;
    case FACE_PY: return y1;
    case FACE_NZ: return z0;
    default:      return z1;
    }
  }
}

class RayHit {
  float t = Float.MAX_VALUE;
  PVector p, n;
  Box box;
  int face = -1;
  boolean hit() { return box != null; }
}

class Laboratory {
  ArrayList<Box> boxes = new ArrayList<Box>();
  PShape shFloor, shPanel, shMetal, shHazard, shDeco;
  ArrayList<float[]> edges = new ArrayList<float[]>();      // glowing edge strips x0,y0,z0,x1,y1,z1
  ArrayList<Sign> signs = new ArrayList<Sign>();
  PShape ringGen, ringGyro, ringTesla;   // one per material: P3D bakes fill/emissive into a PShape

  Laboratory() {
    build();
    meshAll();
    ringGen = makeTorus(1, 0.035, 48, 6, color(120, 130, 140), color(10, 90, 40));
    ringGyro = makeTorus(1, 0.035, 48, 6, color(200, 210, 230), color(30, 70, 110));
    ringTesla = makeTorus(1, 0.035, 48, 6, color(190, 200, 215), color(40, 60, 90));
  }

  Box add(String name, float x0, float y0, float z0, float x1, float y1, float z1, int k) {
    Box b = new Box(name, x0, y0, z0, x1, y1, z1, k);
    boxes.add(b);
    return b;
  }

  void build() {
    // main deck (four slabs around the VOID PIT)
    add("DECK", -2000, 0, -2000, 2000, 80, 200, K_METAL).face(FACE_NY, K_FLOOR);
    add("DECK", -2000, 0, 900, 2000, 80, 2000, K_METAL).face(FACE_NY, K_FLOOR);
    add("DECK", -2000, 0, 200, -350, 80, 900, K_METAL).face(FACE_NY, K_FLOOR);
    add("DECK", 350, 0, 200, 2000, 80, 900, K_METAL).face(FACE_NY, K_FLOOR);
    edges.add(new float[] { -2000, 0, 2000, 2000, 0, 2000 });
    edges.add(new float[] { -2000, 0, -2000, -2000, 0, 2000 });
    edges.add(new float[] { 2000, 0, -2000, 2000, 0, 2000 });
    edges.add(new float[] { -350, 0, 200, 350, 0, 200 });
    edges.add(new float[] { -350, 0, 900, 350, 0, 900 });
    edges.add(new float[] { -350, 0, 200, -350, 0, 900 });
    edges.add(new float[] { 350, 0, 200, 350, 0, 900 });

    // walls and the ceiling over the back of the lab
    add("BACK WALL", -2000, -1400, -2080, 2000, 0, -2000, K_METAL).face(FACE_PZ, K_PANEL);
    add("CEILING", -2000, -1480, -2080, 2000, -1400, -1000, K_METAL).face(FACE_PY, K_PANEL);
    add("LEFT WALL", -2080, -1400, -2000, -2000, 0, -500, K_METAL).face(FACE_PX, K_PANEL);
    add("RIGHT WALL", 2000, -1400, -2000, 2080, 0, -500, K_METAL).face(FACE_NX, K_PANEL);
    add("PILLAR", -740, -1400, -1060, -660, 0, -1000, K_METAL);
    add("PILLAR", 660, -1400, -1060, 740, 0, -1000, K_METAL);
    edges.add(new float[] { -2000, -1400, -1000, 2000, -1400, -1000 });

    // portal testing chamber: free-standing panels
    add("TEST PANEL", -1100, -800, -500, -500, 0, -460, K_METAL).face(FACE_NZ, K_PANEL).face(FACE_PZ, K_PANEL);
    add("TEST PANEL", 500, -800, -500, 1100, 0, -460, K_METAL).face(FACE_NZ, K_PANEL).face(FACE_PZ, K_PANEL);
    add("TEST PANEL", -1500, -600, 300, -1460, 0, 1100, K_METAL).face(FACE_NX, K_PANEL).face(FACE_PX, K_PANEL);
    add("TEST PANEL", 1460, -600, 300, 1500, 0, 1100, K_METAL).face(FACE_NX, K_PANEL).face(FACE_PX, K_PANEL);
    add("DROP TOWER", 1100, -900, -1500, 1500, 0, -1100, K_PANEL).face(FACE_NY, K_FLOOR);

    // machines and storage (no portals on these)
    add("CALIBRATION PLINTH", -400, -120, -1350, 400, 0, -1050, K_METAL);
    add("RESEARCH CONSOLE", 900, -110, -1950, 1700, 0, -1720, K_METAL);
    add("CONTAINMENT BARRIER", -2000, -320, -1200, -1150, 0, -1160, K_HAZARD);
    add("MATTER DISPENSER", -1850, -260, 1450, -1550, 0, 1750, K_METAL);
    add("QUANTUM PEDESTAL", 1580, -100, 380, 1700, 0, 500, K_METAL);
    add("QUANTUM PEDESTAL", 1780, -100, 580, 1900, 0, 700, K_METAL);
    add("QUANTUM PEDESTAL", 1580, -100, 760, 1700, 0, 880, K_METAL);
    add("TESLA COIL", -1420, -520, -1700, -1280, 0, -1560, K_METAL).hide();
    add("SERVER RACK", 1000, -420, 1250, 1110, 0, 1450, K_METAL);
    add("SERVER RACK", 1000, -420, 1500, 1110, 0, 1700, K_METAL);
    add("CHEMISTRY BENCH", -900, -95, 1300, -350, 0, 1480, K_METAL);
    add("GENERATOR", -1830, -900, 1770, -1670, 0, 1930, K_METAL).hide();
    add("GENERATOR", 1670, -900, 1770, 1830, 0, 1930, K_METAL).hide();

    // floating platforms out in space
    add("ORBITAL TEST PLATFORM", 2700, -560, -900, 3700, -480, 300, K_METAL).face(FACE_NY, K_FLOOR);
    add("ORBITAL TEST WALL", 3620, -1300, -900, 3700, -560, 300, K_METAL).face(FACE_NX, K_PANEL);
    add("OBSERVATION DECK", -3900, -980, -600, -2800, -900, 500, K_METAL).face(FACE_NY, K_FLOOR);
    add("HIGH PLATFORM", -600, -2500, 500, 600, -2420, 1500, K_METAL).face(FACE_NY, K_FLOOR).face(FACE_PY, K_PANEL);
    add("SUB-DECK", -700, 1500, 0, 700, 1580, 1300, K_METAL).face(FACE_NY, K_FLOOR);
    edges.add(new float[] { 2700, -560, 300, 3700, -560, 300 });
    edges.add(new float[] { -3900, -980, 500, -2800, -980, 500 });
    edges.add(new float[] { -600, -2500, 1500, 600, -2500, 1500 });
    edges.add(new float[] { -700, 1500, 1300, 700, 1500, 1300 });

    signs.add(new Sign("PORTAL TESTING CHAMBER", "AUTHORISED GENIUSES ONLY", color(120, 255, 140), 0, -1180, -1995, 0, 900));
    signs.add(new Sign("UNSTABLE MATTER STORAGE", "DO NOT TOUCH", color(255, 90, 70), -1575, -560, -1150, 0, 560));
    signs.add(new Sign("QUANTUM OBJECT STORAGE", "STATUS: PROBABLY SAFE", color(170, 140, 255), 1960, -420, 630, -HALF_PI, 560));
    signs.add(new Sign("SPACETIME CALIBRATION", "DO NOT LOOK DIRECTLY AT THE GYRO", color(120, 220, 255), 0, -760, -1040, 0, 600));
    signs.add(new Sign("VOID PIT", "DO NOT LEAN.  SERIOUSLY.", color(255, 200, 80), 0, -230, 905, 0, 420));
    signs.add(new Sign("MATTER DISPENSER", "PRESS E FOR STUFF", color(120, 255, 200), -1700, -470, 1760, 0, 380));
    signs.add(new Sign("ORBITAL TEST PLATFORM", "GRAVITY: ON (MOSTLY)", color(120, 255, 140), 3200, -900, 310, 0, 520));
    signs.add(new Sign("PROBABLY SAFE", null, color(170, 255, 170), -800, -900, -455, 0, 300));
  }

  // ---------------------------------------------------------------- meshing
  void meshAll() {
    shFloor = beginMesh(texFloor);
    shPanel = beginMesh(texPanel);
    shMetal = beginMesh(texMetal);
    shHazard = beginMesh(texHazard);
    for (Box b : boxes) {
      if (b.hidden) continue;
      for (int f = 0; f < 6; f++) {
        PShape s = b.kind[f] == K_FLOOR ? shFloor : b.kind[f] == K_PANEL ? shPanel : b.kind[f] == K_HAZARD ? shHazard : shMetal;
        meshFace(s, b, f, b.kind[f] == K_HAZARD ? 160 : 240);
      }
    }
    shFloor.endShape();
    shPanel.endShape();
    shMetal.endShape();
    shHazard.endShape();
  }

  PShape beginMesh(PImage tex) {
    PShape s = createShape();
    s.beginShape(QUADS);
    s.noStroke();
    s.texture(tex);
    s.fill(255);
    return s;
  }

  // a face split into tiles (so per-vertex lighting looks right), UVs in world space
  void meshFace(PShape s, Box b, int f, float tile) {
    float[] r = b.faceRect(f);
    float plane = b.facePlane(f);
    PVector n = faceNormal(f);
    int nu = max(1, ceil((r[1] - r[0]) / 200)), nv = max(1, ceil((r[3] - r[2]) / 200));
    for (int i = 0; i < nu; i++) {
      for (int j = 0; j < nv; j++) {
        float a0 = lerp(r[0], r[1], i / (float) nu), a1 = lerp(r[0], r[1], (i + 1) / (float) nu);
        float c0 = lerp(r[2], r[3], j / (float) nv), c1 = lerp(r[2], r[3], (j + 1) / (float) nv);
        s.normal(n.x, n.y, n.z);
        faceVertex(s, f, plane, a0, c0, tile);
        faceVertex(s, f, plane, a1, c0, tile);
        faceVertex(s, f, plane, a1, c1, tile);
        faceVertex(s, f, plane, a0, c1, tile);
      }
    }
  }

  void faceVertex(PShape s, int f, float plane, float a, float c, float tile) {
    if (f == FACE_NX || f == FACE_PX) s.vertex(plane, a, c, c / tile, a / tile);
    else if (f == FACE_NY || f == FACE_PY) s.vertex(a, plane, c, a / tile, c / tile);
    else s.vertex(a, c, plane, a / tile, c / tile);
  }

  // ring (torus) mesh of radius 1 for machines
  PShape makeTorus(float R, float r, int seg, int sides, int fillC, int emisC) {
    PShape s = createShape();
    s.beginShape(QUADS);
    s.noStroke();
    s.fill(fillC);
    s.emissive(emisC);
    for (int i = 0; i < seg; i++) {
      float a0 = TWO_PI * i / seg, a1 = TWO_PI * (i + 1) / seg;
      for (int j = 0; j < sides; j++) {
        float b0 = TWO_PI * j / sides, b1 = TWO_PI * (j + 1) / sides;
        torusV(s, R, r, a0, b0);
        torusV(s, R, r, a1, b0);
        torusV(s, R, r, a1, b1);
        torusV(s, R, r, a0, b1);
      }
    }
    s.endShape();
    return s;
  }

  void torusV(PShape s, float R, float r, float a, float b) {
    float cx = cos(a), cz = sin(a);
    s.normal(cos(b) * cx, sin(b), cos(b) * cz);
    s.vertex((R + r * cos(b)) * cx, r * sin(b), (R + r * cos(b)) * cz);
  }

  // ---------------------------------------------------------------- per frame
  void update(float dt) {
  }

  void lightsOn() {
    lightFalloff(1, 0, 0);
    ambientLight(58, 62, 78);
    directionalLight(250, 236, 214, -0.35, 0.85, -0.4);
    directionalLight(70, 90, 150, 0.4, -0.7, 0.6);
    lightFalloff(1, 0, 0.0000016);
    pointLight(60, 255, 120, -1750, -400, 1850);
    pointLight(60, 255, 120, 1750, -400, 1850);
    pointLight(255, 70, 60, -1600, -300, -1600);
  }

  void drawSolid() {
    shape(shFloor);
    shape(shPanel);
    shape(shMetal);
    shape(shHazard);
    drawMachines();
  }

  void drawMachines() {
    // generators: a glowing core column with spinning rings
    for (int s = -1; s <= 1; s += 2) {
      pushMatrix();
      translate(s * 1750, -450, 1850);
      noStroke();
      fill(40, 44, 52);
      emissive(20, 160, 60);
      drawCylinder(70, 900, 16);
      emissive(0);
      for (int i = 0; i < 3; i++) {
        pushMatrix();
        translate(0, 300 - i * 250, 0);
        rotateY(T * (1.2 + i * 0.7) * s);
        rotateX(sin(T + i) * 0.25);
        scale(150 + i * 10);
        shape(ringGen);
        popMatrix();
      }
      popMatrix();
    }
    // spacetime calibration gyroscope above the plinth
    pushMatrix();
    translate(0, -420, -1200);
    for (int i = 0; i < 3; i++) {
      pushMatrix();
      if (i == 0) rotateX(T * 0.8);
      if (i == 1) { rotateZ(T * 1.1); rotateX(HALF_PI); }
      if (i == 2) { rotateY(T * 0.6); rotateZ(HALF_PI); }
      scale(260 - i * 55);
      shape(ringGyro);
      popMatrix();
    }
    fill(30, 40, 60);
    emissive(60, 160, 255);
    sphere(60);
    emissive(0);
    popMatrix();
    // containment pods in unstable storage
    for (int i = 0; i < 3; i++) {
      pushMatrix();
      translate(-1850 + i * 260, -40, -1700);
      fill(50, 54, 62);
      drawCylinder(95, 40, 14);
      translate(0, -460, 0);
      drawCylinder(95, 40, 14);
      popMatrix();
    }
    // tesla coil: stacked rings on a column
    pushMatrix();
    translate(-1350, -260, -1630);
    fill(60, 64, 74);
    drawCylinder(35, 520, 12);
    translate(0, -270, 0);
    scale(90);
    shape(ringTesla);
    scale(0.7);
    translate(0, 0.6, 0);
    shape(ringTesla);
    popMatrix();
    // beakers on the chemistry bench
    for (int i = 0; i < 5; i++) {
      pushMatrix();
      translate(-820 + i * 110, -125, 1390 + (i % 2) * 40);
      fill(200, 230, 255, 140);
      drawCylinder(22, 60, 10);
      translate(0, 12, 0);
      int c = i % 3 == 0 ? color(90, 255, 120) : i % 3 == 1 ? color(255, 90, 200) : color(90, 200, 255);
      fill(c);
      emissive(red(c) * 0.5, green(c) * 0.5, blue(c) * 0.5);
      drawCylinder(19, 32, 10);
      emissive(0);
      popMatrix();
    }
    // console screens frame
    pushMatrix();
    translate(1300, -110, -1835);
    fill(35, 38, 46);
    box(760, 30, 200);
    popMatrix();
  }

  // vertical cylinder centred on the origin
  void drawCylinder(float r, float h, int seg) {
    beginShape(QUAD_STRIP);
    for (int i = 0; i <= seg; i++) {
      float a = TWO_PI * i / seg;
      normal(cos(a), 0, sin(a));
      vertex(cos(a) * r, -h / 2, sin(a) * r);
      vertex(cos(a) * r, h / 2, sin(a) * r);
    }
    endShape();
    beginShape(TRIANGLE_FAN);
    normal(0, -1, 0);
    vertex(0, -h / 2, 0);
    for (int i = 0; i <= seg; i++) vertex(cos(TWO_PI * i / seg) * r, -h / 2, sin(TWO_PI * i / seg) * r);
    endShape();
  }

  void drawGlow() {
    // edge strips
    strokeWeight(2.5);
    for (float[] e : edges) {
      stroke(80, 220, 255, 150 + 60 * sin(T * 2 + e[0] * 0.001));
      line(e[0], e[1] - 1, e[2], e[3], e[4] - 1, e[5]);
    }
    noStroke();
    // generator cores
    for (int s = -1; s <= 1; s += 2) {
      for (int i = 0; i < 4; i++) glowSprite(s * 1750, -200 - i * 200, 1850, 420 + 60 * sin(T * 3 + i), color(60, 255, 120), 90);
    }
    // containment pod glass + unstable blobs
    for (int i = 0; i < 3; i++) {
      float x = -1850 + i * 260;
      float wob = sin(T * 3 + i * 2);
      glowSprite(x + wob * 20, -270 + cos(T * 2.3 + i) * 30, -1700, 160 + 40 * wob, color(255, 80 + i * 40, 60), 190);
      noFill();
      stroke(160, 220, 255, 70);
      strokeWeight(1.5);
      for (int k = 0; k < 2; k++) {
        float y = k == 0 ? -60 : -480;
        beginShape();
        for (int j = 0; j <= 20; j++) vertex(x + cos(TWO_PI * j / 20) * 90, y, -1700 + sin(TWO_PI * j / 20) * 90);
        endShape();
      }
      for (int j = 0; j < 6; j++) {
        float a = TWO_PI * j / 6;
        line(x + cos(a) * 90, -60, -1700 + sin(a) * 90, x + cos(a) * 90, -480, -1700 + sin(a) * 90);
      }
      noStroke();
    }
    // gyroscope core glow + crystals orbiting it
    glowSprite(0, -420, -1200, 420 + 50 * sin(T * 2), color(80, 170, 255), 150);
    for (int i = 0; i < 6; i++) {
      float a = T * 0.7 + i * TWO_PI / 6;
      float x = cos(a) * 380, z = -1200 + sin(a) * 380, y = -420 + sin(T * 1.3 + i) * 60;
      glowSprite(x, y, z, 70, i % 2 == 0 ? color(120, 220, 255) : color(200, 140, 255), 200);
      glowSprite(x, y, z, 18, color(255), 255);
    }
    // tesla coil lightning
    if (random(1) < 0.55) {
      stroke(170, 210, 255, 230);
      strokeWeight(2.2);
      noFill();
      float px = -1350, py = -540, pz = -1630;
      PVector end = new PVector(-1350 + random(-420, 420), random(-700, -60), -1630 + random(-380, 380));
      beginShape();
      for (int k = 0; k <= 8; k++) {
        float t = k / 8.0;
        float jx = k == 0 || k == 8 ? 0 : random(-40, 40), jy = k == 0 || k == 8 ? 0 : random(-40, 40);
        vertex(lerp(px, end.x, t) + jx, lerp(py, end.y, t) + jy, lerp(pz, end.z, t) + jx);
      }
      endShape();
      noStroke();
      glowSprite(end.x, end.y, end.z, 90, color(150, 200, 255), 200);
      if (random(1) < 0.08 && PVector.dist(cam.pos, new PVector(px, py, pz)) < 1800) sfx.play(sfx.zap, 0.18, random(0.8, 1.3));
    }
    glowSprite(-1350, -540, -1630, 260, color(120, 170, 255), 120);
    // server rack status lights
    for (int r = 0; r < 2; r++) {
      for (int i = 0; i < 18; i++) {
        boolean on = noise(i * 3.1 + r * 10, T * 2.5) > 0.5;
        if (!on) continue;
        float y = -380 + (i % 9) * 40, z = 1270 + r * 250 + (i / 9) * 120;
        glowSprite(995, y, z + 30, 26, i % 4 == 0 ? color(255, 120, 80) : color(100, 255, 160), 230);
      }
    }
    // bubbles over the beakers
    if (frameCount % 4 == 0) parts.emit(-820 + int(random(5)) * 110, -170, 1400, random(-6, 6), -60, random(-6, 6), 1.2, 9, color(160, 255, 200), 0, 0.3);
    for (Sign s : signs) s.draw();
  }

  // ---------------------------------------------------------------- physics queries
  // push a sphere out of every box; returns the last contact normal (or null).
  // skip, if given, may let the sphere pass through a box face (portals).
  PVector collideSphere(PVector p, PVector v, float r, PassFilter skip) {
    PVector contact = null;
    for (Box b : boxes) {
      if (p.x < b.x0 - r || p.x > b.x1 + r || p.y < b.y0 - r || p.y > b.y1 + r || p.z < b.z0 - r || p.z > b.z1 + r) continue;
      float qx = constrain(p.x, b.x0, b.x1), qy = constrain(p.y, b.y0, b.y1), qz = constrain(p.z, b.z0, b.z1);
      float dx = p.x - qx, dy = p.y - qy, dz = p.z - qz;
      float d2 = dx * dx + dy * dy + dz * dz;
      if (d2 > r * r) continue;
      PVector n;
      float pen;
      if (d2 > 1e-6) {
        float d = sqrt(d2);
        n = new PVector(dx / d, dy / d, dz / d);
        pen = r - d;
      } else {
        // centre is inside the box: leave by the nearest face
        float[] ds = { p.x - b.x0, b.x1 - p.x, p.y - b.y0, b.y1 - p.y, p.z - b.z0, b.z1 - p.z };
        int best = 0;
        for (int i = 1; i < 6; i++) if (ds[i] < ds[best]) best = i;
        n = faceNormal(best);
        pen = ds[best] + r;
      }
      int face = dominantFace(n);
      if (skip != null && skip.passes(b, face, p, r)) continue;
      p.add(PVector.mult(n, pen));
      float vn = v.dot(n);
      if (vn < 0) v.sub(PVector.mult(n, vn));
      contact = n;
    }
    return contact;
  }

  // bounce a moving body off the lab: restitution e, friction mu (per second), substep h.
  // Returns the hardest impact speed this step (0 = no contact); nOut = contact normal.
  float collideBody(PVector p, PVector v, float r, float e, float mu, float h, PassFilter skip, PVector nOut) {
    return collideBody(p, v, r, e, mu, h, skip, nOut, null);
  }

  // safe = a recent position known to be outside every box: if the centre has
  // ended up inside a box, it leaves through the side it came from (never
  // squeezed out of the far side of a thin wall)
  float collideBody(PVector p, PVector v, float r, float e, float mu, float h, PassFilter skip, PVector nOut, PVector safe) {
    float impact = 0;
    for (Box b : boxes) {
      if (p.x < b.x0 - r || p.x > b.x1 + r || p.y < b.y0 - r || p.y > b.y1 + r || p.z < b.z0 - r || p.z > b.z1 + r) continue;
      float qx = constrain(p.x, b.x0, b.x1), qy = constrain(p.y, b.y0, b.y1), qz = constrain(p.z, b.z0, b.z1);
      float dx = p.x - qx, dy = p.y - qy, dz = p.z - qz;
      float d2 = dx * dx + dy * dy + dz * dz;
      if (d2 > r * r) continue;
      PVector n;
      float pen;
      if (d2 > 1e-6) {
        float d = sqrt(d2);
        n = new PVector(dx / d, dy / d, dz / d);
        pen = r - d;
      } else {
        float[] ds = { p.x - b.x0, b.x1 - p.x, p.y - b.y0, b.y1 - p.y, p.z - b.z0, b.z1 - p.z };
        int best = -1;
        if (safe != null) {
          // only faces that the safe position is outside of
          boolean[] ok = { safe.x < b.x0, safe.x > b.x1, safe.y < b.y0, safe.y > b.y1, safe.z < b.z0, safe.z > b.z1 };
          for (int i = 0; i < 6; i++) if (ok[i] && (best < 0 || ds[i] < ds[best])) best = i;
        }
        if (best < 0) {
          best = 0;
          for (int i = 1; i < 6; i++) if (ds[i] < ds[best]) best = i;
        }
        n = faceNormal(best);
        pen = ds[best] + r;
      }
      if (skip != null && skip.passes(b, dominantFace(n), p, r)) continue;
      p.add(PVector.mult(n, pen));
      float vn = v.dot(n);
      if (vn < 0) {
        impact = max(impact, -vn);
        PVector vt = PVector.sub(v, PVector.mult(n, vn));
        vt.mult(exp(-mu * h * 6));
        float out = -vn * e;
        if (out < 40) out = 0;                     // settle instead of jittering
        v.set(PVector.add(vt, PVector.mult(n, out)));
        nOut.set(n);
      }
    }
    return impact;
  }

  Box insideAnyBox(PVector p) {
    for (Box b : boxes) if (p.x > b.x0 && p.x < b.x1 && p.y > b.y0 && p.y < b.y1 && p.z > b.z0 && p.z < b.z1) return b;
    return null;
  }

  int dominantFace(PVector n) {
    float ax = abs(n.x), ay = abs(n.y), az = abs(n.z);
    if (ax >= ay && ax >= az) return n.x < 0 ? FACE_NX : FACE_PX;
    if (ay >= az) return n.y < 0 ? FACE_NY : FACE_PY;
    return n.z < 0 ? FACE_NZ : FACE_PZ;
  }

  // nearest box face hit by a ray (slab method)
  RayHit raycast(PVector o, PVector d, float maxT) {
    RayHit best = new RayHit();
    best.t = maxT;
    for (Box b : boxes) {
      float tmin = -Float.MAX_VALUE, tmax = Float.MAX_VALUE;
      int face = -1;
      float[] lo = { b.x0, b.y0, b.z0 }, hi = { b.x1, b.y1, b.z1 };
      float[] oo = { o.x, o.y, o.z }, dd = { d.x, d.y, d.z };
      boolean miss = false;
      for (int a = 0; a < 3; a++) {
        if (abs(dd[a]) < 1e-9) {
          if (oo[a] < lo[a] || oo[a] > hi[a]) { miss = true; break; }
          continue;
        }
        float t1 = (lo[a] - oo[a]) / dd[a], t2 = (hi[a] - oo[a]) / dd[a];
        int f1 = a * 2, f2 = a * 2 + 1;        // entering through the low face has normal -axis
        if (t1 > t2) { float tt = t1; t1 = t2; t2 = tt; int ff = f1; f1 = f2; f2 = ff; }
        if (t1 > tmin) { tmin = t1; face = f1; }
        if (t2 < tmax) tmax = t2;
        if (tmin > tmax) { miss = true; break; }
      }
      if (miss || face < 0 || tmin < 0 || tmin >= best.t) continue;
      best.t = tmin;
      best.box = b;
      best.face = face;
    }
    if (best.box != null) {
      best.p = PVector.add(o, PVector.mult(d, best.t));
      best.n = faceNormal(best.face);
    }
    return best;
  }
}

interface PassFilter {
  boolean passes(Box b, int face, PVector p, float r);
}

// floating holographic sign (drawn in the glow pass)
class Sign {
  PImage img;
  float x, y, z, rotY, w;

  Sign(String title, String sub, int c, float x, float y, float z, float rotY, float w) {
    img = makeSign(title, sub, c);
    this.x = x;
    this.y = y;
    this.z = z;
    this.rotY = rotY;
    this.w = w;
  }

  void draw() {
    float h = w * img.height / img.width;
    pushMatrix();
    translate(x, y + sin(T * 1.3 + x * 0.01) * 8, z);
    rotateY(rotY);
    // readable from both sides
    if ((cam.pos.x - x) * sin(rotY) + (cam.pos.z - z) * cos(rotY) < 0) rotateY(PI);
    noStroke();
    tint(255, 200 + 55 * sin(T * 9 + x) * sin(T * 3.1));
    beginShape(QUADS);
    texture(img);
    vertex(-w / 2, -h / 2, 0, 0, 0);
    vertex(w / 2, -h / 2, 0, 1, 0);
    vertex(w / 2, h / 2, 0, 1, 1);
    vertex(-w / 2, h / 2, 0, 0, 1);
    endShape();
    noTint();
    popMatrix();
  }
}


// ======================================================================
// TAB: MathUtil.pde
// ======================================================================
// Small helpers shared by every tab.

float easeOutBack(float t) {
  t = constrain(t, 0, 1);
  float c1 = 1.70158, c3 = c1 + 1;
  return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2);
}

float smooth01(float t) {
  t = constrain(t, 0, 1);
  return t * t * (3 - 2 * t);
}

String f1(float v) { return nf(v, 0, 1); }

// metres with 2 decimals, never "-0.00"
String fm(float v) {
  if (abs(v) < 0.005) v = 0;
  return nf(v, 0, 2);
}
String f2(float v) { return nf(v, 0, 2); }

// a whole number for display (nf(x, 0, 0) keeps up to three decimals)
String i0(float v) {
  return str(round(v));
}

// rounded rectangle in the current fill / stroke. rect(x, y, w, h, r) sends P3D through its slow
// polygon tessellator every call; a convex fan (fill) plus a closed line loop (outline) does not
void roundBox(float x, float y, float w, float h, float r) {
  r = min(r, min(w, h) / 2);
  if (g.fill) {
    pushStyle();
    noStroke();
    beginShape(TRIANGLE_FAN);
    vertex(x + w / 2, y + h / 2);
    roundBoxPath(x, y, w, h, r);
    vertex(x + w - r, y);              // close the fan
    endShape();
    popStyle();
  }
  if (g.stroke) {
    pushStyle();
    noFill();
    beginShape();
    roundBoxPath(x, y, w, h, r);
    endShape(CLOSE);
    popStyle();
  }
}

void roundBoxPath(float x, float y, float w, float h, float r) {
  for (int c = 0; c < 4; c++) {
    float cx = (c == 0 || c == 1) ? x + w - r : x + r;
    float cy = (c == 1 || c == 2) ? y + h - r : y + r;
    float a0 = -HALF_PI + c * HALF_PI;
    for (int i = 0; i <= 6; i++) {
      float a = a0 + HALF_PI * i / 6;
      vertex(cx + cos(a) * r, cy + sin(a) * r);
    }
  }
}


// ======================================================================
// TAB: Particle.pde
// ======================================================================
// Particle (one spark), the pooled Particles system (every Particle made once,
// no per-frame allocation) and in-plane shockwave rings. All drawn additively.

// one spark of light
class Particle {
  float x, y, z, vx, vy, vz;
  float life, maxLife, size, grav, drag;
  int col;

  void step(float dt) {
    float k = exp(-drag * dt);
    vx *= k;
    vy = vy * k + grav * dt;
    vz *= k;
    x += vx * dt;
    y += vy * dt;
    z += vz * dt;
  }
}

// the pool: every Particle is made once up front; the live ones are pool[0 .. count-1]
class Particles {
  final int CAP = 1400;
  Particle[] pool = new Particle[CAP];
  int count;

  Particles() {
    for (int i = 0; i < CAP; i++) pool[i] = new Particle();
  }

  void emit(float px, float py, float pz, float pvx, float pvy, float pvz, float plife, float psize, int pcol, float pgrav, float pdrag) {
    Particle q;
    if (count < CAP) q = pool[count++];
    else q = pool[(int) random(CAP)];        // full: overwrite a random one
    q.x = px; q.y = py; q.z = pz;
    q.vx = pvx; q.vy = pvy; q.vz = pvz;
    q.life = q.maxLife = plife;
    q.size = psize;
    q.col = pcol;
    q.grav = pgrav;
    q.drag = pdrag;
  }

  void emit(PVector p, PVector v, float plife, float psize, int pcol, float pgrav, float pdrag) {
    emit(p.x, p.y, p.z, v.x, v.y, v.z, plife, psize, pcol, pgrav, pdrag);
  }

  // a ball of sparks
  void burst(PVector p, int n, float speed, int c, float lifeMax, float sizeMax) {
    for (int k = 0; k < n; k++) {
      PVector d = PVector.random3D().mult(speed * random(0.3, 1));
      emit(p, d, random(0.3, lifeMax), random(sizeMax * 0.4, sizeMax), c, 300, 2.2);
    }
  }

  void update(float dt) {
    for (int i = count - 1; i >= 0; i--) {
      Particle q = pool[i];
      q.life -= dt;
      if (q.life <= 0) {
        // swap the dead one past the end of the live range
        count--;
        pool[i] = pool[count];
        pool[count] = q;
        continue;
      }
      q.step(dt);
    }
  }

  // one batch of camera-facing textured quads
  void draw() {
    if (count == 0) return;
    float rx = cam.right.x, ry = cam.right.y, rz = cam.right.z;
    float ux = cam.up.x, uy = cam.up.y, uz = cam.up.z;
    noStroke();
    beginShape(QUADS);
    texture(texGlow);
    for (int i = 0; i < count; i++) {
      Particle q = pool[i];
      float a = q.life / q.maxLife;
      float s = q.size * (0.4 + 0.6 * a) * 0.5;
      int c = q.col;
      tint((c >> 16) & 255, (c >> 8) & 255, c & 255, 255 * min(1, a * 1.6));
      float ax = (rx + ux) * s, ay = (ry + uy) * s, az = (rz + uz) * s;
      float bx = (rx - ux) * s, by = (ry - uy) * s, bz = (rz - uz) * s;
      vertex(q.x - ax, q.y - ay, q.z - az, 0, 0);
      vertex(q.x + bx, q.y + by, q.z + bz, 1, 0);
      vertex(q.x + ax, q.y + ay, q.z + az, 1, 1);
      vertex(q.x - bx, q.y - by, q.z - bz, 0, 1);
    }
    endShape();
    noTint();
  }
}

// expanding ring lying in a plane (portal openings, impacts)
class Shockwave {
  PVector c, a, b;          // centre and the two in-plane axes
  float age, life, maxR;
  int col;

  Shockwave(PVector c, PVector a, PVector b, float maxR, float life, int col) {
    this.c = c.copy();
    this.a = a.copy();
    this.b = b.copy();
    this.maxR = maxR;
    this.life = life;
    this.col = col;
  }

  boolean dead() { return age >= life; }

  void draw() {
    float p = age / life;
    float r = maxR * (1 - pow(1 - p, 3));
    noStroke();
    tint(red(col), green(col), blue(col), 255 * (1 - p));
    beginShape(QUADS);
    texture(texRing);
    shockV(-r, -r, 0, 0);
    shockV(r, -r, 1, 0);
    shockV(r, r, 1, 1);
    shockV(-r, r, 0, 1);
    endShape();
    noTint();
  }

  void shockV(float i, float j, float u, float v) {
    vertex(c.x + a.x * i + b.x * j, c.y + a.y * i + b.y * j, c.z + a.z * i + b.z * j, u, v);
  }
}


// ======================================================================
// TAB: PlayerCamera.pde
// ======================================================================
// The player IS the camera: a floating viewpoint with no body.
// Smooth acceleration, collision with the lab, and mouse-look that
// keeps working on macOS/Windows/Linux by re-centring the hidden
// pointer only when it drifts toward the window edge.

class PlayerCamera {
  PVector pos = new PVector(), vel = new PVector();
  float yaw, pitch;                       // yaw 0 looks down -Z, pitch > 0 looks up
  PVector fwd = new PVector(), right = new PVector(), up = new PVector();
  final float RADIUS = 24;
  final float FOV = PI / 3, NEAR = 5, FAR = 60000;
  float sensitivity = 0.0028;
  boolean captured;
  boolean noclip;
  float lastMX, lastMY;
  boolean resetRef = true;
  com.jogamp.newt.opengl.GLWindow win;
  boolean movedThisFrame;
  float teleportFlash;
  boolean awaitCentre;                    // right after capture: skip stale events queued before the warp landed
  int captureMs;
  int askMs;                              // when a re-centre was requested and hasn't been seen to land yet
  boolean warpBroken;                     // the OS ignores warpPointer (macOS without Accessibility permission)

  PlayerCamera(float x, float y, float z) {
    pos.set(x, y, z);
    Object n = surface.getNative();
    if (n instanceof com.jogamp.newt.opengl.GLWindow) win = (com.jogamp.newt.opengl.GLWindow) n;
    updateBasis();
  }

  void updateBasis() {
    pitch = constrain(pitch, -1.55, 1.55);
    float cp = cos(pitch);
    fwd.set(sin(yaw) * cp, -sin(pitch), -cos(yaw) * cp);
    right.set(cos(yaw), 0, sin(yaw));
    up = fwd.cross(right);                // screen-up (points to -Y when level)
  }

  // point the camera along a direction (used after travelling through a portal)
  void lookAlong(PVector d) {
    PVector n = d.copy().normalize();
    pitch = asin(constrain(-n.y, -1, 1));
    yaw = atan2(n.x, -n.z);
    updateBasis();
  }

  // same, but when the new direction is (nearly) straight up/down - where the
  // heading is undefined - take it from the old screen-up carried through the portal
  void lookAlong(PVector d, PVector upHint) {
    PVector n = d.copy().normalize();
    pitch = asin(constrain(-n.y, -1, 1));
    PVector h = new PVector(n.x, 0, n.z);
    float hm = h.mag();
    // looking up: flat-forward = -screenUp ; looking down: flat-forward = +screenUp
    PVector hu = new PVector(upHint.x, 0, upHint.z).mult(n.y < 0 ? -1 : 1);
    float w = constrain(1 - hm / 0.15, 0, 1);            // only within ~8 degrees of vertical
    if (hm > 1e-6) h.div(hm);
    if (hu.magSq() > 1e-12) h = PVector.add(PVector.mult(h, 1 - w), PVector.mult(hu.normalize(), w));
    if (h.magSq() > 1e-12) yaw = atan2(h.x, -h.z);
    updateBasis();
  }

  void update(float dt) {
    // keyboard look (fallback for touchpads / when the mouse can't be captured)
    float kl = 1.9 * dt;
    if (kLookL) yaw -= kl;
    if (kLookR) yaw += kl;
    if (kLookU) pitch += kl;
    if (kLookD) pitch -= kl;
    edgeTurn(dt);
    updateBasis();

    PVector wish = new PVector();
    PVector flatF = new PVector(sin(yaw), 0, -cos(yaw));
    PVector flatR = new PVector(cos(yaw), 0, sin(yaw));
    if (kW) wish.add(flatF);
    if (kS) wish.sub(flatF);
    if (kD) wish.add(flatR);
    if (kA) wish.sub(flatR);
    if (kUp) wish.y -= 1;
    if (kDown || kDown2) wish.y += 1;
    movedThisFrame = wish.magSq() > 0;
    if (movedThisFrame) wish.normalize();
    float speed = (kFast ? 19 : 6.5) * M;
    PVector target = PVector.mult(wish, speed);
    float k = 1 - exp(-dt * (movedThisFrame ? 7 : 5));
    vel.lerp(target, k);

    // move in small steps so we never tunnel through a thin wall
    int n = max(1, ceil(vel.mag() * dt / (RADIUS * 0.5)));
    float h = dt / n;
    for (int i = 0; i < n; i++) {
      PVector before = pos.copy();
      pos.add(PVector.mult(vel, h));          // vel can change mid-frame (portal, wall)
      if (!noclip) lab.collideSphere(pos, vel, RADIUS, portals);
      onMoved(before);
    }
  }

  // did that step carry us through a portal?
  void onMoved(PVector before) {
    Portal q = portals.crossed(before, pos);
    if (q == null) return;
    PVector newFwd = portals.mapDir(q, fwd);
    PVector newUp = portals.mapDir(q, up);
    pos.set(portals.mapPoint(q, pos, 0.5));
    vel.set(portals.mapDir(q, vel));
    lookAlong(newFwd, newUp);
    portals.exitFx(q, pos, 1);
    q.splash(PVector.add(q.c, PVector.mult(q.n, 10)), 0.8);
    sfx.play(sfx.teleport, 0.7, 1);
    teleportFlash = 1;
    onCameraTeleported(q);
  }

  void apply() {
    perspective(FOV, width / (float) height, NEAR, FAR);
    camera(pos.x, pos.y, pos.z, pos.x + fwd.x, pos.y + fwd.y, pos.z + fwd.z, 0, 1, 0);
  }

  // ---------------------------------------------------------------- mouse
  void capture(boolean on) {
    captured = on;
    resetRef = true;
    if (on) {
      noCursor();
      awaitCentre = true;
      captureMs = millis();
      askMs = 0;
      warpBroken = false;                 // give the warp another chance on every capture
      if (win != null) {
        try {
          win.confinePointer(true);
        } catch (Exception e) {
          // some window systems refuse - arrow keys still look around
        }
      }
      recentre();
    } else {
      cursor();                           // the system arrow (cursor(ARROW) swaps in a low-res bitmap)
      if (win != null) {
        try {
          win.confinePointer(false);
        } catch (Exception e) {
        }
      }
    }
  }

  // warpPointer works in surface pixels, which differ from sketch units at pixelDensity 2
  void recentre() {
    if (win == null) return;
    try {
      win.warpPointer(win.getSurfaceWidth() / 2, win.getSurfaceHeight() / 2);
    } catch (Exception e) {
    }
  }

  void mouseMovedTo(float x, float y) {
    if (!captured) return;
    if (askMs > 0 && abs(x - width / 2) < width * 0.1 && abs(y - height / 2) < height * 0.1) {
      // the re-centre landed; one landing right on the centre also proves a "broken" warp works after all
      if (warpBroken && abs(x - width / 2) <= 3 && abs(y - height / 2) <= 3 && millis() - askMs < 150) warpBroken = false;
      askMs = 0;
    }
    if (awaitCentre) {
      // events queued before the capture warp landed still carry the click position - wait for the centre
      boolean atCentre = abs(x - width / 2) <= 3 && abs(y - height / 2) <= 3;
      if (!atCentre && millis() - captureMs < 250) return;
      awaitCentre = false;
      resetRef = true;
    }
    if (resetRef) {
      lastMX = x;
      lastMY = y;
      resetRef = false;
      return;
    }
    float dx = x - lastMX, dy = y - lastMY;
    lastMX = x;
    lastMY = y;
    // a huge jump is the pointer being warped back to the centre, not the player
    if (abs(dx) > width * 0.22 || abs(dy) > height * 0.22) return;
    yaw += dx * sensitivity;
    pitch -= dy * sensitivity;
    updateBasis();
    // only re-centre when the hidden pointer drifts near the edge
    if (win != null && !warpBroken && nearEdge(x, y)) {
      recentre();
      if (askMs == 0) askMs = max(1, millis());   // a working warp lands (and reports back) within a frame or two
    }
  }

  // fallback when the pointer can't be re-centred: keep turning while it sits near a window edge
  boolean nearEdge(float x, float y) {
    return x < width * 0.25 || x > width * 0.75 || y < height * 0.25 || y > height * 0.75;
  }

  void edgeTurn(float dt) {
    if (!captured || win == null) return;
    boolean edge = nearEdge(mouseX, mouseY);
    // asked for a re-centre long ago and the pointer is still out at the edge: the OS ignores the warp
    if (!warpBroken && askMs > 0 && millis() - askMs > 400 && edge) warpBroken = true;
    // keep checking now and then, in case it starts working
    if (warpBroken && edge && millis() - askMs > 600) {
      recentre();
      askMs = max(1, millis());
    }
    if (!warpBroken) return;
    float ex = (mouseX - width * 0.5) / (width * 0.5), ey = (mouseY - height * 0.5) / (height * 0.5);
    float sx = constrain((abs(ex) - 0.8) / 0.2, 0, 1), sy = constrain((abs(ey) - 0.8) / 0.2, 0, 1);
    yaw += Math.signum(ex) * sx * 2.4 * dt;
    pitch -= Math.signum(ey) * sy * 1.6 * dt;
  }

  void drawCrosshair() {
    float cx = width / 2, cy = height / 2;
    int c = portals.p[gun.next].colLight;
    stroke(red(c), green(c), blue(c), 210);
    strokeWeight(1.5);
    noFill();
    ellipse(cx, cy, 14, 14);
    line(cx - 12, cy, cx - 5, cy);
    line(cx + 5, cy, cx + 12, cy);
    line(cx, cy - 12, cx, cy - 5);
    line(cx, cy + 5, cx, cy + 12);
    noStroke();
    fill(red(c), green(c), blue(c), 200);
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(gun.next == 0 ? "A" : "B", cx + 9, cy - 6);
  }
}


// ======================================================================
// TAB: Portal.pde
// ======================================================================
// Portals: an oval opening stuck flush to a lab surface, described by a
// centre c and an orthonormal frame (r = right, u = up, n = out of the wall).
// Entering A's front comes out of B's front: local (x, y, z) -> (-x, y, -z).

final float PORTAL_HW = 68, PORTAL_HH = 110;          // half width / half height

class Portal {
  int id;                       // 0 = A, 1 = B
  boolean active;
  PVector c = new PVector(), n = new PVector(), u = new PVector(), r = new PVector();
  Box box;
  int face = -1;
  float open;                   // 0..1 formation
  float age;
  float spin;                   // extra in-plane rotation set by the player (radians)
  int col, colDark, colLight;

  Portal(int id) {
    this.id = id;
    col = id == 0 ? color(110, 255, 70) : color(40, 255, 175);
    colDark = id == 0 ? color(20, 110, 25) : color(10, 105, 80);
    colLight = id == 0 ? color(225, 255, 190) : color(200, 255, 235);
  }

  String label() { return id == 0 ? "A" : "B"; }

  void set(PVector c, PVector n, PVector u, Box box, int face) {
    this.c.set(c);
    this.n.set(n);
    this.u.set(u);
    this.r = n.cross(u);
    this.box = box;
    this.face = face;
    active = true;
    open = 0;
    age = 0;
  }

  // rotate the portal in its own plane (manipulation mode)
  void rotateInPlane(float ang) {
    PVector nu = PVector.add(PVector.mult(u, cos(ang)), PVector.mult(r, sin(ang)));
    u.set(nu.normalize());
    r = n.cross(u);
  }

  PVector toLocal(PVector p) {
    PVector d = PVector.sub(p, c);
    return new PVector(d.dot(r), d.dot(u), d.dot(n));
  }

  PVector toWorld(PVector l) {
    return new PVector(c.x + r.x * l.x + u.x * l.y + n.x * l.z,
                       c.y + r.y * l.x + u.y * l.y + n.y * l.z,
                       c.z + r.z * l.x + u.z * l.y + n.z * l.z);
  }

  PVector dirToLocal(PVector v) {
    return new PVector(v.dot(r), v.dot(u), v.dot(n));
  }

  PVector dirToWorld(PVector l) {
    return new PVector(r.x * l.x + u.x * l.y + n.x * l.z,
                       r.y * l.x + u.y * l.y + n.y * l.z,
                       r.z * l.x + u.z * l.y + n.z * l.z);
  }

  // is a local (x, y) inside the oval (k < 1 shrinks it)?
  boolean insideOval(float lx, float ly, float k) {
    float a = lx / (PORTAL_HW * k), b = ly / (PORTAL_HH * k);
    return a * a + b * b < 1;
  }

  LiquidSurface liquid = new LiquidSurface();
  float rippleAge = 99;         // seconds since something splashed through
  float jig;                    // wobble impulse

  void update(float dt) {
    if (!active) return;
    age += dt;
    open = min(1, open + dt / 0.55);
    rippleAge += dt;
    jig *= exp(-dt * 4);
    if (open < 0.5) return;
    // droplets flung off the spinning rim
    if (random(1) < 0.55) {
      float a = random(TWO_PI);
      PVector p = toWorld(new PVector(cos(a) * PORTAL_HW, sin(a) * PORTAL_HH, 8));
      PVector tangent = dirToWorld(new PVector(sin(a) * PORTAL_HW, -cos(a) * PORTAL_HH, 0)).normalize();
      PVector radial = dirToWorld(new PVector(cos(a) * PORTAL_HH, sin(a) * PORTAL_HW, 0)).normalize();
      PVector v = PVector.mult(tangent, random(120, 260));
      v.add(PVector.mult(radial, random(30, 110))).add(PVector.mult(n, random(60, 160)));
      parts.emit(p, v, random(0.5, 0.9), random(7, 13), lerpColor(col, colLight, random(0.6)), 650, 0.6);
    }
    // glowing motes being sucked into the eye
    if (random(1) < 0.5) {
      float a = random(TWO_PI);
      float rr = random(0.5, 0.95);
      PVector p = toWorld(new PVector(cos(a) * PORTAL_HW * rr, sin(a) * PORTAL_HH * rr, 30));
      PVector v = dirToWorld(new PVector(-cos(a) * 140 + sin(a) * 160, -sin(a) * 140 - cos(a) * 160, -25));
      parts.emit(p, v, random(0.35, 0.6), random(6, 11), colLight, 0, 0.5);
    }
  }

  // something went through: ripple + splash
  void splash(PVector where, float strength) {
    rippleAge = 0;
    jig = min(1.5, jig + strength);
    for (int i = 0; i < 26 * strength; i++) {
      PVector v = PVector.add(PVector.random3D().mult(random(150, 420)), PVector.mult(n, random(100, 380)));
      parts.emit(where, v, random(0.4, 0.9), random(8, 18), lerpColor(col, colLight, random(1)), 650, 0.8);
    }
  }

  float pulse() { return 0.82 + 0.18 * sin(age * 6 + id * 2); }

  float scaleNow() { return easeOutBack(open) * (1 + 0.05 * jig * sin(age * 22)); }

  // multiply the current matrix by the portal frame (local x = r, y = u, z = n)
  void applyFrame(float lift) {
    PVector o = PVector.add(c, PVector.mult(n, lift));
    applyMatrix(r.x, u.x, n.x, o.x,
                r.y, u.y, n.y, o.y,
                r.z, u.z, n.z, o.z,
                0, 0, 0, 1);
  }

  // the liquid vortex (solid pass, unlit, depth-tested)
  void drawSolid() {
    if (!active || open <= 0.01) return;
    float s = scaleNow();
    float lift = 0.8;
    float ripR = rippleAge * 0.9, ripA = rippleAge < 3 ? 9 * exp(-rippleAge * 2.2) : 0;
    float o = smooth01(open);
    boolean gpu = liquidShader != null && liquidMesh != null;
    if (gpu) liquid.buildRim(age);             // the vertex shader shapes the liquid
    else liquid.build(age, o, ripR, ripA);     // CPU fallback: whole height field
    PVector camL = toLocal(cam.pos);
    camL.z -= lift;
    camL.div(s);
    pushMatrix();
    applyFrame(lift);
    scale(s);
    if (gpu) {
      liquidShader.set("time", age);
      liquidShader.set("open", o);
      liquidShader.set("camLocal", camL.x, camL.y, camL.z);
      liquidShader.set("colA", red(col) / 255.0, green(col) / 255.0, blue(col) / 255.0);
      liquidShader.set("colB", red(colLight) / 255.0, green(colLight) / 255.0, blue(colLight) / 255.0);
      liquidShader.set("colC", red(colDark) / 255.0, green(colDark) / 255.0, blue(colDark) / 255.0);
      liquidShader.set("halfSize", PORTAL_HW, PORTAL_HH);
      liquidShader.set("ripR", ripR);
      liquidShader.set("ripA", ripA);
      shader(liquidShader);
      shape(liquidMesh);
      resetShader();
    } else {
      liquid.drawCPU(this, camL, age);
    }
    liquid.drawRim(this, camL, age, o);
    popMatrix();
  }

  // additive part: halo, floating energy rings above the whirlpool, opening flash
  void drawGlow() {
    if (!active || open <= 0.01) return;
    float s = scaleNow(), p = pulse();
    pushMatrix();
    applyFrame(1.5);
    scale(s);
    planeQuad(texGlow, PORTAL_HW * 3.2, PORTAL_HH * 2.8, 0, col, 120 * p);
    if (age < 0.7) planeQuad(texGlow, PORTAL_HW * 7, PORTAL_HH * 6, 0, colLight, 255 * (1 - age / 0.7));
    popMatrix();
    // rotating rings, out past the glossy rim: two counter-rotating in the plane, one tilted and precessing above it
    pushMatrix();
    applyFrame(12);
    scale(s);
    planeQuad(texRingDash, PORTAL_HW * 2.95, PORTAL_HH * 2.75, age * 1.3, col, 170 * p);
    planeQuad(texRingDash, PORTAL_HW * 3.4, PORTAL_HH * 3.15, -age * 0.8, colLight, 110 * p);
    translate(0, 0, 44);
    rotateZ(age * 0.5);
    rotateX(0.33);
    planeQuad(texRingDash, PORTAL_HW * 2.7, PORTAL_HW * 2.7, age * 2.1, colLight, 120 * p);
    popMatrix();
    // energy beads orbiting above the whirlpool, spiralling down into the eye
    for (int k = 0; k < 10; k++) {
      float ph = (age * 0.35 + k / 10.0) % 1.0;           // 0 = outer edge, 1 = in the eye
      float rr = (1 - ph) * 0.95;
      float a = k * TWO_PI / 10 - age * 2.4 - ph * 5;
      float zh = (8 + 40 * sin(PI * (1 - ph)) * (1 - ph)) * s;
      PVector w = toWorld(new PVector(cos(a) * PORTAL_HW * rr * s, sin(a) * PORTAL_HH * rr * s, zh + 2));
      float fade = sin(PI * ph);
      glowSprite(w.x, w.y, w.z, 26, colLight, 230 * fade);
      glowSprite(w.x, w.y, w.z, 60, col, 90 * fade);
    }
  }

  // a texture quad in the portal plane, elliptically stretched, rotated in texture space
  void planeQuad(PImage tex, float w, float h, float rot, int c, float a) {
    noStroke();
    tint(red(c), green(c), blue(c), a);
    beginShape(QUADS);
    texture(tex);
    for (int i = 0; i < 4; i++) {
      float cx = (i == 0 || i == 3) ? -1 : 1, cy = (i < 2) ? -1 : 1;
      float rx = cx * cos(rot) - cy * sin(rot), ry = cx * sin(rot) + cy * cos(rot);
      vertex(rx * w / 2, ry * h / 2, 0, (cx + 1) / 2, (cy + 1) / 2);
    }
    endShape();
    noTint();
  }
}

class Placement {
  PVector c, n, u;
  Box box;
  int face;
  String fail;
}

// ====================================================================
// The pair of portals and everything that needs both of them.

class PortalPair implements PassFilter {
  Portal[] p = { new Portal(0), new Portal(1) };
  ArrayList<Shockwave> waves = new ArrayList<Shockwave>();

  boolean linked() { return p[0].active && p[1].active && p[0].open > 0.6 && p[1].open > 0.6; }

  Portal other(Portal q) { return q == p[0] ? p[1] : p[0]; }

  // try to open portal `which` on a ray hit; returns null on success or the reason it failed
  String place(int which, RayHit h, PVector shotDir) {
    Placement pl = tryPlace(which, h, shotDir, 0);
    if (pl.fail != null) return pl.fail;
    Portal q = p[which];
    q.set(pl.c, pl.n, pl.u, pl.box, pl.face);
    q.spin = 0;
    openFx(q);
    return null;
  }

  // work out where a portal would go (without moving it)
  Placement tryPlace(int which, RayHit h, PVector shotDir, float spin) {
    Placement pl = new Placement();
    if (!h.hit()) { pl.fail = "NO SURFACE"; return pl; }
    if (!h.box.portalable(h.face)) { pl.fail = "SURFACE REJECTS PORTALS"; return pl; }
    PVector n = h.n.copy();
    PVector u;
    if (abs(n.y) > 0.5) {
      // floor / ceiling: the top of the portal points the way you were looking
      u = PVector.sub(shotDir, PVector.mult(n, shotDir.dot(n)));
      if (u.magSq() < 1e-4) u = new PVector(0, 0, -1);
      u.normalize();
    } else {
      u = new PVector(0, -1, 0);                     // walls: upright
    }
    if (spin != 0) {
      PVector rr = n.cross(u);
      u = PVector.add(PVector.mult(u, cos(spin)), PVector.mult(rr, sin(spin))).normalize();
    }
    PVector c = h.p.copy();
    if (!fit(c, n, u, h.box, h.face)) { pl.fail = "NOT ENOUGH ROOM"; return pl; }
    Portal o = p[1 - which];
    if (o.active && o.box == h.box && o.face == h.face) {
      PVector d = PVector.sub(c, o.c);
      float need = PORTAL_HH * 2.05;
      if (d.mag() < need) {
        if (d.magSq() < 1) d = u.copy();
        d.normalize().mult(need);
        c = PVector.add(o.c, d);
        if (!fit(c, n, u, h.box, h.face) || PVector.dist(c, o.c) < need * 0.98) { pl.fail = "TOO CLOSE TO PORTAL " + o.label(); return pl; }
      }
    }
    pl.c = c;
    pl.n = n;
    pl.u = u;
    pl.box = h.box;
    pl.face = h.face;
    return pl;
  }

  // slide the centre so the whole oval fits on the face; false if the face is too small
  boolean fit(PVector c, PVector n, PVector u, Box b, int face) {
    PVector r = n.cross(u);
    float[] rect = b.faceRect(face);
    PVector e1, e2;
    if (face == FACE_NX || face == FACE_PX) { e1 = new PVector(0, 1, 0); e2 = new PVector(0, 0, 1); }
    else if (face == FACE_NY || face == FACE_PY) { e1 = new PVector(1, 0, 0); e2 = new PVector(0, 0, 1); }
    else { e1 = new PVector(1, 0, 0); e2 = new PVector(0, 1, 0); }
    float m = 6;
    float ext1 = sqrt(sq(PORTAL_HW * r.dot(e1)) + sq(PORTAL_HH * u.dot(e1))) + m;
    float ext2 = sqrt(sq(PORTAL_HW * r.dot(e2)) + sq(PORTAL_HH * u.dot(e2))) + m;
    if (rect[1] - rect[0] < ext1 * 2 || rect[3] - rect[2] < ext2 * 2) return false;
    float a = constrain(c.dot(e1), rect[0] + ext1, rect[1] - ext1);
    float bb = constrain(c.dot(e2), rect[2] + ext2, rect[3] - ext2);
    float plane = b.facePlane(face);
    // slide out from under anything standing on (or hanging over) this face:
    // test panels on the floor, the back wall under the ceiling, ...
    PVector nn = faceNormal(face);
    float side = nn.x + nn.y + nn.z;
    PVector nAx = new PVector(abs(nn.x), abs(nn.y), abs(nn.z));
    for (int iter = 0; iter < 4; iter++) {
      boolean moved = false;
      for (Box o : lab.boxes) {
        if (o == b) continue;
        float lo = o.x0 * nAx.x + o.y0 * nAx.y + o.z0 * nAx.z, hi = o.x1 * nAx.x + o.y1 * nAx.y + o.z1 * nAx.z;
        float probe = plane + side;
        if (probe <= lo || probe >= hi) continue;
        float o1a = e1.x * o.x0 + e1.y * o.y0 + e1.z * o.z0, o1b = e1.x * o.x1 + e1.y * o.y1 + e1.z * o.z1;
        float o2a = e2.x * o.x0 + e2.y * o.y0 + e2.z * o.z0, o2b = e2.x * o.x1 + e2.y * o.y1 + e2.z * o.z1;
        float p1 = min(a + ext1 - o1a, o1b - (a - ext1)), p2 = min(bb + ext2 - o2a, o2b - (bb - ext2));
        if (p1 <= 0 || p2 <= 0) continue;
        if (p1 < p2) a += (a < (o1a + o1b) / 2) ? -p1 : p1;
        else bb += (bb < (o2a + o2b) / 2) ? -p2 : p2;
        moved = true;
      }
      if (!moved) break;
      if (a < rect[0] + ext1 - 0.01 || a > rect[1] - ext1 + 0.01 || bb < rect[2] + ext2 - 0.01 || bb > rect[3] - ext2 + 0.01 || iter == 3) return false;
    }
    // rebuild the centre from the two in-plane coords and the plane
    PVector nAxis = new PVector(abs(n.x), abs(n.y), abs(n.z));
    c.set(PVector.add(PVector.mult(e1, a), PVector.mult(e2, bb)));
    c.add(PVector.mult(nAxis, plane));
    return true;
  }

  void openFx(Portal q) {
    PVector cc = PVector.add(q.c, PVector.mult(q.n, 4));
    waves.add(new Shockwave(cc, q.r, q.u, PORTAL_HH * 3.2, 0.7, q.col));
    waves.add(new Shockwave(cc, q.r, q.u, PORTAL_HH * 1.8, 0.45, q.colLight));
    for (int i = 0; i < 70; i++) {
      float a = random(TWO_PI), sp = random(150, 700);
      PVector v = q.dirToWorld(new PVector(cos(a) * sp, sin(a) * sp, random(20, 260)));
      parts.emit(cc, v, random(0.4, 1.1), random(10, 26), lerpColor(q.col, q.colLight, random(1)), 0, 2.5);
    }
  }

  void update(float dt) {
    for (Portal q : p) q.update(dt);
    for (int i = waves.size() - 1; i >= 0; i--) {
      Shockwave w = waves.get(i);
      w.age += dt;
      if (w.dead()) waves.remove(i);
    }
  }

  void drawSolid() {
    for (Portal q : p) q.drawSolid();
  }

  void drawGlow() {
    for (Portal q : p) q.drawGlow();
    for (Shockwave w : waves) w.draw();
  }

  // green light spilling out of open portals (uses 2 of the 8 lights)
  void lights() {
    lightFalloff(1, 0, 0.000004);
    for (Portal q : p) {
      if (!q.active) continue;
      float k = q.open * q.pulse();
      PVector lp = PVector.add(q.c, PVector.mult(q.n, 90));
      pointLight(red(q.col) * k, green(q.col) * k, blue(q.col) * k, lp.x, lp.y, lp.z);
    }
  }

  // PassFilter: let a sphere through a wall where a linked portal sits
  boolean passes(Box b, int face, PVector pos, float rad) {
    if (!linked()) return false;
    for (Portal q : p) {
      if (q.box != b || q.face != face) continue;
      PVector l = q.toLocal(pos);
      if (q.insideOval(l.x, l.y, 1)) return true;
    }
    return false;
  }

  // if the segment a->b went in through a portal's front, return that portal
  Portal crossed(PVector a, PVector b) {
    if (!linked()) return null;
    for (Portal q : p) {
      float da = PVector.sub(a, q.c).dot(q.n), db = PVector.sub(b, q.c).dot(q.n);
      if (da >= 0 && db < 0) {
        float t = da / (da - db);
        PVector hit = PVector.lerp(a, b, t);
        PVector l = q.toLocal(hit);
        if (q.insideOval(l.x, l.y, 1)) return q;
      }
    }
    return null;
  }

  // a centre that sits just behind a linked portal's mouth (closer than one radius) without having crossed it
  Portal behindMouth(PVector pt, float rad) {
    if (!linked()) return null;
    for (Portal q : p) {
      PVector l = q.toLocal(pt);
      if (l.z < 0 && l.z > -rad && q.insideOval(l.x, l.y, 1)) return q;
    }
    return null;
  }

  // portal transform for a point, a direction
  PVector mapPoint(Portal from, PVector pt, float minOut) {
    Portal to = other(from);
    PVector l = from.toLocal(pt);
    return to.toWorld(new PVector(-l.x, l.y, max(-l.z, minOut)));
  }

  PVector mapDir(Portal from, PVector v) {
    Portal to = other(from);
    PVector l = from.dirToLocal(v);
    return to.dirToWorld(new PVector(-l.x, l.y, -l.z));
  }

  // exitFx: a burst where something comes out
  void exitFx(Portal from, PVector where, float strength) {
    Portal to = other(from);
    waves.add(new Shockwave(PVector.add(to.c, PVector.mult(to.n, 5)), to.r, to.u, PORTAL_HH * 1.6 * strength, 0.4, to.colLight));
    parts.burst(where, int(24 * strength), 380, to.col, 0.7, 20);
    to.splash(PVector.add(to.c, PVector.mult(to.n, 12)), strength);
  }

  // the rotation a portal trip applies (for an object's orientation)
  PMatrix3D mapMatrix(Portal from) {
    Portal to = other(from);
    PVector[] a = { from.r, from.u, from.n };
    PVector[] b = { PVector.mult(to.r, -1), to.u, PVector.mult(to.n, -1) };
    float[][] m = new float[3][3];
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        m[i][j] = comp(b[0], i) * comp(a[0], j) + comp(b[1], i) * comp(a[1], j) + comp(b[2], i) * comp(a[2], j);
    return new PMatrix3D(m[0][0], m[0][1], m[0][2], 0, m[1][0], m[1][1], m[1][2], 0, m[2][0], m[2][1], m[2][2], 0, 0, 0, 0, 1);
  }

  float comp(PVector v, int i) { return i == 0 ? v.x : i == 1 ? v.y : v.z; }

  float distance() { return PVector.dist(p[0].c, p[1].c); }

  // angle between the two openings' facing directions, degrees
  float relativeAngle() { return degrees(acos(constrain(p[0].n.dot(p[1].n), -1, 1))); }

  // ray vs portal ovals (for selecting a portal)
  Portal rayPick(PVector o, PVector d, float maxT) {
    Portal best = null;
    float bestT = maxT;
    for (Portal q : p) {
      if (!q.active) continue;
      float den = d.dot(q.n);
      if (den >= -1e-4) continue;                 // must look at its front
      float t = PVector.sub(q.c, o).dot(q.n) / den;
      if (t < 0 || t > bestT) continue;
      PVector l = q.toLocal(PVector.add(o, PVector.mult(d, t)));
      if (q.insideOval(l.x, l.y, 1.15)) {
        best = q;
        bestT = t;
      }
    }
    return best;
  }
}


// ======================================================================
// TAB: PortalGun.pde
// ======================================================================
// The portal gun is not a weapon model on screen - it's an aiming device.
// M1 raycasts from the centre of the screen, then fires a glowing energy
// projectile from just below the view toward the hit. When it lands, the
// portal opens there (or fizzles if the surface rejects portals).

class PortalGun {
  ArrayList<Shot> shots = new ArrayList<Shot>();
  int next = 0;                 // 0 -> portal A, 1 -> portal B (alternates every shot)
  float cooldown;
  int shotsFired;
  String lastResult = "";
  final float SPEED = 7500;     // projectile speed, units/s (75 m/s)
  float device;                 // 0..1 visibility of the floating aiming device
  float recoil;

  void fire() {
    if (cooldown > 0) return;
    cooldown = 0.28;
    shotsFired++;
    RayHit h = aimRay();
    checkShotThroughRick(h);
    PVector muzzle = PVector.add(cam.pos, PVector.mult(cam.fwd, 34));
    muzzle.add(PVector.mult(cam.right, 24)).sub(PVector.mult(cam.up, 20));   // off-axis, so the bolt visibly crosses into the centre
    PVector target = h.hit() ? h.p : PVector.add(cam.pos, PVector.mult(cam.fwd, 9000));
    shots.add(new Shot(muzzle, target, h, next, cam.fwd.copy()));
    next = 1 - next;
    device = 1.6;
    recoil = 1;
    parts.burst(muzzle, 10, 160, portals.p[shots.get(shots.size() - 1).which].col, 0.25, 10);
    sfx.play(sfx.fire, 0.6, random(0.95, 1.05));
  }

  // what the centre of the screen is pointing at (lab surfaces only)
  RayHit aimRay() {
    return lab.raycast(cam.pos, cam.fwd, 20000);
  }

  void update(float dt) {
    cooldown -= dt;
    if (manip.active()) device = max(device, 1);
    device = max(0, device - dt);
    recoil *= exp(-dt * 9);
    for (int i = shots.size() - 1; i >= 0; i--) {
      Shot s = shots.get(i);
      s.update(dt);
      if (s.done) shots.remove(i);
    }
  }

  void draw() {
    for (Shot s : shots) s.draw();
    drawDevice();
  }

  // the portal gun as a small floating emitter that fades in when you use it
  void drawDevice() {
    float a = min(1, device);
    if (a <= 0.01) return;
    int c = manip.active() ? manip.sel.colLight : portals.p[next].col;
    PVector p = PVector.add(cam.pos, PVector.mult(cam.fwd, 58 - recoil * 6));
    p.add(PVector.mult(cam.right, 21 + sin(T * 2) * 0.6)).sub(PVector.mult(cam.up, 14 + cos(T * 2.3) * 0.6));
    glowSprite(p.x, p.y, p.z, 11 + recoil * 7, c, 210 * a);
    glowSprite(p.x, p.y, p.z, 5, color(255), 255 * a);
    // two little rings spinning round the emitter
    noFill();
    strokeWeight(1.3);
    for (int k = 0; k < 2; k++) {
      stroke(c, 200 * a);
      beginShape();
      for (int i = 0; i <= 24; i++) {
        float t = TWO_PI * i / 24;
        float sp = T * (k == 0 ? 5 : -4);
        PVector ax = k == 0 ? cam.right : cam.up;
        PVector bx = cam.fwd;
        float rx = cos(t) * 5.5, ry = sin(t) * 5.5;
        PVector q = PVector.add(p, PVector.mult(ax, rx * cos(sp))).add(PVector.mult(bx, rx * sin(sp))).add(PVector.mult(k == 0 ? cam.up : cam.right, ry));
        vertex(q.x, q.y, q.z);
      }
      endShape();
    }
    noStroke();
  }

  class Shot {
    PVector pos, from, to, dir, aimDir;
    RayHit hit;
    int which;
    float travelled, total, age;
    boolean done;

    Shot(PVector from, PVector to, RayHit hit, int which, PVector aimDir) {
      this.from = from.copy();
      this.to = to.copy();
      this.hit = hit;
      this.which = which;
      this.aimDir = aimDir;
      pos = from.copy();
      dir = PVector.sub(to, from);
      total = dir.mag();
      dir.normalize();
    }

    void update(float dt) {
      age += dt;
      travelled += SPEED * dt;
      if (travelled >= total) {
        pos.set(to);
        land();
        done = true;
        return;
      }
      pos = PVector.add(from, PVector.mult(dir, travelled));
      // spiralling trail
      int c = portals.p[which].col;
      for (int k = 0; k < 3; k++) {
        float a = age * 40 + k * TWO_PI / 3;
        PVector off = PVector.add(PVector.mult(cam.right, cos(a) * 6), PVector.mult(cam.up, sin(a) * 6));
        parts.emit(PVector.add(pos, off), PVector.mult(dir, -150), random(0.2, 0.45), random(8, 14), c, 0, 4);
      }
    }

    void land() {
      Portal q = portals.p[which];
      if (!hit.hit()) {
        lastResult = "SHOT LOST IN SPACE";
        hud.toast("SHOT LOST IN SPACE", color(255, 150, 110));
        sfx.play(sfx.fizzle, 0.35, 0.8);
        giveLetterBack();
        onShotLost();
        return;
      }
      String fail = portals.place(which, hit, aimDir);
      PVector at = PVector.add(hit.p, PVector.mult(hit.n, 4));
      if (fail == null) {
        lastResult = "PORTAL " + q.label() + " OPENED ON " + hit.box.name;
        hud.toast("PORTAL " + q.label() + " OPENED", q.col);
        parts.burst(at, 40, 420, q.colLight, 0.6, 22);
        sfx.play(sfx.portalOpen, 0.75, which == 0 ? 1 : 1.12);
        onPortalPlaced(q);
      } else {
        lastResult = "FIZZLED: " + fail;
        hud.toast(fail, color(255, 120, 90));
        parts.burst(at, 26, 300, color(255, 150, 90), 0.4, 14);
        PVector[] ax = planeAxes(hit.n);
        portals.waves.add(new Shockwave(at, ax[0], ax[1], 70, 0.3, color(255, 140, 80)));
        sfx.play(sfx.fizzle, 0.6, 1);
        giveLetterBack();
        onPortalFizzled(fail, hit);
      }
    }

    // a shot that didn't open anything doesn't use up its letter (unless a newer shot is already flying)
    void giveLetterBack() {
      if (shots.get(shots.size() - 1) == this) next = which;
    }

    void draw() {
      int c = portals.p[which].col;
      // about the same size on screen at any distance, so it reads as a bolt all the way to the wall
      float s = constrain(PVector.dist(pos, cam.pos) * 0.11, 22, 700);
      for (int k = 6; k >= 1; k--) {                          // comet tail
        PVector t = PVector.sub(pos, PVector.mult(dir, min(k * s * 0.22, travelled)));
        glowSprite(t.x, t.y, t.z, s * (0.8 - k * 0.1), c, 170 - k * 24);
      }
      glowSprite(pos.x, pos.y, pos.z, s, c, 235);
      glowSprite(pos.x, pos.y, pos.z, s * 0.32, color(240, 255, 230), 255);
    }
  }
}

// two axes spanning the plane with normal n
PVector[] planeAxes(PVector n) {
  PVector a = abs(n.y) > 0.9 ? new PVector(1, 0, 0) : new PVector(0, 1, 0);
  PVector x = n.cross(a).normalize();
  PVector y = n.cross(x).normalize();
  return new PVector[] { x, y };
}

// ====================================================================
// Portal manipulation: look at a portal + E to select it, then the portal
// follows the crosshair across valid surfaces. Q / R rotate it in its own
// plane (that changes which way things come out), LEFT CLICK confirms,
// RIGHT CLICK puts it back where it was.

class PortalManipulator {
  Portal sel;
  PVector oc = new PVector(), on = new PVector(), ou = new PVector();
  Box obox;
  int oface;
  float spin;
  boolean valid = true;
  String status = "";
  PVector ghost;

  boolean active() { return sel != null; }

  void select(Portal q) {
    sel = q;
    oc.set(q.c);
    on.set(q.n);
    ou.set(q.u);
    obox = q.box;
    oface = q.face;
    // keep its current rotation relative to the default orientation for this surface
    PVector ud = abs(q.n.y) > 0.5 ? PVector.sub(cam.fwd, PVector.mult(q.n, cam.fwd.dot(q.n))) : new PVector(0, -1, 0);
    if (ud.magSq() < 1e-4) ud = new PVector(0, 0, -1);
    ud.normalize();
    PVector rd = q.n.cross(ud);
    spin = atan2(q.u.dot(rd), q.u.dot(ud));
    sfx.play(sfx.select, 0.6, 1);
    hud.toast("PORTAL " + q.label() + " SELECTED", q.colLight);
    q.splash(PVector.add(q.c, PVector.mult(q.n, 10)), 0.4);
  }

  void update(float dt) {
    if (sel == null) return;
    if (kRotL) spin -= 1.7 * dt;
    if (kRotR) spin += 1.7 * dt;
    RayHit h = lab.raycast(cam.pos, cam.fwd, 20000);
    Placement pl = portals.tryPlace(sel.id, h, cam.fwd, spin);
    if (pl.fail == null) {
      if (PVector.dist(sel.c, pl.c) > 0.5 || PVector.dist(sel.u, pl.u) > 0.01) markAction();   // dragging it around counts as doing something
      sel.c.set(pl.c);
      sel.n.set(pl.n);
      sel.u.set(pl.u);
      sel.r = sel.n.cross(sel.u);
      sel.box = pl.box;
      sel.face = pl.face;
      onHoloPortalMoved(sel);
      valid = true;
      status = "REPOSITIONING";
      ghost = null;
    } else {
      valid = false;
      status = pl.fail;
      ghost = h.hit() ? h.p.copy() : null;
    }
  }

  void rotateStep(float a) {
    spin += a;
  }

  void confirm() {
    if (sel == null) return;
    sfx.play(sfx.confirm, 0.6, 1);
    sel.splash(PVector.add(sel.c, PVector.mult(sel.n, 10)), 0.7);
    hud.toast("PORTAL " + sel.label() + " LOCKED IN", sel.colLight);
    Portal q = sel;
    sel = null;
    onPortalManipulated(q);
  }

  void cancel() {
    if (sel == null) return;
    sel.c.set(oc);
    sel.n.set(on);
    sel.u.set(ou);
    sel.r = sel.n.cross(sel.u);
    sel.box = obox;
    sel.face = oface;
    sfx.play(sfx.cancel, 0.6, 1);
    hud.toast("CANCELLED - PORTAL " + sel.label() + " RESTORED", color(200, 220, 255));
    sel = null;
  }

  // holographic selection brackets + an arrow showing the portal's "up"
  void drawGlow() {
    if (sel == null) return;
    Portal q = sel;
    pushMatrix();
    q.applyFrame(6);
    noFill();
    int c = valid ? color(200, 255, 240) : color(255, 110, 90);
    stroke(c, 220);
    strokeWeight(2.5);
    float k = 1.25 + 0.05 * sin(T * 6);
    for (int i = 0; i < 4; i++) {
      float a0 = HALF_PI * i + T * 0.8, a1 = a0 + 0.9;
      beginShape();
      for (int j = 0; j <= 10; j++) {
        float a = lerp(a0, a1, j / 10.0);
        vertex(cos(a) * PORTAL_HW * k, sin(a) * PORTAL_HH * k, 0);
      }
      endShape();
    }
    // up arrow
    float top = PORTAL_HH * 1.42;
    line(0, PORTAL_HH * 1.1, 0, 0, top, 0);
    line(-14, top - 16, 0, 0, top, 0);
    line(14, top - 16, 0, 0, top, 0);
    noStroke();
    popMatrix();
    if (ghost != null && !valid) glowSprite(ghost.x, ghost.y, ghost.z, 60, color(255, 90, 70), 200);
  }
}


// ======================================================================
// TAB: PortalLiquid.pde
// ======================================================================
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
final int LQ_RINGS = 26, LQ_SEG = 88;          // CPU fallback mesh (rebuilt every frame)
final int LQ_GPU_RINGS = 48, LQ_GPU_SEG = 168;  // GPU mesh (built once; the vertex shader moves it)

// the mesh is a flat unit disc (position.xy = q); the vertex shader wobbles its rim and
// lifts it into the whirlpool with the same height function the fragment shader shades
String[] LIQUID_VERT = {
  "#define PROCESSING_TEXTURE_SHADER",
  "uniform mat4 transformMatrix;",
  "uniform float time;",
  "uniform float open;",
  "uniform vec2 halfSize;",
  "uniform float ripR;",
  "uniform float ripA;",
  "attribute vec4 position;",
  "attribute vec2 texCoord;",
  "varying vec2 vQ;",
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
  "  vec2 q = position.xy + vec2(1e-5, 0.0);",      // the centre vertex must not hit atan(0, 0)
  "  float w = rimWob(atan(q.y, q.x));",
  "  vQ = q * w;",
  "  gl_Position = transformMatrix * vec4(q * w * halfSize, hgt(q), 1.0);",
  "}"
};

PShape liquidMesh;             // static unit disc, built once

void buildLiquidMesh(int rings, int seg) {
  liquidMesh = createShape();
  liquidMesh.beginShape(TRIANGLES);
  liquidMesh.noStroke();
  liquidMesh.texture(texGlow);   // any texture: it makes Processing use the (texture-type) liquid shader
  for (int i = 0; i < rings; i++) {
    float r0 = pow(i / (float) rings, 0.85), r1 = pow((i + 1) / (float) rings, 0.85);
    for (int j = 0; j < seg; j++) {
      float a0 = TWO_PI * j / seg, a1 = TWO_PI * (j + 1) / seg;
      float x00 = cos(a0) * r0, y00 = sin(a0) * r0, x01 = cos(a1) * r0, y01 = sin(a1) * r0;
      float x10 = cos(a0) * r1, y10 = sin(a0) * r1, x11 = cos(a1) * r1, y11 = sin(a1) * r1;
      liquidMesh.vertex(x00, y00, 0, x00, y00);
      liquidMesh.vertex(x10, y10, 0, x10, y10);
      liquidMesh.vertex(x11, y11, 0, x11, y11);
      liquidMesh.vertex(x00, y00, 0, x00, y00);
      liquidMesh.vertex(x11, y11, 0, x11, y11);
      liquidMesh.vertex(x01, y01, 0, x01, y01);
    }
  }
  liquidMesh.endShape();
}

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
    buildLiquidMesh(LQ_GPU_RINGS, LQ_GPU_SEG);
  } catch (Exception e) {
    println("Liquid portal shader not available (" + e.getMessage() + ") - shading portals on the CPU.");
    liquidShader = null;
    liquidMesh = null;
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

  // GPU path: the shader moves the liquid itself, so only the rim tube needs this frame's outline
  void buildRim(float t) {
    for (int j = 0; j <= LQ_SEG; j++) {
      float th = TWO_PI * j / LQ_SEG;
      float w = lqRimWob(th, t);
      rimX[j] = cos(th) * w * PORTAL_HW;
      rimY[j] = sin(th) * w * PORTAL_HH;
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

  // glossy tube of liquid running round the edge. Its normals never change, so they're worked out once
  final int RIM_SIDES = 9;
  float[][] rnx = new float[RIM_SIDES + 1][LQ_SEG + 1], rny = new float[RIM_SIDES + 1][LQ_SEG + 1], rnz = new float[RIM_SIDES + 1][LQ_SEG + 1];

  LiquidSurface() {
    for (int k = 0; k <= RIM_SIDES; k++) {
      float f = TWO_PI * k / RIM_SIDES;
      for (int j = 0; j <= LQ_SEG; j++) {
        float th = TWO_PI * j / LQ_SEG;
        float ox = cos(th) * PORTAL_HH, oy = sin(th) * PORTAL_HW;   // ellipse outward normal
        float om = sqrt(ox * ox + oy * oy);
        rnx[k][j] = ox / om * cos(f);
        rny[k][j] = oy / om * cos(f);
        rnz[k][j] = sin(f);
      }
    }
  }

  void drawRim(Portal p, PVector camL, float t, float open) {
    float tube = 8.5 * open;
    float lm = sqrt(0.35 * 0.35 + 0.55 * 0.55 + 0.75 * 0.75);
    float lx = -0.35 / lm, ly = 0.55 / lm, lz = 0.75 / lm;
    float cr = red(p.col), cg = green(p.col), cb = blue(p.col);
    float lr = red(p.colLight), lg = green(p.colLight), lb = blue(p.colLight);
    noStroke();
    for (int k = 0; k < RIM_SIDES; k++) {
      beginShape(QUAD_STRIP);
      for (int j = 0; j <= LQ_SEG; j++) {
        float th = TWO_PI * j / LQ_SEG;
        float flow = 0.5 + 0.5 * sin(th * 6 - t * 7);
        for (int s = 0; s < 2; s++) {
          float nx = rnx[k + s][j], ny = rny[k + s][j], nz = rnz[k + s][j];
          float x = rimX[j] + nx * tube, y = rimY[j] + ny * tube, z = 4 + nz * tube;
          float vx = camL.x - x, vy = camL.y - y, vz = camL.z - z;
          float vm = max(1e-6, sqrt(vx * vx + vy * vy + vz * vz));
          vx /= vm;
          vy /= vm;
          vz /= vm;
          float hx = lx + vx, hy = ly + vy, hz = lz + vz;
          float hm = max(1e-6, sqrt(hx * hx + hy * hy + hz * hz));
          float diff = max(nx * lx + ny * ly + nz * lz, 0);
          float spec = pow(max((nx * hx + ny * hy + nz * hz) / hm, 0), 50);
          float fres = pow(1 - max(nx * vx + ny * vy + nz * vz, 0), 2.5);
          float kk = 0.45 + 0.6 * diff + 0.25 * flow;
          fill(cr * kk + 255 * spec + lr * fres * 0.6,
               cg * kk + 255 * spec + lg * fres * 0.6,
               cb * kk + 255 * spec + lb * fres * 0.6);
          vertex(x, y, z);
        }
      }
      endShape();
    }
  }
}


// ======================================================================
// TAB: PortalPhysics.pde
// ======================================================================
// FICTIONAL PORTAL PHYSICS - the numbers are real calculations on the live
// scene, the physics they pretend to describe is not.
//
//   D        = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)          metres
//   C        = 1 + 0.35 sin^2(theta / 2)        curvature coefficient (theta = angle between the openings)
//   E_portal = K x D^2 x C                      K = 0.9477 PJ/m^2  (made up, but consistent)
//   S        = E_available / E_required         stability (shown capped at 100 %)
//   ds^2     = -(c dt)^2 + dx^2 + dy^2 + dz^2   for the last jump (dt = 0, so it's spacelike - oops)
//   E        = m c^2                            rest energy of the last thing you threw through

final float C_LIGHT = 299792458;

class PortalPhysics {
  final float K = 0.9477;          // PJ per m^2
  boolean linked;
  float D, theta, C, Ereq, Eavail, S, stability = 1;
  float boost;                     // extra power from teleported batteries (decays)
  float baseOutput = 1180;         // generator output, PJ
  // last teleport event
  String lastName = "-";
  float lastIn, lastOut, lastMass, lastDs2, lastRestE, lastAgo = 999;
  int jumps;
  ThrowableObject focus;           // object whose velocity is tracked live
  boolean warned;

  void update(float dt) {
    Portal a = portals.p[0], b = portals.p[1];
    linked = a.active && b.active;
    boost = max(0, boost - dt * 25);
    Eavail = baseOutput + 70 * sin(T * 0.37) + 25 * sin(T * 2.3) + boost;
    if (linked) {
      D = portals.distance() / M;
      theta = portals.relativeAngle();
      C = 1 + 0.35 * sq(sin(radians(theta) / 2));
      Ereq = K * D * D * C;
      S = Eavail / max(Ereq, 0.001);
      stability = min(1, S);
    } else {
      D = theta = Ereq = 0;
      C = 1;
      S = 0;
      stability = 1;
    }
    lastAgo += dt;
    if (linked && stability < 0.5 && !warned) {
      warned = true;
      sfx.play(sfx.warn, 0.4, 1);
      onLowStability();
    }
    if (stability > 0.6) warned = false;
  }

  void recordTeleport(ThrowableObject o, Portal from, Portal to) {
    lastName = o.name;
    lastIn = o.speedIn;
    lastOut = o.speedOut;
    lastMass = o.mass;
    lastDs2 = D * D;                                     // dt = 0
    lastRestE = o.mass * C_LIGHT * C_LIGHT / 1e15;       // PJ
    lastAgo = 0;
    jumps++;
    focus = o;
  }

  float focusSpeed() {
    if (focus == null) return 0;
    return focus.vel.mag() / M;
  }

  String stabilityWord() {
    if (!linked) return "NO LINK";
    if (S >= 1.5) return "STABLE (SURPLUS)";
    if (S >= 1) return "STABLE";
    if (S >= 0.75) return "WOBBLY";
    if (S >= 0.5) return "UNSTABLE";
    return "CRITICAL - SPACETIME TAFFY";
  }
}

// ====================================================================
// PORTAL RESEARCH TERMINAL: a big hologram over the research console,
// redrawn a few times a second into an offscreen image. TAB shows the same
// screen full size.

class ResearchTerminal {
  PGraphics g;
  PImage img;                  // GPU-friendly copy: only re-uploaded when it changes
  PImage bg;                   // the background grid never changes: drawn once
  float refresh;
  PFont head, mono, small, val;
  float[] history = new float[160];
  int histPos;
  final float X = 1290, Y = -640, Z = -1790, ROT = -0.42, W = 980, H = 612;

  ResearchTerminal() {
    g = createGraphics(1024, 640);
    img = createImage(1024, 640, RGB);
    head = createFont("SansSerif.bold", 30, true);
    mono = createFont("Monospaced.bold", 17, true);
    small = createFont("Monospaced", 13, true);
    val = createFont("Monospaced.bold", 14, true);
    g.beginDraw();
    g.background(4, 18, 22);
    g.stroke(30, 90, 90, 60);       // faint grid
    g.strokeWeight(1);
    for (int x = 0; x < g.width; x += 32) g.line(x, 0, x, g.height);
    for (int y = 0; y < g.height; y += 32) g.line(0, y, g.width, y);
    g.endDraw();
    bg = g.get();
  }

  void update(float dt) {
    refresh -= dt;
    if (refresh <= 0) {
      refresh = hud.terminalOpen ? 0.2 : 0.3;
      history[histPos] = physics.linked ? physics.stability : -1;
      histPos = (histPos + 1) % history.length;
      if (visible()) render();
    }
  }

  // only redraw the screen when someone can actually see it
  boolean visible() {
    if (hud.terminalOpen || img.width == 0 || frameCount < 5) return true;
    PVector d = new PVector(X - cam.pos.x, Y - cam.pos.y, Z - cam.pos.z);
    return d.mag() < 6000 && d.normalize().dot(cam.fwd) > 0.2;
  }

  String m(float units) { return fm(units / M); }
  String up(float y) { return fm(-y / M); }             // show heights as positive-up

  void render() {
    PortalPhysics ph = physics;
    Portal a = portals.p[0], b = portals.p[1];
    g.beginDraw();
    g.background(bg);
    g.noStroke();
    // header
    g.fill(120, 255, 200);
    g.textFont(head);
    g.textAlign(LEFT, TOP);
    g.text("PORTAL RESEARCH TERMINAL", 22, 14);
    g.fill(255, 190, 70);
    g.rect(g.width - 330, 16, 308, 34, 6);
    g.fill(20, 10, 0);
    g.textFont(mono);
    g.textAlign(CENTER, CENTER);
    g.text("FICTIONAL PORTAL PHYSICS", g.width - 176, 32);
    g.textAlign(LEFT, TOP);
    g.textFont(small);
    g.fill(110, 200, 180);
    g.text("live numbers from the lab  -  real-ish equations  -  completely made-up portals", 24, 54);
    g.stroke(80, 220, 200, 160);
    g.line(20, 76, g.width - 20, 76);
    g.noStroke();

    float y = 86;
    g.textFont(mono);
    y = portalLine(a, y);
    y = portalLine(b, y);
    y += 6;
    String dx = ph.linked ? m(b.c.x) + " - " + m(a.c.x) : "x2 - x1";
    String dy = ph.linked ? up(b.c.y) + " - " + up(a.c.y) : "y2 - y1";
    String dz = ph.linked ? m(b.c.z) + " - " + m(a.c.z) : "z2 - z1";
    y = section("SPACETIME", "ds² = gμν dxμ dxν", y);
    y = value(ph.jumps > 0 ? "  last jump: ds² = -(c·Δt)² + Δx²+Δy²+Δz² = 0 + " + nf(ph.lastDs2, 0, 1) + " m²  (spacelike!)" : "no jumps yet - throw something through", y);
    y = section("DISTANCE", "D = √((x₂-x₁)² + (y₂-y₁)² + (z₂-z₁)²)", y);
    y = value(ph.linked ? "  = √((" + dx + ")² + (" + dy + ")² + (" + dz + ")²) = " + nf(ph.D, 0, 2) + " m" : "  = needs both portals", y);
    y = section("ENERGY", "E = mc²", y);
    y = value(ph.jumps > 0 ? "  " + ph.lastName + ": " + nf(ph.lastMass, 0, 2) + " kg × (2.998e8 m/s)² = " + nf(ph.lastRestE, 0, 1) + " PJ" : "  = (nothing has jumped yet)", y);
    y = section("PORTAL ENERGY", "E_portal = K × D² × C", y);
    y = value(ph.linked ? "  = " + nf(ph.K, 0, 4) + " PJ/m² × " + nf(ph.D, 0, 2) + "² m² × " + nf(ph.C, 0, 3) + " = " + nf(ph.Ereq, 0, 1) + " PJ" : "  = 0 PJ (portals not linked)", y);
    y = section("STABILITY", "S = E_available / E_required", y);
    y = value(ph.linked ? "  = " + nf(ph.Eavail, 0, 1) + " / " + nf(ph.Ereq, 0, 1) + " = " + nf(ph.S, 0, 2) + "  ->  " + nf(ph.stability * 100, 0, 1) + " %  " + ph.stabilityWord() : "  = no link", y);
    y = section("RELATIVE ANGLE", "θ = acos(nA · nB)      C = 1 + 0.35 sin²(θ/2)", y);
    y = value(ph.linked ? "  = " + nf(ph.theta, 0, 1) + "°          C = " + nf(ph.C, 0, 3) : "  = -", y);
    y = section("OBJECT VELOCITY", "|v| = √(vx² + vy² + vz²)", y);
    String fname = ph.focus != null ? ph.focus.name : "-";
    y = value("  = " + nf(ph.focusSpeed(), 0, 1) + " m/s  (" + fname + ")" + (ph.jumps > 0 ? "   last jump: in " + nf(ph.lastIn, 0, 2) + " -> out " + nf(ph.lastOut, 0, 2) + " m/s" : ""), y);

    drawMap(706, 92, 296, 296);
    drawStabilityGraph(706, 404, 296, 120);
    g.fill(110, 200, 180);
    g.textFont(small);
    g.text("GENERATORS " + i0(ph.Eavail) + " PJ", 706, 534);
    g.text("BATTERY BOOST " + i0(ph.boost) + " PJ   JUMPS " + ph.jumps, 706, 552);
    g.fill(255, 190, 70, 200);
    g.text("Portal mechanics on this screen are fictional. The arithmetic is real.", 24, g.height - 26);
    g.endDraw();
    g.loadPixels();
    img.loadPixels();
    arrayCopy(g.pixels, img.pixels);
    img.updatePixels();
  }

  float portalLine(Portal q, float y) {
    g.fill(q.active ? q.col : color(90));
    g.ellipse(32, y + 10, 12, 12);
    g.fill(q.active ? color(220, 255, 240) : color(120));
    String s = "PORTAL " + q.label() + "  " + (q.active ? "ACTIVE " : "OFFLINE");
    if (q.active) s += "  X " + m(q.c.x) + "  Y " + up(q.c.y) + "  Z " + m(q.c.z) + "   on " + q.box.name;
    g.text(s, 46, y);
    return y + 24;
  }

  float section(String title, String eq, float y) {
    g.textFont(mono);
    g.fill(120, 255, 200);
    g.text(title, 24, y);
    g.fill(200, 240, 255);
    g.text(eq, 196, y);
    return y + 21;
  }

  float value(String s, float y) {
    g.textFont(val);
    g.fill(255, 230, 140);
    g.text(s, 34, y);
    return y + 27;
  }

  // top-down map: deck, portals with their facing, objects, you
  void drawMap(float x, float y, float w, float h) {
    g.noFill();
    g.stroke(80, 220, 200, 160);
    g.rect(x, y, w, h);
    float s = min(w, h) / 9000.0;           // 90 m across
    float cx = x + w / 2, cy = y + h / 2;
    g.stroke(120, 200, 220, 120);
    g.rect(cx - 2000 * s, cy - 2000 * s, 4000 * s, 4000 * s);
    g.rect(cx - 350 * s, cy + 200 * s, 700 * s, 700 * s);
    g.noStroke();
    for (ThrowableObject o : objects.list) {
      if (o.gone > 0) continue;
      g.fill(o.held ? color(255, 255, 255) : color(150, 170, 190));
      g.ellipse(cx + o.pos.x * s, cy + o.pos.z * s, 4, 4);
    }
    Portal a = portals.p[0], b = portals.p[1];
    if (physics.linked) {
      g.stroke(255, 230, 140, 180);
      g.line(cx + a.c.x * s, cy + a.c.z * s, cx + b.c.x * s, cy + b.c.z * s);
    }
    for (Portal q : portals.p) {
      if (!q.active) continue;
      float px = cx + q.c.x * s, pz = cy + q.c.z * s;
      g.stroke(q.col);
      g.strokeWeight(2);
      g.line(px, pz, px + q.n.x * 18, pz + q.n.z * 18);
      g.noStroke();
      g.fill(q.col);
      g.ellipse(px, pz, 11, 11);
      g.fill(0);
      g.textFont(small);
      g.textAlign(CENTER, CENTER);
      g.text(q.label(), px, pz - 1);
      g.textAlign(LEFT, TOP);
      g.strokeWeight(1);
    }
    // you
    g.fill(255, 120, 200);
    g.pushMatrix();
    g.translate(cx + cam.pos.x * s, cy + cam.pos.z * s);
    g.rotate(atan2(cam.fwd.z, cam.fwd.x));
    g.triangle(8, 0, -6, -5, -6, 5);
    g.popMatrix();
    g.fill(110, 200, 180);
    g.textFont(small);
    g.text("TOP VIEW  (90 m)", x + 6, y + 4);
  }

  void drawStabilityGraph(float x, float y, float w, float h) {
    g.noFill();
    g.stroke(80, 220, 200, 160);
    g.rect(x, y, w, h);
    g.stroke(255, 120, 90, 120);
    g.line(x, y + h * 0.5, x + w, y + h * 0.5);
    g.stroke(120, 255, 170);
    g.strokeWeight(2);
    g.beginShape();
    for (int i = 0; i < history.length; i++) {
      float v = history[(histPos + i) % history.length];
      if (v < 0) continue;
      g.vertex(x + w * i / (history.length - 1.0), y + h - v * h);
    }
    g.endShape();
    g.strokeWeight(1);
    g.noStroke();
    g.fill(110, 200, 180);
    g.textFont(small);
    g.text("STABILITY HISTORY", x + 6, y + 4);
    g.fill(255, 140, 110);
    g.text("50%: things come out wrong", x + 6, y + h * 0.5 + 2);
  }

  // the floating hologram in the lab (glow pass)
  void drawGlow() {
    pushMatrix();
    translate(X, Y + sin(T * 0.8) * 6, Z);
    rotateY(ROT);
    noStroke();
    tint(255, 235 + 20 * sin(T * 11) * sin(T * 3.7));
    beginShape(QUADS);
    texture(img);
    vertex(-W / 2, -H / 2, 0, 0, 0);
    vertex(W / 2, -H / 2, 0, 1, 0);
    vertex(W / 2, H / 2, 0, 1, 1);
    vertex(-W / 2, H / 2, 0, 0, 1);
    endShape();
    noTint();
    // projector light from the console
    beginShape(QUADS);
    fill(60, 255, 200, 40);
    vertex(-W / 2, H / 2, 0);
    vertex(W / 2, H / 2, 0);
    fill(60, 255, 200, 0);
    vertex(W * 0.3, H / 2 + 420, 60);
    vertex(-W * 0.3, H / 2 + 420, 60);
    endShape();
    popMatrix();
  }
}


// ======================================================================
// TAB: RickDialogue.pde
// ======================================================================
// Rick: a cartoon speech box in the corner of the screen, a holographic
// head floating in the lab, an idle timer, and a lot of opinions.
//
// Idle rule: if you do nothing useful for 20 seconds (millis()-based, so it
// works at any frame rate) Rick comments, then the 20 s starts over.
// Moving, shooting, grabbing, throwing, opening the computer or moving a
// portal all count as doing something. Just looking around does not.

final float IDLE_LIMIT = 20;

String[] IDLE_LINES = {
  "You're seriously just gonna stand there?",
  "Do something already.",
  "That's your experiment? Really?",
  "Come on, genius.",
  "I've seen rocks with more initiative. Literally - there's a quantum rock right there.",
  "Hello? Is the camera on? Can floating cameras even die?",
  "I could be inventing a new colour right now and I'm babysitting you."
};
final String MAIN_IDLE_LINE = "Dazing off? Lazy a**.";

class RickDialogue {
  PImage face, faceTalk, holo, holoTalk;
  String text = "";
  float age, life;
  boolean showing;
  boolean idleLine;            // the line on screen is an idle complaint
  int lastIdleMs;              // when Rick last complained about idling
  int idleCount;
  float eventCooldown;         // keeps event jokes from spamming
  java.util.HashMap<String, Float> seen = new java.util.HashMap<String, Float>();
  java.util.HashMap<String, Integer> pick = new java.util.HashMap<String, Integer>();
  PFont font, nameFont;
  float stare;                 // seconds you've been staring at his hologram
  float holdTime;              // seconds the current object has been held
  float lastStareLine = -999;
  float stare2, lastStareLine2 = -999;         // the long stare
  boolean holoFlip, holoGlitch, pingPong;      // hanging upside down / bad reception out in space / bouncing between two portals
  Portal holoAt;                               // the portal he came out of while portalled away
  float blockT;                                // something has been sitting on his projector this long
  // a milestone line that arrived while he was busy: said as soon as the current line has been read
  String pendKey;
  String[] pendLines;
  float pendRepeat, pendT;
  final PVector holoHome = new PVector(-1100, -980, -120);
  PVector holoPos = holoHome.copy();          // where his head is right now
  PVector holoTarget = holoHome.copy();
  float holoAway;                             // > 0 while he's been portalled somewhere else
  ArrayList<Float> camJumps = new ArrayList<Float>(), dispenses = new ArrayList<Float>();

  RickDialogue() {
    face = makeRickFace(false);
    faceTalk = makeRickFace(true);
    holo = hologramise(face);
    holoTalk = hologramise(faceTalk);
    font = createFont("SansSerif.bold", 34, true);
    nameFont = createFont("SansSerif.bold", 40, true);
    lastIdleMs = millis();
  }

  // ---------------------------------------------------------------- talking
  void say(String line) {
    text = line;
    age = 0;
    life = 2.6 + line.length() / 17.0;
    showing = true;
    idleLine = false;
    lastIdleMs = millis();                  // whatever he says, the 20 s idle window starts over
    sfx.play(line.contains("*burp*") ? sfx.burp : sfx.pop, line.contains("*burp*") ? 0.7 : 0.35, 0.8);
  }

  // event joke: once per `key` per `repeat` seconds, never more often than every 6 s overall
  void event(String key, float repeat, String[] lines) {
    event(key, repeat, lines, false);
  }

  // priority: milestone / combo lines that mustn't be swallowed by the cooldown - they wait their turn instead
  void event(String key, float repeat, String[] lines, boolean priority) {
    Float last = seen.get(key);
    if (last != null && T - last < repeat) return;
    boolean idleUp = showing && idleLine && lastActionMs < lastIdleMs;   // things happening by themselves don't cut off "Lazy a**"
    if (eventCooldown > 0 || idleUp) {
      if (priority) {
        pendKey = key;
        pendLines = lines;
        pendRepeat = repeat;
        pendT = T;
      }
      return;
    }
    seen.put(key, T);
    int i = pick.containsKey(key) ? pick.get(key) : 0;
    pick.put(key, i + 1);
    say(lines[i % lines.length]);
    eventCooldown = 6;
  }

  void update(float dt) {
    eventCooldown -= dt;
    if (pendKey != null) {
      if (T - pendT > 8) pendKey = null;                                   // too late, the moment has passed
      else if (!showing || age * 38 > text.length() + 38) {               // the current line is typed out and read
        String k = pendKey;
        pendKey = null;
        eventCooldown = 0;
        idleLine = false;
        event(k, pendRepeat, pendLines, false);
      }
    }
    if (showing) {
      age += dt;
      if (age > life) showing = false;
    }
    // the idle timer
    if (idleSeconds() > IDLE_LIMIT && !showing) {
      idleCount++;
      // always the user's exact line; from the second time on, with a little extra
      String variant;
      if (hud.terminalAnim > 0.5) variant = TERMINAL_IDLE[idleCount % TERMINAL_IDLE.length];
      else if (staringAtWall()) variant = "Congratulations. You're staring at a wall.";
      else variant = IDLE_LINES[(idleCount / 3 + idleCount) % IDLE_LINES.length];
      say(idleCount % 3 == 1 ? MAIN_IDLE_LINE : MAIN_IDLE_LINE + " " + variant);
      idleLine = true;
      lastIdleMs = millis();                                      // 20 s timer starts over
    }
    // staring at the hologram
    PVector toHolo = PVector.sub(holoPos, cam.pos);
    float d = toHolo.mag();
    if (d < 2500 && toHolo.normalize().dot(cam.fwd) > 0.995) {
      stare += dt;
      stare2 += dt;
    } else {
      stare = 0;
      stare2 = 0;
    }
    if (stare > 2.5 && !showing && T - lastStareLine > 60) {
      lastStareLine = T;
      stare = 0;
      say("What? Never seen a holographic genius before?");
    }
    if (stare2 > 9 && !showing && T - lastStareLine2 > 180) {
      lastStareLine2 = T;
      stare2 = 0;
      say(STARE_LONG[(int) random(STARE_LONG.length)]);
    }
    // flew right into his head
    if (d < 170) event("inholo", 90, IN_HOLO);
    // things thrown through his face
    for (ThrowableObject o : objects.list) {
      if (o.held || o.gone > 0 || o.vel.mag() < 250) continue;
      if (PVector.dist(o.pos, holoPos) < 160) {
        if (T - o.lastTeleportT < 2.5) event("holobank", 90, HOLO_BANKSHOT);
        else if (o.type == OB_PICKLE) event("holopickle", 40, HOLO_PICKLE);
        else if (o.type == OB_DUMMY) event("holgary", 60, HOLO_GARY);
        else if (o.type == OB_BATTERY) event("holbatt", 60, HOLO_BATTERY);
        else if (o.type == OB_UNSTABLE) event("holunst", 60, HOLO_UNSTABLE);
        else if (o.type == OB_ANVIL) event("holanvil", 60, HOLO_ANVIL);
        else event("holohit", 25, HOLO_HIT);
      }
    }
    // holding the pickle up to his face
    if (objects.heldObj != null && objects.heldObj.type == OB_PICKLE && PVector.dist(objects.heldObj.pos, holoPos) < 260) event("pickleface", 120, PICKLE_FACE);
    // something parked on his projector spot
    boolean blocked = false;
    for (ThrowableObject o : objects.list) {
      if (!o.held && o.gone <= 0 && o.pos.y > -120 && o.vel.mag() < 40 && dist(o.pos.x, o.pos.z, holoHome.x, holoHome.z) < 90) blocked = true;
    }
    blockT = (blocked && holoAway <= 0) ? blockT + dt : 0;
    if (blockT > 2) event("projblock", 90, PROJECTOR_BLOCKED);
    // no-clipped into a wall
    if (cam.noclip && lab.insideAnyBox(cam.pos) != null) event("inwall", 120, IN_WALL);
    // clinging to one object for ages
    if (objects.heldObj != null) holdTime += dt;
    else holdTime = 0;
    if (holdTime > 40 && eventCooldown <= 0) {
      String nm = objects.heldObj.name;
      event("clingy", 120, new String[] {
        "You've been holding that " + nm + " for " + i0(holdTime) + " seconds. Put a ring on it or put it down.",
        "Still holding the " + nm + "? It's not a teddy bear. Well, unless it's Gary. Even then, no." });
    }
    // wandered off into the universe
    if (cam.pos.mag() > 9000) event("faraway", 90, FAR_AWAY);
    // went down into the void pit / up to the high platform
    if (cam.pos.y > 150 && abs(cam.pos.x) < 380 && cam.pos.z > 180 && cam.pos.z < 920) event("pit", 120, IN_PIT);
    if (cam.pos.y < -2500 && abs(cam.pos.x) < 650 && cam.pos.z > 450 && cam.pos.z < 1550) event("high", 180, HIGH_UP);
    // portalled away: drift over to the other portal, then home again
    if (holoAway > 0) {
      holoAway -= dt;
      if (pingPong && portals.linked()) {
        Portal a = portals.p[(int) (T * 1.6) % 2];
        holoTarget.set(a.c.x, a.c.y - 380, a.c.z);
      }
      if (holoAway <= 0) {
        holoTarget.set(holoHome);
        holoFlip = holoGlitch = pingPong = false;
        holoAt = null;
        event("holoback", 0, HOLO_BACK, true);
      }
    }
    holoPos.lerp(holoTarget, 1 - exp(-dt * (holoAway > 0 ? 4 : 1.5)));
  }

  boolean staringAtWall() {
    RayHit h = lab.raycast(cam.pos, cam.fwd, 400);
    return h.hit();
  }

  boolean talking() {
    return showing && age * 38 < text.length() + 2;
  }

  // ---------------------------------------------------------------- drawing
  // the floating head in the lab (glow pass)
  void drawHologram() {
    float bob = sin(T * 1.4) * 10;
    float x = holoPos.x, y = holoPos.y + bob, z = holoPos.z;
    float s = 420;
    PVector r = PVector.mult(cam.right, s / 2), u = PVector.mult(cam.up, s / 2);
    boolean open = talking() && (int) (T * 9) % 2 == 0;
    float alpha = 200 + 55 * sin(T * 13) * sin(T * 3.1);
    if (holoGlitch && holoAway > 0) {                 // bad reception out in space
      if (random(1) < 0.2) return;
      x += random(-25, 25);
      alpha = random(60, 200);
    }
    if (blockT > 0.5 && random(1) < 0.3) alpha = random(30, 120);   // something's on the projector
    float v0 = holoFlip ? 1 : 0, v1 = 1 - v0;          // hanging from the ceiling
    noStroke();
    tint(255, alpha);
    beginShape(QUADS);
    texture(open ? holoTalk : holo);
    vertex(x - r.x + u.x, y - r.y + u.y, z - r.z + u.z, 0, v0);
    vertex(x + r.x + u.x, y + r.y + u.y, z + r.z + u.z, 1, v0);
    vertex(x + r.x - u.x, y + r.y - u.y, z + r.z - u.z, 1, v1);
    vertex(x - r.x - u.x, y - r.y - u.y, z - r.z - u.z, 0, v1);
    endShape();
    noTint();
    glowSprite(x, y, z, 420, color(60, 200, 255), 70);
    // projector cone from the console
    beginShape(TRIANGLES);
    fill(80, 220, 255, 60);
    vertex(x, 0, z);
    fill(80, 220, 255, 0);
    vertex(x - r.x * 0.9, y - r.y * 0.9 - 40, z - r.z * 0.9);
    vertex(x + r.x * 0.9, y + r.y * 0.9 - 40, z + r.z * 0.9);
    endShape();
  }

  // the cartoon speech box (2D)
  void draw() {
    if (!showing) return;
    float pop = easeOutBack(min(1, age / 0.25));
    float fade = constrain((life - age) / 0.35, 0, 1);
    // portrait centre; with the TAB computer open he moves into its empty lower-left corner
    float k = constrain(hud.terminalAnim, 0, 1), px = lerp(width - 120, 760, k), py = lerp(height - 150, height - 140, k);
    // portrait
    pushMatrix();
    translate(px, py + sin(T * 3) * 3);
    scale(pop);
    noStroke();
    fill(10, 40, 50, 230 * fade);
    ellipse(0, 0, 176, 176);
    boolean open = talking() && (int) (T * 9) % 2 == 0;
    imageMode(CENTER);
    tint(255, 255 * fade);
    image(open ? faceTalk : face, 0, 6, 168, 168);
    noTint();
    imageMode(CORNER);
    noFill();
    stroke(20, 20, 26, 255 * fade);
    strokeWeight(5);
    ellipse(0, 0, 176, 176);
    stroke(90, 230, 255, 220 * fade);
    strokeWeight(2.5);
    ellipse(0, 0, 186, 186);
    popMatrix();

    // box
    textFont(font, 19);
    float maxW = 470;
    ArrayList<String> lines = wrap(text, maxW);
    float lh = 25;
    float w = maxW + 36, h = lines.size() * lh + 58;
    float bx = px - 108 - w, by = py - h / 2 - 20;
    pushMatrix();
    translate(bx + w, by + h * 0.65);
    scale(pop);
    translate(-(bx + w), -(by + h * 0.65));
    noStroke();
    fill(0, 120 * fade);
    roundBox(bx + 7, by + 7, w, h, 22);
    stroke(20, 20, 26, 255 * fade);
    strokeWeight(4);
    fill(255, 252, 240, 250 * fade);
    triangle(bx + w - 6, by + h * 0.45, bx + w - 6, by + h * 0.8, bx + w + 48, by + h * 0.72);
    roundBox(bx, by, w, h, 22);
    noStroke();
    triangle(bx + w - 9, by + h * 0.47, bx + w - 9, by + h * 0.78, bx + w + 40, by + h * 0.71);
    // name
    textFont(nameFont, 22);
    textAlign(LEFT, TOP);
    fill(30, 140, 70, 255 * fade);
    text("RICK:", bx + 18, by + 12);
    // typewriter text, *burps* in green
    textFont(font, 19);
    int budget = (int) (age * 38);
    float ty = by + 44;
    for (String l : lines) {
      float lx = bx + 18;
      String[] words = split(l, ' ');
      for (int i = 0; i < words.length && budget > 0; i++) {
        String word = words[i];
        String shown = word.substring(0, min(word.length(), budget));
        budget -= word.length() + 1;
        boolean burp = word.startsWith("*") && word.length() > 2;     // *burp* - not "a**."
        fill(burp ? color(40, 150, 40, 255 * fade) : color(28, 26, 36, 255 * fade));
        text(shown, lx, ty);
        lx += textWidth(word + " ");
      }
      ty += lh;
    }
    popMatrix();
  }

  ArrayList<String> wrap(String s, float maxW) {
    ArrayList<String> out = new ArrayList<String>();
    String cur = "";
    for (String w : split(s, ' ')) {
      String t = cur.length() == 0 ? w : cur + " " + w;
      if (textWidth(t) > maxW && cur.length() > 0) {
        out.add(cur);
        cur = w;
      } else cur = t;
    }
    if (cur.length() > 0) out.add(cur);
    return out;
  }
}

// ====================================================================
// Rick's head, drawn with shapes (same design as A Piece Of Cake's Rick).

PImage makeRickFace(boolean talking) {
  PGraphics g = createGraphics(256, 256);
  g.beginDraw();
  g.clear();
  g.translate(128, 232);
  g.scale(1.02);
  g.strokeJoin(ROUND);
  g.strokeCap(ROUND);
  drawRickHead(g, talking);
  g.endDraw();
  return g.get();
}

void drawRickHead(PGraphics g, boolean talking) {
  int SKIN = #F1D6BA, SKIN_SH = #D9B596, HAIR = #AEDDF5, HAIR_SH = #86BEDF, HAIR_DK = #5E93B8, INK = #1E1C28;
  g.scale(1.2);
  float cx = 0, cy = -50;
  g.stroke(INK);
  g.strokeWeight(2.4);
  g.fill(HAIR);
  float[] tipR = { 58, 72, 80, 78, 84, 80, 84, 78, 80, 72, 58 };
  float[] curl = { -0.16, -0.14, -0.12, -0.08, -0.04, 0, 0.04, 0.08, 0.12, 0.14, 0.16 };
  int n = tipR.length;
  float a0 = radians(166), a1 = radians(374);
  float step = (a1 - a0) / (n - 1);
  g.beginShape();
  g.vertex(cx + cos(a0 - step * 0.6) * 30, cy + sin(a0 - step * 0.6) * 42);
  for (int i = 0; i < n; i++) {
    float a = a0 + step * i;
    float vr = 47;
    float va = a - step * 0.5, vb = a + step * 0.5;
    float tx = cx + cos(a + curl[i]) * tipR[i];
    float ty = cy + sin(a + curl[i]) * tipR[i] * 1.04;
    if (i == 0) g.vertex(cx + cos(va) * vr * 0.8, cy + sin(va) * vr);
    g.quadraticVertex(cx + cos(a - step * 0.12) * (vr + 10), cy + sin(a - step * 0.12) * (vr + 10) * 1.04, tx, ty);
    g.quadraticVertex(cx + cos(a + step * 0.2) * (vr + 8), cy + sin(a + step * 0.2) * (vr + 8) * 1.04,
                      cx + cos(vb) * vr, cy + sin(vb) * vr * 1.04);
  }
  g.vertex(cx + cos(a1 + step * 0.6) * 30, cy + sin(a1 + step * 0.6) * 42);
  g.endShape(CLOSE);
  g.stroke(HAIR_SH);
  g.noFill();
  for (int i = 0; i < n; i++) {
    float a = a0 + step * i;
    float r1 = tipR[i] * 0.84;
    g.line(cx + cos(a) * 44, cy + sin(a) * 44 * 1.04, cx + cos(a + curl[i] * 0.8) * r1, cy + sin(a + curl[i] * 0.8) * r1 * 1.04);
  }
  // ears + neck
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(SKIN);
  g.ellipse(-31, -46, 13, 20);
  g.ellipse(31, -46, 13, 20);
  g.rect(-8.5, -12, 17, 14);
  // face
  g.strokeWeight(2.4);
  float[][] face = { { 0, -94 }, { 20, -91 }, { 31, -76 }, { 33, -56 }, { 31, -36 }, { 26, -18 }, { 14, -6 }, { 0, -3 },
    { -14, -6 }, { -26, -18 }, { -31, -36 }, { -33, -56 }, { -31, -76 }, { -20, -91 } };
  g.beginShape();
  for (int i = 0; i < face.length + 3; i++) g.curveVertex(face[i % face.length][0], face[i % face.length][1]);
  g.endShape();
  // hair cap
  g.fill(HAIR);
  g.beginShape();
  g.vertex(-32, -64);
  g.bezierVertex(-32, -88, -18, -100, 0, -100);
  g.bezierVertex(18, -100, 32, -88, 32, -64);
  g.vertex(26, -76);
  g.vertex(19, -71);
  g.vertex(12, -79);
  g.vertex(4, -73);
  g.vertex(-4, -80);
  g.vertex(-12, -73);
  g.vertex(-19, -79);
  g.vertex(-26, -72);
  g.endShape(CLOSE);
  // unibrow
  g.noFill();
  g.stroke(HAIR_DK);
  g.strokeWeight(5);
  g.beginShape();
  g.vertex(-26, -57);
  g.vertex(-18, -61.5);
  g.vertex(-11, -58);
  g.vertex(-4, -60.5);
  g.vertex(4, -60.5);
  g.vertex(11, -58);
  g.vertex(18, -61.5);
  g.vertex(26, -57);
  g.endShape();
  // eyes
  g.stroke(INK);
  g.strokeWeight(2.2);
  g.fill(255);
  g.ellipse(-11, -46, 22, 22);
  g.ellipse(11, -46, 22, 22);
  g.noStroke();
  g.fill(INK);
  g.ellipse(-8.5, -45, 4.6, 4.6);
  g.ellipse(9.5, -46.5, 4.6, 4.6);
  g.noFill();
  g.stroke(SKIN_SH);
  g.strokeWeight(1.6);
  g.arc(-11, -40, 22, 16, radians(25), radians(155));
  g.arc(11, -40, 22, 16, radians(25), radians(155));
  // nose
  g.stroke(INK);
  g.strokeWeight(2);
  g.beginShape();
  g.vertex(1, -36);
  g.quadraticVertex(7, -30, 1.5, -27.5);
  g.endShape();
  // mouth
  g.strokeWeight(2.4);
  if (!talking) {
    g.beginShape();
    g.vertex(-18, -19);
    g.quadraticVertex(-9, -16, -1, -19.5);
    g.quadraticVertex(8, -16, 18, -19.5);
    g.endShape();
  } else {
    g.fill(#4A1E26);
    g.beginShape();
    g.vertex(-17, -22);
    g.quadraticVertex(0, -19, 17, -22.5);
    g.quadraticVertex(14, -6, 0, -6);
    g.quadraticVertex(-14, -6, -17, -22);
    g.endShape(CLOSE);
    g.noStroke();
    g.fill(255);
    g.rect(-12, -21.5, 24, 4, 2);
    g.fill(#D7616B);
    g.ellipse(2, -9.5, 14, 6);
  }
}

// cyan hologram version with baked scanlines
PImage hologramise(PImage src) {
  PImage img = src.copy();
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    float scan = (y % 3 == 0) ? 0.45 : 1;
    for (int x = 0; x < img.width; x++) {
      int c = img.pixels[y * img.width + x];
      float a = alpha(c);
      if (a < 1) continue;
      float l = (red(c) * 0.3 + green(c) * 0.59 + blue(c) * 0.11) / 255.0;
      img.pixels[y * img.width + x] = color(60 + 150 * l, 180 + 75 * l, 255, a * scan * (0.55 + 0.45 * l));
    }
  }
  img.updatePixels();
  return img;
}

// ====================================================================
// Rick reacting to your experiments. Each kind of event has its own lines,
// cycles through them, and has its own cooldown so he never spams.

String[] FIRST_PORTAL = { "Ooh, portals. Careful, those are worth more than your entire planet." };
String[] LINKED = {
  "Two portals. Congratulations, you've invented a very expensive door.",
  "Linked! Now throw something through it. That's the whole point. That's science.",
  "A and B, connected. Like me and alcohol. *burp*"
};
String[] FLOOR_CEILING = { "Floor to ceiling? Classic. Drop something in and watch it fall forever." };
String[] TOO_CLOSE = { "Portals that close together? You're making a localised infinity. I love it. Don't tell the council." };
String[] FIZZLE = {
  "That's anti-portal paneling, genius. The dark stuff. Read the room. It's literally dark.",
  "Nope. Portals don't stick to that. Physics has rules. Well - I have rules.",
  "You shot the void. The void doesn't take portals. I've asked."
};
String[] CAM_JUMP = {
  "Look who went through a portal. Want a juice box?",
  "Every time you do that, a version of you somewhere gets a headache. *burp*",
  "Disassembled, transmitted, reassembled. You're welcome. Mostly the same you."
};
String[] OBJ_JUMP = {
  "Momentum in, momentum out. Physics doesn't care where the hole goes.",
  "See that? Same speed out as in. That's conservation. Like me conserving my patience.",
  "Through the portal and out the other side. Nobel committee, call me. Actually don't."
};
String[] LOOPING = {
  "Infinite loop! Now THAT'S science, baby!",
  "It's falling forever. Free energy! Don't tell the Federation.",
  "Look at it go. Round and round. Like a hamster with a physics degree."
};
String[] LOW_STAB = {
  "You're stretching spacetime like cheap taffy. Bring them closer, genius.",
  "Stability's tanking. Stuff's gonna come out of there a little inside-out-ish."
};
String[] EXPLODED = { "Told you it was unstable. It's literally in the name.", "And it's gone. Again. That thing has commitment issues." };
String[] Q_BOUNCE = { "The rock went through AND didn't. Don't think about it. Seriously, don't, it's contagious." };
String[] Q_TUNNEL = { "Did the rock just move by itself? ...Yeah. It does that. Probably safe." };
String[] SHATTER = { "That was my flask! I had... science in there.", "Great. Now the floor is 40% glass and 60% a smoothie I was saving." };
String[] LOST = {
  "And it's gone. Into the infinite void. Hope it wasn't important.",
  "Gravity: one. You: zero. I'll respawn it, but I'm judging you.",
  "That's a lot of lab equipment for the space gods. They don't even say thanks."
};
String[] GRAB_PICKLE = { "Put the pickle down. ...Trust me.", "It's just a pickle. Probably. Ninety percent. Eighty." };
String[] GRAB_DUMMY = { "That's Gary. Gary's been through four hundred portals. Gary has seen things.", "Be nice to Gary. Gary's the only one here who never complains." };
String[] GRAB_ANVIL = { "Fifty kilos of bad decisions. Lift with your... camera." };
String[] GRAB_UNSTABLE = { "Oh sure, pick up the UNSTABLE one. Why not hug a supernova while you're at it?" };
String[] GRAB_BATTERY = { "Careful with that, there's a whole civilisation in there. They think I'm a god. I am." };
String[] THROW_FAST = { "Whoa, easy there, Hulk. That's lab property.", "Did you just throw that at forty metres a second? Respect." };
String[] PICKLE_JUMP = { "A pickle. Through a portal. Peak science. I'm not crying, you're crying." };
String[] BATTERY_JUMP = { "You just gave a tiny civilisation a hyperspace commute. They're gonna write songs about you." };
String[] ANTIGRAV_JUMP = { "Anti-gravity through a portal. Now it falls the OTHER way. Or double anti. Look, I'm busy." };
String[] DUMMY_JUMP = { "Gary's spinning. Gary's fine. Gary signed a waiver." };
String[] DISPENSED = { "Ooh, what'd you get? ...Disappointing.", "The dispenser picks randomly. Like evolution. Or my ex-wives' lawyers.", "Free stuff! It's not free. Nothing's free. *burp*" };
String[] TERMINAL = { "Reading the equations, huh? Half of them are real. Guess which half.", "Look at you doing maths. I'm so proud I could throw up. *burp*" };
String[] MANIPULATED = { "Dragging portals around like furniture. Interior designer of the multiverse.", "Nice placement. Feng shui for spacetime." };
String[] HOLO_HIT = { "Hey! That went right through my face. Rude.", "I'm a hologram, genius. Throw it at something that can feel it." };
String[] FAR_AWAY = { "Where are you going? The lab's back there. The universe is mostly empty - I've checked." };

boolean floorCeilingPair() {
  Portal a = portals.p[0], b = portals.p[1];
  return abs(a.n.y) > 0.9 && abs(b.n.y) > 0.9 && a.n.y * b.n.y < 0;
}

void onPortalPlaced(Portal q) {
  markAction();
  if (checkPortalUnderRick(q)) return;      // the hologram gag is the line this time
  if (portals.p[0].active && portals.p[1].active) {
    if (floorCeilingPair()) rick.event("floorceil", 180, FLOOR_CEILING, true);
    else if (portals.distance() < 420) rick.event("close", 120, TOO_CLOSE, true);
    else rick.event("linked", 240, LINKED, true);
  } else {
    rick.event("first", 100000, FIRST_PORTAL, true);
  }
}

void onPortalFizzled(String why, RayHit h) {
  rick.event("fizzle", 45, FIZZLE);
}

void onCameraTeleported(Portal from) {
  markAction();
  noteCameraJump();
  rick.event("camjump", 50, CAM_JUMP);
}

void onPortalManipulated(Portal q) {
  markAction();
  checkPortalUnderRick(q);
  if (abs(q.n.y) < 0.5 && q.u.y > 0.7) rick.event("upsidedown", 90, UPSIDE_DOWN);
  else if (abs(q.n.y) < 0.5 && abs(q.u.y) < 0.35) rick.event("sideways", 90, SIDEWAYS);
  rick.event("manip", 90, MANIPULATED);
}

void onMuteToggled(boolean muted) {
  if (muted) rick.event("mute", 120, MUTED);
}

void onDebugToggled(boolean on) {
  if (on) rick.event("debug", 180, DEBUG_ON);
}

void onNoclipToggled(boolean on) {
  if (on) rick.event("noclip", 120, NOCLIP_ON);
}

void onObjectTeleported(ThrowableObject o, Portal from, int chain) {
  if (chain >= 10) { rick.event("loop10", 120, LOOP_TEN, true); return; }
  if (chain >= 4 && o.type == OB_PICKLE) { rick.event("pickleloop", 120, PICKLE_LOOP); return; }
  if (chain >= 4) { rick.event("loop", 60, LOOPING); return; }
  if (o.type == OB_PICKLE) { rick.event("pickle", 60, PICKLE_JUMP); return; }
  if (o.type == OB_BATTERY) { rick.event("battery", 60, BATTERY_JUMP); return; }
  if (o.type == OB_ANTIGRAV) { rick.event("antigrav", 60, ANTIGRAV_JUMP); return; }
  if (o.type == OB_DUMMY) { rick.event("dummy", 60, DUMMY_JUMP); return; }
  if (o.type == OB_ANVIL) { rick.event("anvilslow", 60, ANVIL_SLOW); return; }
  rick.event("objjump", 45, OBJ_JUMP);
}

String[] ANVIL_SLOW = {
  "The anvil came out slower. Portal friction. That's not a real thing. The anvil made it a real thing. Out of spite.",
  "Fifty kilos through a hole in space and it lost half its speed. Even physics is tired of that anvil."
};
String[] ZERO_G_ECHO = {
  "The zero-g core went back for seconds. No gravity, no commitment. Relatable.",
  "It changed its mind. Zero gravity, zero decisiveness. Like a Jerry in a ball."
};

void onZeroGEcho(ThrowableObject o) {
  rick.event("zgecho", 60, ZERO_G_ECHO);
}

void onQuantumBounce(ThrowableObject o) {
  rick.event("qbounce", 60, Q_BOUNCE);
}

void onQuantumTunnel(ThrowableObject o) {
  if (PVector.dist(o.pos, cam.pos) < 1500) rick.event("qtunnel", 120, Q_TUNNEL);
}

void onObjectShattered(ThrowableObject o) {
  rick.event("shatter", 40, SHATTER);
}

void onObjectExploded(ThrowableObject o) {
  rick.event("explode", 40, EXPLODED);
}

void onObjectLost(ThrowableObject o) {
  if (o.dispensed) rick.event("lostdisp", 40, LOST_DISPENSED);
  else rick.event("lost", 40, LOST);
}

void onObjectGrabbed(ThrowableObject o) {
  if (o.type == OB_PICKLE) rick.event("gpickle", 60, GRAB_PICKLE);
  if (o.type == OB_DUMMY) rick.event("gdummy", 90, GRAB_DUMMY);
  if (o.type == OB_ANVIL) rick.event("ganvil", 90, GRAB_ANVIL);
  if (o.type == OB_UNSTABLE) rick.event("gunstable", 90, GRAB_UNSTABLE);
  if (o.type == OB_BATTERY) rick.event("gbattery", 90, GRAB_BATTERY);
}

void onObjectThrown(ThrowableObject o) {
  physics.focus = o;
  if (objects.lastThrowSpeed > 30) rick.event("throwfast", 60, THROW_FAST);
}

void onObjectDispensed(ThrowableObject o) {
  markAction();
  noteDispense();
  rick.event("dispense", 30, DISPENSED);
}

void onLowStability() {
  rick.event("lowstab", 60, LOW_STAB);
}

String[] SHOT_LOST = {
  "You shot a portal into space. It'll land somewhere in about four billion years. Someone's gonna be SO confused.",
  "Missed the entire lab. The ENTIRE lab. It's a big lab, Morty- I mean, whoever you are."
};

void onShotLost() {
  rick.event("shotlost", 90, SHOT_LOST);
}

void onTerminalOpened() {
  rick.event("terminal", 120, TERMINAL);
}

// ---------------------------------------------------------------- extra weird interactions
String[] HOLO_PICKLE = { "Don't throw the pickle at me! ...Wait. Is that- no. Just a pickle. Probably." };
String[] HOLO_SUCK = {
  "Are you trying to portal ME? I'm light, genius. Light doesn't fa-  AAAA-",
  "Whoa whoa whoa, not the projector! Okay. Okay. Nice view, actually."
};
String[] HOLO_LONELY = { "Are you trying to portal me? There's no second portal. You just put a hole under a hologram. Bold." };
String[] HOLO_BACK = { "And I'm back. Don't do that again. Do it again." };
String[] IN_PIT = { "You're IN the void pit. The sign said DO NOT LEAN. You went full opposite of leaning." };
String[] HIGH_UP = { "Nice view up here. Don't look down. Actually do - it's the void, it's pretty." };
String[] HOPPING = { "Stop portal-hopping, you'll get spatial whiplash. Trust me. I have it permanently." };
String[] DISPENSER_SPAM = { "Stop spamming the dispenser! Matter doesn't grow on trees. Well. Technically it does. Shut up." };
String[] GARY_ANVIL = { "You hit Gary with an anvil. Gary's lawyer will be in touch.", "Anvil versus Gary. Gary lost. Gary always loses. That's why we love Gary." };
String[] LOOP_TEN = { "Ten loops. This is my favourite show now. Don't touch anything." };
String[] UPSIDE_DOWN = {
  "You flipped the portal upside down. Now everything that comes out is Australian.",
  "Upside-down portal. The other side of that hole is now emotionally upside down too. Good job."
};
String[] SIDEWAYS = { "A sideways portal. Very avant-garde. Very 'I took one art class at community college'." };
String[] MUTED = {
  "You muted the lab? I'm a speech box, genius. You can't mute TEXT.",
  "Muted again. I'm still talking. I'm always talking. It's like a curse, but for you."
};
String[] DEBUG_ON = { "Ooh, nerd numbers. Look at you reading frame rates like a real scientist. Adorable." };
String[] NOCLIP_ON = { "No-clip? Walking through walls? I was doing that before it was a cheat code. It was called 'Tuesday'." };

// a portal opened on the floor right under his hologram; true if Rick reacted to it
boolean checkPortalUnderRick(Portal q) {
  if (q.n.y > -0.9) return false;
  if (dist(q.c.x, q.c.z, rick.holoHome.x, rick.holoHome.z) > 380) return false;
  Portal o = portals.other(q);
  if (!o.active) {
    rick.event("hololonely", 60, HOLO_LONELY);
    return true;
  }
  rick.eventCooldown = 0;
  rick.holoFlip = rick.holoGlitch = rick.pingPong = false;
  rick.holoAt = null;
  if (o.n.y < -0.9 && dist(o.c.x, o.c.z, rick.holoHome.x, rick.holoHome.z) <= 380) {
    // both portals under him: he falls through himself, back and forth
    rick.pingPong = true;
    rick.holoAway = 10;
    rick.event("holodouble", 60, HOLO_DOUBLE);
  } else {
    String bn = o.box.name;
    boolean ceil = o.n.y > 0.9;                       // comes out of the ceiling: hangs upside down
    boolean space = bn.startsWith("ORBITAL") || bn.equals("OBSERVATION DECK") || bn.equals("HIGH PLATFORM") || bn.equals("SUB-DECK");
    rick.holoFlip = ceil;
    rick.holoGlitch = space;                          // out of the lab: terrible reception
    rick.holoAt = o;
    if (ceil) rick.event("holoceil", 20, HOLO_CEILING);
    else if (space) rick.event("holospace", 20, HOLO_SPACE);
    else rick.event("holosuck", 20, HOLO_SUCK);
    rick.holoTarget.set(holoSpotAt(o));
    rick.holoAway = 14;
  }
  q.splash(PVector.add(q.c, PVector.mult(q.n, 20)), 1.2);
  o.splash(PVector.add(o.c, PVector.mult(o.n, 20)), 1.2);
  sfx.play(sfx.teleport, 0.7, 0.7);
  return true;
}

// where his head floats after coming out of portal o
PVector holoSpotAt(Portal o) {
  PVector t = PVector.add(o.c, PVector.mult(o.n, 320));
  t.y -= 120;
  return t;
}

// the exit portal he's parked at is being dragged around: he gets dragged with it
void onHoloPortalMoved(Portal sel) {
  if (rick.holoAway <= 0 || sel != rick.holoAt) return;
  rick.holoTarget.set(holoSpotAt(sel));
  rick.holoFlip = sel.n.y > 0.9;
  rick.holoAway = max(rick.holoAway, 4);
  rick.event("holodrag", 60, HOLO_DRAG);
}

// the portal gun's aim line went straight through his head
void checkShotThroughRick(RayHit h) {
  PVector toH = PVector.sub(rick.holoPos, cam.pos);
  float along = toH.dot(cam.fwd);
  if (along > 0 && along < (h.hit() ? h.t : 9000) && PVector.sub(toH, PVector.mult(cam.fwd, along)).mag() < 150) {
    rick.event("shotholo", 60, SHOT_HOLO);
  }
}

String[] IN_HOLO = {
  "Get out of my face. No, literally - you're IN my face. It's all pixels and resentment in here.",
  "Personal space! I can see your camera lens from the inside of my nose."
};
String[] HOLO_BANKSHOT = {
  "You bank-shot that through a PORTAL to hit me? ...Okay, that's actually good. Still rude.",
  "Trick shot through spacetime, right in my face. I'd clap, but I'm just a head."
};
String[] HOLO_GARY = { "Gary! Buddy! You went straight through me. We've talked about boundaries, Gary." };
String[] HOLO_BATTERY = { "Watch it! There are people in there. They just saw a giant floating head. That's their new religion now. Great." };
String[] HOLO_UNSTABLE = { "The UNSTABLE one? At my FACE? I've dated people with better aim and worse intentions." };
String[] HOLO_ANVIL = { "You threw an anvil at a hologram. You're bullying photons. Fifty kilos of photon bullying." };
String[] SHOT_HOLO = {
  "Did you just shoot me with my own portal gun? It went straight through. It tickles. Stop it.",
  "Portals go on WALLS. I'm a face. Faces aren't walls. Mostly."
};
String[] HOLO_CEILING = {
  "Why am I upside down? I don't even HAVE blood and it's rushing to my head. *burp* Upwards.",
  "Great, I'm a bat now. A genius bat. Flip me back before I start liking it."
};
String[] HOLO_SPACE = {
  "You portalled me into SPACE? The signal out here is garbage. Can you hear m- kssshhh- ...idiot.",
  "Floating in the void. Very peaceful. Very lonely. Bring me back before I start writing poetry."
};
String[] HOLO_DOUBLE = {
  "Two portals under me? Now I'm falling through myself. Forever. This is either hell or a screensaver.",
  "Back and forth, back and forth. I'm a hologram on a trampoline. Get me off this thing."
};
String[] HOLO_DRAG = {
  "Stop dragging me around! I'm a hologram, not a carry-on bag.",
  "Oh sure, move the exit while I'm standing in it. That's how you get Rick smeared across a wall."
};
String[] PROJECTOR_BLOCKED = {
  "Something's sitting on my projector. I can feel it. It feels like a cube with no ambition. Move it.",
  "Get that off my projector or I'm gonna gl-gl-glitch out and k-k-keep doing this f-f-forever."
};
String[] PICKLE_FACE = {
  "Get that pickle out of my face. I said OUT. ...Why is it warm? Pickles shouldn't be warm.",
  "Don't wave the pickle at me. It knows what it did. I know what it did. We don't talk about it."
};
String[] PICKLE_LOOP = {
  "The pickle's in the loop. Every lap it gets a little smarter. Don't make eye contact with the pickle.",
  "Round and round goes the pickle. If it starts talking, I was never here."
};
String[] IN_WALL = {
  "You're inside the wall. Don't touch anything - it's mostly wires and bad decisions in there. Mine.",
  "No-clipping through my walls? That's breaking and entering. Mostly entering."
};
String[] STARE_LONG = {
  "Okay, this is getting weird. Blink. Do cameras blink? Blink anyway.",
  "You've been staring at me for ten seconds. In hologram years we're basically married."
};
String[] TERMINAL_IDLE = {
  "Reading isn't doing, genius. Close the computer and go break something.",
  "Still on the equations? The mu is decorative. Half the Greek letters are decorative."
};
String[] LOST_DISPENSED = { "Dispenser junk, lost to the void. Easy come, easy go. Mostly go." };

void noteCameraJump() {
  rick.camJumps.add(T);
  while (rick.camJumps.size() > 0 && T - rick.camJumps.get(0) > 20) rick.camJumps.remove(0);
  if (rick.camJumps.size() >= 5) rick.event("hopping", 90, HOPPING, true);
}

void noteDispense() {
  rick.dispenses.add(T);
  while (rick.dispenses.size() > 0 && T - rick.dispenses.get(0) > 10) rick.dispenses.remove(0);
  if (rick.dispenses.size() >= 5) rick.event("dispspam", 60, DISPENSER_SPAM, true);
}

void onObjectsCollide(ThrowableObject a, ThrowableObject b, float speed) {
  boolean garyAnvil = (a.type == OB_ANVIL && b.type == OB_DUMMY) || (a.type == OB_DUMMY && b.type == OB_ANVIL);
  if (garyAnvil && speed > 3) rick.event("garyanvil", 45, GARY_ANVIL);
}


// ======================================================================
// TAB: Sound.pde
// ======================================================================
// Synthesized sound effects (Java's built-in javax.sound - nothing to install).
// Every sound is generated into a float array at startup; a small mixer
// thread plays any number of them at once. No audio device = silent sketch.


class Sfx implements Runnable {
  final float SR = 44100;
  SourceDataLine line;
  boolean ok, muted;
  final ArrayList<Voice> voices = new ArrayList<Voice>();
  java.util.Random rng = new java.util.Random(77);

  float[] fire, portalOpen, fizzle, teleport, whoosh, thud, clink, grab, drop, select, confirm, cancel;
  float[] burp, hum, spawn, zap, warn, pop;

  Sfx() {
    try {
      AudioFormat fmt = new AudioFormat(SR, 16, 1, true, false);
      line = AudioSystem.getSourceDataLine(fmt);
      line.open(fmt, 4096);
      line.start();
      build();
      ok = true;
      Thread th = new Thread(this, "portal-lab-audio");
      th.setDaemon(true);
      th.start();
      Voice h = new Voice(hum, 0.22, 1);
      h.loop = true;
      synchronized (voices) {
        voices.add(h);
      }
    } catch (Exception e) {
      println("No sound (" + e.getMessage() + ") - running silently.");
    }
  }

  void play(float[] s, float vol, float pitch) {
    if (!ok || s == null) return;
    synchronized (voices) {
      if (voices.size() < 32) voices.add(new Voice(s, vol, pitch));
    }
  }

  public void run() {
    int N = 512;
    float[] mix = new float[N];
    byte[] out = new byte[N * 2];
    while (true) {
      java.util.Arrays.fill(mix, 0);
      synchronized (voices) {
        for (int v = voices.size() - 1; v >= 0; v--) {
          Voice vc = voices.get(v);
          for (int i = 0; i < N; i++) {
            if (vc.pos >= vc.s.length - 1) {
              if (vc.loop) vc.pos = 0;
              else break;
            }
            int p = (int) vc.pos;
            float f = vc.pos - p;
            mix[i] += (vc.s[p] * (1 - f) + vc.s[p + 1] * f) * vc.vol;
            vc.pos += vc.pitch;
          }
          if (!vc.loop && vc.pos >= vc.s.length - 1) voices.remove(v);
        }
      }
      float g = muted ? 0 : 0.75;
      for (int i = 0; i < N; i++) {
        int sv = (int) (Math.tanh(mix[i] * g) * 32000);
        out[i * 2] = (byte) (sv & 0xff);
        out[i * 2 + 1] = (byte) ((sv >> 8) & 0xff);
      }
      line.write(out, 0, out.length);
    }
  }

  // ---------------------------------------------------------------- synthesis
  float[] buf(float sec) { return new float[(int) (sec * SR)]; }
  float nz() { return rng.nextFloat() * 2 - 1; }
  float sq(float ph) { return (ph % 1) < 0.5 ? 1 : -1; }

  void build() {
    fire = buf(0.22);
    float ph = 0, lp = 0;
    for (int i = 0; i < fire.length; i++) {
      float t = i / SR;
      float f = 1900 * exp(-t * 14) + 260;
      ph += f / SR;
      lp += (nz() - lp) * 0.25;
      fire[i] = (sin(TWO_PI * ph) * 0.7 + sq(ph * 0.5) * 0.15 + lp * 0.3 * exp(-t * 30)) * exp(-t * 11);
    }

    portalOpen = buf(0.9);
    float p1 = 0, p2 = 0;
    lp = 0;
    for (int i = 0; i < portalOpen.length; i++) {
      float t = i / SR;
      float f = 70 + 160 * (1 - exp(-t * 5));
      p1 += f / SR;
      p2 += f * 1.507 / SR;
      lp += (nz() - lp) * (0.02 + 0.1 * t);
      float env = min(1, t * 20) * exp(-t * 3.2);
      portalOpen[i] = (sin(TWO_PI * p1) * 0.6 + sin(TWO_PI * p2) * 0.3 + lp * 1.5 + sin(TWO_PI * p1 * 4) * 0.12 * sin(t * 60)) * env;
    }

    fizzle = buf(0.4);
    for (int i = 0; i < fizzle.length; i++) {
      float t = i / SR;
      fizzle[i] = (rng.nextFloat() < 0.06 ? nz() : nz() * 0.25) * exp(-t * 9) * 0.8;
    }

    teleport = buf(0.45);
    ph = 0;
    lp = 0;
    for (int i = 0; i < teleport.length; i++) {
      float t = i / SR;
      ph += (300 + 2400 * t / 0.45) / SR;
      lp += (nz() - lp) * 0.3;
      float env = sin(PI * t / 0.45);
      teleport[i] = (sin(TWO_PI * ph) * 0.4 + lp * 0.5) * env * 0.8;
    }

    whoosh = sweep(0.45, 300, 1600, 0.6);

    thud = buf(0.3);
    for (int i = 0; i < thud.length; i++) {
      float t = i / SR;
      thud[i] = (sin(TWO_PI * 85 * t * (1 - t)) + nz() * 0.4 * exp(-t * 80)) * exp(-t * 16);
    }

    clink = buf(0.5);
    for (int i = 0; i < clink.length; i++) {
      float t = i / SR;
      clink[i] = (sin(TWO_PI * 2250 * t) * 0.5 + sin(TWO_PI * 3410 * t) * 0.3 + sin(TWO_PI * 5130 * t) * 0.15) * exp(-t * 12) * 0.6;
    }

    grab = buf(0.3);
    ph = 0;
    for (int i = 0; i < grab.length; i++) {
      float t = i / SR;
      ph += (220 + 500 * t / 0.3) / SR;
      grab[i] = (sin(TWO_PI * ph) + 0.3 * sin(TWO_PI * ph * 2)) * sin(PI * t / 0.3) * 0.5;
    }
    drop = buf(0.25);
    ph = 0;
    for (int i = 0; i < drop.length; i++) {
      float t = i / SR;
      ph += (600 - 1400 * t) / SR;
      drop[i] = sin(TWO_PI * ph) * sin(PI * t / 0.25) * 0.4;
    }

    select = tones(new float[] { 880, 1320 }, 0.09, 0.45);
    confirm = tones(new float[] { 660, 880, 1320 }, 0.08, 0.45);
    cancel = tones(new float[] { 520, 330 }, 0.1, 0.45);
    spawn = tones(new float[] { 330, 495, 660, 990 }, 0.06, 0.4);
    warn = tones(new float[] { 440, 330, 440, 330 }, 0.14, 0.3);

    burp = buf(0.55);
    ph = 0;
    lp = 0;
    for (int i = 0; i < burp.length; i++) {
      float t = i / SR;
      float f = 75 + 25 * sin(t * 18) + 30 * (1 - t / 0.55);
      ph += f / SR;
      lp += (nz() - lp) * 0.08;
      float saw = (ph % 1) * 2 - 1;
      burp[i] = (saw * 0.6 + lp * 0.8) * (0.6 + 0.4 * sin(t * 70)) * sin(PI * t / 0.55) * 0.9;
    }

    zap = buf(0.35);
    for (int i = 0; i < zap.length; i++) {
      float t = i / SR;
      zap[i] = (sq(t * 120 + rng.nextFloat() * 0.3) * 0.5 + nz() * 0.5) * exp(-t * 10) * 0.6;
    }

    pop = buf(0.12);
    for (int i = 0; i < pop.length; i++) {
      float t = i / SR;
      pop[i] = sin(TWO_PI * (400 * t + 3000 * t * t)) * exp(-t * 30) * 0.7;
    }

    // seamless 4 s lab drone (whole number of cycles of every partial)
    hum = buf(4);
    for (int i = 0; i < hum.length; i++) {
      float t = i / SR;
      float lfo = 0.75 + 0.25 * sin(TWO_PI * 0.5 * t);
      hum[i] = (sin(TWO_PI * 55 * t) * 0.5 + sin(TWO_PI * 110 * t) * 0.25 + sin(TWO_PI * 165.25 * t) * 0.08) * lfo;
    }
  }

  float[] tones(float[] f, float each, float vol) {
    float[] s = buf(each * f.length + 0.15);
    for (int k = 0; k < f.length; k++) {
      int off = (int) (k * each * SR);
      for (int i = 0; i < (int) ((each + 0.15) * SR) && off + i < s.length; i++) {
        float t = i / SR;
        s[off + i] += (sin(TWO_PI * f[k] * t) + 0.3 * sin(TWO_PI * f[k] * 2 * t)) * exp(-t * 14) * vol;
      }
    }
    return s;
  }

  float[] sweep(float sec, float f0, float f1, float vol) {
    float[] s = buf(sec);
    float lp = 0, bp = 0;
    for (int i = 0; i < s.length; i++) {
      float t = i / SR;
      float k = constrain(lerp(f0, f1, t / sec) / SR * 6, 0.001, 0.9);
      lp += (nz() - lp) * k;
      bp += (lp - bp) * k * 0.5;
      s[i] = (lp - bp) * sin(PI * t / sec) * vol * 3;
    }
    return s;
  }
}

class Voice {
  float[] s;
  float vol, pitch, pos;
  boolean loop;

  Voice(float[] s, float vol, float pitch) {
    this.s = s;
    this.vol = vol;
    this.pitch = pitch;
  }
}


// ======================================================================
// TAB: ThrowableObject.pde
// ======================================================================
// Things to throw through portals. Every object is a physics sphere
// (position, velocity, gravity, bounce, friction, spin, mass) drawn as
// whatever it looks like. Some of them get weird when they teleport.

final int OB_CUBE = 0, OB_METAL = 1, OB_ANTIGRAV = 2, OB_UNSTABLE = 3, OB_QUANTUM = 4, OB_BATTERY = 5;
final int OB_FLASK = 6, OB_ROCK = 7, OB_DUMMY = 8, OB_PICKLE = 9, OB_BOUNCY = 10, OB_ANVIL = 11, OB_FLOATER = 12;
final int OB_TYPES = 13;
final float GRAVITY = 9.81 * M;       // units/s^2  (Y is down)
final float MAX_SPEED = 60 * M;       // the lab's polite speed limit

String[] OB_NAME = { "NORMAL CUBE", "METAL BALL", "ANTI-GRAVITY BALL", "UNSTABLE OBJECT", "QUANTUM ROCK", "MICROVERSE BATTERY",
  "ERLENMEYER FLASK", "SMALL ROCK", "CRASH TEST DUMMY 'GARY'", "PICKLE", "HYPER-ELASTIC BALL", "HEAVY ANVIL", "ZERO-G CORE" };
String[] OB_STATUS = { "BORING. RELIABLE.", "DENSE", "POLARITY: REVERSED", "MASS: ??? (DO NOT HUG)", "STATUS: PROBABLY SAFE", "CONTAINS A TINY CIVILISATION",
  "FRAGILE. LIKE YOUR EGO.", "IT'S A ROCK", "SURVIVED 412 TESTS", "PROBABLY JUST A PICKLE", "GAINS SPEED THROUGH PORTALS", "50 KG OF BAD IDEAS", "IGNORES GRAVITY" };
float[] OB_MASS = { 5, 8, 2, 3, 4, 1.5, 0.6, 1, 20, 0.3, 0.8, 50, 2.5 };
float[] OB_RADIUS = { 24, 20, 20, 24, 22, 18, 18, 14, 38, 16, 15, 30, 22 };
float[] OB_BOUNCE = { 0.25, 0.35, 0.6, 0.45, 0.3, 0.3, 0.2, 0.25, 0.15, 0.4, 0.97, 0.05, 0.6 };
float[] OB_FRICTION = { 0.9, 0.25, 0.3, 0.6, 0.8, 0.6, 0.6, 0.9, 0.9, 0.5, 0.15, 1.2, 0.2 };
float[] OB_GRAV = { 1, 1, -0.28, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 };

class ThrowableObject {
  int type;
  String name, status;
  float mass, radius, bounce, friction, grav;
  PVector pos = new PVector(), vel = new PVector(), home = new PVector(), angVel = new PVector();
  PMatrix3D rot = new PMatrix3D();
  boolean held;
  boolean dispensed;
  boolean expired;              // a dispensed extra that got lost: removed instead of respawned
  float spawnFx = 1;            // materialize animation 1 -> 0
  float unstable;               // glow / jitter amount
  int teleports, chain;
  float lastTeleportT = -99, lastImpactT = -99;
  float speedIn, speedOut;
  float quantumTimer = random(4, 9);
  float gone;                   // > 0 while shattered / respawning
  float stuck;                  // held but not reaching the hold point
  float driftT;                 // seconds spent drifting slowly outside the lab
  PVector prePush = new PVector();   // position before this sub-step's collision pushes
  float echoT;                  // zero-g core: countdown to diving back into the portal it just left
  Portal echoInto;
  boolean echoReturn;           // this trip is the echo itself (one echo per jump)
  PVector safe = new PVector();  // last position that was outside every wall
  int massRoll;                 // unstable object's displayed mass changes

  ThrowableObject(int type, float x, float y, float z) {
    this.type = type;
    name = OB_NAME[type];
    status = OB_STATUS[type];
    mass = OB_MASS[type];
    radius = OB_RADIUS[type];
    bounce = OB_BOUNCE[type];
    friction = OB_FRICTION[type];
    grav = OB_GRAV[type];
    home.set(x, y, z);
    pos.set(x, y, z);
    safe.set(x, y, z);
    rot.rotateY(random(TWO_PI));
  }

  String massLabel() {
    if (type == OB_UNSTABLE) return massRoll == 0 ? "MASS: ???" : "MASS: " + f1(mass) + " kg (TODAY)";
    return "MASS: " + nf(mass, 0, mass < 1 ? 1 : 0) + " kg";
  }

  float speedMS() { return vel.mag() / M; }

  void respawn() {
    if (objects != null && objects.heldObj == this) objects.heldObj = null;
    stuck = 0;
    driftT = 0;
    pos.set(home);
    safe.set(home);
    vel.set(0, 0, 0);
    angVel.set(0, 0, 0);
    spawnFx = 1;
    unstable = 0;
    gone = 0;
    held = false;
    if (type == OB_ANTIGRAV) grav = OB_GRAV[OB_ANTIGRAV];
    parts.burst(pos, 30, 260, color(120, 255, 200), 0.6, 16);
  }

  // one physics step (called several times per frame for fast objects)
  void step(float h) {
    if (gone > 0) return;
    if (held) {
      // hold point: in front of the camera, but never inside / behind a wall
      float reach = objects.holdDist + radius;
      RayHit wall = lab.raycast(cam.pos, cam.fwd, reach + radius + 4);
      if (wall.hit()) reach = max(cam.RADIUS + radius * 0.5, wall.t - radius - 4);
      PVector target = PVector.add(cam.pos, PVector.mult(cam.fwd, reach));
      // tractor beam: if it can't reach you (or a wall hides it) for half a second, bring it through
      boolean far = PVector.dist(target, pos) > 250;
      boolean hidden = false;
      if (!far && frameCount % 6 == 0) {
        PVector toObj = PVector.sub(pos, cam.pos);
        RayHit los = lab.raycast(cam.pos, toObj.copy().normalize(), max(1, toObj.mag() - radius));
        hidden = los.hit();
      }
      if (far || hidden) stuck += far ? h : 0.1;
      else if (PVector.dist(target, pos) < 120) stuck = 0;
      if (stuck > 0.5) {
        parts.burst(pos, 12, 200, color(140, 255, 220), 0.4, 10);
        pos.set(target);
        safe.set(target);
        vel.set(cam.vel);
        stuck = 0;
      }
      PVector want = PVector.sub(target, pos).mult(16);
      want.limit(4500);
      vel.lerp(want, 1 - exp(-h * 22));
      angVel.lerp(new PVector(0.6, 1.2, 0.3), 1 - exp(-h * 3));
    } else {
      vel.y += GRAVITY * grav * h;
      if (type == OB_FLOATER) vel.mult(exp(-0.15 * h));
      else vel.mult(exp(-0.05 * h));
    }
    vel.limit(MAX_SPEED);
    PVector before = pos.copy();
    pos.add(PVector.mult(vel, h));

    PVector n = new PVector();
    float impact = lab.collideBody(pos, vel, radius, bounce, friction, h, portals, n, safe);
    if (lab.insideAnyBox(pos) == null) safe.set(pos);
    if (impact > 0) {
      // roll: spin to match the surface
      PVector rollW = n.cross(vel).div(radius);
      angVel.lerp(rollW, 1 - exp(-h * 18));
      if (impact > 180 && T - lastImpactT > 0.12) {
        lastImpactT = T;
        float vol = constrain(impact / 1500, 0.08, 0.8);
        if (type == OB_METAL || type == OB_ANVIL || type == OB_BATTERY) sfx.play(sfx.clink, vol, random(0.8, 1.2) * (type == OB_ANVIL ? 0.6 : 1));
        else sfx.play(sfx.thud, vol, random(0.9, 1.2) * (40 / (radius + 10)));
        if (impact > 500) parts.burst(PVector.sub(pos, PVector.mult(n, radius)), int(impact / 120), impact * 0.3, color(200, 220, 255), 0.35, 10);
        onImpact(impact / M, n);
      }
    }
    Portal q = portals.crossed(before, pos);
    if (q == null) {
      // pushed just behind a portal's mouth by something else (a collision, the camera) without crossing it this step
      Portal m = portals.behindMouth(pos, radius);
      if (m != null) {
        if (vel.dot(m.n) < 0) q = m;
        else pos.add(PVector.mult(m.n, 0.5 - PVector.sub(pos, m.c).dot(m.n)));
      }
    }
    if (q != null) teleport(q);

    // integrate spin
    float w = angVel.mag();
    if (w > 1e-3) {
      PMatrix3D m = new PMatrix3D();
      m.rotate(w * h, angVel.x / w, angVel.y / w, angVel.z / w);
      rot.preApply(m);
    }
  }

  void onImpact(float speed, PVector n) {
    if (type == OB_FLASK && speed > 7 && !held) {
      parts.burst(pos, 50, 500, color(120, 255, 120), 0.9, 18);
      parts.burst(pos, 20, 300, color(220, 240, 255), 0.6, 10);
      sfx.play(sfx.clink, 0.9, 1.6);
      sfx.play(sfx.fizzle, 0.6, 1.3);
      gone = 3.5;
      onObjectShattered(this);
    }
    if (type == OB_BATTERY && speed > 5) {
      parts.burst(pos, 18, 420, color(120, 220, 255), 0.4, 12);
      sfx.play(sfx.zap, 0.4, random(0.9, 1.3));
    }
  }

  void teleport(Portal from) {
    Portal to = portals.other(from);
    speedIn = vel.mag() / M;
    boolean quantumBounce = type == OB_QUANTUM && random(1) < 0.35;
    if (quantumBounce) {
      // superposition: it both went through and didn't. Mostly didn't.
      PVector l = from.toLocal(pos);
      pos.set(from.toWorld(new PVector(l.x, l.y, radius + 3)));
      safe.set(pos);
      PVector lv = from.dirToLocal(vel);
      vel.set(from.dirToWorld(new PVector(lv.x, lv.y, -lv.z)));
      from.splash(pos, 0.6);
      parts.burst(pos, 30, 300, color(180, 140, 255), 0.6, 16);
      onQuantumBounce(this);
      return;
    }
    // come out exactly as far past B as it went past A (adding a gap here would
    // hand the object free potential energy on every floor-to-floor loop)
    pos.set(portals.mapPoint(from, pos, 0.5));
    safe.set(pos);
    vel.set(portals.mapDir(from, vel));
    angVel.set(portals.mapDir(from, angVel));
    rot.preApply(portals.mapMatrix(from));
    float stab = physics.stability;
    // weird stuff
    if (type == OB_BOUNCY) vel.mult(1.12);
    if (type == OB_ANVIL) vel.mult(0.55);          // "portal friction": too heavy to get through at full speed
    if (type == OB_FLOATER) {
      if (echoReturn) echoReturn = false;
      else if (random(1) < 0.35) {
        echoT = 0.45;                               // it'll change its mind in a moment
        echoInto = to;
      }
    }
    if (type == OB_ANTIGRAV) grav = -grav;
    if (type == OB_DUMMY) angVel.add(PVector.random3D().mult(14));
    if (type == OB_UNSTABLE) {
      unstable = 1;
      vel.add(PVector.random3D().mult(random(200, 700)));
      angVel.add(PVector.random3D().mult(9));
      mass = random(0.1, 99);
      massRoll++;
    }
    if (type == OB_BATTERY) physics.boost = min(physics.boost + 220, 900);
    if (stab < 0.5) {
      // stretched spacetime: things come out a bit wrong
      vel.add(PVector.random3D().mult((0.5 - stab) * 1600));
      angVel.add(PVector.random3D().mult(6));
      unstable = max(unstable, 0.6);
    }
    vel.limit(MAX_SPEED);
    speedOut = vel.mag() / M;
    chain = (T - lastTeleportT < 1.6) ? chain + 1 : 1;
    lastTeleportT = T;
    teleports++;
    if (held) {
      held = false;
      objects.heldObj = null;
      hud.toast("YOU LOST YOUR GRIP IN ANOTHER DIMENSION", color(255, 200, 120));
    }
    portals.exitFx(from, pos, 0.8);
    from.splash(PVector.add(from.c, PVector.mult(from.n, 10)), 0.6);
    sfx.play(sfx.teleport, 0.55, random(0.9, 1.15));
    physics.recordTeleport(this, from, to);
    if (T - hud.lastJumpToast > 1.2) {
      hud.lastJumpToast = T;
      hud.toast(name + "   IN " + nf(speedIn, 0, 1) + " m/s  ->  OUT " + nf(speedOut, 0, 1) + " m/s", to.colLight);
    }
    onObjectTeleported(this, from, chain);
    if (type == OB_UNSTABLE && teleports % 3 == 0) {
      // three hops and it gives up on existing for a bit
      parts.burst(pos, 80, 700, color(255, 120, 60), 1.0, 26);
      sfx.play(sfx.portalOpen, 0.8, 0.6);
      gone = 3;
      onObjectExploded(this);
    }
  }

  void update(float dt) {
    if (gone > 0) {
      gone -= dt;
      if (gone <= 0) respawn();
      return;
    }
    spawnFx = max(0, spawnFx - dt * 1.6);
    unstable = max(0, unstable - dt * 0.25);
    if (type == OB_UNSTABLE && !held) unstable = max(unstable, 0.25);
    if (type == OB_FLOATER && !held && vel.mag() < 30) vel.y += sin(T * 1.7 + home.x) * 10 * dt;
    // the quantum rock occasionally tunnels a little way on its own
    if (type == OB_QUANTUM && !held) {
      quantumTimer -= dt;
      if (quantumTimer < 0) {
        quantumTimer = random(5, 11);
        PVector jump = PVector.random3D().mult(random(60, 160));
        jump.y = -abs(jump.y);
        parts.burst(pos, 16, 200, color(180, 140, 255), 0.5, 14);
        PVector tryPos = PVector.add(pos, jump);
        RayHit rh = lab.raycast(pos, jump.copy().normalize(), jump.mag() + radius);
        if (!rh.hit()) {
          pos.set(tryPos);
          safe.set(tryPos);
          parts.burst(pos, 16, 200, color(180, 140, 255), 0.5, 14);
          sfx.play(sfx.pop, 0.35, 1.5);
          onQuantumTunnel(this);
        }
      }
    }
    // the zero-g core changes its mind and dives back into the portal it just came out of
    if (echoT > 0) {
      echoT -= dt;
      if (held) echoT = 0;
      else if (echoT <= 0) {
        if (portals.linked() && echoInto != null && echoInto.active) {
          vel.set(PVector.sub(echoInto.c, pos).normalize().mult(max(vel.mag(), 350)));
          echoReturn = true;
          parts.burst(pos, 14, 200, color(150, 220, 255), 0.4, 12);
          onZeroGEcho(this);
        }
        echoInto = null;
      }
    }
    // drifting slowly out in space (zero-g things never fall far enough to count as lost)
    boolean outside = abs(pos.x) > 4500 || abs(pos.z) > 3000 || pos.y < -3200 || pos.y > 2200;
    if (!held && outside && vel.mag() < 150) driftT += dt;
    else driftT = 0;
    // fell off into the universe?
    if (pos.y > 5000 || abs(pos.x) > 12000 || abs(pos.z) > 12000 || pos.y < -9000 || driftT > 6) {
      onObjectLost(this);
      if (dispensed) {
        expired = true;           // dispensed extras just go; the dispenser can always make more
        return;
      }
      respawn();
    }
    // re-orthonormalise the spin matrix now and then
    if (frameCount % 120 == 0) orthonormalize(rot);
  }

  // ---------------------------------------------------------------- drawing (lit, solid pass)
  void draw() {
    if (gone > 0) return;
    pushMatrix();
    PVector p = pos.copy();
    if (unstable > 0.05) p.add(PVector.random3D().mult(unstable * 3));
    translate(p.x, p.y, p.z);
    applyMatrix(rot);
    float s = 1 - spawnFx * spawnFx;
    scale(max(0.01, s));
    noStroke();
    switch (type) {
    case OB_CUBE:
      fill(205, 212, 222);
      box(radius * 1.55);
      fill(60, 200, 255);
      emissive(30, 120, 160);
      box(radius * 1.58, radius * 0.25, radius * 0.25);
      box(radius * 0.25, radius * 1.58, radius * 0.25);
      emissive(0);
      break;
    case OB_METAL:
      fill(150, 156, 168);
      specular(255);
      shininess(12);
      sphere(radius);
      specular(0);
      break;
    case OB_ANTIGRAV:
      fill(120, 60, 200);
      emissive(60, 20, 120);
      sphere(radius);
      emissive(0);
      break;
    case OB_UNSTABLE:
      fill(200, 70, 40);
      emissive(120 + 120 * unstable, 40, 10);
      scale(1 + 0.12 * sin(T * 18) * (0.3 + unstable));
      sphereDetail(5);
      sphere(radius);
      sphereDetail(12);
      emissive(0);
      break;
    case OB_QUANTUM:
      scale(radius);
      shape(galaxy.rockQuantum);
      break;
    case OB_BATTERY:
      fill(40, 44, 54);
      lab.drawCylinder(radius * 0.7, radius * 2.2, 12);
      fill(60, 200, 255);
      emissive(40, 160, 220);
      lab.drawCylinder(radius * 0.72, radius * 0.5, 12);
      emissive(0);
      break;
    case OB_FLASK:
      drawFlask();
      break;
    case OB_ROCK:
      scale(radius);
      shape(galaxy.rockSmall);
      break;
    case OB_DUMMY:
      drawDummy();
      break;
    case OB_PICKLE:
      fill(90, 150, 50);
      scale(radius * 0.55, radius * 0.55, radius * 1.15);
      sphere(1);
      break;
    case OB_BOUNCY:
      fill(255, 70, 90);
      emissive(80, 10, 20);
      sphere(radius);
      emissive(0);
      break;
    case OB_ANVIL:
      fill(55, 58, 64);
      translate(0, radius * 0.35, 0);
      box(radius * 1.2, radius * 0.5, radius * 0.9);
      translate(0, -radius * 0.45, 0);
      box(radius * 0.6, radius * 0.5, radius * 0.6);
      translate(0, -radius * 0.4, 0);
      box(radius * 2.0, radius * 0.4, radius * 0.8);
      break;
    case OB_FLOATER:
      fill(160, 255, 230);
      emissive(40, 140, 120);
      sphereDetail(4);
      sphere(radius);
      sphereDetail(12);
      emissive(0);
      break;
    }
    popMatrix();
  }

  void drawFlask() {
    fill(200, 230, 255, 120);
    pushMatrix();
    translate(0, radius * 0.35, 0);
    beginShape(QUAD_STRIP);
    for (int i = 0; i <= 14; i++) {
      float a = TWO_PI * i / 14;
      normal(cos(a), -0.4, sin(a));
      vertex(cos(a) * radius * 0.9, radius * 0.6, sin(a) * radius * 0.9);
      vertex(cos(a) * radius * 0.28, -radius * 0.8, sin(a) * radius * 0.28);
    }
    endShape();
    fill(90, 255, 120);
    emissive(30, 160, 50);
    translate(0, radius * 0.38, 0);
    lab.drawCylinder(radius * 0.72, radius * 0.4, 12);
    emissive(0);
    popMatrix();
    fill(220, 235, 255);
    translate(0, -radius * 0.75, 0);
    lab.drawCylinder(radius * 0.26, radius * 0.6, 10);
  }

  void drawDummy() {
    float s = radius / 38;
    scale(s);
    fill(235, 200, 40);
    box(26, 34, 16);                         // torso
    pushMatrix();
    translate(0, -26, 0);
    sphere(10);                              // head
    popMatrix();
    fill(30);
    pushMatrix();
    translate(0, -26, 9.5);
    box(12, 3, 1);
    popMatrix();
    fill(235, 200, 40);
    for (int sd = -1; sd <= 1; sd += 2) {
      pushMatrix();
      translate(sd * 17, -4 + sin(T * 6) * 2 * sd, 0);
      box(7, 26, 7);
      popMatrix();
      pushMatrix();
      translate(sd * 7, 30, 0);
      box(9, 28, 9);
      popMatrix();
    }
  }

  // additive extras (glow pass)
  void drawGlow() {
    if (gone > 0) return;
    if (type == OB_ANTIGRAV) {
      glowSprite(pos.x, pos.y, pos.z, radius * 5, color(160, 90, 255), 120);
      pushMatrix();
      translate(pos.x, pos.y, pos.z);
      rotateX(HALF_PI);
      rotateZ(T * 3);
      noFill();
      stroke(190, 140, 255, 180);
      strokeWeight(1.5);
      ellipse(0, 0, radius * 2.8, radius * 2.8);
      rotateX(1.1);
      ellipse(0, 0, radius * 2.4, radius * 2.4);
      noStroke();
      popMatrix();
    }
    if (type == OB_UNSTABLE) glowSprite(pos.x, pos.y, pos.z, radius * (4 + 3 * unstable), color(255, 90, 40), 140 + 100 * unstable);
    if (type == OB_QUANTUM) {
      // faint copies of where else it might be
      for (int k = 0; k < 2; k++) {
        float a = T * 2 + k * PI;
        glowSprite(pos.x + cos(a) * 30, pos.y + sin(a * 1.3) * 15, pos.z + sin(a) * 30, radius * 2.4, color(170, 130, 255), 70);
      }
    }
    if (type == OB_FLOATER || type == OB_BATTERY) glowSprite(pos.x, pos.y, pos.z, radius * 3.5, type == OB_FLOATER ? color(120, 255, 220) : color(80, 200, 255), 80);
    if (unstable > 0.1 && type != OB_UNSTABLE) glowSprite(pos.x, pos.y, pos.z, radius * 3, color(255, 140, 80), 120 * unstable);
    if (spawnFx > 0) glowSprite(pos.x, pos.y, pos.z, radius * 6, color(120, 255, 200), 255 * spawnFx);
  }
}

void orthonormalize(PMatrix3D m) {
  PVector x = new PVector(m.m00, m.m10, m.m20).normalize();
  PVector y = new PVector(m.m01, m.m11, m.m21);
  y.sub(PVector.mult(x, x.dot(y))).normalize();
  PVector z = x.cross(y);
  m.m00 = x.x; m.m10 = x.y; m.m20 = x.z;
  m.m01 = y.x; m.m11 = y.y; m.m21 = y.z;
  m.m02 = z.x; m.m12 = z.y; m.m22 = z.z;
}

// ====================================================================
// All the objects, grabbing, throwing, and the matter dispenser.

class ObjectLab {
  ArrayList<ThrowableObject> list = new ArrayList<ThrowableObject>();
  ThrowableObject heldObj;
  float holdDist = 170;
  float throwPower = 14;              // m/s, mouse wheel changes it
  float lastThrowSpeed;
  int thrown;

  ObjectLab() {
    add(OB_CUBE, -60, -24, -150);
    add(OB_CUBE, 160, -24, -250);
    add(OB_METAL, -260, -20, -60);
    add(OB_BOUNCY, 420, -15, 60);
    add(OB_ANVIL, -900, -30, 600);
    add(OB_UNSTABLE, -1600, -24, -1450);
    add(OB_QUANTUM, 1640, -122, 440);
    add(OB_ROCK, 1840, -114, 640);
    add(OB_BATTERY, 1100, -150, -1830);
    add(OB_PICKLE, 1450, -126, -1830);
    add(OB_FLASK, -200, -138, -1200);
    add(OB_DUMMY, 900, -40, -950);
    add(OB_ANTIGRAV, -400, -200, -1500);
    add(OB_FLOATER, 600, -420, 300);
    add(OB_ROCK, -1200, -14, 1300);
  }

  ThrowableObject add(int type, float x, float y, float z) {
    ThrowableObject o = new ThrowableObject(type, x, y, z);
    list.add(o);
    return o;
  }

  void update(float dt) {
    for (ThrowableObject o : list) o.update(dt);
    for (int i = list.size() - 1; i >= 0; i--) {
      if (!list.get(i).expired) continue;
      if (list.get(i) == heldObj) heldObj = null;
      list.remove(i);
    }
    // sub-step so fast things don't tunnel through walls
    float vmax = 0;
    for (ThrowableObject o : list) vmax = max(vmax, o.vel.mag());
    int n = constrain(ceil(vmax * dt / 8), 1, 16);
    float h = dt / n;
    for (int s = 0; s < n; s++) {
      for (ThrowableObject o : list) o.step(h);
      collidePairs();
    }
    pushedByCamera();
  }

  void collidePairs() {
    for (ThrowableObject o : list) o.prePush.set(o.pos);
    for (int i = 0; i < list.size(); i++) {
      ThrowableObject a = list.get(i);
      if (a.gone > 0) continue;
      for (int j = i + 1; j < list.size(); j++) {
        ThrowableObject b = list.get(j);
        if (b.gone > 0) continue;
        PVector d = PVector.sub(b.pos, a.pos);
        float rr = a.radius + b.radius;
        float d2 = d.magSq();
        if (d2 >= rr * rr || d2 < 1e-6) continue;
        float dist = sqrt(d2);
        PVector nrm = PVector.div(d, dist);
        float ma = a.held ? 1e4 : a.mass, mb = b.held ? 1e4 : b.mass;
        float pen = rr - dist;
        // separate them, but never shove either one into a wall: whatever is blocked goes to the other one
        PVector ra = safeMove(a, PVector.mult(nrm, -pen * mb / (ma + mb)));
        PVector rb = safeMove(b, PVector.mult(nrm, pen * ma / (ma + mb)));
        if (rb.magSq() > 0) safeMove(a, PVector.mult(rb, -1));
        if (ra.magSq() > 0) safeMove(b, PVector.mult(ra, -1));
        float rel = PVector.sub(b.vel, a.vel).dot(nrm);
        if (rel < 0) {
          float e = min(a.bounce, b.bounce);
          float jimp = -(1 + e) * rel / (1 / ma + 1 / mb);
          a.vel.sub(PVector.mult(nrm, jimp / ma));
          b.vel.add(PVector.mult(nrm, jimp / mb));
          if (-rel > 300) sfx.play(sfx.thud, constrain(-rel / 2000, 0.05, 0.5), random(1, 1.4));
          if (-rel > 300) onObjectsCollide(a, b, -rel / M);
        }
      }
    }
    // a push that carried a centre across a linked portal's mouth is a trip through it
    for (int i = 0; i < list.size(); i++) {
      ThrowableObject o = list.get(i);
      if (o.gone > 0) continue;
      Portal q = portals.crossed(o.prePush, o.pos);
      if (q != null) o.teleport(q);
    }
  }

  // flying into things nudges them
  void pushedByCamera() {
    for (ThrowableObject o : list) {
      if (o.held || o.gone > 0) continue;
      PVector d = PVector.sub(o.pos, cam.pos);
      float rr = o.radius + cam.RADIUS;
      if (d.magSq() < rr * rr && d.magSq() > 1e-4) {
        float dist = d.mag();
        d.div(dist);
        o.prePush.set(o.pos);
        PVector rest = safeMove(o, PVector.mult(d, rr - dist));
        Portal q = portals.crossed(o.prePush, o.pos);
        if (q != null) {
          o.teleport(q);                  // shoved through a portal by the camera
          continue;
        }
        if (rest.magSq() > 0.01) {
          // pinned against a wall: the camera is what gives way
          cam.pos.sub(rest);
          float into = cam.vel.dot(d);
          if (into > 0) cam.vel.sub(PVector.mult(d, into));
          continue;
        }
        // bounce off the camera like off a soft wall that may be moving
        float rel = PVector.sub(o.vel, cam.vel).dot(d);
        if (rel < 0) o.vel.sub(PVector.mult(d, rel * (1 + o.bounce)));
        float push = cam.vel.dot(d);
        if (push > 0) o.vel.add(PVector.mult(d, push * 0.2 * min(1, 10 / o.mass)));
      }
    }
  }

  // move an object by delta but stop short of any wall (a linked portal's mouth lets it through);
  // returns the part of the move that was blocked
  PVector safeMove(ThrowableObject o, PVector delta) {
    float L = delta.mag();
    if (L < 1e-4) return new PVector();
    PVector dir = PVector.div(delta, L);
    RayHit h = lab.raycast(o.pos, dir, L + o.radius);
    float ok = L;
    if (h.hit() && !portals.passes(h.box, h.face, h.p, o.radius)) ok = constrain(h.t - o.radius, 0, L);
    o.pos.add(PVector.mult(dir, ok));
    return PVector.mult(dir, L - ok);
  }

  // nearest object under the crosshair (spheres, blocked by walls)
  ThrowableObject pick(float maxT) {
    RayHit wall = lab.raycast(cam.pos, cam.fwd, maxT);
    float best = wall.hit() ? wall.t : maxT;
    ThrowableObject found = null;
    for (ThrowableObject o : list) {
      if (o.gone > 0 || o.held) continue;
      PVector oc = PVector.sub(cam.pos, o.pos);
      float r = o.radius * 1.25;
      float b = oc.dot(cam.fwd), c = oc.magSq() - r * r;
      float disc = b * b - c;
      if (disc < 0) continue;
      float t = -b - sqrt(disc);
      if (t < 0) t = -b + sqrt(disc);
      if (t > 0 && t < best) {
        best = t;
        found = o;
      }
    }
    return found;
  }

  void grab(ThrowableObject o) {
    heldObj = o;
    o.held = true;
    holdDist = constrain(PVector.dist(o.pos, cam.pos) - o.radius, 110, 320);
    sfx.play(sfx.grab, 0.5, 1);
    parts.burst(o.pos, 14, 160, color(140, 255, 220), 0.4, 10);
    onObjectGrabbed(o);
  }

  void throwHeld() {
    if (heldObj == null) return;
    ThrowableObject o = heldObj;
    o.held = false;
    heldObj = null;
    o.vel.set(PVector.mult(cam.fwd, throwPower * M));
    o.vel.add(PVector.mult(cam.vel, 0.5));
    o.angVel.add(PVector.random3D().mult(4));
    lastThrowSpeed = o.vel.mag() / M;
    thrown++;
    sfx.play(sfx.whoosh, 0.6, 0.8 + throwPower / 40);
    onObjectThrown(o);
  }

  void release() {
    if (heldObj == null) return;
    heldObj.held = false;
    heldObj.vel.mult(0.3);
    sfx.play(sfx.drop, 0.5, 1);
    heldObj = null;
  }

  // the matter dispenser coughs up something random
  void dispense() {
    int dispensedCount = 0;
    for (ThrowableObject o : list) if (o.dispensed) dispensedCount++;
    if (dispensedCount >= 12) {
      for (int i = 0; i < list.size(); i++) {
        if (list.get(i).dispensed && list.get(i) != heldObj) {
          list.remove(i);
          break;
        }
      }
    }
    int t = int(random(OB_TYPES));
    ThrowableObject o = add(t, -1700, -330, 1600);
    o.dispensed = true;
    o.home.set(-1700, -330, 1600);
    o.vel.set(random(100, 260), -320, random(-260, -100));
    o.angVel = PVector.random3D().mult(6);
    if (o.grav <= 0) o.vel.mult(0.25);   // zero-g / anti-grav: a gentle push, or it sails off into space
    sfx.play(sfx.spawn, 0.6, 1);
    parts.burst(o.pos, 40, 320, color(120, 255, 200), 0.7, 18);
    onObjectDispensed(o);
  }

  void draw() {
    for (ThrowableObject o : list) o.draw();
  }

  void drawGlow() {
    for (ThrowableObject o : list) o.drawGlow();
  }
}
