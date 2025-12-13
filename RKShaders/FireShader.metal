//
//  FireShader.metal
//  RKShaders
//
//  Fire effect shader with animated noise
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

// Simple noise function
float hash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal Brownian Motion for more complex noise
float fbm(float2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

[[visible]]
void fireSurfaceShader(realitykit::surface_parameters params)
{
    // Get UV coordinates
    float2 uv = params.geometry().uv0();

    // Get time for animation
    float time = params.uniforms().time();

    // Create animated noise pattern
    float2 noiseCoord = uv * 3.0;
    noiseCoord.y -= time * 0.5; // Scroll upward

    // Add turbulence
    float n1 = fbm(noiseCoord);
    float n2 = fbm(noiseCoord * 2.0 + float2(time * 0.3, 0.0));

    // Combine noise patterns
    float firePattern = n1 * 0.6 + n2 * 0.4;

    // Create vertical gradient (hotter at bottom, cooler at top)
    float gradient = 1.0 - uv.y;
    firePattern = firePattern * gradient;

    // Add some flickering
    float flicker = sin(time * 10.0 + uv.x * 20.0) * 0.05 + 0.95;
    firePattern *= flicker;

    // Define fire colors
    float3 color1 = float3(1.0, 0.0, 0.0);      // Deep red
    float3 color2 = float3(1.0, 0.3, 0.0);      // Orange-red
    float3 color3 = float3(1.0, 0.7, 0.0);      // Orange
    float3 color4 = float3(1.0, 1.0, 0.3);      // Yellow-white
    float3 color5 = float3(0.1, 0.05, 0.0);     // Dark (burned)

    // Map fire pattern to colors
    float3 fireColor;
    if (firePattern < 0.2) {
        fireColor = mix(color5, color1, firePattern / 0.2);
    } else if (firePattern < 0.4) {
        fireColor = mix(color1, color2, (firePattern - 0.2) / 0.2);
    } else if (firePattern < 0.6) {
        fireColor = mix(color2, color3, (firePattern - 0.4) / 0.2);
    } else {
        fireColor = mix(color3, color4, (firePattern - 0.6) / 0.4);
    }

    // Set the base color
    params.surface().set_base_color(half3(fireColor));

    // Make it emit light
    params.surface().set_emissive_color(half3(fireColor * 2.0));

    // Set roughness and metallic
    params.surface().set_roughness(0.9);
    params.surface().set_metallic(0.0);

    // Add some opacity variation for more depth
    float alpha = smoothstep(0.1, 0.5, firePattern);
    params.surface().set_opacity(half(alpha));
}

[[visible]]
void fireEnvelopeShader(realitykit::surface_parameters params)
{
    // Get UV coordinates
    float2 uv = params.geometry().uv0();

    // Get time for animation
    float time = params.uniforms().time();

    // More aggressive animated noise for outer envelope
    float2 noiseCoord = uv * 5.0;
    noiseCoord.y -= time * 0.8; // Faster upward scroll
    noiseCoord.x += sin(time * 2.0 + uv.y * 10.0) * 0.2; // Add horizontal wave distortion

    // Multiple layers of turbulent noise
    float n1 = fbm(noiseCoord);
    float n2 = fbm(noiseCoord * 1.5 + float2(time * 0.5, time * 0.3));
    float n3 = fbm(noiseCoord * 3.0 - float2(time * 0.4, time * 0.6));

    // Combine noise with more chaos
    float firePattern = n1 * 0.4 + n2 * 0.3 + n3 * 0.3;

    // Vertical gradient - flames more intense at bottom
    float gradient = pow(1.0 - uv.y, 1.5);
    firePattern = firePattern * gradient;

    // More aggressive flickering
    float flicker = sin(time * 15.0 + uv.x * 30.0 + uv.y * 20.0) * 0.1 + 0.9;
    firePattern *= flicker;

    // Add pulsing effect
    float pulse = sin(time * 3.0) * 0.1 + 0.9;
    firePattern *= pulse;

    // Outer flames are hotter/brighter - more yellow and white
    float3 color1 = float3(1.0, 0.2, 0.0);      // Orange-red
    float3 color2 = float3(1.0, 0.5, 0.0);      // Bright orange
    float3 color3 = float3(1.0, 0.8, 0.1);      // Yellow-orange
    float3 color4 = float3(1.0, 1.0, 0.7);      // Bright yellow-white
    float3 color5 = float3(0.05, 0.0, 0.0);     // Nearly transparent dark

    // Map fire pattern to colors
    float3 fireColor;
    if (firePattern < 0.15) {
        fireColor = mix(color5, color1, firePattern / 0.15);
    } else if (firePattern < 0.35) {
        fireColor = mix(color1, color2, (firePattern - 0.15) / 0.2);
    } else if (firePattern < 0.6) {
        fireColor = mix(color2, color3, (firePattern - 0.35) / 0.25);
    } else {
        fireColor = mix(color3, color4, (firePattern - 0.6) / 0.4);
    }

    // Set the base color
    params.surface().set_base_color(half3(fireColor));

    // Strong emission for the envelope
    params.surface().set_emissive_color(half3(fireColor * 3.0));

    // Set roughness and metallic
    params.surface().set_roughness(1.0);
    params.surface().set_metallic(0.0);

    // More transparent, wispy appearance
    // Use noise to create gaps in the flames
    float alpha = smoothstep(0.05, 0.4, firePattern);

    // Add additional noise-based transparency for wispy effect
    float transparencyNoise = noise(uv * 10.0 + time * 0.5);
    alpha *= smoothstep(0.3, 0.7, transparencyNoise);

    // Overall envelope transparency
    alpha *= 0.7;

    params.surface().set_opacity(half(alpha));
}
