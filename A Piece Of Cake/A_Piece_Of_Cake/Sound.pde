// Sound effects and a chiptune "Happy Birthday", synthesized at startup
// with Java's built-in javax.sound (no Processing libraries needed).
// If your computer has no audio device the sketch simply runs silently.

import javax.sound.sampled.*;
import java.util.Random;

class Sfx implements Runnable {
  final float SR = 44100;
  SourceDataLine line;
  boolean ok, muted;
  final ArrayList<Voice> voices = new ArrayList<Voice>();
  Voice music;
  Random rng = new Random(1234);

  float[] warp, pop, thud, beep, click, alarm, boing, boom, popper, portal;
  float[] clap, blow, applause, launch, crackle, melody;

  Sfx(boolean enabled) {
    if (!enabled) return;
    try {
      AudioFormat fmt = new AudioFormat(SR, 16, 1, true, false);
      line = AudioSystem.getSourceDataLine(fmt);
      line.open(fmt, 4096);
      line.start();
      build();
      ok = true;
      Thread th = new Thread(this, "a-piece-of-cake-audio");
      th.setDaemon(true);
      th.start();
    } catch (Exception e) {
      println("No sound (" + e.getMessage() + ") - carrying on silently.");
      ok = false;
    }
  }

  void play(float[] s, float vol, float pitch) {
    if (!ok || s == null) return;
    synchronized (voices) {
      if (voices.size() < 40) voices.add(new Voice(s, vol, pitch));
    }
  }

  void playMusic() {
    if (!ok) return;
    stopMusic();
    music = new Voice(melody, 0.55, 1);
    synchronized (voices) {
      voices.add(music);
    }
  }

  void stopMusic() {
    if (!ok || music == null) return;
    synchronized (voices) {
      voices.remove(music);
    }
    music = null;
  }

  void toggleMute() { muted = !muted; }

