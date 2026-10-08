// Synthesized sound effects (Java's built-in javax.sound - nothing to install).
// Every sound is generated into a float array at startup; a small mixer
// thread plays any number of them at once. No audio device = silent sketch.

import javax.sound.sampled.*;

class Sfx implements Runnable {
  final float SR = 44100;
  SourceDataLine line;
  boolean ok, muted;
  final ArrayList<Voice> voices = new ArrayList<Voice>();
  java.util.Random rng = new java.util.Random(77);

  float[] fire, portalOpen, fizzle, teleport, whoosh, thud, clink, grab, drop, select, confirm, cancel;
  float[] burp, hum, spawn, zap, warn, pop;

  Sfx() {
    try {
      AudioFormat fmt = new AudioFormat(SR, 16, 1, true, false);
      line = AudioSystem.getSourceDataLine(fmt);
      line.open(fmt, 4096);
      line.start();
      build();
      ok = true;
      Thread th = new Thread(this, "portal-lab-audio");
      th.setDaemon(true);
      th.start();
      Voice h = new Voice(hum, 0.22, 1);
      h.loop = true;
      synchronized (voices) {
        voices.add(h);
      }
    } catch (Exception e) {
      println("No sound (" + e.getMessage() + ") - running silently.");
    }
  }

  void play(float[] s, float vol, float pitch) {
    if (!ok || s == null) return;
    synchronized (voices) {
      if (voices.size() < 32) voices.add(new Voice(s, vol, pitch));
    }
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
            if (vc.pos >= vc.s.length - 1) {
              if (vc.loop) vc.pos = 0;
              else break;
            }
            int p = (int) vc.pos;
            float f = vc.pos - p;
            mix[i] += (vc.s[p] * (1 - f) + vc.s[p + 1] * f) * vc.vol;
            vc.pos += vc.pitch;
          }
          if (!vc.loop && vc.pos >= vc.s.length - 1) voices.remove(v);
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
  float[] buf(float sec) { return new float[(int) (sec * SR)]; }
  float nz() { return rng.nextFloat() * 2 - 1; }
  float sq(float ph) { return (ph % 1) < 0.5 ? 1 : -1; }

