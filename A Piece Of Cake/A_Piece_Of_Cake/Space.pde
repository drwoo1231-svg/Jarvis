// The galaxy: Hubble eXtreme Deep Field backdrop, a spinning spiral galaxy
// behind the box, twinkling parallax stars, planets and the odd fly-by.

class Space {
  // stars
  int NS = 520;
  float[] sx = new float[NS], sy = new float[NS], sd = new float[NS], ss = new float[NS], sp = new float[NS];
  int[] sc = new int[NS];

  // spiral galaxy particles
  int NG = 2600;
  float[] gr = new float[NG], ga = new float[NG], gw = new float[NG], gs = new float[NG];
  int[] gc = new int[NG];
  float gcx = 640, gcy = 365, gTilt = 0.36, gRot = -0.2;

  ArrayList<FlyBy> flybys = new ArrayList<FlyBy>();
  float nextFly = 9;
  float nextShoot = 2;
  ArrayList<float[]> shooting = new ArrayList<float[]>();

  Space() {
    for (int i = 0; i < NS; i++) {
      sx[i] = random(-VW * 0.75, VW * 0.75);
      sy[i] = random(-VH * 0.75, VH * 0.75);
      sd[i] = random(0.15, 1);
      ss[i] = random(0.8, 2.6) * (0.5 + sd[i] * 0.6);
      sp[i] = random(TWO_PI);
      float k = random(1);
      sc[i] = k < 0.6 ? color(255) : k < 0.8 ? color(170, 200, 255) : k < 0.92 ? color(255, 220, 170) : color(255, 170, 220);
    }
    for (int i = 0; i < NG; i++) {
      float r = pow(random(1), 1.5) * 620 + 8;
      int arm = int(random(3));
      float spread = random(-1, 1) * random(0.1, 0.55) * (0.4 + 0.6 * r / 560);
      gr[i] = r;
      ga[i] = arm * TWO_PI / 3 + log(r / 8) * 1.35 + spread;
      gw[i] = 0.9 / sqrt(r / 60 + 0.4);           // inner stars orbit faster
      gs[i] = random(1.3, 3.2) * (r < 80 ? 1.4 : 1);
      float t = r / 620;
      int core = color(255, 225, 175), arms = color(150, 185, 255), hot = color(255, 120, 210);
      gc[i] = random(1) < 0.07 && r > 120 ? hot : lerpColor(core, arms, constrain(t * 1.8, 0, 1));
    }
  }

  void update() {
    if (state != WARP) {
      nextFly -= dt;
      if (nextFly < 0) {
        flybys.add(new FlyBy(random(1) < 0.6 ? 0 : 1));
        nextFly = random(14, 24);
      }
    }
    for (int i = flybys.size() - 1; i >= 0; i--) {
      FlyBy f = flybys.get(i);
      f.update();
      if (f.done) flybys.remove(i);
    }
    nextShoot -= dt;
    if (nextShoot < 0) {
      float a = random(radians(20), radians(40)) * (random(1) < 0.5 ? 1 : -1) + (random(1) < 0.5 ? 0 : PI);
      shooting.add(new float[] { random(100, VW - 100), random(40, 260), cos(a) * 900, abs(sin(a)) * 900, 0 });
      nextShoot = random(2.5, 6);
    }
    for (int i = shooting.size() - 1; i >= 0; i--) {
      float[] s = shooting.get(i);
      s[0] += s[2] * dt;
      s[1] += s[3] * dt;
      s[4] += dt;
      if (s[4] > 0.7) shooting.remove(i);
    }
  }

  // mouse parallax offset for something at depth d (0 = far, 1 = near)
  float px(float d) { return -(mx - VW / 2) * 0.03 * d; }
  float py(float d) { return -(my - VH / 2) * 0.03 * d; }

  void drawBackdrop() {
    // cover the whole window (even outside the 16:9 stage)
    float s = max(width / (float) imgXdf.width, height / (float) imgXdf.height) * (1.12 + 0.03 * sin(T * 0.05));
    imageMode(CENTER);
    tint(150);
    image(imgXdf, width / 2 + px(0.3) * viewS * 0.6, height / 2 + py(0.3) * viewS * 0.6, imgXdf.width * s, imgXdf.height * s);
    noTint();
  }

