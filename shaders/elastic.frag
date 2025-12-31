#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;      // 时间 (0.0 -> 1.0)
uniform vec2 uCenter;     // 点击中心
uniform float uForce;     // 冲击力度 (控制变形幅度)
uniform float uSize;      // 冲击波的宽度 (越宽越有弹性感)

uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    float aspectRatio = uResolution.x / uResolution.y;

    // 1. 坐标修正
    vec2 scaledUV = uv;
    scaledUV.x *= aspectRatio;
    vec2 scaledCenter = uCenter / uResolution;
    scaledCenter.x *= aspectRatio;

    vec2 dir = scaledUV - scaledCenter;
    float dist = length(dir);

    // 2. 核心逻辑：移动的波前 (Traveling Wavefront)
    // 速度设为 1.5，随时间推移，currentRadius 从 0 变大
    float speed = 1.5;
    float currentRadius = uTime * speed;

    // 3. 定义冲击波的“形状”
    // 我们需要一个仅仅存在于 currentRadius 附近的环
    // 使用 smoothstep 创建一个“软边缘”的圆环
    // 范围：[currentRadius - uSize, currentRadius]
    float mask = smoothstep(currentRadius - uSize, currentRadius, dist) * smoothstep(currentRadius + uSize, currentRadius, dist);

    // 4. 增加“回弹”感 (Sine Wave Profile)
    // 在这个环内部，我们应用一个正弦波，模拟“推开-拉回”的过程
    // 乘以 3.14159 (PI) 保证在一个 uSize 范围内完成半个或一个周期的变形
    float waveProfile = sin((dist - currentRadius) / uSize * 3.14159);

    // 5. 计算位移
    // normalize(dir): 沿着径向推开
    // mask: 限制只在波环范围内变形
    // waveProfile: 提供波峰波谷的形状
    // (1.0 - uTime): 随着扩散，能量逐渐衰减
    vec2 displacement = normalize(dir) * mask * waveProfile * uForce * (1.0 - uTime);

    // 修正 X 轴比例
    displacement.x /= aspectRatio;

    // 应用位移
    fragColor = texture(uTexture, uv - displacement);
}