// The quiz: multiple choice (1-4 / click) and "click the part" on a diagram.
// Every answer shows the explanation, so a wrong answer still teaches.
// Wrong answers go to the mistakes pile (REVIEW), right answers in review
// work them back out. RICK MODE has a clock.

class QuizScene extends Scene {
  String title, topicKey;
  int level;
  boolean review;
  ArrayList<Question> qs;
  int idx;
  Question q;
  int[] order = new int[4];            // shuffled choice order: display slot -> original index
  boolean[] gone = new boolean[4];     // removed by a hint
  int chosen = -1;                     // display slot picked
  Part clicked;
  boolean answered, wasRight, hinted, timedOut;
  float hintX, hintY;                  // label hint circle (diagram units)
  int score, streak, bestStreak, right, gained;
  ArrayList<Question> missed = new ArrayList<Question>();
  float qT, answerT;
  float top;                           // where the answer area starts (below the question)
  float escT = -9;                     // ESC must be pressed twice to abandon the quiz
  float timeLimit;
  int lastTick;
  DiagramView view = new DiagramView();
  Button nextB, hintB;

  QuizScene(String title, ArrayList<Question> qs, int level, String topicKey, boolean review) {
    this.title = title;
    this.qs = qs;
    this.level = level;
    this.topicKey = topicKey;
    this.review = review;
    timeLimit = level == 4 ? 45 : 0;
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    nextB = button("next", "NEXT >", 990, 470, 230, 54).key(" ");
    hintB = button("hint", "HINT  (half points)", 760, 470, 260, 54).key("H").colour(C_GOLD);
    hintB.showKey = false;
    button("quit", "QUIT", 1110, 14, 110, 40).colour(C_RED);
    load(0);
    rick.say(pick(QUIZ_START));
  }

  void load(int i) {
    idx = i;
    q = qs.get(idx);
    answered = false;
    wasRight = false;
    hinted = false;
    timedOut = false;
    chosen = -1;
    clicked = null;
    qT = 0;
    lastTick = -1;
    rick.dock = DOCK_CORNER;
    rick.quiet();
    textFont(fH2);
    top = 100 + max(70, textBlockHeight(q.q, 1150, 34) + 30) + 16;
    hintB.x = 770;
    hintB.y = top + 240;
    for (int k = 0; k < 4; k++) {
      order[k] = k;
      gone[k] = false;
    }
    if (!q.isLabel()) {
      for (int k = 3; k > 0; k--) {
        int j = (int) random(k + 1);
        int tmp = order[k];
        order[k] = order[j];
        order[j] = tmp;
      }
    } else {
      view.set(diagram(q.diagram), 140, top + 14, 440);
      view.marks.clear();
      view.pulse = null;
      view.hoverOn = true;
    }
  }

  // ---------------------------------------------------------------- answering
  void pickChoice(int slot) {
    if (answered || q.isLabel() || gone[slot]) return;
    chosen = slot;
    finish(order[slot] == q.answer);
  }

  void pickPart(Part p) {
    if (answered || !q.isLabel() || p == null) return;
    clicked = p;
    boolean ok = p.id.equals(q.part);
    view.marks.put(q.part, C_GREEN);
    if (!ok) view.marks.put(p.id, C_RED);
    finish(ok);
  }

  void timeout() {
    if (answered) return;
    timedOut = true;
    if (q.isLabel()) view.marks.put(q.part, C_GREEN);
    finish(false);
  }

