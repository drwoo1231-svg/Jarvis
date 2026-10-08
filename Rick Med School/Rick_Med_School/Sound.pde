// Synthesized sound effects (Java's built-in javax.sound - nothing to install).
// Every sound is generated into a float array at startup; a small mixer
// thread plays any number of them at once. No audio device = silent game.

import javax.sound.sampled.*;

class Sfx implements Runnable {
  final float SR = 44100;
  SourceDataLine line;
  boolean ok, muted;
  final ArrayList<Voice> voices = new ArrayList<Voice>();
  java.util.Random rng = new java.util.Random(77);

  float[] burp, bigBurp, hic, blip, click, correct, wrong, portal, whoosh, fanfare, sad, tick, slurp, thud, streak;

  Sfx() {
    try {
      AudioFormat fmt = new AudioFormat(SR, 16, 1, true, false);
      line = AudioSystem.getSourceDataLine(fmt);
      line.open(fmt, 4096);
      line.start();
      build();
      ok = true;
      Thread th = new Thread(this, "rick-med-audio");
      th.setDaemon(true);
      th.start();
    } catch (Exception e) {
      println("No sound (" + e.getMessage() + ") - running silently.");
    }
  }

  void play(float[] s, float vol, float pitch) {
    if (!ok || s == null) return;
    synchronized (voices) {
      if (voices.size() < 24) voices.add(new Voice(s, vol, pitch));
    }
  }

  void play(float[] s, float vol) {
    play(s, vol, 1);
  }

  public void run() {
    int N = 512;
    float[] mix = new float[N];
    byte[] out = new byte[N * 2];
    while (true) {
      java.util.Arrays.fill(mix, 0);
      synchronized (voices) {
        for (int v = voices.size() - 1; v >= 0; v--) {
          Voice vc = voices.get(v);
          for (int i = 0; i < N; i++) {
            if (vc.pos >= vc.s.length - 1) break;
            int p = (int) vc.pos;
            float f = vc.pos - p;
            mix[i] += (vc.s[p] * (1 - f) + vc.s[p + 1] * f) * vc.vol;
            vc.pos += vc.pitch;
          }
          if (vc.pos >= vc.s.length - 1) voices.remove(v);
        }
      }
      float g = muted ? 0 : 0.75;
      for (int i = 0; i < N; i++) {
        int sv = (int) (Math.tanh(mix[i] * g) * 32000);
        out[i * 2] = (byte) (sv & 0xff);
        out[i * 2 + 1] = (byte) ((sv >> 8) & 0xff);
      }
      line.write(out, 0, out.length);
    }
  }

  // ---------------------------------------------------------------- synthesis
  float[] buf(float sec) {
    return new float[(int) (sec * SR)];
  }

  float nz() {
    return rng.nextFloat() * 2 - 1;
  }

  float[] makeBurp(float sec, float f0) {
    float[] s = buf(sec);
    float ph = 0, lp = 0;
    for (int i = 0; i < s.length; i++) {
      float t = i / SR;
      float f = f0 + 25 * sin(t * 18) + 30 * (1 - t / sec) + 12 * sin(t * 7.3);
      ph += f / SR;
      lp += (nz() - lp) * 0.08;
      float saw = (ph % 1) * 2 - 1;
      float flutter = 0.6 + 0.4 * sin(t * 70 + 3 * sin(t * 11));
      s[i] = (saw * 0.6 + lp * 0.8) * flutter * sin(PI * t / sec) * 0.95;
    }
    return s;
  }

