// Holographic Ricks: each one is assembled from the PNG parts into its own
// buffer every frame (so he can clap / talk), then drawn through
// data/hologram.glsl for the scanlines, flicker, glitch and materialize.

// rig numbers - must match tools/RickPartsGenerator
final float HEAD_W = 230, HEAD_H = 215, HEAD_AX = 115, HEAD_AY = 200, NECK_Y = -228;
final float BODY_W = 150, BODY_H = 250, BODY_AX = 75, BODY_AY = 244;
final float UP_W = 90, UP_H = 40, UP_AX = 14, UP_AY = 20;
final float FORE_W = 100, FORE_H = 48, FORE_AX = 14, FORE_AY = 24;
final float L1 = 58, L2 = 57, SHOULDER_X = 34, SHOULDER_Y = -206;
final float RICK_H = 395;                                      // feet to hair tips
final int BUF_W = 270, BUF_H = 420;
final float BUF_AX = 135, BUF_AY = 410;                        // where his feet sit in the buffer

PGraphics[] rickBuffers = new PGraphics[6];

PGraphics rickBuffer(int i) {
  if (rickBuffers[i] == null) {
    rickBuffers[i] = createGraphics(BUF_W, BUF_H, P2D);
    rickBuffers[i].smooth(4);
  }
  return rickBuffers[i];
}

class HoloRick {
  int id;
  float x, y, s;
  String tag;
  float spawnAt;
  boolean alive, greeted;
  float age;
  float reveal, glitch;
  float clapPhase, clapRate, clapIn;
  float talkBlend, cheer;
  boolean talking, mouthOpen;
  int talkSide;
  float seed;
  float tr, tg, tb;
  PGraphics buf;
  float[] arm = new float[3];

