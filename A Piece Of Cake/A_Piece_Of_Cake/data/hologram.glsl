// Hologram look for the Ricks: tint, rim light, scanlines, flicker,
// chromatic split, glitch slices and a bottom-up "materialize" reveal.

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;

uniform float time;
uniform float reveal;   // 0..1 how much of him has materialized (from the feet up)
uniform float glitch;   // 0..1
uniform float alpha;    // overall opacity
uniform vec3 tint;      // hologram colour

varying vec4 vertColor;
varying vec4 vertTexCoord;

float hash(float n) {
  return fract(sin(n) * 43758.5453123);
}

void main() {
  vec2 uv = vertTexCoord.st;
  float vy = uv.y;                       // 0 = top of the sprite, 1 = feet

  float cut = 1.0 - reveal;
  if (vy < cut) discard;
  float edgeGlow = (1.0 - smoothstep(0.0, 0.04, vy - cut)) * step(reveal, 0.999);

  // horizontal glitch slices
  float band = floor(vy * 46.0);
  float tick = floor(time * 16.0);
  float h = hash(band * 7.13 + tick * 1.37);
  float shift = 0.0;
  if (h > 1.0 - 0.35 * glitch) shift = (hash(band + tick * 3.1) - 0.5) * 0.14 * glitch;
  uv.x += shift + sin(vy * 38.0 + time * 6.0) * 0.0016;

  // chromatic split
  float ca = 0.004 + 0.018 * glitch;
  vec4 c = texture2D(texture, uv);
  float ar = texture2D(texture, uv + vec2(ca, 0.0)).a;
  float ab = texture2D(texture, uv - vec2(ca, 0.0)).a;

  // rim light where the silhouette ends
  vec2 o = texOffset * 3.0;
  float around = texture2D(texture, uv + vec2(0.0, -o.y)).a
               + texture2D(texture, uv + vec2(0.0, o.y)).a
               + texture2D(texture, uv + vec2(-o.x, 0.0)).a
               + texture2D(texture, uv + vec2(o.x, 0.0)).a;
  float rim = clamp(c.a - around * 0.25, 0.0, 1.0);

  float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
  vec3 col = tint * (0.32 + 1.0 * lum) + c.rgb * 0.16;
  col += vec3(0.75, 1.0, 1.0) * rim * 1.5;

  float a = max(c.a, max(ar, ab) * 0.7);
  edgeGlow *= clamp(a * 2.0 + around * 0.4, 0.0, 1.0);   // the scan line only lights up his outline
  vec3 fringe = vec3(max(c.a, ar), c.a, max(c.a, ab)) / max(a, 0.001);
  col *= mix(vec3(1.0), fringe, 0.6);

  float scan = 0.8 + 0.2 * sin(gl_FragCoord.y * 1.7 - time * 9.0);
  float roll = 0.85 + 0.3 * smoothstep(0.93, 1.0, sin(vy * 5.0 - time * 2.2));
  float flick = 0.92 + 0.08 * sin(time * 47.0) * sin(time * 13.0);

  col = col * scan * roll * flick + vec3(0.7, 1.0, 1.0) * edgeGlow * 1.8;
  float outA = a * alpha * (0.72 + 0.28 * scan) * flick + edgeGlow * 0.8 * alpha;
  gl_FragColor = vec4(col, clamp(outA, 0.0, 1.0)) * vertColor;
}
