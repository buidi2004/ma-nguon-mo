#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

// Silk Shader: Supports dual color palettes:
// - Netflix Cinema Red (uTheme = 0.0, Default)
// - Windows 11 Fluent Blue & White (uTheme = 1.0, Option in Settings)

uniform vec2 uSize;   // painted size in logical pixels (float 0, 1)
uniform float uTime;  // wrapped to [0, 10*pi) from Dart (float 2)
uniform float uTheme; // 0.0 = Netflix Red, 1.0 = Win 11 Blue (float 3)

out vec4 fragColor;

// 1. Netflix Red Palette (Default)
const vec3 RED_C0 = vec3(0.008, 0.004, 0.039); // #02010A
const vec3 RED_C1 = vec3(0.165, 0.016, 0.031); // #2A0408
const vec3 RED_C2 = vec3(0.698, 0.027, 0.063); // #B20710
const vec3 RED_C3 = vec3(0.898, 0.035, 0.078); // #E50914

// 2. Cyan Blue #00A2ED & Frosted Pearl White Palette (Option)
// #00A2ED vivid cyan blue with pristine frosted pearl white waves
const vec3 WIN_C0 = vec3(0.941, 0.957, 0.973); // #F0F4F8 frosted pearl white
const vec3 WIN_C1 = vec3(0.839, 0.922, 0.988); // #D6EBFC translucent sky mist
const vec3 WIN_C2 = vec3(0.0, 0.635, 0.929);   // #00A2ED vivid cyan blue
const vec3 WIN_C3 = vec3(1.0, 1.0, 1.0);       // #FFFFFF pure pristine white

const float AMP = 0.488;               // 0.25 + intensity(0.28) * 0.85
const float SEED_PHASE = 3.9204879;    // 1581 mod 2*pi
const vec2 GRAIN_OFFSET = vec2(26877.0, 49011.0); // seed * 17, seed * 31

float grainHash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec3 palette(float x) {
  float t = clamp(uTheme, 0.0, 1.0);
  vec3 c0 = mix(RED_C0, WIN_C0, t);
  vec3 c1 = mix(RED_C1, WIN_C1, t);
  vec3 c2 = mix(RED_C2, WIN_C2, t);
  vec3 c3 = mix(RED_C3, WIN_C3, t);

  float f = clamp(x, 0.0, 1.0) * 3.0;
  vec3 col = mix(c0, c1, smoothstep(0.0, 1.0, clamp(f, 0.0, 1.0)));
  col = mix(col, c2, smoothstep(0.0, 1.0, clamp(f - 1.0, 0.0, 1.0)));
  col = mix(col, c3, smoothstep(0.0, 1.0, clamp(f - 2.0, 0.0, 1.0)));
  return col;
}

vec3 shade(vec2 p, float t) {
  vec2 q = p * 1.6;
  for (int j = 1; j < 5; j++) {
    float i = float(j);
    q.x += AMP / i * cos(i * 2.4 * q.y + t * 0.8 + SEED_PHASE);
    q.y += AMP / i * cos(i * 1.7 * q.x + t * 0.6);
  }
  return palette(0.5 + 0.5 * sin(q.x + q.y));
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  fc.y = uSize.y - fc.y; // match GL's bottom-left origin

  vec2 p = (fc - 0.5 * uSize) / min(uSize.x, uSize.y) * 1.26; // scale 1.26
  vec3 col = shade(p, uTime);

  col = (col - 0.5) * 1.11 + 0.5;                     // contrast
  col += (grainHash(fc + GRAIN_OFFSET) - 0.5) * 0.05; // grain

  fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