  HoloRick(int id, float x, float y, float s, String tag, float spawnAt, float[] tint) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.s = s;
    this.tag = tag;
    this.spawnAt = spawnAt;
    tr = tint[0];
    tg = tint[1];
    tb = tint[2];
    seed = random(100);
    clapRate = random(2.0, 2.4);
    clapPhase = random(1);
    talkSide = x < VW / 2 ? 1 : -1;     // gesture with the hand nearest the middle
    buf = rickBuffer(id);
  }

  float headTopY() { return y - RICK_H * s; }
  float handsY() { return y - 182 * s; }

  boolean over(float px, float py) {
    return alive && reveal > 0.5 && px > x - 75 * s && px < x + 75 * s && py > headTopY() && py < y;
  }

  void update(float partyT) {
    if (!alive) {
      if (partyT < spawnAt) return;
      alive = true;
      age = 0;
      sfx.play(sfx.portal, 0.45, random(0.9, 1.15));
    }
    age += dt;
    reveal = constrain((age - 0.35) / 0.9, 0, 1);
    if (!greeted && reveal >= 1) {
      greeted = true;
      party.say(this, random(1) < 0.75 ? "HAPPY BIRTHDAY!" : "HAPPY B-*burp*-IRTHDAY!", true);
      fx.burst(x, y - RICK_H * s * 0.5, 14, color(tr * 255, tg * 255, tb * 255));
      fx.emoji(imgSparkles, x + 40 * s, headTopY() + 40 * s, 70 * s, 0.9, 0.2);
    }

    if (random(1) < 0.004) glitch = random(0.4, 1);
    glitch = max(0.05, glitch - dt * 2.5);
    if (reveal < 1) glitch = max(glitch, 0.55 * (1 - reveal));

    talkBlend += ((talking ? 1 : 0) - talkBlend) * min(1, dt * 6);
    clapIn = constrain((age - 1.3) / 0.4, 0, 1);
    if (age > 1.5) {
      float prev = clapPhase;
      clapPhase += dt * clapRate * (1 + cheer * 0.9);
      if (floor(clapPhase) != floor(prev) && talkBlend < 0.3) clap();
    }
    cheer = max(0, cheer - dt * 0.25);
  }

  void clap() {
    sfx.play(sfx.clap, 0.16 + random(0.08), random(0.85, 1.2));
    if (random(1) < 0.3) {
      fx.emojiDrift(imgClap, x + random(-12, 12) * s, handsY() - 34 * s, 46 * s, 0.7, random(-0.3, 0.3));
    }
  }

  // two-bone IK -> {upper arm angle, forearm angle, forearm length factor}
  void solve(int side, float hx, float hy, int bend, float fore, float[] out) {
    float l2 = L2 * fore;
    float sx = SHOULDER_X * side, sy = SHOULDER_Y;
    float dx = hx - sx, dy = hy - sy;
    float d = constrain(sqrt(dx * dx + dy * dy), abs(L1 - l2) + 0.5, L1 + l2 - 0.5);
    float a = atan2(dy, dx);
    float b = acos(constrain((L1 * L1 + d * d - l2 * l2) / (2 * L1 * d), -1, 1));
    float u = a - b * side * bend;
    float ex = sx + cos(u) * L1, ey = sy + sin(u) * L1;
    out[0] = u;
    out[1] = atan2(hy - ey, hx - ex);
    out[2] = fore;
  }

  float[] pa = new float[3], pb = new float[3], pc = new float[3];

  void poseArm(int side) {
    float o = pow(sin(PI * (clapPhase % 1)), 0.7);
    solve(side, 46 * side, -100 + sin(T * 1.3 + seed) * 2, 1, 1, pa);       // arms down
    solve(side, (9 + 30 * o) * side, -180 - 5 * o, 1, 0.82, pb);              // clapping
    if (side == talkSide) {                                                   // talking: wave a hand around
      solve(side, (84 + 6 * sin(T * 5 + seed)) * side, -238 + 8 * sin(T * 3.1 + seed), -1, 1, pc);
    } else {
      solve(side, 42 * side, -112, 1, 1, pc);                                 // other hand on the hip
    }
    float k = smooth01(talkBlend);
    arm[0] = angleLerp(angleLerp(pa[0], pb[0], clapIn), pc[0], k);
    arm[1] = angleLerp(angleLerp(pa[1], pb[1], clapIn), pc[1], k);
    arm[2] = lerp(lerp(pa[2], pb[2], clapIn), pc[2], k);
  }

  void drawArm(PGraphics g, int side) {
    poseArm(side);
    float sx = SHOULDER_X * side, sy = SHOULDER_Y;
    float ex = sx + cos(arm[0]) * L1, ey = sy + sin(arm[0]) * L1;
    g.pushMatrix();
    g.translate(sx, sy);
    g.rotate(arm[0]);
    if (side < 0) g.scale(1, -1);
    g.image(imgRickUpper, -UP_AX, -UP_AY, UP_W, UP_H);
    g.popMatrix();
    g.pushMatrix();
    g.translate(ex, ey);
    g.rotate(arm[1]);
    g.scale(arm[2], side < 0 ? -1 : 1);
    g.image(imgRickFore, -FORE_AX, -FORE_AY, FORE_W, FORE_H);
    g.popMatrix();
  }

  void render() {
    if (!alive) return;
    float bob = -abs(sin(PI * clapPhase)) * 2.5 * clapIn * (1 - talkBlend);
    float tilt = sin(T * 4.5 + seed) * 0.06 * talkBlend + sin(clapPhase * TWO_PI) * 0.025 * clapIn;
    buf.beginDraw();
    buf.clear();
    buf.imageMode(CORNER);
    buf.pushMatrix();
    buf.translate(BUF_AX, BUF_AY + bob);
    buf.image(imgRickBody, -BODY_AX, -BODY_AY, BODY_W, BODY_H);
    buf.pushMatrix();
    buf.translate(0, NECK_Y);
    buf.rotate(tilt);
    buf.image(mouthOpen ? imgRickHeadTalk : imgRickHead, -HEAD_AX, -HEAD_AY, HEAD_W, HEAD_H);
    buf.popMatrix();
    drawArm(buf, 1);
    drawArm(buf, -1);
    buf.popMatrix();
    buf.endDraw();
  }

  float portalOpen() {
    if (age < 0.35) return easeOutBack(age / 0.35);
    if (age < 1.6) return 1;
    return 1 - smooth01((age - 1.6) / 0.35);
  }

  void draw() {
    if (!alive) return;
    int tint = color(tr * 255, tg * 255, tb * 255);
    float po = portalOpen();
    if (po > 0.01) drawPortal(x, y - 180 * s, 86 * s, 168 * s, po, T * 1.5 + seed);

    // projector pad + light cone
    float v = reveal;
    blendMode(ADD);
    noStroke();
    beginShape(QUADS);
    fill(tint, 55 * v);
    vertex(x - 55 * s, y);
    vertex(x + 55 * s, y);
    fill(tint, 0);
    vertex(x + 105 * s, y - RICK_H * s);
    vertex(x - 105 * s, y - RICK_H * s);
    endShape();
    glowAt(x, y, 240 * s, tint, 120 * v);
    noFill();
    stroke(tint, 210 * v);
    strokeWeight(2);
    ellipse(x, y, 120 * s, 22 * s);
    stroke(tint, 120 * v);
    ellipse(x, y, 86 * s * (1 + 0.08 * sin(T * 5 + seed)), 15 * s);
    noStroke();
    blendMode(BLEND);

    // the hologram itself, then a faint additive bloom pass
    imageMode(CORNER);
    holoPass(0.95);
    blendMode(ADD);
    holoPass(0.22);
    blendMode(BLEND);
  }

  void holoPass(float alpha) {
    float k = alpha < 0.5 ? 1.025 : 1;   // bloom pass is drawn slightly bigger
    float x0 = x - BUF_AX * s * k, y0 = y - BUF_AY * s * k, w = BUF_W * s * k, h = BUF_H * s * k;
    if (holoShader != null) {
      holoShader.set("time", T + seed);
      holoShader.set("reveal", reveal);
      holoShader.set("glitch", glitch);
      holoShader.set("alpha", alpha);
      holoShader.set("tint", tr, tg, tb);
      shader(holoShader);
      image(buf, x0, y0, w, h);
      resetShader();
    } else {
      // no shader support: tinted + flickering, still materializing from the feet up
      int cut = (int) ((1 - reveal) * BUF_H);
      float flick = 0.85 + 0.15 * sin(T * 37 + seed) * sin(T * 11);
      tint(140 + tr * 115, 140 + tg * 115, 140 + tb * 115, 230 * alpha * flick);
      image(buf, x0, y0 + cut * h / BUF_H, w, h - cut * h / BUF_H, 0, cut, BUF_W, BUF_H);
      noTint();
    }
  }
}

