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
HUD hud;
Sfx sfx;

float T;                          // seconds since start
float dt = 1 / 60.0;
int lastMs;

// held keys
boolean kW, kA, kS, kD, kUp, kDown, kFast, kLookL, kLookR, kLookU, kLookD;

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
  sfx = new Sfx();
  galaxy = new Galaxy();
  lab = new Laboratory();
  parts = new Particles();
  portals = new PortalPair();
  gun = new PortalGun();
  hud = new HUD();
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
  portals.update(dt);
  parts.update(dt);
  hud.update(dt);

  // ---- 3D
  background(0);
  hint(ENABLE_DEPTH_TEST);
  cam.apply();
  galaxy.drawSky(cam.pos);
  lab.lightsOn();
  portals.lights();
  lab.drawSolid();
  galaxy.drawWorld();
  noLights();
  portals.drawSolid();
  beginGlowPass();
  lab.drawGlow();
  galaxy.drawDust();
  portals.drawGlow();
  gun.draw();
  parts.draw();
  endGlowPass();

  // ---- 2D overlay
  begin2D();
  hud.draw();
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
}

void keyReleased() {
  setKey(false);
}

void setKey(boolean down) {
  char k = Character.toLowerCase(key);
  if (k == 'w') kW = down;
  if (k == 'a') kA = down;
  if (k == 's') kS = down;
  if (k == 'd') kD = down;
  if (k == ' ') kUp = down;
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
  if (mouseButton == LEFT) gun.fire();
}

// ------------------------------------------------------------------ events
void onPortalPlaced(Portal q) {
}

void onPortalFizzled(String why, RayHit h) {
}

void onCameraTeleported(Portal from) {
}

void mouseMoved() {
  cam.mouseMovedTo(mouseX, mouseY);
}

void mouseDragged() {
  cam.mouseMovedTo(mouseX, mouseY);
}

void focusLost() {
  kW = kA = kS = kD = kUp = kDown = kFast = kLookL = kLookR = kLookU = kLookD = false;
  if (cam != null) cam.capture(false);
}
