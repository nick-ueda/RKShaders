//
//  WaterShader.metal
//  RKShaders
//
//  Realistic water surface with Fresnel, normal mapping, and advanced wave simulation
//  Based on modern water rendering techniques
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

// Hash function for noise generation
float waterHash(float2 p) {
    p = fract(p * float2(234.567, 789.123));
    p += dot(p, p + 56.78);
    return fract(p.x * p.y);
}

// Smooth noise function
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

// Gerstner wave - creates more realistic wave motion
float3 gerstnerWave(float2 uv, float2 direction, float wavelength, float steepness, float time) {
    float k = 2.0 * M_PI_F / wavelength;
    float c = sqrt(9.8 / k); // Wave speed based on gravity
    float2 d = normalize(direction);
    float f = k * (dot(d, uv) - c * time);
    float a = steepness / k;

    float3 wave;
    wave.x = d.x * (a * cos(f));
    wave.y = a * sin(f);
    wave.z = d.y * (a * cos(f));

    return wave;
}

// Calculate water normal from height field
float3 calculateWaterNormal(float2 uv, float time, float normalStrength) {
    const float delta = 0.01;

    // Sample height at neighboring positions
    float2 uvX = uv + float2(delta, 0.0);
    float2 uvZ = uv + float2(0.0, delta);

    // Calculate heights using layered noise for normal mapping
    float h = waterNoise(uv * 8.0 + time * 0.3) * 0.5 +
              waterNoise(uv * 16.0 - time * 0.5) * 0.25;

    float hX = waterNoise(uvX * 8.0 + time * 0.3) * 0.5 +
               waterNoise(uvX * 16.0 - time * 0.5) * 0.25;

    float hZ = waterNoise(uvZ * 8.0 + time * 0.3) * 0.5 +
               waterNoise(uvZ * 16.0 - time * 0.5) * 0.25;

    // Calculate tangent and bitangent
    float3 tangent = normalize(float3(delta, (hX - h) * normalStrength, 0.0));
    float3 bitangent = normalize(float3(0.0, (hZ - h) * normalStrength, delta));

    // Cross product for normal
    return normalize(cross(tangent, bitangent));
}

// Fresnel effect - controls reflection vs refraction based on view angle
float fresnelEffect(float3 normal, float3 viewDir, float power) {
    float cosTheta = max(0.0, dot(normal, viewDir));
    return pow(1.0 - cosTheta, power);
}

[[visible]]
void waterSurfaceShader(realitykit::surface_parameters params)
{
    // Get UV coordinates and time
    float2 uv = params.geometry().uv0();
    float time = params.uniforms().time();

    // Get model space position for world-space effects
    float3 modelPos = params.geometry().model_position();

    // === WAVE SIMULATION ===
    // Use multiple Gerstner waves for realistic ocean motion
    float3 waveOffset = float3(0.0);

    waveOffset += gerstnerWave(uv, float2(1.0, 0.3), 0.4, 0.25, time * 0.8);
    waveOffset += gerstnerWave(uv, float2(-0.5, 1.0), 0.3, 0.2, time * 1.0);
    waveOffset += gerstnerWave(uv, float2(0.7, -0.8), 0.25, 0.15, time * 1.2);
    waveOffset += gerstnerWave(uv, float2(-0.3, -0.5), 0.2, 0.1, time * 1.5);

    // Add fine detail waves
    float2 detailUV1 = uv * 5.0 + time * 0.3;
    float2 detailUV2 = uv * 8.0 - time * 0.5;
    float detailWaves = sin(detailUV1.x + cos(detailUV1.y)) * 0.02 +
                        sin(detailUV2.x * 1.3 + sin(detailUV2.y * 0.8)) * 0.015;

    float waveHeight = waveOffset.y + detailWaves;

    // === NORMAL MAPPING ===
    // Calculate detailed surface normal
    float3 waterNormal = calculateWaterNormal(uv, time, 3.0);

    // Add high-frequency detail to normals
    float3 detailNormal1 = calculateWaterNormal(uv * 3.0, time * 1.5, 2.0);
    float3 detailNormal2 = calculateWaterNormal(uv * 7.0, time * 2.0, 1.0);

    // Blend normals for multi-scale detail
    waterNormal = normalize(waterNormal + detailNormal1 * 0.3 + detailNormal2 * 0.15);

    // === LIGHTING SETUP ===
    // Approximate view direction (camera is typically at positive Z)
    float3 viewDir = normalize(float3(0.0, 0.0, 1.0) - modelPos);

    // Light direction (sun from above and slightly to the side)
    float3 lightDir = normalize(float3(0.5, 1.0, 0.3));

    // === FRESNEL EFFECT ===
    // Water reflects more at grazing angles, refracts more when viewed from above
    float fresnel = fresnelEffect(waterNormal, viewDir, 5.0);

    // === COLOR CALCULATION ===
    // Deep water color (absorbs most light)
    float3 deepWaterColor = float3(0.0, 0.1, 0.3);

    // Shallow water color (cyan/turquoise)
    float3 shallowWaterColor = float3(0.1, 0.5, 0.7);

    // Reflection color (sky/environment - bright blue-white)
    float3 reflectionColor = float3(0.6, 0.8, 1.0);

    // Mix water colors based on depth simulation
    float depthFactor = saturate(waveHeight * 2.0 + 0.5);
    float3 waterColor = mix(deepWaterColor, shallowWaterColor, depthFactor);

    // Apply Fresnel to blend water color with reflections
    waterColor = mix(waterColor, reflectionColor, fresnel * 0.8);

    // === SPECULAR HIGHLIGHTS ===
    // Calculate sun specular reflection (Phong model)
    float3 halfVector = normalize(lightDir + viewDir);
    float specular = pow(max(0.0, dot(waterNormal, halfVector)), 128.0);
    float3 specularColor = float3(1.0, 1.0, 0.95) * specular * 2.0;

    // Add specular to water color
    waterColor += specularColor;

    // === FOAM ===
    // Foam appears at wave peaks
    float foamMask = smoothstep(0.3, 0.5, waveHeight + 0.3);
    float foamNoise = waterNoise(uv * 20.0 + time * 0.5);
    float foam = foamMask * step(0.6, foamNoise) * 0.8;

    // Mix in foam
    waterColor = mix(waterColor, float3(1.0, 1.0, 1.0), foam);

    // === CAUSTICS ===
    // Simulate underwater light caustics
    float caustics1 = waterNoise(uv * 12.0 + time * 0.4);
    float caustics2 = waterNoise(uv * 18.0 - time * 0.6);
    float caustics = pow(caustics1 * caustics2, 2.0) * 0.3;

    // Add caustics to color
    waterColor += float3(0.3, 0.4, 0.5) * caustics * (1.0 - fresnel);

    // === SUBSURFACE SCATTERING ===
    // Simulate light passing through water
    float subsurface = pow(max(0.0, dot(waterNormal, lightDir)), 3.0) * 0.2;
    waterColor += float3(0.1, 0.3, 0.4) * subsurface;

    // === OUTPUT ===
    // Set base color
    params.surface().set_base_color(half3(saturate(waterColor)));

    // Slight emission for underwater glow
    params.surface().set_emissive_color(half3(waterColor * 0.1));

    // Dynamic roughness - calmer water is smoother
    float roughness = 0.02 + abs(waveHeight) * 0.12;
    params.surface().set_roughness(half(saturate(roughness)));

    // High metallic for strong reflections
    params.surface().set_metallic(0.95);

    // Slight transparency for refraction effect
    float opacity = 0.95 + fresnel * 0.05;
    params.surface().set_opacity(half(saturate(opacity)));
}
