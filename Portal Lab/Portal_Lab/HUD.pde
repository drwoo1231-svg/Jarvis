// Screen overlay: crosshair, toasts (grows into the full research HUD later).

class HUD {
  ArrayList<Toast> toasts = new ArrayList<Toast>();
  PFont mono, sans;

  HUD() {
    mono = createFont("Monospaced.bold", 28, true);
    sans = createFont("SansSerif.bold", 32, true);
  }

  void toast(String s, int c) {
    toasts.add(0, new Toast(s, c));
    if (toasts.size() > 4) toasts.remove(toasts.size() - 1);
  }

  void update(float dt) {
    for (int i = toasts.size() - 1; i >= 0; i--) {
      toasts.get(i).age += dt;
      if (toasts.get(i).age > 2.6) toasts.remove(i);
    }
  }

  void draw() {
    textFont(mono, 14);
    textAlign(LEFT, TOP);
    fill(170, 255, 200);
    text("PORTAL LAB  -  " + nf(frameRate, 0, 0) + " FPS", 14, 12);
    text("NEXT SHOT: PORTAL " + (gun.next == 0 ? "A" : "B"), 14, 30);
    text("PORTAL A: " + (portals.p[0].active ? "ACTIVE" : "OFFLINE") + "    PORTAL B: " + (portals.p[1].active ? "ACTIVE" : "OFFLINE"), 14, 48);
    // toasts
    textAlign(CENTER, CENTER);
    for (int i = 0; i < toasts.size(); i++) {
      Toast t = toasts.get(i);
      float a = 255 * min(1, (2.6 - t.age) / 0.5) * min(1, t.age / 0.12);
      textFont(sans, 20);
      fill(0, a * 0.6);
      text(t.s, width / 2 + 2, height * 0.68 + i * 30 + 2);
      fill(red(t.c), green(t.c), blue(t.c), a);
      text(t.s, width / 2, height * 0.68 + i * 30);
    }
    if (!cam.captured) {
      textFont(sans, 18);
      fill(170, 255, 200, 150 + 100 * sin(T * 4));
      text("CLICK TO CONTROL THE CAMERA", width / 2, height - 40);
    }
    cam.drawCrosshair();
  }
}

class Toast {
  String s;
  int c;
  float age;

  Toast(String s, int c) {
    this.s = s;
    this.c = c;
  }
}