// ======================================================================
// The party: who stands where, who talks when.

class Party {
  ArrayList<HoloRick> ricks = new ArrayList<HoloRick>();
  ArrayList<Speech> speech = new ArrayList<Speech>();
  boolean started;
  float t;
  float nextJokeAt = 5.2;
  Speech current;
  HoloRick lastTalker;
  IntList deck = new IntList();
  float nextBalloon = 0.6, nextFirework = 3.5;

  Party() {
    float[][] spots = {
      { 115, 702, 0.80 }, { 1165, 702, 0.80 },
      { 272, 652, 0.70 }, { 1008, 652, 0.70 },
      { 398, 588, 0.58 }, { 882, 588, 0.58 }
    };
    String[] tags = { "RICK  C-137", "RICK  J-19", "RICK  D-99", "RICK  K-22", "RICK  Z-12", "RICK  F-5" };
    float[][] tints = {
      { 0.35, 0.95, 1.0 }, { 0.45, 1.0, 0.85 }, { 0.5, 0.8, 1.0 },
      { 0.35, 0.95, 1.0 }, { 0.8, 0.65, 1.0 }, { 0.45, 1.0, 0.85 }
    };
    for (int i = 0; i < spots.length; i++) {
      ricks.add(new HoloRick(i, spots[i][0], spots[i][1], spots[i][2], tags[i], 0.15 + i * 0.4, tints[i]));
    }
  }

  void start() {
    started = true;
    t = 0;
  }

