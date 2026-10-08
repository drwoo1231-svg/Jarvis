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

  void update(float dt) {
    // keyboard look (fallback for touchpads / when the mouse can't be captured)
    float kl = 1.9 * dt;
    if (kLookL) yaw -= kl;
    if (kLookR) yaw += kl;
    if (kLookU) pitch += kl;
    if (kLookD) pitch -= kl;
    updateBasis();

    PVector wish = new PVector();
    PVector flatF = new PVector(sin(yaw), 0, -cos(yaw));
    PVector flatR = new PVector(cos(yaw), 0, sin(yaw));
    if (kW) wish.add(flatF);
    if (kS) wish.sub(flatF);
    if (kD) wish.add(flatR);
    if (kA) wish.sub(flatR);
    if (kUp) wish.y -= 1;
    if (kDown) wish.y += 1;
    movedThisFrame = wish.magSq() > 0;
    if (movedThisFrame) wish.normalize();
    float speed = (kFast ? 19 : 6.5) * M;
    PVector target = PVector.mult(wish, speed);
    float k = 1 - exp(-dt * (movedThisFrame ? 7 : 5));
    vel.lerp(target, k);

    // move in small steps so we never tunnel through a thin wall
    PVector step = PVector.mult(vel, dt);
    int n = max(1, ceil(step.mag() / (RADIUS * 0.5)));
    step.div(n);
    for (int i = 0; i < n; i++) {
      PVector before = pos.copy();
      pos.add(step);
      if (!noclip) lab.collideSphere(pos, vel, RADIUS, portals);
      onMoved(before);
    }
  }

  // did that step carry us through a portal?
  void onMoved(PVector before) {
    Portal q = portals.crossed(before, pos);
    if (q == null) return;
    PVector newFwd = portals.mapDir(q, fwd);
    pos.set(portals.mapPoint(q, pos, RADIUS * 0.5 + 2));
    vel.set(portals.mapDir(q, vel));
    lookAlong(newFwd);
    portals.exitFx(q, pos, 1);
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
      if (win != null) {
        try {
          win.confinePointer(true);
          win.warpPointer(width / 2, height / 2);
        } catch (Exception e) {
          // some window systems refuse - arrow keys still look around
        }
      }
    } else {
      cursor(ARROW);
      if (win != null) {
        try {
          win.confinePointer(false);
        } catch (Exception e) {
        }
      }
    }
  }

  void mouseMovedTo(float x, float y) {
    if (!captured) return;
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
    if (win != null && (x < width * 0.25 || x > width * 0.75 || y < height * 0.25 || y > height * 0.75)) {
      try {
        win.warpPointer(width / 2, height / 2);
      } catch (Exception e) {
      }
    }
  }

  void drawCrosshair() {
    float cx = width / 2, cy = height / 2;
    stroke(170, 255, 200, 200);
    strokeWeight(1.5);
    noFill();
    ellipse(cx, cy, 14, 14);
    line(cx - 12, cy, cx - 5, cy);
    line(cx + 5, cy, cx + 12, cy);
    line(cx, cy - 12, cx, cy - 5);
    line(cx, cy + 5, cx, cy + 12);
    noStroke();
  }
}
