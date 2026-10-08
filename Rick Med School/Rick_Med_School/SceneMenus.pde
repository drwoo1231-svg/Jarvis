// "TODAY'S LESSON: CHOOSE DIFFICULTY, IDIOT." and the body-system picker.

// ---------------------------------------------------------------- shared bits
void drawStars(float x, float y, int n, float s) {
  for (int i = 0; i < 3; i++) {
    fill(i < n ? C_GOLD : #2A3550);
    stroke(i < n ? #8A6A10 : #3A4766);
    strokeWeight(1.5);
    star(x + i * s * 1.15, y, s * 0.5, s * 0.22);
  }
}

void star(float cx, float cy, float r1, float r2) {
  beginShape();
  for (int i = 0; i < 10; i++) {
    float a = -HALF_PI + i * PI / 5;
    float r = i % 2 == 0 ? r1 : r2;
    vertex(cx + cos(a) * r, cy + sin(a) * r);
  }
  endShape(CLOSE);
}

void levelBadge(float x, float y, int level) {
  textFont(fMono);
  String s = level == 0 ? "STUDY" : "LV" + level + " " + LEVEL_NAMES[level];
  float w = textWidth(s) + 20;
  noStroke();
  fill(level == 0 ? C_BLUE : LEVEL_COLS[level]);
  rect(x, y, w, 26, 13);
  fill(#0B1020);
  textAlign(LEFT, CENTER);
  text(s, x + 10, y + 12);
}

void schmeckles(float x, float y) {
  textFont(fMono);
  textAlign(RIGHT, TOP);
  fill(C_GOLD);
  text(progress.xp() + " SCHMECKLES", x, y);
}

// ---------------------------------------------------------------- difficulty
class DifficultyScene extends Scene {
  float t;
  int hoverLv;
  float[] lift = new float[5];

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.drunkMode = false;
    rick.say(pick(DIFF_ENTER));
    button("explore", "STUDY DIAGRAMS", 60, 622, 250, 64).key("S").sub = "point at stuff, learn stuff";
    int n = progress.mistakes(0).size();
    Button r = button("review", "REVIEW MISTAKES", 326, 622, 250, 64).key("R").colour(C_GOLD);
    r.sub = n == 0 ? "nothing to review yet" : n + " question" + (n == 1 ? "" : "s") + " to fix";
    r.enabled = n > 0;
  }

  float cardX(int lv) {
    return 60 + (lv - 1) * 296;
  }

  void update(float dt) {
    t += dt;
    int h = 0;
    for (int lv = 1; lv <= 4; lv++) if (over(cardX(lv), 190, 276, 370)) h = lv;
    if (h != hoverLv && h != 0) rick.say(pick(DIFF_HOVER[h]));
    hoverLv = h;
    for (int lv = 1; lv <= 4; lv++) lift[lv] += ((lv == hoverLv ? 1 : 0) - lift[lv]) * min(1, dt * 12);
    rick.idleCheck();
  }

  void draw() {
    space.draw();
    drawPortal(W / 2, 96, 330, 70, T * 0.6, 60);
    // the title, wobbling like the man who wrote it
    textAlign(CENTER, CENTER);
    textFont(fH2);
    fill(C_GREEN);
    text("TODAY'S LESSON:", W / 2, 46);
    textFont(fTitle);
    String title = "CHOOSE DIFFICULTY, IDIOT.";
    float tw = textWidth(title), x = W / 2 - tw / 2;
    for (int i = 0; i < title.length(); i++) {
      String c = title.substring(i, i + 1);
      float cw = textWidth(c);
      pushMatrix();
      translate(x + cw / 2, 112 + sin(T * 2.4 + i * 0.5) * 5);
      rotate(sin(T * 1.7 + i * 0.8) * 0.06);
      fill(0, 150);
      text(c, 3, 4);
      fill(lerpColor(#E8FFE0, C_GREEN, 0.5 + 0.5 * sin(T * 2 + i * 0.3)));
      text(c, 0, 0);
      popMatrix();
      x += cw;
    }
    for (int lv = 1; lv <= 4; lv++) drawCard(lv);
    drawButtons();
    schmeckles(W - 20, 14);
    rick.drawBox();
  }

  void drawCard(int lv) {
    float x = cardX(lv), y = 190 - lift[lv] * 10, w = 276, h = 370;
    int c = LEVEL_COLS[lv];
    noStroke();
    fill(0, 120);
    rect(x + 6, y + 10, w, h, 22);
    fill(lerpColor(C_PANEL, c, 0.08 + 0.1 * lift[lv]));
    stroke(lerpColor(C_EDGE, c, 0.5 + 0.5 * lift[lv]));
    strokeWeight(2 + lift[lv] * 2);
    rect(x, y, w, h, 22);
    // icon
    pushMatrix();
    translate(x + w / 2, y + 108);
    scale(1 + lift[lv] * 0.08);
    rotate(sin(T * 2 + lv) * 0.05 * lift[lv]);
    levelIcon(lv);
    popMatrix();
    textAlign(CENTER, TOP);
    textFont(fMono);
    fill(c);
    text("LEVEL " + lv + "   [" + lv + "]", x + w / 2, y + 20);
    textFont(fH2);
    fill(C_TEXT);
    text(LEVEL_NAMES[lv], x + w / 2, y + 196);
    textFont(fSmall);
    fill(C_DIM);
    textBlockCentered(LEVEL_SUBS[lv], x + w / 2, y + 236, w - 40, 22);
    // progress across the ten topics
    int stars = 0, done = 0;
    for (String k : TOPIC_ORDER) {
      stars += progress.stars(k, lv);
      if (progress.best(k, lv) >= 0) done++;
    }
    fill(C_GOLD);
    star(x + 40, y + h - 46, 12, 5.4);
    textFont(fBodyB);
    textAlign(LEFT, CENTER);
    fill(C_TEXT);
    text(stars + " / " + TOPIC_ORDER.length * 3, x + 58, y + h - 47);
    textFont(fSmall);
    fill(C_DIM);
    textAlign(RIGHT, CENTER);
    text(done + "/" + TOPIC_ORDER.length + " systems", x + w - 22, y + h - 46);
  }

  void mouse() {
    for (int lv = 1; lv <= 4; lv++) if (over(cardX(lv), 190, 276, 370)) choose(lv);
  }

  void choose(int lv) {
    sfx.play(sfx.click, 0.5);
    go(new TopicScene(lv));
  }

  void key(char k, int code) {
    if (k >= '1' && k <= '4') choose(k - '0');
  }

  void clicked(Button b) {
    if (b.id.equals("explore")) go(new ExploreScene(null));
    if (b.id.equals("review")) startReview(0);
  }

  void back() {
    go(new IntroScene());
  }
}

void textBlockCentered(String s, float cx, float y, float w, float lh) {
  ArrayList<String> ls = wrapText(s, w);
  textAlign(CENTER, TOP);
  for (int i = 0; i < ls.size(); i++) text(ls.get(i), cx, y + i * lh);
}

// little drawings on the difficulty cards
void levelIcon(int lv) {
  strokeWeight(3);
  stroke(#1E1C28);
  if (lv == 1) {               // baby bottle
    fill(#FFE7EF);
    rect(-26, -30, 52, 74, 14);
    fill(#F6C0D0);
    rect(-30, -40, 60, 14, 6);
    fill(#F2D2B6);
    beginShape();
    vertex(-12, -40);
    bezierVertex(-12, -70, 12, -70, 12, -40);
    endShape(CLOSE);
    noStroke();
    fill(255, 255, 255, 200);
    rect(-16, -18, 10, 50, 5);
    stroke(#E58FAA);
    for (int i = 0; i < 3; i++) line(10, -12 + i * 16, 22, -12 + i * 16);
  } else if (lv == 2) {        // test tube
    rotate(0.3);
    fill(#DFF6FF);
    rect(-16, -56, 32, 100, 0, 0, 16, 16);
    noStroke();
    fill(#5FD3FF);
    rect(-14, -6, 28, 48, 0, 0, 14, 14);
    fill(255, 160);
    ellipse(-4, 10, 8, 8);
    ellipse(5, 26, 6, 6);
    stroke(#1E1C28);
    noFill();
    rect(-16, -56, 32, 100, 0, 0, 16, 16);
    fill(#9AA6B5);
    rect(-20, -62, 40, 10, 4);
  } else if (lv == 3) {        // stethoscope
    noFill();
    stroke(#3A4766);
    strokeWeight(7);
    beginShape();
    vertex(-30, -50);
    bezierVertex(-36, 10, 36, 10, 30, -50);
    endShape();
    line(0, 8, 0, 30);
    stroke(#1E1C28);
    strokeWeight(3);
    fill(#C9D2DC);
    ellipse(0, 40, 36, 36);
    fill(#8C96A3);
    ellipse(0, 40, 18, 18);
    fill(#FFB547);
    ellipse(-30, -52, 12, 12);
    ellipse(30, -52, 12, 12);
  } else {                     // Rick's flask with a skull
    fill(#B9C2CC);
    rect(-30, -40, 60, 80, 12);
    fill(#8C96A3);
    rect(-10, -54, 20, 16, 4);
    noStroke();
    fill(#FF4F6D);
    ellipse(0, 0, 34, 30);
    rect(-9, 8, 18, 12, 3);
    fill(#B9C2CC);
    ellipse(-7, -2, 9, 9);
    ellipse(7, -2, 9, 9);
    rect(-5, 12, 3, 8);
    rect(2, 12, 3, 8);
  }
}

// ---------------------------------------------------------------- body systems
class TopicScene extends Scene {
  int level;
  String hoverKey = "";
  float[] lift = new float[12];

  TopicScene(int level) {
    this.level = level;
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.say(pick(TOPIC_ENTER));
    button("back", "< BACK", 54, 640, 170, 56).key("B");
    button("explore", "STUDY DIAGRAMS", 240, 640, 270, 56).key("S").colour(C_BLUE);
  }

  float[] cell(int i) {
    float w = 186, h = 220, gap = 12;
    int col = i % 6, row = i / 6;
    return new float[] { 54 + col * (w + gap), 118 + row * (h + 16), w, h };
  }

  String keyAt(int i) {
    if (i < TOPIC_ORDER.length) return TOPIC_ORDER[i];
    return i == 10 ? "mix" : "review";
  }

  void update(float dt) {
    String h = "";
    for (int i = 0; i < 12; i++) {
      float[] c = cell(i);
      boolean on = over(c[0], c[1], c[2], c[3]);
      if (on) h = keyAt(i);
      lift[i] += ((on ? 1 : 0) - lift[i]) * min(1, dt * 12);
    }
    if (!h.equals(hoverKey) && h.length() > 0) {
      if (TOPIC_HOVER.containsKey(h)) rick.say(TOPIC_HOVER.get(h)[0]);
      else if (h.equals("mix")) rick.say("Random mix. Questions from every system. Chaos. I love it.");
      else rick.say("Your mistakes. All of them. Fix them and they go away. Like my marriages.");
    }
    hoverKey = h;
    rick.idleCheck();
  }

  void draw() {
    space.draw();
    levelBadge(54, 26, level);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text("PICK A BODY SYSTEM", 54, 56);
    schmeckles(W - 20, 14);
    for (int i = 0; i < 12; i++) drawCell(i);
    drawButtons();
    rick.drawBox();
  }

  void drawCell(int i) {
    float[] c = cell(i);
    float x = c[0], y = c[1] - lift[i] * 6, w = c[2], h = c[3];
    String k = keyAt(i);
    int col = LEVEL_COLS[level];
    noStroke();
    fill(0, 110);
    rect(x + 5, y + 8, w, h, 18);
    fill(lerpColor(C_PANEL, col, 0.06 + 0.1 * lift[i]));
    stroke(lerpColor(C_EDGE, col, 0.4 + 0.6 * lift[i]));
    strokeWeight(2 + lift[i]);
    rect(x, y, w, h, 18);
    textAlign(CENTER, TOP);
    if (i < TOPIC_ORDER.length) {
      Topic t = TOPICS.get(k);
      // thumbnail
      noStroke();
      fill(C_PAPER);
      ellipse(x + w / 2, y + 74, 116, 116);
      Diagram d = diagram(t.mainDiagram());
      if (d != null) {
        imageMode(CENTER);
        image(d.thumb(), x + w / 2, y + 74, 104, 104);
        imageMode(CORNER);
      }
      textFont(fBodyB);
      fill(C_TEXT);
      text(t.title, x + w / 2, y + 140);
      int b = progress.best(k, level);
      drawStars(x + w / 2 - 23, y + 198, progress.stars(k, level), 18);
      textFont(fSmall);
      fill(C_DIM);
      textAlign(CENTER, TOP);
      text(b < 0 ? "not tried" : "best " + b + "%", x + w / 2, y + 164);
      // which levels have been passed
      for (int lv = 1; lv <= 4; lv++) {
        noStroke();
        fill(progress.stars(k, lv) > 0 ? LEVEL_COLS[lv] : #2A3550);
        ellipse(x + w - 16, y + 16 + (lv - 1) * 12, 7, 7);
      }
    } else if (k.equals("mix")) {
      // dice
      pushMatrix();
      translate(x + w / 2, y + 76);
      rotate(sin(T) * 0.2);
      stroke(#1E1C28);
      strokeWeight(3);
      fill(#F6F1E4);
      rect(-34, -34, 68, 68, 12);
      noStroke();
      fill(#1E1C28);
      ellipse(-16, -16, 11, 11);
      ellipse(16, 16, 11, 11);
      ellipse(0, 0, 11, 11);
      ellipse(16, -16, 11, 11);
      ellipse(-16, 16, 11, 11);
      popMatrix();
      textFont(fBodyB);
      fill(C_TEXT);
      textAlign(CENTER, TOP);
      text("RANDOM MIX", x + w / 2, y + 140);
      textFont(fSmall);
      fill(C_DIM);
      text("12 from every system", x + w / 2, y + 168);
    } else {
      int n = progress.mistakes(level).size();
      textFont(fTitle);
      fill(n > 0 ? C_GOLD : C_DIM);
      textAlign(CENTER, CENTER);
      text("" + n, x + w / 2, y + 74);
      textFont(fBodyB);
      fill(C_TEXT);
      textAlign(CENTER, TOP);
      text("MISTAKES", x + w / 2, y + 140);
      textFont(fSmall);
      fill(C_DIM);
      text(n > 0 ? "fix them, they vanish" : "none yet at this level", x + w / 2, y + 168);
    }
  }

  void mouse() {
    for (int i = 0; i < 12; i++) {
      float[] c = cell(i);
      if (!over(c[0], c[1], c[2], c[3])) continue;
      sfx.play(sfx.click, 0.5);
      String k = keyAt(i);
      if (i < TOPIC_ORDER.length) go(new LessonScene(TOPICS.get(k), level));
      else if (k.equals("mix")) startMix(level);
      else startReview(level);
    }
  }

  void clicked(Button b) {
    if (b.id.equals("back")) back();
    if (b.id.equals("explore")) go(new ExploreScene(null));
  }

  void back() {
    go(new DifficultyScene());
  }
}

// ---------------------------------------------------------------- quiz launchers
void startMix(int level) {
  ArrayList<Question> all = new ArrayList<Question>();
  for (String k : TOPIC_ORDER) all.addAll(TOPICS.get(k).levels[level].questions);
  java.util.Collections.shuffle(all);
  if (all.isEmpty()) return;
  ArrayList<Question> qs = new ArrayList<Question>(all.subList(0, min(12, all.size())));
  go(new QuizScene("RANDOM MIX", qs, level, "mix", false));
}

void startReview(int level) {
  ArrayList<Question> qs = progress.mistakes(level);
  if (qs.isEmpty()) {
    rick.say(pick(REVIEW_EMPTY));
    return;
  }
  java.util.Collections.shuffle(qs);
  if (qs.size() > 12) qs = new ArrayList<Question>(qs.subList(0, 12));
  go(new QuizScene("MISTAKES REVIEW", qs, level, "review", true));
}
