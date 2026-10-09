// RICK MED SCHOOL
// Anatomy & physiology, very basic to expert, taught by a drunk, burping,
// sarcastic genius scientist who would rather be anywhere else.
//
// Processing 4.5.6 (Java mode). No libraries, no data folder: every picture
// and sound is made in code. Progress is saved next to the sketch.
//
//   mouse ........ everything          1-4 / A-D ... answer
//   SPACE/ENTER .. next                H ........... hint (half points)
//   ESC .......... back                M ........... mute
//   L ............ labels (study mode)

final int W = 1280, H = 720;

Scene scene, pending;
float T, dt;
int lastMs;
float transT = -1;              // portal wipe: -1 = idle, 0..1 closing, 1..2 opening
boolean transSwapped;

Sfx sfx;
SpaceBg space;
Rick rick;
Progress progress;

void settings() {
  size(1280, 720);
  pixelDensity(displayDensity());
  smooth(8);
}

void setup() {
  surface.setTitle("Rick Med School");
  frameRate(60);
  setupFonts();
  sfx = new Sfx();
  loadContent();
  registerDiagrams();
  makeDrillQuestions();
  loadTopicHovers();
  space = new SpaceBg();
  rick = new Rick();
  progress = new Progress();
  progress.load();
  scene = new IntroScene();
  scene.enter();
  lastMs = millis();
}

void draw() {
  int now = millis();
  dt = constrain((now - lastMs) / 1000.0, 0.0005, 0.05);
  lastMs = now;
  T += dt;
  if (transT < 0 || transSwapped) scene.update(dt);    // the scene being left freezes during the wipe
  rick.update(dt);
  scene.draw();
  drawTransition();
  if (sfx.muted) {
    textFont(fMono);
    textAlign(RIGHT, TOP);
    fill(C_DIM);
    text("MUTED (M)", W - 12, H - 24);
  }
  if (!progress.saveOk) {
    textFont(fMono);
    textAlign(LEFT, TOP);
    fill(C_RED);
    text("PROGRESS NOT SAVING - the sketch folder is read-only", 12, H - 22);
  }
}

// ---------------------------------------------------------------- scenes
abstract class Scene {
  ArrayList<Button> buttons = new ArrayList<Button>();

  void enter() {}
  void update(float dt) {}
  abstract void draw();
  void clicked(Button b) {}
  void mouse() {}                       // a click that didn't hit a button
  void key(char k, int code) {}
  void back() {}                        // BACK buttons
  void escape() {                       // ESC (scenes can ask for a second press)
    back();
  }

  Button button(String id, String label, float x, float y, float w, float h) {
    Button b = new Button(id, label, x, y, w, h);
    buttons.add(b);
    return b;
  }

  void drawButtons() {
    for (Button b : buttons) b.draw();
  }

  boolean clickButtons() {
    for (Button b : buttons) {
      if (b.over()) {
        sfx.play(sfx.click, 0.5);
        clicked(b);
        return true;
      }
    }
    return false;
  }
}

// switch scenes through a green portal wipe
void go(Scene s) {
  if (transT >= 0 && !transSwapped) {
    pending = s;
    return;
  }
  pending = s;
  transT = 0;
  transSwapped = false;
  sfx.play(sfx.whoosh, 0.6);
}

void drawTransition() {
  if (transT < 0) return;
  transT += dt * 2.6;
  if (transT >= 1 && !transSwapped) {
    transSwapped = true;
    scene = pending;
    pending = null;
    rick.quiet();
    scene.enter();
  }
  if (transT >= 2) {
    transT = -1;
    return;
  }
  float k = transT < 1 ? transT : 2 - transT;      // 0 -> 1 -> 0
  k = k * k * (3 - 2 * k);
  float r = k * 1600;
  drawPortal(W / 2, H / 2, r, r * 0.92, T * 3, 255);
  if (k > 0.85) {
    noStroke();
    fill(#103A12, (k - 0.85) / 0.15 * 255);
    rect(0, 0, W, H);
  }
}

// ---------------------------------------------------------------- input
void mousePressed() {
  if (transT >= 0) return;
  rick.clickSkip();
  if (!scene.clickButtons()) scene.mouse();
}

// hovering and reading count as studying, not idling
void mouseMoved() {
  rick.clickSkip();
}

void mouseDragged() {
  rick.clickSkip();
}

// build the diagram images a little at a time while nothing else is going on
void prebuildDiagrams() {
  if (transT >= 0) return;
  for (String id : DIAGRAM_ORDER) {
    Diagram d = diagram(id);
    if (d != null && d.thumb == null) {
      d.thumb();
      return;
    }
  }
}

// which level's body-system grid the study mode was opened from (0 = the difficulty screen)
int studyFromLevel = 0;

void keyPressed() {
  rick.clickSkip();              // any input resets Rick's idle nagging
  if (key == ESC) {
    key = 0;                     // don't quit - go back instead
    if (transT < 0) scene.escape();
    return;
  }
  if (transT >= 0) return;
  char k = Character.toLowerCase(key);
  if (k == 'm') {
    sfx.muted = !sfx.muted;
    return;
  }
  for (Button b : scene.buttons) {
    if (b.visible && b.enabled && b.hotkey != null && b.hotkey.length() == 1 && Character.toLowerCase(b.hotkey.charAt(0)) == k) {
      sfx.play(sfx.click, 0.5);
      scene.clicked(b);
      return;
    }
  }
  scene.key(k, keyCode);
}
