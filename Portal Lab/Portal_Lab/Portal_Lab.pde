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
HUD hud;
Sfx sfx;

int lastActionMs;                 // for Rick's idle timer (millis based)

float T;                          // seconds since start
float dt = 1 / 60.0;
int lastMs;

// held keys
boolean kW, kA, kS, kD, kUp, kDown, kFast, kLookL, kLookR, kLookU, kLookD, kRotL, kRotR;

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
  gun.draw();
  parts.draw();
  endGlowPass();
  hud.capturePortalTags();

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
  char k = Character.toLowerCase(key);
  if (k == 'e') interact();
  if (key == TAB) {
    hud.terminalOpen = !hud.terminalOpen;
    markAction();
    if (hud.terminalOpen) onTerminalOpened();
  }
  // F3 (NEWT reports it as code 99; 114 is the AWT code) - the ` key works too
  if ((key == CODED && (keyCode == 99 || keyCode == 114)) || key == '`') hud.debug = !hud.debug;
  if (k == 'h') hud.showControls = !hud.showControls;
  if (k == 'n' && hud.debug) cam.noclip = !cam.noclip;
  if (k == 'm') sfx.muted = !sfx.muted;
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

float idleSeconds() {
  return (millis() - lastActionMs) / 1000.0;
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
  if (k == 'q') kRotL = down;
  if (k == 'r') kRotR = down && manip.active();
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

void mouseWheel(processing.event.MouseEvent e) {
  float c = e.getCount();
  if (manip.active()) {
    manip.rotateStep(radians(15) * c);
  } else {
    objects.throwPower = constrain(objects.throwPower - c, 2, 40);
    hud.toast("THROW POWER " + nf(objects.throwPower, 0, 0) + " m/s", color(170, 255, 220));
  }
}

// ------------------------------------------------------------------ events
void onPortalPlaced(Portal q) {
}

void onPortalFizzled(String why, RayHit h) {
}

void onCameraTeleported(Portal from) {
}

void onPortalManipulated(Portal q) {
}

void onObjectTeleported(ThrowableObject o, Portal from, int chain) {
}

void onQuantumBounce(ThrowableObject o) {
}

void onQuantumTunnel(ThrowableObject o) {
}

void onObjectShattered(ThrowableObject o) {
}

void onObjectExploded(ThrowableObject o) {
}

void onObjectLost(ThrowableObject o) {
}

void onObjectGrabbed(ThrowableObject o) {
}

void onObjectThrown(ThrowableObject o) {
}

void onObjectDispensed(ThrowableObject o) {
}

void onLowStability() {
}

void onTerminalOpened() {
}

void mouseMoved() {
  cam.mouseMovedTo(mouseX, mouseY);
}

void mouseDragged() {
  cam.mouseMovedTo(mouseX, mouseY);
}

void focusLost() {
  kW = kA = kS = kD = kUp = kDown = kFast = kLookL = kLookR = kLookU = kLookD = kRotL = kRotR = false;
  if (cam != null) cam.capture(false);
}
