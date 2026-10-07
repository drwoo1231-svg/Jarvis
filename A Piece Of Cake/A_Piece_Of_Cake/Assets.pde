// All PNGs live in data/ (see CREDITS.md for where each one came from).

PImage imgXdf, imgCake, imgLid, imgBody;
PImage imgPopper, imgSparkles, imgStar, imgClap, imgBoom, imgSiren, imgWarning, imgPuff;
PImage imgPlanet, imgEarth, imgMoon, imgUfo, imgRocket, imgConfettiBall;
PImage[] imgBalloons;
PImage imgRickBody, imgRickHead, imgRickHeadTalk, imgRickUpper, imgRickFore;
PImage glow, vignette;

PFont fTitle, fComic, fStencil, fStencilSmall, fTech;
PShader holoShader;

void loadAssets() {
  imgXdf = loadImage("hubble_xdf.png");
  imgCake = loadImage("cake.png");
  imgLid = loadImage("gift_lid.png");
  imgBody = loadImage("gift_body.png");
  imgPopper = loadImage("party_popper.png");
  imgSparkles = loadImage("sparkles.png");
  imgStar = loadImage("star.png");
  imgClap = loadImage("clap.png");
  imgBoom = loadImage("boom.png");
  imgSiren = loadImage("siren.png");
  imgWarning = loadImage("warning.png");
  imgPuff = loadImage("puff.png");
  imgPlanet = loadImage("planet_ringed.png");
  imgEarth = loadImage("earth.png");
  imgMoon = loadImage("moon.png");
  imgUfo = loadImage("ufo.png");
  imgRocket = loadImage("rocket.png");
  imgConfettiBall = loadImage("confetti_ball.png");
  String[] colors = { "red", "blue", "green", "yellow", "purple", "pink", "orange" };
  imgBalloons = new PImage[colors.length];
  for (int i = 0; i < colors.length; i++) imgBalloons[i] = loadImage("balloon_" + colors[i] + ".png");

  // Rick, drawn by tools/RickPartsGenerator
  imgRickBody = loadImage("rick_body.png");
  imgRickHead = loadImage("rick_head.png");
  imgRickHeadTalk = loadImage("rick_head_talk.png");
  imgRickUpper = loadImage("rick_arm_upper.png");
  imgRickFore = loadImage("rick_arm_fore.png");

  // fonts are created ~2x the size they are drawn at so they stay sharp on retina screens
  fTitle = createFont("Bangers.ttf", 150, true);
  fComic = createFont("Bangers.ttf", 52, true);
  fStencil = createFont("BlackOpsOne.ttf", 120, true);
  fStencilSmall = createFont("BlackOpsOne.ttf", 44, true);
  fTech = createFont("Orbitron-Bold.ttf", 30, true);

  holoShader = loadShader("hologram.glsl");

  glow = makeGlow(128);
  vignette = makeVignette(320, 180);
}

// soft white dot, tinted and drawn additively for every glow in the scene
PImage makeGlow(int s) {
  PImage g = createImage(s, s, ARGB);
  g.loadPixels();
  for (int y = 0; y < s; y++) {
    for (int x = 0; x < s; x++) {
      float d = dist(x + 0.5, y + 0.5, s / 2.0, s / 2.0) / (s / 2.0);
      float a = pow(max(0, 1 - d), 2.2);
      g.pixels[y * s + x] = color(255, 255, 255, 255 * a);
    }
  }
  g.updatePixels();
  return g;
}

PImage makeVignette(int w, int h) {
  PImage v = createImage(w, h, ARGB);
  v.loadPixels();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      float dx = (x - w / 2.0) / (w / 2.0), dy = (y - h / 2.0) / (h / 2.0);
      float d = sqrt(dx * dx * 0.8 + dy * dy);
      v.pixels[y * w + x] = color(0, 0, 0, 255 * constrain(pow(max(0, d - 0.55), 1.6) * 1.4, 0, 0.85));
    }
  }
  v.updatePixels();
  return v;
}

// call inside blendMode(ADD)
void glowAt(float x, float y, float size, int c, float a) {
  imageMode(CENTER);
  tint(red(c), green(c), blue(c), a);
  image(glow, x, y, size, size);
  noTint();
}

void sprite(PImage img, float x, float y, float size, float rot, float a) {
  pushMatrix();
  translate(x, y);
  rotate(rot);
  imageMode(CENTER);
  tint(255, a);
  image(img, 0, 0, size, size * img.height / (float) img.width);
  noTint();
  popMatrix();
}
