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
  float spawnFx = 1;            // materialize animation 1 -> 0
  float unstable;               // glow / jitter amount
  int teleports, chain;
  float lastTeleportT = -99, lastImpactT = -99;
  float speedIn, speedOut;
  float quantumTimer = random(4, 9);
  float gone;                   // > 0 while shattered / respawning
  float stuck;                  // held but not reaching the hold point
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
    // fell off into the universe?
    if (pos.y > 5000 || abs(pos.x) > 12000 || abs(pos.z) > 12000 || pos.y < -9000) {
      onObjectLost(this);
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
      fill(120, 100, 150);
      scale(radius);
      shape(galaxy.rockMesh[1]);
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
      fill(110, 100, 92);
      scale(radius);
      shape(galaxy.rockMesh[0]);
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
        a.pos.sub(PVector.mult(nrm, pen * mb / (ma + mb)));
        b.pos.add(PVector.mult(nrm, pen * ma / (ma + mb)));
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
        o.pos.add(PVector.mult(d, rr - dist));
        // bounce off the camera like off a soft wall that may be moving
        float rel = PVector.sub(o.vel, cam.vel).dot(d);
        if (rel < 0) o.vel.sub(PVector.mult(d, rel * (1 + o.bounce)));
        float push = cam.vel.dot(d);
        if (push > 0) o.vel.add(PVector.mult(d, push * 0.2 * min(1, 10 / o.mass)));
      }
    }
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
        if (list.get(i).dispensed) {
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
