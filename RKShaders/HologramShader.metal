//
//  HologramShader.metal
//  RKShaders
//
//  Sci-fi holographic projection effect
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

// Noise for hologram glitches
float holoHash(float2 p) {
    p = fract(p * float2(456.789, 123.456));
    p += dot(p, p + 78.90);
    return fract(p.x * p.y);
}

float holoNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = holoHash(i);
    float b = holoHash(i + float2(1.0, 0.0));
    float c = holoHash(i + float2(0.0, 1.0));
    float d = holoHash(i + float2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

[[visible]]
void hologramSurfaceShader(realitykit::surface_parameters params)
{
    // Get UV coordinates
    float2 uv = params.geometry().uv0();

    // Get time for animation
    float time = params.uniforms().time();

    // Create scanlines
    float scanlineCount = 80.0;
    float scanline = sin(uv.y * scanlineCount * 3.14159) * 0.5 + 0.5;
    scanline = pow(scanline, 3.0); // Make scanlines sharper

    // Animated scanline movement
    float movingScanline = step(0.98, sin((uv.y - time * 0.5) * 50.0));

    // Add horizontal scan waves
    float scanWave = sin(uv.y * 20.0 - time * 3.0) * 0.1 + 0.9;

    // Hologram flicker/glitch effect
    float glitch = holoNoise(float2(time * 2.0, floor(uv.y * 20.0)));
    float glitchEffect = step(0.95, glitch) * 0.3;

    // Random horizontal displacement for glitch
    float displacement = (glitch - 0.5) * glitchEffect;
    float2 glitchedUV = uv + float2(displacement, 0.0);

    // Fresnel-like edge glow
    // Approximate fresnel using UV distance from center
    float2 centered = (uv - 0.5) * 2.0;
    float dist = length(centered);
    float edgeGlow = smoothstep(0.3, 1.0, dist);

    // Hologram base color (cyan/blue)
    float3 holoColor = float3(0.2, 0.8, 1.0);

    // Combine effects
    float intensity = scanline * scanWave * (1.0 - glitchEffect);
    intensity += movingScanline * 0.5;
    intensity += edgeGlow * 0.3;

    // Color variation
    float3 finalColor = holoColor * intensity;

    // Add glitch color shift (briefly shift to other colors)
    if (glitchEffect > 0.0) {
        float3 glitchColor = float3(1.0, 0.3, 0.8); // Pink glitch
        finalColor = mix(finalColor, glitchColor, glitchEffect);
    }

    // Pulsing effect
    float pulse = sin(time * 2.0) * 0.15 + 0.85;
    finalColor *= pulse;

    // Set the base color
    params.surface().set_base_color(half3(finalColor));

    // Strong emission for hologram glow
    params.surface().set_emissive_color(half3(finalColor * 2.0));

    // Smooth surface
    params.surface().set_roughness(0.2);
    params.surface().set_metallic(0.0);

    // Semi-transparent hologram effect
    float alpha = 0.6 + scanline * 0.2 + edgeGlow * 0.2;
    alpha *= (1.0 - glitchEffect * 0.5); // Flicker during glitches
    alpha *= pulse;

    params.surface().set_opacity(half(alpha));
}