  void update() {
    if (!started) return;
    t += dt;
    for (HoloRick r : ricks) r.update(t);

    for (int i = speech.size() - 1; i >= 0; i--) {
      Speech sp = speech.get(i);
      sp.update();
      if (sp.finished()) {
        sp.who.talking = false;
        sp.who.mouthOpen = false;
        speech.remove(i);
        if (sp == current) {
          current = null;
          nextJokeAt = t + random(1.0, 1.8);
        }
      }
    }
    if (current == null && t > nextJokeAt) nextJoke();

    nextBalloon -= dt;
    if (nextBalloon < 0 && t > 1) {
      fx.balloon();
      nextBalloon = random(0.7, 1.5);
    }
    nextFirework -= dt;
    if (nextFirework < 0) {
      fx.firework(random(160, VW - 160), random(70, 260));
      nextFirework = random(2.5, 4.5);
    }
  }

  void renderBuffers() {
    for (HoloRick r : ricks) r.render();
  }

  void drawRicks() {
    for (HoloRick r : ricks) r.draw();
  }

  void drawSpeech() {
    for (Speech sp : speech) sp.draw();
  }

  HoloRick rickAt(float px, float py) {
    for (int i = ricks.size() - 1; i >= 0; i--) {
      if (ricks.get(i).over(px, py)) return ricks.get(i);
    }
    return null;
  }

  HoloRick randomRick() {
    ArrayList<HoloRick> pool = new ArrayList<HoloRick>();
    for (HoloRick r : ricks) if (r.alive && r.reveal >= 1 && r != lastTalker) pool.add(r);
    if (pool.isEmpty()) return null;
    return pool.get(int(random(pool.size())));
  }

  String drawJoke() {
    if (deck.size() == 0) {
      for (int i = 0; i < JOKES.length; i++) deck.append(i);
      deck.shuffle();
    }
    int i = deck.get(deck.size() - 1);
    deck.remove(deck.size() - 1);
    return JOKES[i];
  }

  void nextJoke() {
    HoloRick r = randomRick();
    if (r != null) talk(r, drawJoke());
  }

  void jokeFrom(HoloRick r) {
    talk(r, drawJoke());
  }

  void talk(HoloRick r, String line) {
    if (current != null) current.dismiss();
    for (Speech sp : speech) if (sp.who == r) sp.dismiss();
    current = say(r, line, false);
    lastTalker = r;
  }

  Speech say(HoloRick r, String line, boolean shout) {
    Speech sp = new Speech(r, line, shout);
    speech.add(sp);
    if (!shout) r.talking = true;
    return sp;
  }

  // the candles were just blown out
  void wish() {
    HoloRick r = randomRick();
    if (r != null) talk(r, WISHES[int(random(WISHES.length))]);
    for (HoloRick o : ricks) {
      o.cheer = 1;
      if (o != r && o.alive) fx.floatText(random(1) < 0.5 ? "WOOO!" : "YEAH!", o.x, o.headTopY() - 10, color(255, 230, 120));
    }
    for (int i = 0; i < 4; i++) fx.firework(random(200, VW - 200), random(70, 240));
    fx.emoji(imgConfettiBall, box.cx, box.rimY() - 330, 120, 1.4, 0);
    fx.confettiBurst(box.cx, box.rimY() - 140, 160, -HALF_PI, TWO_PI, 520);
    sfx.play(sfx.applause, 0.8, 1);
  }

  // the trick candles came back on
  void relit() {
    HoloRick r = randomRick();
    if (r != null) talk(r, RELIGHTS[int(random(RELIGHTS.length))]);
  }
}

// ======================================================================
// Rick's voice: comic speech boxes with typewriter text.

class Speech {
  HoloRick who;
  String text;
  boolean shout;
  float age, life;
  boolean dismissed;
  float dismissT;
  ArrayList<String> lines = new ArrayList<String>();
  float fs, w, h, lineH;
  final float CPS = 34;   // characters per second
  final float PAD = 14;

