// Lessons: Rick teaches the level's key facts, one card at a time, with the
// relevant part glowing on the diagram. Then: quiz.

class LessonScene extends Scene {
  Topic topic;
  int level, idx;
  Level lv;
  DiagramView view = new DiagramView();
  float cardT;

  LessonScene(Topic topic, int level) {
    this.topic = topic;
    this.level = level;
    lv = topic.levels[level];
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    button("prev", "< BACK", 40, 646, 140, 54).key("B");
    button("next", "NEXT >", 192, 646, 190, 54).key(" ");
    button("quiz", "SKIP TO QUIZ", 394, 646, 200, 54).key("Q").colour(C_GOLD);
    show(0);
  }

  void show(int i) {
    idx = i;
    cardT = 0;
    if (lv.lessons.isEmpty()) {
      rick.say("No lessons here yet. Straight to the quiz, I guess. *burp*");
      return;
    }
    Lesson l = lv.lessons.get(idx);
    String dia = l.diagram != null && l.diagram.length() > 0 ? l.diagram : topic.mainDiagram();
    view.set(diagram(dia), 70, 128, 470);
    view.marks.clear();
    view.pulse = l.part != null && l.part.length() > 0 ? l.part : null;
    view.hoverOn = true;
    rick.say(idx == 0 && l.rick.length() < 60 ? pick(LESSON_START) + " " + l.rick : l.rick);
    sfx.play(sfx.blip, 0.6);
  }

  void update(float dt) {
    cardT += dt;
    view.update();
    for (Button b : buttons) {
      if (b.id.equals("prev")) b.label = idx > 0 ? "< BACK" : "< TOPICS";
      if (b.id.equals("next")) b.label = idx >= lv.lessons.size() - 1 ? "QUIZ TIME >" : "NEXT >";
    }
    rick.idleCheck();
  }

  void draw() {
    space.draw();
    levelBadge(40, 22, level);
    textFont(fH1);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text(topic.title, 40, 52);
    schmeckles(W - 20, 14);
    if (view.d != null) {
      view.draw();
      Part p = view.pulse != null ? view.d.part(view.pulse) : null;
      if (p != null) view.tag(p, partName(view.d.id, p.id), C_GOLD);
      if (view.hover != null && view.hover != p) view.tag(view.hover, partName(view.d.id, view.hover.id), C_BLUE);
      textFont(fSmall);
      fill(C_DIM);
      textAlign(LEFT, TOP);
      text(view.d.title + "  -  hover to see names", 70, 616);
    }
    if (!lv.lessons.isEmpty()) drawCard(lv.lessons.get(idx));
    drawButtons();
    rick.drawBox();
  }

  void drawCard(Lesson l) {
    float x = 600, y = 110, w = 640, h = 420;
    float k = min(1, cardT / 0.3);
    k = 1 - pow(1 - k, 3);
    pushMatrix();
    translate(0, (1 - k) * 30);
    panel(x, y, w, h, C_PANEL, LEVEL_COLS[level], 20);
    textFont(fMono);
    textAlign(LEFT, TOP);
    fill(LEVEL_COLS[level]);
    text("LESSON " + (idx + 1) + " / " + lv.lessons.size(), x + 26, y + 22);
    // progress dots
    for (int i = 0; i < lv.lessons.size(); i++) {
      noStroke();
      fill(i <= idx ? LEVEL_COLS[level] : #2A3550);
      ellipse(x + w - 30 - (lv.lessons.size() - 1 - i) * 18, y + 30, 10, 10);
    }
    textFont(fH1);
    fill(C_TEXT);
    float th = textBlock(l.title, x + 26, y + 54, w - 52, 44);
    textFont(fBody);
    fill(#DCE6F8);
    textBlock(l.fact, x + 26, y + 70 + th, w - 52, 31);
    popMatrix();
  }

  void next() {
    if (idx < lv.lessons.size() - 1) show(idx + 1);
    else startQuiz();
  }

  void startQuiz() {
    if (lv.questions.isEmpty()) {
      rick.say("There's no quiz here yet. Even I can't grade nothing. *burp*");
      return;
    }
    ArrayList<Question> qs = new ArrayList<Question>(lv.questions);
    java.util.Collections.shuffle(qs);
    go(new QuizScene(topic.title, qs, level, topic.key, false));
  }

  void clicked(Button b) {
    if (b.id.equals("prev")) {
      if (idx > 0) show(idx - 1);
      else back();
    }
    if (b.id.equals("next")) next();
    if (b.id.equals("quiz")) startQuiz();
  }

  void key(char k, int code) {
    if (code == RIGHT || code == ENTER || code == RETURN) next();
    if (code == LEFT && idx > 0) show(idx - 1);
  }

  void back() {
    go(new TopicScene(level));
  }
}
