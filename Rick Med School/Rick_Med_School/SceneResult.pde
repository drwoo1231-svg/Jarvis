// End of a quiz: the grade, Rick's verdict, what you missed, where to go next.

class ResultScene extends Scene {
  QuizScene quiz;
  int pct, grade, bonus;
  boolean newBest;
  float t;

  ResultScene(QuizScene q) {
    quiz = q;
    pct = q.qs.isEmpty() ? 0 : round(100.0 * q.right / q.qs.size());
    grade = pct >= 90 ? 4 : pct >= 75 ? 3 : pct >= 60 ? 2 : pct >= 40 ? 1 : 0;
  }

  boolean realTopic() {
    return TOPICS.containsKey(quiz.topicKey) && quiz.level > 0;
  }

  void enter() {
    if (realTopic()) newBest = progress.record(quiz.topicKey, quiz.level, pct);
    bonus = max(1, quiz.score / 20);
    progress.addXp(bonus);
    progress.save();
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.drunkMode = grade <= 1;
    rick.say(pick(RESULT_LINES[grade]));
    sfx.play(grade >= 2 ? sfx.fanfare : sfx.sad, 0.6);
    float y = 640;
    button("retry", "RETRY", 40, y, 140, 56).key("R");
    boolean nx = realTopic() && quiz.level < 4;
    if (nx) button("nextlv", "NEXT LEVEL >", 192, y, 190, 56).key("N").colour(LEVEL_COLS[quiz.level + 1]);
    int n = progress.mistakes(quiz.level).size();
    Button rv = button("review", "REVIEW", nx ? 394 : 192, y, 190, 56).key("V").colour(C_GOLD);
    rv.enabled = n > 0;
    button("topics", "MENU", 40, 572, 170, 56).key("T").colour(C_BLUE);
  }

  void update(float dt) {
    t += dt;
  }

  String gradeLetter() {
    return new String[] { "F", "D", "C", "B", "A" }[grade];
  }

  void draw() {
    space.draw();
    levelBadge(40, 22, quiz.level);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text(quiz.title + " - RESULTS", 40, 54);
    schmeckles(W - 20, 14);
    // grade disc
    float k = min(1, t / 0.6);
    k = 1 - pow(1 - k, 3);
    int gc = grade >= 3 ? C_GREEN : grade == 2 ? C_GOLD : C_RED;
    pushMatrix();
    translate(200, 268);
    scale(k);
    rotate((1 - k) * -1.2);
    drawPortal(0, 0, 130, 130, T * 1.4, 120);
    noStroke();
    fill(#0B1020, 220);
    ellipse(0, 0, 190, 190);
    textFont(createFontOnce());
    textAlign(CENTER, CENTER);
    fill(gc);
    text(gradeLetter(), 0, -12);
    textFont(fH2);
    fill(C_TEXT);
    text(pct + "%", 0, 58);
    popMatrix();
    // stats
    float x = 40, y = 428;
    textFont(fBodyB);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text(quiz.right + " / " + quiz.qs.size() + " correct", x, y);
    fill(C_GOLD);
    text(quiz.score + " points  (+" + bonus + " schmeckles)", x, y + 32);
    fill(C_DIM);
    text("best streak " + quiz.bestStreak, x, y + 64);
    if (newBest) {
      fill(C_GREEN);
      text("NEW BEST for this level!", x, y + 96);
    }
    // what you missed
    float px = 400, py = 110, pw = 840, ph = 430;
    panel(px, py, pw, ph, C_PANEL, C_EDGE, 18);
    textFont(fH2);
    fill(C_TEXT);
    textAlign(LEFT, TOP);
    text(quiz.missed.isEmpty() ? "NOTHING MISSED. SUSPICIOUS." : "STUDY THESE (" + quiz.missed.size() + " missed)", px + 24, py + 18);
    float cy = py + 64;
    textFont(fSmall);
    int shown = 0;
    for (Question q : quiz.missed) {
      String qt = q.q, at = "-> " + q.answerText();
      float h1 = textBlockHeight(qt, pw - 48, 20), h2 = textBlockHeight(at, pw - 48, 20);
      if (cy + h1 + h2 > py + ph - 40) {
        fill(C_DIM);
        text("... and " + (quiz.missed.size() - shown) + " more in your REVIEW pile", px + 24, cy);
        break;
      }
      fill(#C9D6EE);
      cy += textBlock(qt, px + 24, cy, pw - 48, 20);
      fill(C_GREEN);
      cy += textBlock(at, px + 24, cy, pw - 48, 20) + 10;
      shown++;
    }
    if (quiz.missed.isEmpty()) {
      textFont(fBody);
      fill(C_DIM);
      textBlock("Everything right. Either you studied, or the multiverse glitched. Try the next level before I check the logs.", px + 24, cy, pw - 48, 30);
    }
    drawButtons();
    rick.drawBox();
  }

  void clicked(Button b) {
    if (b.id.equals("retry")) {
      ArrayList<Question> qs = new ArrayList<Question>(quiz.qs);
      java.util.Collections.shuffle(qs);
      go(new QuizScene(quiz.title, qs, quiz.level, quiz.topicKey, quiz.review));
    }
    if (b.id.equals("nextlv")) go(new LessonScene(TOPICS.get(quiz.topicKey), quiz.level + 1));
    if (b.id.equals("review")) startReview(quiz.level);
    if (b.id.equals("topics")) back();
  }

  void back() {
    if (quiz.topicKey.equals("explore")) go(new ExploreScene(quiz.qs.isEmpty() ? null : quiz.qs.get(0).diagram));
    else if (quiz.level == 0) go(new DifficultyScene());
    else go(new TopicScene(quiz.level));
  }
}

PFont bigGrade;

PFont createFontOnce() {
  if (bigGrade == null) bigGrade = createFont("SansSerif.bold", 120, true);
  return bigGrade;
}
