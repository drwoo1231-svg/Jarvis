// Study mode: pick a diagram, hover parts to learn them, L for all labels,
// Q for a quick "click the part" drill on that diagram.

final HashMap<String, String> DIAGRAM_TOPIC = new HashMap<String, String>();

// one generated "click the X" question per diagram part (study drills / review pile)
void makeDrillQuestions() {
  String[][] owner = { { "cell", "cells" }, { "skeleton", "bones" }, { "muscles", "muscles" }, { "neuron", "nervous" }, { "brain", "nervous" },
    { "heart", "heart" }, { "lungs", "lungs" }, { "digestive", "digestion" }, { "nephron", "kidneys" }, { "organ_map", "hormones" } };
  for (String[] o : owner) DIAGRAM_TOPIC.put(o[0], o[1]);
  for (String id : DIAGRAM_ORDER) {
    Diagram d = diagram(id);
    if (d == null) continue;
    for (Part p : d.parts) {
      Question k = new Question();
      k.id = "drill-" + id + "-" + p.id;
      k.type = "label";
      k.diagram = id;
      k.part = p.id;
      PartInfo pi = PART_INFO.get(id + ":" + p.id);
      k.q = "Click the " + partName(id, p.id) + ".";
      k.explain = pi != null ? pi.desc : "That's the " + partName(id, p.id) + ".";
      k.rick = pi != null ? pi.rick : "";
      k.topic = TOPICS.get(DIAGRAM_TOPIC.get(id));
      k.level = 0;
      QUESTIONS.put(k.id, k);
    }
  }
}

class ExploreScene extends Scene {
  String diaId;
  DiagramView view = new DiagramView();
  Part pinned, shown;
  float infoT;

  ExploreScene(String diaId) {
    this.diaId = diaId == null ? DIAGRAM_ORDER[0] : diaId;
  }

  void enter() {
    rick.dock = DOCK_CORNER;
    rick.boxW = 470;
    rick.say(pick(EXPLORE_ENTER));
    for (int i = 0; i < DIAGRAM_ORDER.length; i++) {
      Diagram d = diagram(DIAGRAM_ORDER[i]);
      Button b = button("dia:" + DIAGRAM_ORDER[i], shortTitle(d), 24 + i * 123, 70, 116, 44).colour(C_BLUE);
      b.font = fSmall;
    }
    button("back", "< BACK", 24, 652, 126, 52).key("B");
    button("labels", "LABELS (L)", 162, 652, 196, 52).key("L").colour(C_GOLD);
    button("drill", "QUIZ ME (Q)", 370, 652, 196, 52).key("Q").colour(C_GREEN);
    select(diaId);
  }

  String shortTitle(Diagram d) {
    String[] s = { "Cell", "Skeleton", "Muscles", "Neuron", "Brain", "Heart", "Lungs", "Gut", "Nephron", "Organs" };
    for (int i = 0; i < DIAGRAM_ORDER.length; i++) if (DIAGRAM_ORDER[i].equals(d.id)) return s[i];
    return d.id;
  }

  void select(String id) {
    diaId = id;
    view.set(diagram(id), 250, 140, 480);
    view.labelsOn = view.labelsOn;
    pinned = null;
    shown = null;
  }

  void update(float dt) {
    view.update();
    Part s = view.hover != null ? view.hover : pinned;
    if (s != shown) {
      shown = s;
      infoT = 0;
    }
    infoT += dt;
    for (Button b : buttons) {
      if (b.id.startsWith("dia:")) b.col = b.id.equals("dia:" + diaId) ? C_GREEN : C_BLUE;
      if (b.id.equals("labels")) b.label = view.labelsOn ? "LABELS: ON (L)" : "LABELS: OFF (L)";
    }
    rick.idleCheck();
  }

  void draw() {
    space.draw();
    levelBadge(24, 24, 0);
    textFont(fH2);
    textAlign(LEFT, TOP);
    fill(C_TEXT);
    text("STUDY DIAGRAMS  -  " + view.d.title, 110, 22);
    schmeckles(W - 20, 14);
    view.marks.clear();
    if (pinned != null) view.marks.put(pinned.id, C_GOLD);
    view.draw();
    drawInfo();
    drawButtons();
    rick.drawBox();
  }

  void drawInfo() {
    float x = 960, y = 140, w = 300, h = 400;
    panel(x, y, w, h, C_PANEL, shown != null ? C_GOLD : C_EDGE, 18);
    textAlign(LEFT, TOP);
    if (shown == null) {
      textFont(fBodyB);
      fill(C_TEXT);
      text("Hover a part.", x + 20, y + 20);
      textFont(fSmall);
      fill(C_DIM);
      textBlock("Click to pin it. L shows every label. QUIZ ME drills you on this diagram (no level, no clock).\n\n" + view.d.parts.size() + " parts on this one.", x + 20, y + 56, w - 40, 22);
      return;
    }
    PartInfo pi = PART_INFO.get(diaId + ":" + shown.id);
    textFont(fH2);
    fill(C_GOLD);
    float cy = y + 18 + textBlock(partName(diaId, shown.id), x + 20, y + 18, w - 40, 30) + 10;
    textFont(fSmall);
    fill(#DCE6F8);
    if (pi != null) {
      textFont(fBody);
      textSize(18);
      cy += textBlock(pi.desc, x + 20, cy, w - 40, 24) + 14;
      textFont(fRick);
      textSize(17);
      fill(#9BE36A);
      textBlock("RICK: " + pi.rick, x + 20, cy, w - 40, 22);
    } else {
      textBlock("(No notes for this part yet.)", x + 20, cy, w - 40, 22);
    }
  }

  void mouse() {
    Part p = view.hitMouse();
    if (p != null) {
      pinned = pinned == p ? null : p;
      sfx.play(sfx.blip, 0.6);
    }
  }

  void clicked(Button b) {
    if (b.id.startsWith("dia:")) select(b.id.substring(4));
    if (b.id.equals("back")) back();
    if (b.id.equals("labels")) view.labelsOn = !view.labelsOn;
    if (b.id.equals("drill")) drill();
  }

  void drill() {
    ArrayList<Question> qs = new ArrayList<Question>();
    for (Part p : view.d.parts) {
      Question q = QUESTIONS.get("drill-" + diaId + "-" + p.id);
      if (q != null) qs.add(q);
    }
    java.util.Collections.shuffle(qs);
    if (qs.size() > 10) qs = new ArrayList<Question>(qs.subList(0, 10));
    go(new QuizScene("DRILL: " + view.d.title.toUpperCase(), qs, 0, "explore", false));
  }

  void key(char k, int code) {
    if (code == LEFT || code == RIGHT) {
      int i = java.util.Arrays.asList(DIAGRAM_ORDER).indexOf(diaId);
      i = (i + (code == RIGHT ? 1 : DIAGRAM_ORDER.length - 1)) % DIAGRAM_ORDER.length;
      select(DIAGRAM_ORDER[i]);
    }
  }

  void back() {
    go(studyFromLevel > 0 ? new TopicScene(studyFromLevel) : new DifficultyScene());
  }
}