  void draw() {
    float warp = state == WARP ? pow(max(0, 1 - st / 1.3), 2) : 0;
    blendMode(ADD);

    // nebula haze
    glowAt(300 + px(0.1), 260 + py(0.1), 900, color(120, 40, 160), 70);
    glowAt(1050 + px(0.1), 470 + py(0.1), 900, color(20, 90, 150), 70);
    glowAt(640 + px(0.15), 120 + py(0.15), 700, color(150, 30, 90), 45);

    // spiral galaxy, centred behind the box
    float rot = T * 0.05;
    float cg = cos(gRot), sg = sin(gRot);
    glowAt(gcx + px(0.2), gcy + py(0.2), 1350, color(100, 70, 170), 110);
    glowAt(gcx + px(0.2), gcy + py(0.2), 520, color(255, 190, 130), 130);
    glowAt(gcx + px(0.2), gcy + py(0.2), 200, color(255, 235, 200), 200);
    strokeCap(ROUND);
    for (int i = 0; i < NG; i++) {
      float a = ga[i] + rot * gw[i] * 3;
      float x = cos(a) * gr[i];
      float y = sin(a) * gr[i] * gTilt;
      float rx = x * cg - y * sg, ry = x * sg + y * cg;
      float tw = 0.7 + 0.3 * sin(T * 2 + i);
      stroke(gc[i], (gr[i] < 90 ? 210 : 175) * tw);
      strokeWeight(gs[i]);
      point(gcx + rx + px(0.2), gcy + ry + py(0.2));
    }

    // stars (streak during the opening warp)
    for (int i = 0; i < NS; i++) {
      float x = VW / 2 + sx[i] + px(sd[i]);
      float y = VH / 2 + sy[i] + py(sd[i]);
      float tw = 0.55 + 0.45 * sin(T * (1.5 + sd[i] * 2) + sp[i]);
      if (warp > 0.01) {
        float k = warp * 1.6 * sd[i];
        stroke(sc[i], 220);
        strokeWeight(ss[i]);
        line(x, y, x + sx[i] * k, y + sy[i] * k);
      } else {
        stroke(sc[i], 255 * tw);
        strokeWeight(ss[i]);
        point(x, y);
        if (ss[i] > 2.1) glowAt(x, y, ss[i] * 9, sc[i], 90 * tw);
      }
    }

    // shooting stars
    for (float[] s : shooting) {
      float a = 1 - s[4] / 0.7;
      stroke(255, 255 * a);
      strokeWeight(2);
      float len = 0.09;
      line(s[0], s[1], s[0] - s[2] * len, s[1] - s[3] * len);
      glowAt(s[0], s[1], 24, color(200, 230, 255), 255 * a);
    }
    blendMode(BLEND);

    // planets
    if (warp < 0.5) {
      float a = 255 * (state == WARP ? constrain((st - 0.8) / 0.8, 0, 1) : 1);
      sprite(imgPlanet, 1135 + px(0.45), 150 + py(0.45) + sin(T * 0.6) * 6, 140, -0.15 + sin(T * 0.3) * 0.05, a);
      sprite(imgEarth, 150 + px(0.35), 120 + py(0.35) + sin(T * 0.5 + 1) * 4, 84, T * 0.02, a);
      sprite(imgMoon, 238 + px(0.5), 76 + py(0.5), 34, 0.3, a);
    }

    for (FlyBy f : flybys) f.draw();
  }
}

class FlyBy {
  int kind;   // 0 = UFO, 1 = rocket
  float x, y, vx, vy, t, size;
  boolean done;

  FlyBy(int k) {
    kind = k;
    boolean ltr = random(1) < 0.5;
    if (kind == 0) {
      x = ltr ? -120 : VW + 120;
      y = random(70, 240);
      vx = (ltr ? 1 : -1) * random(150, 220);
      vy = 0;
      size = random(70, 95);
    } else {
      x = ltr ? -100 : VW + 100;
      y = random(420, 620);
      vx = (ltr ? 1 : -1) * 330;
      vy = -230;
      size = 64;
    }
  }

  void update() {
    t += dt;
    x += vx * dt;
    y += vy * dt;
    if (kind == 1 && frameCount % 2 == 0) {
      float back = vx > 0 ? -1 : 1;
      fx.spark(x + back * size * 0.4, y + size * 0.28, random(-20, 20) + back * 80, random(40, 90), color(255, 170, 60), 0.5, 10);
    }
    if (x < -200 || x > VW + 200 || y < -200) done = true;
  }

  void draw() {
    if (kind == 0) {
      float wob = sin(t * 3) * 0.12;
      sprite(imgUfo, x, y + sin(t * 2.2) * 10, size, wob, 230);
      blendMode(ADD);
      glowAt(x, y + size * 0.3, size * 1.6, color(140, 255, 160), 60 + 30 * sin(t * 9));
      blendMode(BLEND);
    } else {
      // the emoji rocket points up-right; mirror it when flying left
      pushMatrix();
      translate(x, y);
      if (vx < 0) scale(-1, 1);
      sprite(imgRocket, 0, 0, size, 0.12, 255);
      popMatrix();
    }
  }
}
