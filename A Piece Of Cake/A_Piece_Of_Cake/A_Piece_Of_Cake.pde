/*
  A PIECE OF CAKE
  a birthday surprise box floating in the middle of the galaxy
  ------------------------------------------------------------
  Processing 4 (Java mode)  -  open this file and press Run.

  MOUSE   press the big red button (it says DO NOT OPEN... so obviously)
          click the cake   -> blow out the candles
          click a Rick     -> he tells you another joke
          click in space   -> fireworks
  KEYS    SPACE  next joke      M  mute / unmute
          R      start over     S  save a screenshot
*/

// =================== make it yours ===================
String BIRTHDAY_NAME = "";      // e.g. "SAM" -> "HAPPY BIRTHDAY, SAM!"
boolean FULL_SCREEN = false;    // true = fill the whole screen
boolean SOUND = true;           // synthesized sound effects + birthday tune
// =====================================================

// everything is laid out on a 1280 x 720 stage that is scaled to fit the window
final float VW = 1280, VH = 720;
float viewS = 1, viewX = 0, viewY = 0;
float mx, my;                   // mouse position on the stage

final int WARP = 0, IDLE = 1, ARMED = 2, BOOM = 3, PARTY = 4;
int state;
float st;                       // seconds spent in the current state
float T;                        // seconds since the sketch started
float dt = 1 / 60.0;
int lastMs;

float shake;                    // screen shake strength (px)
float flashA;                   // white flash
float alarmA;                   // red alarm wash
int cursorNow = -1;

Space space;
SurpriseBox box;
Cake cake;
Party party;
Title title;
FX fx;
Sfx sfx;

void settings() {
  if (FULL_SCREEN) fullScreen(P2D);
  else size(1280, 720, P2D);
  pixelDensity(displayDensity());
  smooth(8);
}

void setup() {
  surface.setTitle("A Piece Of Cake  -  DO NOT OPEN");
  surface.setResizable(true);
  frameRate(60);
  loadAssets();
  sfx = new Sfx(SOUND);
  restart();
  lastMs = millis();
}

void restart() {
  space = new Space();
  box = new SurpriseBox();
  cake = new Cake();
  party = new Party();
  title = new Title();
  fx = new FX();
  shake = 0;
  flashA = 1;
  alarmA = 0;
  sfx.stopMusic();
  setState(WARP);
  sfx.play(sfx.warp, 0.7, 1);
}

void setState(int s) {
  state = s;
  st = 0;
}

// true exactly once: on the frame where the state clock passes t
boolean at(float t) {
  return st >= t && st - dt < t;
}

void draw() {
  int now = millis();
  dt = constrain((now - lastMs) / 1000.0, 0.001, 0.05);
  lastMs = now;
  T += dt;

  viewS = min(width / VW, height / VH);
  viewX = (width - VW * viewS) / 2;
  viewY = (height - VH * viewS) / 2;
  mx = (mouseX - viewX) / viewS;
  my = (mouseY - viewY) / viewS;

  update();
  party.renderBuffers();   // draw each hologram into its own buffer before the main pass

  background(0);
  space.drawBackdrop();    // full-window Hubble field

  pushMatrix();
  translate(viewX, viewY);
  scale(viewS);
  if (shake > 0.2) translate(random(-shake, shake), random(-shake, shake));

  space.draw();
  fx.drawLayer(fx.back);
  title.draw();
  box.drawBeam();
  party.drawRicks();
  box.drawBack();
  cake.draw();
  box.drawFront();
  cake.drawFlames();
  fx.drawLayer(fx.front);
  party.drawSpeech();
  drawHints();
  popMatrix();

  drawScreenOverlays();
  updateCursor();
}

