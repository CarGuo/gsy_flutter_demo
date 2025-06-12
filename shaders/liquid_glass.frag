#version 460 core
#include <flutter/runtime_effect.glsl>

//
// ========================= 核心修正 =========================
//
// 明确声明片段着色器的输出变量。这是必需的。
out vec4 fragColor;
//
// ==========================================================
//

// 输入变量，由 Flutter 的 Dart 代码传入
uniform vec2 uResolution; // 画面分辨率 (宽, 高)
uniform vec4 uMouse;      // 鼠标/触摸位置 (x, y, z, w)，z > 0 表示按下
uniform sampler2D uTexture; // 输入的纹理 (iChannel0)

// 全局宏定义
#define R uResolution.xy
#define PI 3.14159265
#define S smoothstep
#define PX(a) a/R.y

// 旋转矩阵
mat2 Rot(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

// 矩形距离函数
float Box(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// “照片”图标的形状
float IconPhoto(vec2 uv) {
    float c = 0.0;
    for (float i = 0.0; i < 1.0; i += 1.0/8.0) {
        vec2 u = uv;
        u *= Rot(i * 2.0 * PI);
        u += vec2(0.0, PX(40.0));
        float b = Box(u, vec2(PX(0.0), PX(13.0)));
        c += S(PX(1.5), 0.0, b - PX(15.0)) * 0.2;
}
return c;
}

// 液态玻璃模糊效果
vec4 LiquidGlass(sampler2D tex, vec2 uv, float direction, float quality, float size) {
    vec2 radius = size / R;
    vec4 color = texture(tex, uv);

    for (float d = 0.0; d < PI; d += PI / direction) {
        for (float i = 1.0 / quality; i <= 1.0; i += 1.0 / quality) {
            color += texture(tex, uv + vec2(cos(d), sin(d)) * radius * i);
        }
    }

    color /= (quality * direction + 1.0); // +1.0 for the initial color
    return color;
}

// 主图标逻辑
vec4 Icon(vec2 uv) {
    float box = Box(uv, vec2(PX(50.0)));
    float boxShape = S(PX(1.5), 0.0, box - PX(50.0));
float boxDisp = S(PX(35.0), 0.0, box - PX(25.0));
float boxLight = boxShape * S(0.0, PX(30.0), box - PX(40.0));
float icon = IconPhoto(uv);
return vec4(boxShape, boxDisp, boxLight, icon);
}

// Flutter 的主函数
void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution.xy;
    vec2 st = (FlutterFragCoord().xy - 0.5 * R) / R.y;
    vec2 M = uMouse.z > 0.0 ? (uMouse.xy - 0.5 * R) / R.y : vec2(0.0);

    vec4 icon = Icon(st - M);

    vec2 uv2 = uv - uMouse.xy / R;
    uv2 *= 0.5 + 0.5 * S(0.5, 1.0, icon.y);
    uv2 += uMouse.xy / R;

    vec3 col = mix(
    texture(uTexture, uv).rgb * 0.8,
    0.2 + LiquidGlass(uTexture, uv2, 10.0, 10.0, 20.0).rgb * 0.7,
    icon.x
    );
    col += icon.z * 0.9 + icon.w;

    col *= 1.0 - 0.2 * S(PX(80.0), 0.0, Box(st - M + vec2(0.0, PX(40.0)), vec2(PX(50.0))));

// 输出最终颜色 (现在这行代码可以正确工作了)
fragColor = vec4(col, 1.0);
}