// Scene 1: a lecture hall in some dimension. A portal tears open, Rick tumbles
// out drunk, burps, rambles, and drags you into today's lesson.

class IntroScene extends Scene {
  PortalFx portal = new PortalFx(980, 360, 120, 190);
  float t;                    // scene time
  float rx = 980, ry = 560;   // Rick's feet
  float spin;                 // tumbling out of the portal
  float sway, flask, tilt;
  int line = -1;
  float lineT;                // time since the current line finished typing
  boolean leaving;
  ArrayList<float[]> gas = new ArrayList<float[]>();    // burp cloud puffs: x, y, vx, vy, life, size
  String[] LINES = {
    "*burp* Wh- where... OH. The med school dimension. Great. Just great.",
    "I was in the middle of a very important science- *hic* -bender. Very important. There was a Gazorpazorp.",
    "But apparently YOU need to learn how the human body works. Ugh. *burp* Fine.",
    "It's meat, bones and electricity, genius. Meat. Bones. Electri- *BUUURP*",
    "Today's lesson... choose difficulty, idiot."
  };

  void enter() {
    rick.drunkMode = true;
    rick.dock = DOCK_POINT;
    rick.boxW = 560;
  }

  void update(float dt) {
    t += dt;
    portal.update(dt);
    if (t > 0.3 && t < 0.35) sfx.play(sfx.portal, 0.8);
    portal.target = t > 0.3 && t < 3.2 ? 1 : 0;
    // tumble out of the portal, land, stagger to the middle
    if (t < 1.3) {
      rx = 980;
      ry = 560;
      spin = 0;
    } else if (t < 2.1) {
      float k = (t - 1.3) / 0.8;
      rx = lerp(980, 640, k);
      ry = 560 - sin(k * PI) * 120;
      spin = -k * TWO_PI;
      if (t - dt < 1.3) sfx.play(sfx.whoosh, 0.6);
    } else {
      if (spin != 0) {
        spin = 0;
        sfx.play(sfx.thud, 0.8);
      }
      rx = 640 + sin(t * 0.9) * 26;   // can't stand still
      ry = 560;
    }
    sway = t > 2.1 ? sin(t * 1.7) * 0.07 + sin(t * 3.1) * 0.025 : 0;
    // drinking between lines
    flask = 0;
    float drinkT = t - 2.5;
    if (drinkT > 0 && drinkT < 1.4) {
      flask = sin(min(1, drinkT / 1.4) * PI);
      if (drinkT - dt <= 0.2 && drinkT > 0.2) sfx.play(sfx.slurp, 0.6);
    }
    tilt = flask * -0.35 + (rick.burping() ? -0.25 : 0) + sway * 0.6;
    // the dialogue
    if (line < 0 && t > 3.6) nextLine();
    if (line >= 0 && rick.done()) lineT += dt;
    if (line >= 0 && line < LINES.length - 1 && rick.done() && lineT > 2.4) nextLine();
    if (line == LINES.length - 1 && rick.done() && lineT > 1.6 && !leaving) finish();
    // burp gas
    if (rick.burping() && frameCount % 2 == 0) {
      float mx = rx + 18 + sin(sway) * 300, my = ry - 300;
      gas.add(new float[] { mx, my, random(30, 140), random(-90, -20), 1.4, random(18, 40) });
    }
    for (int i = gas.size() - 1; i >= 0; i--) {
      float[] g = gas.get(i);
      g[0] += g[2] * dt;
      g[1] += g[3] * dt;
      g[4] -= dt;
      g[5] += dt * 30;
      if (g[4] <= 0) gas.remove(i);
    }
    // the speech-box tail follows his mouth as he sways
    rick.px = rx + 16 + sin(sway) * 285;
    rick.py = ry - 285 * cos(sway);
  }

  void nextLine() {
    line++;
    lineT = 0;
    rick.say(LINES[line]);
  }

  void finish() {
    leaving = true;
    rick.drunkMode = false;
    go(new DifficultyScene());
  }

