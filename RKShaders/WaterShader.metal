//
//  WaterShader.metal
//  RKShaders
//
//  Water surface effect with realistic animated ripples and reflections
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

// Simple noise function for water
float waterHash(float2 p) {
    p = fract(p * float2(234.567, 789.123));
    p += dot(p, p + 56.78);
    return fract(p.x * p.y);
}

float waterNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = waterHash(i);
    float b = waterHash(i + float2(1.0, 0.0));
    float c = waterHash(i + float2(0.0, 1.0));
    float d = waterHash(i + float2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Create realistic circular ripples from a point
float createRipple(float2 uv, float2 center, float time, float speed, float frequency, float amplitude) {
    float dist = length(uv - center);
    float wave = sin((dist * frequency - time * speed)) * amplitude;
    // Fade ripples with distance
    float falloff = exp(-dist * 1.5);
    return wave * falloff;
}

// Calculate normal map from ripple height
float3 calculateWaterNormal(float2 uv, float height, float delta) {
    // Sample neighboring heights for gradient
    float hL = height - 0.01;
    float hR = height + 0.01;
    float hD = height - 0.01;
    float hU = height + 0.01;

    // Calculate gradients
    float3 normal;
    normal.x = (hL - hR) * 10.0;
    normal.y = 1.0;
    normal.z = (hD - hU) * 10.0;

    return normalize(normal);
}

[[visible]]
void waterSurfaceShader(realitykit::surface_parameters params)
{
    // Get UV coordinates
    float2 uv = params.geometry().uv0();

    // Get time for animation
    float time = params.uniforms().time();

    // Create multiple ripple sources with different characteristics
    float ripples = 0.0;

    // Primary ripple source - center
    ripples += createRipple(uv, float2(0.5, 0.5), time, 2.0, 15.0, 0.3);

    // Secondary ripple sources moving around
    float2 source2 = float2(0.3 + sin(time * 0.5) * 0.2, 0.4 + cos(time * 0.3) * 0.2);
    ripples += createRipple(uv, source2, time, 2.5, 20.0, 0.2);

    float2 source3 = float2(0.7 + cos(time * 0.4) * 0.15, 0.6 + sin(time * 0.6) * 0.15);
    ripples += createRipple(uv, source3, time, 1.8, 18.0, 0.25);

    // Add smaller, faster ripples
    float2 source4 = float2(0.2, 0.7);
    ripples += createRipple(uv, source4, time * 1.5, 3.0, 25.0, 0.15);

    // Add directional waves for ocean-like movement
    float2 waveDir1 = normalize(float2(1.0, 0.3));
    float wave1 = sin(dot(uv, waveDir1) * 8.0 - time * 1.5) * 0.15;

    float2 waveDir2 = normalize(float2(-0.5, 1.0));
    float wave2 = sin(dot(uv, waveDir2) * 6.0 - time * 1.2) * 0.12;

    // Combine all water movement
    float waterHeight = ripples + wave1 + wave2;

    // Add fine detail with noise
    float noise1 = waterNoise(uv * 10.0 + time * 0.3) * 0.08;
    float noise2 = waterNoise(uv * 20.0 - time * 0.5) * 0.04;
    waterHeight += noise1 + noise2;

    // Normalize to 0-1 range
    float waterPattern = waterHeight * 0.5 + 0.5;

    // Calculate dynamic normal based on ripples
    float3 waterNormal = calculateWaterNormal(uv, waterHeight, 0.01);

    // Create depth effect with more variation
    float depth = 0.25 + waterPattern * 0.75;

    // Enhanced water colors with more variety
    float3 deepWater = float3(0.0, 0.15, 0.4);
    float3 midWater = float3(0.1, 0.4, 0.7);
    float3 shallowWater = float3(0.3, 0.65, 0.85);
    float3 foam = float3(0.8, 0.95, 1.0);

    // More complex color mixing
    float3 waterColor;
    if (depth < 0.33) {
        waterColor = mix(deepWater, midWater, depth / 0.33);
    } else if (depth < 0.66) {
        waterColor = mix(midWater, shallowWater, (depth - 0.33) / 0.33);
    } else {
        waterColor = mix(shallowWater, foam, (depth - 0.66) / 0.34);
    }

    // Add dynamic specular highlights based on ripple peaks
    float specular = pow(max(0.0, waterPattern), 12.0) * 0.5;

    // Add rim highlights where ripples are steep
    float rimLight = pow(1.0 - abs(waterNormal.y), 3.0) * 0.3;

    // Combine lighting effects
    float3 highlight = float3(1.0, 1.0, 1.0);
    waterColor = mix(waterColor, highlight, specular + rimLight);

    // Add subtle caustics effect
    float caustics = pow(waterNoise(uv * 15.0 + time * 0.4), 2.0) * 0.2;
    waterColor += float3(0.2, 0.3, 0.4) * caustics;

    // Set the base color
    params.surface().set_base_color(half3(waterColor));

    // Dynamic emission based on ripple activity
    float emissionStrength = (abs(waterHeight) + 0.2) * 0.15;
    params.surface().set_emissive_color(half3(waterColor * emissionStrength));

    // Variable roughness based on ripples (rougher at peaks)
    float roughness = 0.05 + abs(waterHeight) * 0.15;
    params.surface().set_roughness(half(roughness));

    // High metallic for reflective water
    params.surface().set_metallic(0.9);

    // Full opacity
    params.surface().set_opacity(1.0);
}
