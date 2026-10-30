#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

// ---- Thông số (chỉnh ở đây) ----
const vec3 C0 = vec3(0.0118, 0.1098, 0.1490);
const vec3 C1 = vec3(0.1059, 0.4235, 0.6588);
const vec3 C2 = vec3(0.3529, 0.8235, 0.9569);
const vec3 C3 = vec3(0.9176, 0.9765, 1.0);

const float SCALE     = 2.0;
const float INTENSITY = 0.54;
const float WARP      = 0.042;
const float DETAIL    = 1.536;
const float CONTRAST  = 1.158;
const float VIGNETTE  = 0.21;
const float GRAIN     = 0.101;
const float SEED      = 4012.0;
const float ROTATE    = 5.6549;
const float DRIFT     = 0.116;
const vec2  OFFSET    = vec2(0.11, -0.19);

float hash21(vec2 p) {
  p = fract(p * vec2(234.34, 435.345));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

float grainHash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash21(i), hash21(i + vec2(1.0, 0.0)), u.x),
    mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), u.x),
    u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p = p * 2.03 + vec2(17.0, 9.2);
    a *= 0.5;
  }
  return v;
}

vec3 palette(float x) {
  float f = clamp(x, 0.0, 1.0) * 3.0;
  vec3 col = C0;
  col = mix(col, C1, smoothstep(0.0, 1.0, clamp(f, 0.0, 1.0)));
  col = mix(col, C2, smoothstep(0.0, 1.0, clamp(f - 1.0, 0.0, 1.0)));
  col = mix(col, C3, smoothstep(0.0, 1.0, clamp(f - 2.0, 0.0, 1.0)));
  return col;
}

vec3 shade(vec2 uv, vec2 p, float t) {
  float y = uv.y
    + sin(uv.x * (3.0 + INTENSITY * 9.0) + t * 0.8) * 0.08
    + (fbm(p * 2.0 + t * 0.1) - 0.5) * INTENSITY * 0.6;
  return palette(y);
}

void main() {
  // Lật trục Y để giống WebGL (gốc ở dưới-trái)
  vec2 fc = vec2(FlutterFragCoord().x, uResolution.y - FlutterFragCoord().y);
  vec2 uv = fc / uResolution;
  float m = min(uResolution.x, uResolution.y);
  vec2 p = (fc - 0.5 * uResolution) / m;

  p *= SCALE;
  float cr = cos(ROTATE), sr = sin(ROTATE);
  p = mat2(cr, -sr, sr, cr) * p;
  p += OFFSET;
  p += DRIFT * vec2(sin(uTime * 0.31), cos(uTime * 0.23));
  p += WARP * (vec2(
    fbm(p * DETAIL + SEED),
    fbm(p * DETAIL + vec2(5.2, 1.3))) - 0.5);

  vec3 col = shade(uv, p, uTime);

  col = (col - 0.5) * CONTRAST + 0.5;

  float vd = length(uv - 0.5) * 1.41421356;
  col *= 1.0 - VIGNETTE * smoothstep(0.35, 1.0, vd);

  col += (grainHash(fc + vec2(SEED * 17.0, SEED * 31.0)) - 0.5) * GRAIN;

  fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}

