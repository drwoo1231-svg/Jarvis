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