  void draw() {
    drawHall();
    portal.draw();
    // Rick (in front of the portal once he's out)
    if (t > 1.3) {
      pushMatrix();
      translate(rx, ry - 160);
      rotate(spin);
      translate(-rx, -(ry - 160));
      float sq = 1 + (rick.burping() ? 0.04 * sin(T * 40) : 0);
      rick.drawBody(rx, ry, 1.0 * sq, sway, flask, tilt);
      popMatrix();
    }
    // burp cloud
    noStroke();
    for (float[] g : gas) {
      fill(140, 200, 90, 90 * g[4] / 1.4);
      ellipse(g[0], g[1], g[5], g[5]);
    }
    if (rick.burping() && T - rick.burpT < 0.6) {
      float k = (T - rick.burpT) / 0.6;
      textFont(fTitle);
      textAlign(CENTER, CENTER);
      fill(#9BE36A, 255 * (1 - k));
      pushMatrix();
      translate(rx + 150, ry - 380 - k * 40);
      rotate(-0.15);
      scale(0.8 + k * 0.4);
      text("BUUURP", 0, 0);
      popMatrix();
    }
    rick.drawBox();
    // skip hint
    textFont(fSmall);
    textAlign(RIGHT, BOTTOM);
    fill(C_DIM, 160 + 80 * sin(T * 3));
    text("click: next line     ENTER: skip intro", W - 18, H - 14);
  }

  // a lecture hall: back wall, chalkboard with doodles, desk
  void drawHall() {
    noStroke();
    for (int y = 0; y < H; y += 4) {
      fill(lerpColor(#1A2238, #0E1322, y / (float) H));
      rect(0, y, W, 4);
    }
    // floor
    fill(#2A2018);
    rect(0, 560, W, 160);
    fill(#33271D);
    for (int i = 0; i < 14; i++) rect(i * 100 - 20, 560, 4, 160);
    // chalkboard
    fill(#5A3B22);
    rect(150, 90, 620, 330, 8);
    fill(#1F3A2C);
    rect(166, 106, 588, 298, 4);
    // chalk doodles (it's a med school...)
    stroke(235, 240, 230, 200);
    strokeWeight(3);
    noFill();
    textFont(fH1);
    fill(235, 240, 230, 210);
    textAlign(LEFT, TOP);
    text("ANATOMY 101", 196, 126);
    textFont(fBody);
    text("Prof: ???", 200, 178);
    text("Rule 1: don't die", 200, 210);
    text("Rule 2: see rule 1", 200, 240);
    noFill();
    // a bone
    strokeWeight(3);
    line(540, 180, 680, 180);
    ellipse(533, 172, 16, 16);
    ellipse(533, 188, 16, 16);
    ellipse(687, 172, 16, 16);
    ellipse(687, 188, 16, 16);
    // a heart
    beginShape();
    vertex(610, 330);
    bezierVertex(560, 290, 570, 245, 610, 268);
    bezierVertex(650, 245, 660, 290, 610, 330);
    endShape();
    // a little neuron
    ellipse(240, 340, 26, 26);
    line(253, 340, 380, 340);
    line(380, 340, 395, 328);
    line(380, 340, 395, 352);
    line(228, 332, 205, 318);
    line(230, 350, 206, 362);
    // a stick figure that looks unwell
    ellipse(470, 300, 22, 22);
    line(470, 311, 470, 350);
    line(470, 322, 452, 338);
    line(470, 322, 488, 338);
    line(470, 350, 456, 380);
    line(470, 350, 484, 380);
    line(462, 296, 466, 300);
    line(466, 296, 462, 300);
    line(474, 296, 478, 300);
    line(478, 296, 474, 300);
    noStroke();
    // desk
    fill(#4A3220);
    rect(80, 500, 360, 26, 4);
    fill(#3A2718);
    rect(100, 526, 20, 60);
    rect(400, 526, 20, 60);
    // a beaker on the desk
    fill(120, 220, 255, 140);
    rect(330, 462, 34, 38, 4);
    fill(120, 255, 140, 170);
    rect(330, 478, 34, 22, 3);
  }

  void mouse() {
    if (line < 0) {
      t = max(t, 3.6);
      return;
    }
    if (!rick.finish()) {
      if (line < LINES.length - 1) nextLine();
      else if (!leaving) finish();
    }
  }

  void key(char k, int code) {
    if (code == ENTER || code == RETURN || k == '\n') {
      if (!leaving) finish();
    } else if (k == ' ') mouse();
  }

  void back() {
    if (!leaving) finish();
  }
}
