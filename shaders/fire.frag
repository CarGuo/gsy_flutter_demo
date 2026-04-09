#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

void main() {
    // Flutter 的坐标通常是本地坐标，需要根据 resolution 归一化
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;

    vec3 rd = normalize(vec3(uv, 2.0));
    vec4 O = vec4(0.0);
    float t = 0.0;

    // 主步进循环
    for(int i = 0; i < 70; i++) {
        vec3 p = t * rd;

        // 场景偏移与扭转
        p.z -= 5.0 + cos(iTime);
        p.xz *= rot(iTime + p.y * 0.25);

        // 分形流体湍流
        float d_inner = 2.0;
        for(int j = 0; j < 6; j++) {
            d_inner /= 0.8;
            p += cos(p.yzx * d_inner + iTime) / d_inner;
        }

        // 距离场计算
        float dist = 0.01 + abs(length(p.xz) + p.y * 0.3 - 1.0) / 9.0;
        t += dist;

        // 颜色积累
        vec4 col = sin(p.y * 0.5 - vec4(1.0, 2.0, 4.0, 1.0)) + 1.1;
        O += col * (0.015 / dist);
    }

    // 最终色调映射
    fragColor = tanh(O / 15.0);
    fragColor.a = 1.0;
}