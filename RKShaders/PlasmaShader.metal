//
//  PlasmaShader.metal
//  RKShaders
//
//  Colorful plasma energy effect
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void plasmaSurfaceShader(realitykit::surface_parameters params)
{
    // Get UV coordinates
    float2 uv = params.geometry().uv0();

    // Get time for animation
    float time = params.uniforms().time();

    // Create plasma patterns using sin waves
    float plasma1 = sin((uv.x + time) * 10.0);
    float plasma2 = sin((uv.y + time * 0.8) * 10.0);
    float plasma3 = sin((uv.x + uv.y + time * 0.5) * 10.0);
    float plasma4 = sin(sqrt((uv.x - 0.5) * (uv.x - 0.5) + (uv.y - 0.5) * (uv.y - 0.5)) * 20.0 - time * 2.0);

    // Combine plasma patterns
    float plasmaValue = (plasma1 + plasma2 + plasma3 + plasma4) / 4.0;

    // Normalize to 0-1 range
    plasmaValue = plasmaValue * 0.5 + 0.5;

    // Create colorful gradient using HSV-like approach
    float hue = plasmaValue + time * 0.1;
    hue = fract(hue); // Keep in 0-1 range

    // Convert hue to RGB (simplified HSV to RGB)
    float3 color;
    float h = hue * 6.0;
    float x = 1.0 - abs(fmod(h, 2.0) - 1.0);

    if (h < 1.0) {
        color = float3(1.0, x, 0.0);
    } else if (h < 2.0) {
        color = float3(x, 1.0, 0.0);
    } else if (h < 3.0) {
        color = float3(0.0, 1.0, x);
    } else if (h < 4.0) {
        color = float3(0.0, x, 1.0);
    } else if (h < 5.0) {
        color = float3(x, 0.0, 1.0);
    } else {
        color = float3(1.0, 0.0, x);
    }

    // Add brightness variation
    float brightness = 0.7 + plasmaValue * 0.3;
    color *= brightness;

    // Set the base color
    params.surface().set_base_color(half3(color));

    // Strong emission for glowing plasma effect
    params.surface().set_emissive_color(half3(color * 1.5));

    // Smooth surface
    params.surface().set_roughness(0.3);
    params.surface().set_metallic(0.0);

    // Full opacity
    params.surface().set_opacity(1.0);
}