  void build() {
    burp = makeBurp(0.55, 75);
    bigBurp = makeBurp(1.25, 62);

    hic = buf(0.16);
    float ph = 0;
    for (int i = 0; i < hic.length; i++) {
      float t = i / SR;
      ph += (380 + 900 * t / 0.16) / SR;
      hic[i] = (sin(TWO_PI * ph) * 0.6 + nz() * 0.25 * exp(-t * 60)) * sin(PI * t / 0.16) * 0.8;
    }

    blip = buf(0.03);
    for (int i = 0; i < blip.length; i++) {
      float t = i / SR;
      blip[i] = sin(TWO_PI * 210 * t) * exp(-t * 120) * 0.35;
    }

    click = tones(new float[] { 990 }, 0.05, 0.35);
    correct = tones(new float[] { 523, 659, 784, 1047 }, 0.07, 0.42);
    streak = tones(new float[] { 784, 988, 1175, 1568, 1976 }, 0.055, 0.38);
    fanfare = tones(new float[] { 392, 523, 659, 784, 659, 784, 1047 }, 0.11, 0.42);

    wrong = buf(0.42);
    float p2 = 0;
    for (int i = 0; i < wrong.length; i++) {
      float t = i / SR;
      p2 += (150 - 40 * t) / SR;
      float sq = (p2 % 1) < 0.5 ? 1 : -1;
      wrong[i] = (sq * 0.35 + ((p2 * 1.5) % 1 < 0.5 ? 0.2 : -0.2)) * min(1, t * 80) * exp(-t * 4) * 0.8;
    }

    sad = buf(1.6);
    float[] sadF = { 392, 370, 349, 330 };
    ph = 0;
    for (int i = 0; i < sad.length; i++) {
      float t = i / SR;
      int k = min(3, (int) (t / 0.32));
      float local = t - k * 0.32;
      float f = sadF[k] * (k == 3 ? 1 + 0.02 * sin(local * 40) : 1);
      ph += f / SR;
      float saw = (ph % 1) * 2 - 1;
      float env = min(1, local * 30) * (k == 3 ? exp(-local * 1.6) : exp(-local * 3));
      sad[i] = saw * env * 0.35;
    }

    portal = buf(1.0);
    ph = 0;
    float p3 = 0, lp = 0;
    for (int i = 0; i < portal.length; i++) {
      float t = i / SR;
      float f = 70 + 160 * (1 - exp(-t * 5));
      ph += f / SR;
      p3 += f * 1.507 / SR;
      lp += (nz() - lp) * (0.02 + 0.1 * t);
      float env = min(1, t * 20) * exp(-t * 2.8);
      portal[i] = (sin(TWO_PI * ph) * 0.6 + sin(TWO_PI * p3) * 0.3 + lp * 1.5 + sin(TWO_PI * ph * 4) * 0.12 * sin(t * 60)) * env;
    }

    whoosh = sweep(0.5, 300, 1800, 0.5);

    tick = buf(0.04);
    for (int i = 0; i < tick.length; i++) {
      float t = i / SR;
      tick[i] = sin(TWO_PI * 1800 * t) * exp(-t * 160) * 0.4;
    }

    slurp = buf(0.6);
    lp = 0;
    for (int i = 0; i < slurp.length; i++) {
      float t = i / SR;
      lp += (nz() - lp) * (0.05 + 0.25 * (0.5 + 0.5 * sin(t * 55)));
      slurp[i] = lp * sin(PI * t / 0.6) * 0.9;
    }

    thud = buf(0.3);
    for (int i = 0; i < thud.length; i++) {
      float t = i / SR;
      thud[i] = (sin(TWO_PI * 85 * t * (1 - t)) + nz() * 0.4 * exp(-t * 80)) * exp(-t * 16);
    }
  }

  float[] tones(float[] f, float each, float vol) {
    float[] s = buf(each * f.length + 0.18);
    for (int k = 0; k < f.length; k++) {
      int off = (int) (k * each * SR);
      for (int i = 0; i < (int) ((each + 0.18) * SR) && off + i < s.length; i++) {
        float t = i / SR;
        s[off + i] += (sin(TWO_PI * f[k] * t) + 0.3 * sin(TWO_PI * f[k] * 2 * t)) * exp(-t * 12) * vol;
      }
    }
    return s;
  }

  float[] sweep(float sec, float f0, float f1, float vol) {
    float[] s = buf(sec);
    float lp = 0, bp = 0;
    for (int i = 0; i < s.length; i++) {
      float t = i / SR;
      float k = constrain(lerp(f0, f1, t / sec) / SR * 6, 0.001, 0.9);
      lp += (nz() - lp) * k;
      bp += (lp - bp) * k * 0.5;
      s[i] = (lp - bp) * sin(PI * t / sec) * vol * 3;
    }
    return s;
  }
}

class Voice {
  float[] s;
  float vol, pitch, pos;

  Voice(float[] s, float vol, float pitch) {
    this.s = s;
    this.vol = vol;
    this.pitch = pitch;
  }
}
