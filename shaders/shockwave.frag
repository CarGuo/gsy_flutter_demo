#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uCenter;
uniform float uForce;
uniform float uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    float aspectRatio = uResolution.x / uResolution.y;

    vec2 scaledUV = uv;
    scaledUV.x *= aspectRatio;
    vec2 scaledCenter = uCenter / uResolution;
    scaledCenter.x *= aspectRatio;

    float dist = distance(scaledUV, scaledCenter);

    // 波纹扩散速度
    float currentRadius = uTime * 1.5;

    // 核心修改：使用 Sin 正弦波制造“震荡” (Ringing Effect)
    // (dist - currentRadius) * 40.0 决定了波纹的频率（疏密）
    // * uSize 决定波纹范围
    float wave = sin((dist - currentRadius) * 40.0);

    // 限制波纹只在半径附近产生
    // 使用 smoothstep 创建一个移动的圆环窗口
    float mask = smoothstep(currentRadius + uSize, currentRadius, dist) * smoothstep(currentRadius - uSize, currentRadius, dist);

    // 计算偏移：
    // wave * mask: 在波纹范围内进行正弦震荡
    // uForce: 震荡幅度
    // (1.0 - uTime): 随时间能量衰减
    vec2 dispVec = normalize(scaledUV - scaledCenter);
    vec2 displacement = dispVec * wave * mask * uForce * (1.0 - uTime);

    fragColor = texture(uTexture, uv - displacement);
}