  // mixer thread: sums every playing voice into the sound card, 512 samples at a time
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
            int p = (int) vc.pos;
            if (p >= vc.s.length - 1) break;
            float f = vc.pos - p;
            mix[i] += (vc.s[p] * (1 - f) + vc.s[p + 1] * f) * vc.vol;
            vc.pos += vc.pitch;
          }
          if (vc.pos >= vc.s.length - 1) voices.remove(v);
        }
      }
      float g = muted ? 0 : 0.7;
      for (int i = 0; i < N; i++) {
        float x = (float) Math.tanh(mix[i] * g);
        int sv = (int) (x * 32000);
        out[i * 2] = (byte) (sv & 0xff);
        out[i * 2 + 1] = (byte) ((sv >> 8) & 0xff);
      }
      line.write(out, 0, out.length);
    }
  }

  // ---------------------------------------------------------------- synthesis
  float[] buf(float sec) { return new float[(int) (sec * SR)]; }
  float noiseS() { return rng.nextFloat() * 2 - 1; }
  float sq(float ph, float duty) { return (ph % 1) < duty ? 1 : -1; }
  float tri(float ph) { float p = ph % 1; return 4 * abs(p - 0.5) - 1; }

  void build() {
    // clap: three quick bursts and a short filtered-noise tail
    clap = buf(0.18);
    float lp = 0;
    for (int i = 0; i < clap.length; i++) {
      float t = i / SR, env = 0;
      for (int k = 0; k < 3; k++) {
        float tk = t - k * 0.011;
        if (tk >= 0) env = max(env, exp(-tk * 400));
      }
      if (t > 0.022) env = max(env, 0.75 * exp(-(t - 0.022) * 40));
      float n = noiseS();
      lp += (n - lp) * 0.3;
      clap[i] = (n - lp) * env;
    }

    pop = buf(0.12);
    for (int i = 0; i < pop.length; i++) {
      float t = i / SR;
      pop[i] = sin(TWO_PI * (500 * t + 4000 * t * t)) * exp(-t * 30) * 0.8;
    }

    thud = buf(0.5);
    for (int i = 0; i < thud.length; i++) {
      float t = i / SR;
      thud[i] = (sin(TWO_PI * 70 * t * (1 - t)) * 0.9 + noiseS() * 0.25 * exp(-t * 40)) * exp(-t * 7);
    }

    beep = buf(0.22);
    for (int i = 0; i < beep.length; i++) {
      float t = i / SR;
      beep[i] = sq(880 * t, 0.5) * 0.35 * min(1, (0.22 - t) * 30);
    }

    click = buf(0.15);
    for (int i = 0; i < click.length; i++) {
      float t = i / SR;
      click[i] = noiseS() * exp(-t * 300) * 0.8 + sin(TWO_PI * 120 * t) * exp(-t * 30) * 0.8;
    }

    alarm = buf(2.6);
    float ph = 0;
    for (int i = 0; i < alarm.length; i++) {
      float t = i / SR;
      float f = ((int) (t * 3.2) % 2 == 0) ? 740 : 960;
      ph += f / SR;
      alarm[i] = sq(ph, 0.5) * 0.22 * min(1, (2.6 - t) * 4);
    }

    boing = buf(0.4);
    ph = 0;
    for (int i = 0; i < boing.length; i++) {
      float t = i / SR;
      ph += (180 + 120 * sin(t * 50) * exp(-t * 6)) / SR;
      boing[i] = tri(ph) * 0.6 * exp(-t * 8);
    }

    boom = buf(1.8);
    lp = 0;
    for (int i = 0; i < boom.length; i++) {
      float t = i / SR;
      lp += (noiseS() - lp) * 0.04;
      boom[i] = (lp * 3.5 * exp(-t * 2.6) + sin(TWO_PI * (60 * t - 15 * t * t)) * exp(-t * 3)) * 0.9;
    }

    popper = buf(0.5);
    for (int i = 0; i < popper.length; i++) {
      float t = i / SR;
      popper[i] = noiseS() * exp(-t * 25) * 0.7 + (rng.nextFloat() < 0.002 ? 0.8 : 0) * exp(-t * 4);
    }

    warp = sweep(1.6, 1500, 120, 0.5);
    portal = buf(0.9);
    ph = 0;
    lp = 0;
    for (int i = 0; i < portal.length; i++) {
      float t = i / SR;
      ph += (220 + 180 * sin(t * 22)) / SR;
      lp += (noiseS() - lp) * 0.08;
      float env = sin(PI * t / 0.9);
      portal[i] = (sin(TWO_PI * ph) * 0.35 + lp * 1.2) * env * 0.7;
    }

    blow = buf(0.8);
    lp = 0;
    for (int i = 0; i < blow.length; i++) {
      float t = i / SR;
      lp += (noiseS() - lp) * 0.12;
      blow[i] = lp * 1.6 * sin(PI * t / 0.8);
    }

    launch = sweep(0.6, 300, 1400, 0.25);
    crackle = buf(0.9);
    for (int i = 0; i < crackle.length; i++) {
      float t = i / SR;
      crackle[i] = (rng.nextFloat() < 0.004 * exp(-t * 3) ? 1 : 0) * (rng.nextFloat() * 2 - 1) + noiseS() * 0.4 * exp(-t * 18);
    }

    // applause = lots of claps scattered over two seconds
    applause = buf(2.4);
    for (int k = 0; k < 90; k++) {
      int off = (int) (rng.nextFloat() * 1.9 * SR);
      float v = 0.25 + rng.nextFloat() * 0.3;
      for (int i = 0; i < clap.length && off + i < applause.length; i++) applause[off + i] += clap[i] * v;
    }

    melody = buildMelody();
  }

  // filtered noise whoosh from f0 to f1 Hz
  float[] sweep(float sec, float f0, float f1, float vol) {
    float[] s = buf(sec);
    float lp = 0, bp = 0;
    for (int i = 0; i < s.length; i++) {
      float t = i / SR;
      float f = lerp(f0, f1, t / sec);
      float k = constrain(f / SR * 6, 0.001, 0.9);
      lp += (noiseS() - lp) * k;
      bp += (lp - bp) * k * 0.5;
      s[i] = (lp - bp) * sin(PI * t / sec) * vol * 3;
    }
    return s;
  }

  float midi(float m) { return 440 * pow(2, (m - 69) / 12.0); }

  float[] buildMelody() {
    // Happy Birthday (traditional), lead + bass
    float[] notes = {
      67, 67, 69, 67, 72, 71,
      67, 67, 69, 67, 74, 72,
      67, 67, 79, 76, 72, 71, 69,
      77, 77, 76, 72, 74, 72
    };
    float[] beats = {
      0.75, 0.25, 1, 1, 1, 2,
      0.75, 0.25, 1, 1, 1, 2,
      0.75, 0.25, 1, 1, 1, 1, 2,
      0.75, 0.25, 1, 1, 1, 3
    };
    float[] bass = {
      48, 48, 48, 48, 48, 43,
      43, 43, 43, 43, 43, 48,
      48, 48, 48, 48, 41, 41, 41,
      48, 48, 48, 48, 43, 48
    };
    float spb = 60 / 128.0;
    float total = 0;
    for (float b : beats) total += b;
    float[] s = buf(total * spb + 1.2);
    int start = 0;
    for (int n = 0; n < notes.length; n++) {
      float dur = beats[n] * spb;
      int len = (int) (dur * SR);
      float f = midi(notes[n]), fb = midi(bass[n]);
      float p1 = 0, p2 = 0, pb = 0;
      for (int i = 0; i < len + (int) (0.25 * SR) && start + i < s.length; i++) {
        float t = i / SR;
        float release = t < dur - 0.03 ? 1 : 1 - (t - dur + 0.03) * 12;
        if (release <= 0) break;
        float env = min(1, t * 120) * (0.8 + 0.2 * exp(-t * 8)) * release;
        float vib = 1 + 0.004 * sin(TWO_PI * 5.5 * t) * min(1, t * 3);
        p1 += f * vib / SR;
        p2 += f * 1.004 * vib / SR;
        pb += fb / SR;
        float lead = (sq(p1, 0.25) + sq(p2, 0.5) * 0.6) * 0.16;
        float low = tri(pb) * 0.3 * exp(-t * 2.5);
        s[start + i] += (lead + low) * env;
      }
      start += len;
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