  void finish(boolean ok) {
    answered = true;
    wasRight = ok;
    answerT = 0;
    rick.dock = DOCK_HIDDEN;           // his reaction goes inside the feedback panel
    progress.answered(ok);
    if (ok) {
      right++;
      streak++;
      bestStreak = max(bestStreak, streak);
      float mult = 1 + 0.1 * min(10, streak - 1);
      gained = (int) (100 * max(1, level) * mult * (hinted ? 0.5 : 1));
      if (timeLimit > 0) gained += (int) max(0, timeLimit - qT) * 4;
      score += gained;
      progress.addXp(max(1, gained / 10));
      progress.hit(q.id, review);
      if (streak == 3 || streak == 5 || streak == 8) {
        sfx.play(sfx.streak, 0.6);
        rick.say(STREAK[streak == 3 ? 0 : streak == 5 ? 1 : 2]);
      } else {
        sfx.play(sfx.correct, 0.6);
        rick.say(q.rick != null && q.rick.length() > 0 && random(1) < 0.75 ? q.rick : pick(CORRECT));
      }
    } else {
      streak = 0;
      gained = 0;
      missed.add(q);
      progress.miss(q.id);
      sfx.play(sfx.wrong, 0.6);
      if (timedOut) rick.say(pick(TIMEOUT_LINES));
      else if (q.isLabel() && clicked != null) rick.say(String.format(pick(LABEL_WRONG), partName(q.diagram, clicked.id)));
      else rick.say(random(1) < 0.5 && q.rick != null && q.rick.length() > 0 ? q.rick : pick(WRONG));
    }
    progress.save();
  }

  void useHint() {
    if (answered || hinted) return;
    hinted = true;
    rick.say(pick(HINT_LINES));
    if (!q.isLabel()) {
      // knock out two wrong answers
      int removed = 0;
      for (int s = 0; s < 4 && removed < 2; s++) {
        int slot = (s + idx) % 4;
        if (order[slot] != q.answer) {
          gone[slot] = true;
          removed++;
        }
      }
    } else {
      // a circle that contains the answer (not centred on it)
      Part p = view.d.part(q.part);
      float[] a = p.anchorPt();
      float ang = random(TWO_PI);
      hintX = constrain(a[0] + cos(ang) * 40, 90, DIA - 90);
      hintY = constrain(a[1] + sin(ang) * 40, 90, DIA - 90);
    }
  }

  void next() {
    if (!answered) return;
    if (idx < qs.size() - 1) load(idx + 1);
    else go(new ResultScene(this));
  }

  // ---------------------------------------------------------------- frame
  void update(float dt) {
    if (!answered) qT += dt;
    else answerT += dt;
    if (q.isLabel()) {
      view.hoverOn = !answered;
      view.update();
    }
    if (timeLimit > 0 && !answered) {
      int left = (int) (timeLimit - qT);
      if (left < 10 && left != lastTick) {
        lastTick = left;
        sfx.play(sfx.tick, 0.5);
      }
      if (qT >= timeLimit) timeout();
    }
    nextB.visible = answered;
    nextB.label = idx < qs.size() - 1 ? "NEXT >" : "RESULTS >";
    hintB.visible = !answered;
    hintB.enabled = !hinted;
  }

  void draw() {
    space.draw();
    drawHeader();
    drawQuestion();
    if (q.isLabel()) drawLabelQ();
    else drawChoices();
    drawSide();
    drawButtons();
    rick.drawBox();
  }