  Speech(HoloRick who, String text, boolean shout) {
    this.who = who;
    this.text = text;
    this.shout = shout;
    fs = shout ? 24 : 25;
    lineH = fs * 1.12;
    textFont(fComic, fs);
    float maxW = shout ? 260 : 330;
    String cur = "";
    for (String word : split(text, ' ')) {
      String test = cur.length() == 0 ? word : cur + " " + word;
      if (textWidth(test) > maxW && cur.length() > 0) {
        lines.add(cur);
        cur = word;
      } else {
        cur = test;
      }
    }
    if (cur.length() > 0) lines.add(cur);
    w = 0;
    for (String l : lines) w = max(w, textWidth(l));
    w += PAD * 2;
    h = lines.size() * lineH + PAD * 2 + (shout ? 0 : 6);
    life = shout ? 1.8 : max(3.8, text.length() / CPS + 3.0);
  }

  void dismiss() {
    if (!dismissed) {
      dismissed = true;
      dismissT = 0;
    }
  }

  boolean typing() { return age * CPS < text.length(); }
  boolean finished() { return age > life || (dismissed && dismissT > 0.18); }

  void update() {
    age += dt;
    if (dismissed) dismissT += dt;
    boolean flap = shout ? age < 1.0 : typing();
    who.mouthOpen = flap && !dismissed && (int)(age * 10) % 2 == 0;
  }

  void draw() {
    float pop = easeOutBack(age / 0.22);
    float fade = 1;
    if (age > life - 0.25) fade = (life - age) / 0.25;
    if (dismissed) fade = min(fade, 1 - dismissT / 0.18);
    fade = constrain(fade, 0, 1);
    if (fade <= 0) return;

    float tipX = who.x + (who.x < VW / 2 ? 8 : -8) * who.s;
    float tipY = who.headTopY() + 4;
    float bx = constrain(who.x, w / 2 + 10, VW - w / 2 - 10);
    float bBottom = tipY - 20;
    float bTop = bBottom - h;
    float tailX = constrain(tipX, bx - w / 2 + 26, bx + w / 2 - 26);

    pushMatrix();
    translate(tipX, tipY);
    scale(pop);
    translate(-tipX, -tipY);

    // shadow
    noStroke();
    fill(0, 110 * fade);
    rect(bx - w / 2 + 6, bTop + 6, w, h, 16);
    // outlined box + tail
    stroke(20, 18, 30, 255 * fade);
    strokeWeight(3);
    fill(255, 252, 240, 250 * fade);
    triangle(tailX - 13, bBottom - 2, tailX + 13, bBottom - 2, tipX, tipY);
    rect(bx - w / 2, bTop, w, h, 16);
    noStroke();
    triangle(tailX - 11, bBottom - 4, tailX + 11, bBottom - 4, tipX, tipY - 4);
    // hologram-cyan accent
    stroke(who.tr * 255, who.tg * 255, who.tb * 255, 200 * fade);
    strokeWeight(2);
    noFill();
    rect(bx - w / 2 + 5, bTop + 5, w - 10, h - 10, 12);

    // name tag
    if (!shout) {
      textFont(fTech, 11);
      float tw = textWidth(who.tag) + 16;
      noStroke();
      fill(20, 18, 30, 255 * fade);
      rect(bx - w / 2 + 12, bTop - 11, tw, 20, 10);
      fill(who.tr * 255, who.tg * 255, who.tb * 255, 255 * fade);
      textAlign(LEFT, CENTER);
      text(who.tag, bx - w / 2 + 20, bTop - 2);
    }

    // typewriter text, *burps* in green
    textFont(fComic, fs);
    textAlign(LEFT, TOP);
    int budget = shout ? 9999 : (int)(age * CPS);
    float ty = bTop + PAD + (shout ? 0 : 4);
    for (String l : lines) {
      float lx = bx - w / 2 + PAD;
      String[] words = split(l, ' ');
      for (int i = 0; i < words.length && budget > 0; i++) {
        String word = words[i];
        String shown = word.substring(0, min(word.length(), budget));
        budget -= word.length() + 1;
        if (word.indexOf('*') >= 0) fill(60, 150, 40, 255 * fade);
        else fill(25, 22, 35, 255 * fade);
        text(shown, lx, ty);
        lx += textWidth(word + " ");
      }
      ty += lineH;
    }
    popMatrix();
  }
}