  void build() {
    fire = buf(0.22);
    float ph = 0, lp = 0;
    for (int i = 0; i < fire.length; i++) {
      float t = i / SR;
      float f = 1900 * exp(-t * 14) + 260;
      ph += f / SR;
      lp += (nz() - lp) * 0.25;
      fire[i] = (sin(TWO_PI * ph) * 0.7 + sq(ph * 0.5) * 0.15 + lp * 0.3 * exp(-t * 30)) * exp(-t * 11);
    }

    portalOpen = buf(0.9);
    float p1 = 0, p2 = 0;
    lp = 0;
    for (int i = 0; i < portalOpen.length; i++) {
      float t = i / SR;
      float f = 70 + 160 * (1 - exp(-t * 5));
      p1 += f / SR;
      p2 += f * 1.507 / SR;
      lp += (nz() - lp) * (0.02 + 0.1 * t);
      float env = min(1, t * 20) * exp(-t * 3.2);
      portalOpen[i] = (sin(TWO_PI * p1) * 0.6 + sin(TWO_PI * p2) * 0.3 + lp * 1.5 + sin(TWO_PI * p1 * 4) * 0.12 * sin(t * 60)) * env;
    }

    fizzle = buf(0.4);
    for (int i = 0; i < fizzle.length; i++) {
      float t = i / SR;
      fizzle[i] = (rng.nextFloat() < 0.06 ? nz() : nz() * 0.25) * exp(-t * 9) * 0.8;
    }

    teleport = buf(0.45);
    ph = 0;
    lp = 0;
    for (int i = 0; i < teleport.length; i++) {
      float t = i / SR;
      ph += (300 + 2400 * t / 0.45) / SR;
      lp += (nz() - lp) * 0.3;
      float env = sin(PI * t / 0.45);
      teleport[i] = (sin(TWO_PI * ph) * 0.4 + lp * 0.5) * env * 0.8;
    }

    whoosh = sweep(0.45, 300, 1600, 0.6);

    thud = buf(0.3);
    for (int i = 0; i < thud.length; i++) {
      float t = i / SR;
      thud[i] = (sin(TWO_PI * 85 * t * (1 - t)) + nz() * 0.4 * exp(-t * 80)) * exp(-t * 16);
    }

    clink = buf(0.5);
    for (int i = 0; i < clink.length; i++) {
      float t = i / SR;
      clink[i] = (sin(TWO_PI * 2250 * t) * 0.5 + sin(TWO_PI * 3410 * t) * 0.3 + sin(TWO_PI * 5130 * t) * 0.15) * exp(-t * 12) * 0.6;
    }

    grab = buf(0.3);
    ph = 0;
    for (int i = 0; i < grab.length; i++) {
      float t = i / SR;
      ph += (220 + 500 * t / 0.3) / SR;
      grab[i] = (sin(TWO_PI * ph) + 0.3 * sin(TWO_PI * ph * 2)) * sin(PI * t / 0.3) * 0.5;
    }
    drop = buf(0.25);
    ph = 0;
    for (int i = 0; i < drop.length; i++) {
      float t = i / SR;
      ph += (600 - 1400 * t) / SR;
      drop[i] = sin(TWO_PI * ph) * sin(PI * t / 0.25) * 0.4;
    }

    select = tones(new float[] { 880, 1320 }, 0.09, 0.45);
    confirm = tones(new float[] { 660, 880, 1320 }, 0.08, 0.45);
    cancel = tones(new float[] { 520, 330 }, 0.1, 0.45);
    spawn = tones(new float[] { 330, 495, 660, 990 }, 0.06, 0.4);
    warn = tones(new float[] { 440, 330, 440, 330 }, 0.14, 0.3);

    burp = buf(0.55);
    ph = 0;
    lp = 0;
    for (int i = 0; i < burp.length; i++) {
      float t = i / SR;
      float f = 75 + 25 * sin(t * 18) + 30 * (1 - t / 0.55);
      ph += f / SR;
      lp += (nz() - lp) * 0.08;
      float saw = (ph % 1) * 2 - 1;
      burp[i] = (saw * 0.6 + lp * 0.8) * (0.6 + 0.4 * sin(t * 70)) * sin(PI * t / 0.55) * 0.9;
    }

    zap = buf(0.35);
    for (int i = 0; i < zap.length; i++) {
      float t = i / SR;
      zap[i] = (sq(t * 120 + rng.nextFloat() * 0.3) * 0.5 + nz() * 0.5) * exp(-t * 10) * 0.6;
    }

    pop = buf(0.12);
    for (int i = 0; i < pop.length; i++) {
      float t = i / SR;
      pop[i] = sin(TWO_PI * (400 * t + 3000 * t * t)) * exp(-t * 30) * 0.7;
    }

    // seamless 4 s lab drone (whole number of cycles of every partial)
    hum = buf(4);
    for (int i = 0; i < hum.length; i++) {
      float t = i / SR;
      float lfo = 0.75 + 0.25 * sin(TWO_PI * 0.5 * t);
      hum[i] = (sin(TWO_PI * 55 * t) * 0.5 + sin(TWO_PI * 110 * t) * 0.25 + sin(TWO_PI * 165.25 * t) * 0.08) * lfo;
    }
  }

  float[] tones(float[] f, float each, float vol) {
    float[] s = buf(each * f.length + 0.15);
    for (int k = 0; k < f.length; k++) {
      int off = (int) (k * each * SR);
      for (int i = 0; i < (int) ((each + 0.15) * SR) && off + i < s.length; i++) {
        float t = i / SR;
        s[off + i] += (sin(TWO_PI * f[k] * t) + 0.3 * sin(TWO_PI * f[k] * 2 * t)) * exp(-t * 14) * vol;
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
  boolean loop;

  Voice(float[] s, float vol, float pitch) {
    this.s = s;
    this.vol = vol;
    this.pitch = pitch;
  }
}