  void drawHeader() {
    levelBadge(40, 20, level);
    textFont(fBodyB);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    float bw = textWidth("LV" + level + " " + (level == 0 ? "STUDY" : LEVEL_NAMES[level])) + 40;
    text(title, 40 + bw + 6, 21);
    textFont(fMono);
    textAlign(LEFT, TOP);
    fill(C_DIM);
    text("QUESTION " + (idx + 1) + " / " + qs.size(), 40, 58);
    // progress pips
    for (int i = 0; i < qs.size(); i++) {
      noStroke();
      fill(i < idx || (i == idx && answered) ? C_GREEN : i == idx ? C_TEXT : #2A3550);
      rect(250 + i * 22, 60, 16, 10, 3);
    }
    textAlign(RIGHT, TOP);
    fill(C_GOLD);
    text("SCORE " + score, 1090, 20);
    fill(streak >= 3 ? #FF9A3C : C_DIM);
    text("STREAK " + streak + (streak >= 3 ? " !!" : ""), 1090, 40);
    if (T - escT < 2) {
      textFont(fMono);
      textAlign(RIGHT, TOP);
      fill(C_RED);
      text("ESC AGAIN TO QUIT", 1090, 62);
    }
    if (timeLimit > 0 && !answered) {
      float k = constrain(1 - qT / timeLimit, 0, 1);
      noStroke();
      fill(#2A3550);
      rect(40, 84, 1200, 8, 4);
      fill(k > 0.3 ? C_GREEN : C_RED);
      rect(40, 84, 1200 * k, 8, 4);
    }
  }

  void drawQuestion() {
    textFont(fH2);
    float h = textBlockHeight(q.q, 1150, 34) + 30;
    panel(40, 100, 1200, max(70, h), C_PANEL2, C_EDGE, 16);
    fill(C_TEXT);
    textBlock(q.q, 64, 114, 1150, 34);
  }

  void drawChoices() {
    textFont(fBody);
    for (int s = 0; s < 4; s++) {
      float x = 40, y = top + s * 92, w = 680, h = 80;
      boolean hov = !answered && !gone[s] && over(x, y, w, h);
      boolean isAns = order[s] == q.answer;
      int bg = C_PANEL, edge = C_EDGE;
      if (hov) {
        bg = lerpColor(C_PANEL, C_BLUE, 0.18);
        edge = C_BLUE;
      }
      if (answered && isAns) {
        bg = lerpColor(C_PANEL, C_GREEN, 0.3);
        edge = C_GREEN;
      } else if (answered && s == chosen) {
        bg = lerpColor(C_PANEL, C_RED, 0.3);
        edge = C_RED;
      }
      float a = gone[s] ? 70 : 255;
      noStroke();
      fill(0, 100 * a / 255);
      rect(x + 4, y + 6, w, h, 14);
      fill(bg, a);
      stroke(edge, a);
      strokeWeight(hov || (answered && (isAns || s == chosen)) ? 3 : 2);
      rect(x, y, w, h, 14);
      // key cap
      noStroke();
      fill(edge, a);
      rect(x + 14, y + h / 2 - 18, 36, 36, 8);
      fill(#0B1020, a);
      textFont(fBodyB);
      textAlign(CENTER, CENTER);
      text("" + (s + 1), x + 32, y + h / 2 - 1);
      textFont(fBody);
      fill(C_TEXT, a);
      ArrayList<String> ls = wrapText(q.choices[order[s]], w - 90);
      float ty = y + h / 2 - ls.size() * 14;
      textAlign(LEFT, TOP);
      for (int i = 0; i < ls.size(); i++) text(ls.get(i), x + 66, ty + i * 28);
      if (answered && (isAns || s == chosen)) {
        textFont(fH2);
        fill(isAns ? C_GREEN : C_RED);
        textAlign(RIGHT, CENTER);
        text(isAns ? "OK" : "X", x + w - 18, y + h / 2);
      }
    }
  }

  void drawLabelQ() {
    view.draw();
    if (hinted && !answered) {
      float s = view.s();
      noFill();
      stroke(C_GOLD);
      strokeWeight(3);
      float r = 95 * s;
      float cx = view.x + hintX * s, cy = view.y + hintY * s;
      for (int i = 0; i < 24; i += 2) arc(cx, cy, r * 2, r * 2, TWO_PI * i / 24 + T, TWO_PI * (i + 1) / 24 + T);
    }
    if (answered) {
      Part ans = view.d.part(q.part);
      if (clicked != null && clicked != ans) view.tag(clicked, partName(q.diagram, clicked.id), C_RED);
      if (ans != null) view.tag(ans, partName(q.diagram, q.part), C_GREEN);
    }
    textFont(fSmall);
    textAlign(LEFT, TOP);
    fill(C_DIM);
    text(answered ? view.d.title : "click the part on the diagram", 140, min(H - 22, view.y + view.size + 18));
  }

  // right column: instructions before, verdict + explanation after
  void drawSide() {
    float x = 740, y = top, w = 510;
    if (!answered) {
      panel(x, y, w, 220, C_PANEL, C_EDGE, 18);
      textFont(fBodyB);
      fill(C_TEXT);
      textAlign(LEFT, TOP);
      text(q.isLabel() ? "CLICK THE RIGHT PART" : "PICK ONE  (1 - 4)", x + 24, y + 22);
      textFont(fSmall);
      fill(C_DIM);
      String tip = q.isLabel() ? "Hover shows outlines, not names. That would be cheating. Cheating's MY thing."
        : "Click an answer or press 1-4. Wrong answers go in your mistakes pile so you can fix them later.";
      textBlock(tip, x + 24, y + 58, w - 48, 22);
      textBlock("H = hint for half points.  " + (timeLimit > 0 ? "RICK MODE: " + (int) max(0, ceil(timeLimit - qT)) + " s left." : "No clock at this level."), x + 24, y + 150, w - 48, 22);
      return;
    }
    textFont(fExplain);
    String extra = "";
    if (!wasRight) extra = q.isLabel() ? "Answer: " + partName(q.diagram, q.part) : "Answer: " + q.choices[q.answer];
    float eh = textBlockHeight(q.explain, w - 48, 24);
    textFont(fBodyB);
    float xh = extra.length() > 0 ? textBlockHeight(extra, w - 48, 26) + 8 : 0;
    textFont(fRickSmall);
    float rh = max(58, textBlockHeight("RICK: " + rick.text, w - 120, 22) + 6);
    float h = 70 + xh + eh + 14 + rh + 70;
    float k = min(1, answerT / 0.25);
    pushMatrix();
    translate((1 - k) * 40, 0);
    panel(x, y, w, h, C_PANEL, wasRight ? C_GREEN : C_RED, 18);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(wasRight ? C_GREEN : C_RED);
    text(wasRight ? "CORRECT!" : timedOut ? "TIME'S UP" : "NOPE.", x + 24, y + 16);
    if (wasRight) {
      textFont(fBodyB);
      fill(C_GOLD);
      textAlign(RIGHT, TOP);
      text("+" + gained, x + w - 24, y + 26);
    }
    float cy = y + 70;
    if (extra.length() > 0) {
      textFont(fBodyB);
      fill(C_TEXT);
      cy += textBlock(extra, x + 24, cy, w - 48, 26) + 8;
    }
    textFont(fExplain);
    fill(#C9D6EE);
    cy += textBlock(q.explain, x + 24, cy, w - 48, 24) + 14;
    // Rick's reaction
    noStroke();
    fill(#13233A);
    stroke(C_GREEN);
    strokeWeight(2);
    ellipse(x + 50, cy + 26, 52, 52);
    imageMode(CENTER);
    image(rick.currentFace(), x + 50, cy + 28, 50, 50);
    imageMode(CORNER);
    textFont(fRickSmall);
    ArrayList<String> rl = wrapText("RICK: " + rick.text, w - 120);
    int left = rick.shownText().length() + 6;
    for (int i = 0; i < rl.size() && left > 0; i++) {
      String ln = rl.get(i);
      richLine(ln.substring(0, min(ln.length(), left)), x + 90, cy + i * 22, #9BE36A, C_GOLD);
      left -= ln.length() + 1;
    }
    popMatrix();
    nextB.y = y + h - 66;
    nextB.x = x + w - nextB.w - 20;
  }

  // ---------------------------------------------------------------- input
  void mouse() {
    if (answered) return;
    if (q.isLabel()) {
      Part p = view.hitMouse();
      if (p != null) pickPart(p);
      return;
    }
    for (int s = 0; s < 4; s++) if (over(40, top + s * 92, 680, 80)) pickChoice(s);
  }

  void key(char k, int code) {
    if (!answered && !q.isLabel()) {
      if (k >= '1' && k <= '4') pickChoice(k - '1');
      if (k >= 'a' && k <= 'd') pickChoice(k - 'a');
    }
    if (answered && (k == '\n' || code == ENTER || code == RETURN || code == RIGHT)) next();
  }

  void clicked(Button b) {
    if (b.id.equals("next")) next();
    if (b.id.equals("hint")) useHint();
    if (b.id.equals("quit")) back();
  }

  void escape() {
    if (T - escT < 2) back();
    else {
      escT = T;
      sfx.play(sfx.click, 0.4);
    }
  }

  void back() {
    if (topicKey.equals("explore")) go(new ExploreScene(qs.isEmpty() ? null : qs.get(0).diagram));
    else if (level == 0) go(new DifficultyScene());
    else go(new TopicScene(level));
  }
}
