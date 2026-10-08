// Small helpers shared by every tab.

float easeOutBack(float t) {
  t = constrain(t, 0, 1);
  float c1 = 1.70158, c3 = c1 + 1;
  return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2);
}

float smooth01(float t) {
  t = constrain(t, 0, 1);
  return t * t * (3 - 2 * t);
}

String f1(float v) { return nf(v, 0, 1); }

// metres with 2 decimals, never "-0.00"
String fm(float v) {
  if (abs(v) < 0.005) v = 0;
  return nf(v, 0, 2);
}
String f2(float v) { return nf(v, 0, 2); }