void update() {
  st += dt;
  shake = max(0, shake - dt * 30);
  flashA = max(0, flashA - dt * 2.2);

  if (state == WARP) {
    if (at(1.25)) {
      box.materialize();
      fx.ring(box.cx, box.centerY(), color(150, 240, 255), 520);
      fx.burst(box.cx, box.centerY(), 40, color(170, 240, 255));
      sfx.play(sfx.pop, 0.8, 0.7);
      shake = 6;
      flashA = 0.5;
    }
    if (at(1.9)) {
      title.stamp();
      sfx.play(sfx.thud, 0.9, 1);
      shake = 9;
    }
    if (st > 2.8) setState(IDLE);
  } else if (state == ARMED) {
    alarmA = 0.17 + 0.13 * sin(st * TWO_PI * 2.5);
    if (at(0.55)) { title.count("3"); sfx.play(sfx.beep, 0.6, 1); }
    if (at(1.25)) { title.count("2"); sfx.play(sfx.beep, 0.6, 1); }
    if (at(1.95)) { title.count("1"); sfx.play(sfx.beep, 0.6, 1.2); }
    if (st < 2.6) shake = max(shake, st * 2.2);
    if (st > 2.6) {
      setState(BOOM);
      alarmA = 0;
      box.explode();
      cake.rise();
      title.clear();
      flashA = 1;
      shake = 26;
      sfx.play(sfx.boom, 1, 1);
      fx.emoji(imgBoom, box.cx, box.rimY() - 40, 420, 0.7, 0);
      fx.ring(box.cx, box.rimY(), color(255, 220, 140), 900);
      fx.confettiBurst(box.cx, box.rimY() - 20, 260, -HALF_PI, PI * 0.9, 900);
      fx.poppers();
      sfx.play(sfx.popper, 0.8, 1);
    }
  } else if (state == BOOM) {
    if (st > 1.7) {
      setState(PARTY);
      party.start();
    }
  } else if (state == PARTY) {
    if (at(0.7)) {
      title.birthday();
      sfx.playMusic();
      for (int i = 0; i < 8; i++) {
        float a = i * TWO_PI / 8;
        fx.emoji(imgStar, VW / 2 + cos(a) * 380, 110 + sin(a) * 70, random(30, 46), 1.4, random(-0.4, 0.4));
      }
    }
  }

  space.update();
  box.update();
  cake.update();
  party.update();
  title.update();
  fx.update();
}

// ------------------------------------------------------------------ input
void mousePressed() {
  if (state == IDLE) {
    if (box.overButton(mx, my)) {
      box.press();
      setState(ARMED);
      title.uhOh();
      sfx.play(sfx.click, 1, 1);
      sfx.play(sfx.alarm, 0.55, 1);
    } else if (box.overBox(mx, my)) {
      box.jiggle();
      title.nope();
      sfx.play(sfx.boing, 0.6, random(0.9, 1.1));
    } else {
      fx.firework(mx, my);
    }
  } else if (state == PARTY) {
    HoloRick r = party.rickAt(mx, my);
    if (r != null) {
      party.jokeFrom(r);
    } else if (cake.over(mx, my)) {
      cake.blow();
    } else {
      fx.firework(mx, my);
    }
  }
}

void keyPressed() {
  if (key == ' ' && state == PARTY) party.nextJoke();
  if (key == 'm' || key == 'M') sfx.toggleMute();
  if (key == 'r' || key == 'R') restart();
  if (key == 's' || key == 'S') saveFrame("screenshots/a-piece-of-cake-####.png");
}

void updateCursor() {
  boolean hand = false;
  if (state == IDLE) hand = box.overButton(mx, my);
  if (state == PARTY) hand = party.rickAt(mx, my) != null || cake.over(mx, my);
  int want = hand ? HAND : ARROW;
  if (want != cursorNow) {
    cursor(want);
    cursorNow = want;
  }
}

// ------------------------------------------------------------------ hints + overlays
void drawHints() {
  String hint = "";
  if (state == IDLE && st > 4) hint = "psst...  press the big red button";
  if (state == PARTY && st > 9) {
    if (cake.canBlow()) hint = "click the cake to blow out the candles   -   click a rick for another joke";
    else hint = "click a rick for another joke   -   click anywhere for fireworks";
  }
  if (hint.length() == 0) return;
  float a = 150 + 90 * sin(T * 3);
  textFont(fTech, 15);
  textAlign(CENTER, CENTER);
  fill(0, 120);
  text(hint.toUpperCase(), VW / 2 + 1.5, VH - 17 + 1.5);
  fill(170, 240, 255, a);
  text(hint.toUpperCase(), VW / 2, VH - 17);
  textFont(fTech, 11);
  textAlign(RIGHT, CENTER);
  fill(170, 240, 255, 90);
  text(sfx.muted ? "M: SOUND OFF" : "M: MUTE", VW - 12, 14);
}

void drawScreenOverlays() {
  noStroke();
  if (alarmA > 0.01) {
    fill(255, 0, 20, 255 * alarmA);
    rect(0, 0, width, height);
  }
  imageMode(CORNER);
  noTint();
  image(vignette, 0, 0, width, height);
  if (flashA > 0.01) {
    fill(255, 255 * flashA);
    rect(0, 0, width, height);
  }
}

// ------------------------------------------------------------------ helpers
float easeOutBack(float t) {
  t = constrain(t, 0, 1);
  float c1 = 1.70158, c3 = c1 + 1;
  return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2);
}

float easeOutElastic(float t) {
  t = constrain(t, 0, 1);
  if (t == 0 || t == 1) return t;
  return pow(2, -10 * t) * sin((t * 10 - 0.75) * (TWO_PI / 3)) + 1;
}

float smooth01(float t) {
  t = constrain(t, 0, 1);
  return t * t * (3 - 2 * t);
}

float angleLerp(float a, float b, float t) {
  float d = b - a;
  while (d > PI) d -= TWO_PI;
  while (d < -PI) d += TWO_PI;
  return a + d * t;
}
