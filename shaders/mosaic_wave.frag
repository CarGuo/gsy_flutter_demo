#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;       // 画布尺寸
uniform float uTime;      // 时间
uniform float uProgress;  // 扫描进度
uniform sampler2D uTexture; // 输入图片

// ---【必须添加这一行】声明输出变量 ---
out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // --- 配置参数 ---
    float blockSize = 30.0;
    float waveFreq = 12.0;
    float waveAmp = 0.05;      // 原来 0.03 -> 改大一点，波浪更明显
    float edgeSoftness = 0.15;  // 原来 0.15 -> 改大一点，渐变区域更宽，扫描感更强

    // --- 1. 计算马赛克坐标 ---
    vec2 blockCount = uSize / blockSize;
    vec2 blockUV = floor(uv * blockCount) / blockCount + (0.5 / blockCount);

    // --- 2. 计算扫描线 (带波浪) ---
    float scanPos = (uProgress * 1.4) - 0.2;
    float wave = sin(uv.y * waveFreq + uTime * 5.0) * waveAmp;

    // 计算 Mask
    float mask = smoothstep(scanPos - edgeSoftness, scanPos + edgeSoftness, uv.x + wave);

    // --- 3. 边缘涟漪扭曲 ---
    float distToEdge = 1.0 - abs(mask - 0.5) * 2.0;
    distToEdge = max(0.0, distToEdge);
    vec2 distortedUV = uv + vec2(wave * 0.5 * distToEdge, 0.0);

    // --- 4. 采样与混合 ---
    vec4 colorOriginal = texture(uTexture, distortedUV);
    vec4 colorMosaic = texture(uTexture, blockUV);

    // 输出到 fragColor
    fragColor = mix(colorMosaic, colorOriginal, mask);
}