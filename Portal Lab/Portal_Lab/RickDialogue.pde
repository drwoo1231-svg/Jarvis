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
  int lastIdleMs;              // when Rick last complained about idling
  int idleCount;
  float eventCooldown;         // keeps event jokes from spamming
  java.util.HashMap<String, Float> seen = new java.util.HashMap<String, Float>();
  java.util.HashMap<String, Integer> pick = new java.util.HashMap<String, Integer>();
  PFont font, nameFont;
  float stare;                 // seconds you've been staring at his hologram
  float holdTime;              // seconds the current object has been held
  float lastStareLine = -999;
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
    sfx.play(line.contains("*burp*") ? sfx.burp : sfx.pop, line.contains("*burp*") ? 0.7 : 0.35, 0.8);
  }

  // event joke: once per `key` per `repeat` seconds, never more often than every 6 s overall
  void event(String key, float repeat, String[] lines) {
    if (eventCooldown > 0) return;
    Float last = seen.get(key);
    if (last != null && T - last < repeat) return;
    seen.put(key, T);
    int i = pick.containsKey(key) ? pick.get(key) : 0;
    pick.put(key, i + 1);
    say(lines[i % lines.length]);
    eventCooldown = 6;
  }

  void update(float dt) {
    eventCooldown -= dt;
    if (showing) {
      age += dt;
      if (age > life) showing = false;
    }
    // the idle timer
    if (idleSeconds() > IDLE_LIMIT && !showing) {
      idleCount++;
      String line;
      if (idleCount % 3 == 1) line = MAIN_IDLE_LINE;              // the classic, first and every third time
      else if (staringAtWall()) line = "Congratulations. You're staring at a wall.";
      else line = IDLE_LINES[(idleCount / 3 + idleCount) % IDLE_LINES.length];
      say(line);
      lastIdleMs = millis();                                      // 20 s timer starts over
    }
    // staring at the hologram
    PVector toHolo = PVector.sub(holoPos, cam.pos);
    float d = toHolo.mag();
    if (d < 2500 && toHolo.normalize().dot(cam.fwd) > 0.995) stare += dt;
    else stare = 0;
    if (stare > 2.5 && T - lastStareLine > 60) {
      lastStareLine = T;
      stare = 0;
      say("What? Never seen a holographic genius before?");
    }
    // things thrown through his face
    for (ThrowableObject o : objects.list) {
      if (o.held || o.gone > 0 || o.vel.mag() < 250) continue;
      if (PVector.dist(o.pos, holoPos) < 160) {
        if (o.type == OB_PICKLE) event("holopickle", 40, HOLO_PICKLE);
        else event("holohit", 25, HOLO_HIT);
      }
    }
    // clinging to one object for ages
    if (objects.heldObj != null) holdTime += dt;
    else holdTime = 0;
    if (holdTime > 40 && eventCooldown <= 0) {
      String nm = objects.heldObj.name;
      event("clingy", 120, new String[] {
        "You've been holding that " + nm + " for forty seconds. Put a ring on it or put it down.",
        "Still holding the " + nm + "? It's not a teddy bear. Well, unless it's Gary. Even then, no." });
    }
    // wandered off into the universe
    if (cam.pos.mag() > 9000) event("faraway", 90, FAR_AWAY);
    // went down into the void pit / up to the high platform
    if (cam.pos.y > 150 && abs(cam.pos.x) < 380 && cam.pos.z > 180 && cam.pos.z < 920) event("pit", 120, IN_PIT);
    if (cam.pos.y < -2350 && abs(cam.pos.x) < 650 && cam.pos.z > 450 && cam.pos.z < 1550) event("high", 180, HIGH_UP);
    // portalled away: drift over to the other portal, then home again
    if (holoAway > 0) {
      holoAway -= dt;
      if (holoAway <= 0) {
        holoTarget.set(holoHome);
        event("holoback", 0, HOLO_BACK);
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
    noStroke();
    tint(255, 200 + 55 * sin(T * 13) * sin(T * 3.1));
    beginShape(QUADS);
    texture(open ? holoTalk : holo);
    vertex(x - r.x + u.x, y - r.y + u.y, z - r.z + u.z, 0, 0);
    vertex(x + r.x + u.x, y + r.y + u.y, z + r.z + u.z, 1, 0);
    vertex(x + r.x - u.x, y + r.y - u.y, z + r.z - u.z, 1, 1);
    vertex(x - r.x - u.x, y - r.y - u.y, z - r.z - u.z, 0, 1);
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
    float px = width - 120, py = height - 150;          // portrait centre
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
    rect(bx + 7, by + 7, w, h, 22);
    stroke(20, 20, 26, 255 * fade);
    strokeWeight(4);
    fill(255, 252, 240, 250 * fade);
    triangle(bx + w - 6, by + h * 0.45, bx + w - 6, by + h * 0.8, bx + w + 48, by + h * 0.72);
    rect(bx, by, w, h, 22);
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
  checkPortalUnderRick(q);
  if (portals.p[0].active && portals.p[1].active) {
    if (floorCeilingPair()) rick.event("floorceil", 180, FLOOR_CEILING);
    else if (portals.distance() < 420) rick.event("close", 120, TOO_CLOSE);
    else rick.event("linked", 240, LINKED);
  } else {
    rick.event("first", 100000, FIRST_PORTAL);
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
  if (chain >= 10) { rick.event("loop10", 120, LOOP_TEN); return; }
  if (chain >= 4) { rick.event("loop", 60, LOOPING); return; }
  if (o.type == OB_PICKLE) { rick.event("pickle", 60, PICKLE_JUMP); return; }
  if (o.type == OB_BATTERY) { rick.event("battery", 60, BATTERY_JUMP); return; }
  if (o.type == OB_ANTIGRAV) { rick.event("antigrav", 60, ANTIGRAV_JUMP); return; }
  if (o.type == OB_DUMMY) { rick.event("dummy", 60, DUMMY_JUMP); return; }
  rick.event("objjump", 45, OBJ_JUMP);
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
  rick.event("lost", 40, LOST);
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

// a portal opened on the floor right under his hologram
void checkPortalUnderRick(Portal q) {
  if (q.n.y > -0.9) return;
  if (dist(q.c.x, q.c.z, rick.holoHome.x, rick.holoHome.z) > 380) return;
  Portal o = portals.other(q);
  if (!o.active) {
    rick.event("hololonely", 60, HOLO_LONELY);
    return;
  }
  rick.eventCooldown = 0;
  rick.event("holosuck", 20, HOLO_SUCK);
  PVector t = PVector.add(o.c, PVector.mult(o.n, 320));
  t.y -= 120;
  rick.holoTarget.set(t);
  rick.holoAway = 14;
  q.splash(PVector.add(q.c, PVector.mult(q.n, 20)), 1.2);
  o.splash(PVector.add(o.c, PVector.mult(o.n, 20)), 1.2);
  sfx.play(sfx.teleport, 0.7, 0.7);
}

void noteCameraJump() {
  rick.camJumps.add(T);
  while (rick.camJumps.size() > 0 && T - rick.camJumps.get(0) > 20) rick.camJumps.remove(0);
  if (rick.camJumps.size() >= 5) rick.event("hopping", 90, HOPPING);
}

void noteDispense() {
  rick.dispenses.add(T);
  while (rick.dispenses.size() > 0 && T - rick.dispenses.get(0) > 10) rick.dispenses.remove(0);
  if (rick.dispenses.size() >= 5) rick.event("dispspam", 60, DISPENSER_SPAM);
}

void onObjectsCollide(ThrowableObject a, ThrowableObject b, float speed) {
  boolean garyAnvil = (a.type == OB_ANVIL && b.type == OB_DUMMY) || (a.type == OB_DUMMY && b.type == OB_ANVIL);
  if (garyAnvil && speed > 3) rick.event("garyanvil", 45, GARY_ANVIL);
}
