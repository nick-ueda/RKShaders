//
//  WireframeShader.metal
//  RKShaders
//
//  Animated wireframe grid effect
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void wireframeSurfaceShader(realitykit::surface_parameters params)
{
    // Get UV coordinates
    float2 uv = params.geometry().uv0();

    // Get time for animation
    float time = params.uniforms().time();

    // Create grid pattern
    float gridSize = 20.0;
    float2 grid = fract(uv * gridSize);

    // Animated line thickness
    float lineThickness = 0.05 + sin(time * 2.0) * 0.02;

    // Create horizontal and vertical lines
    float hLine = step(1.0 - lineThickness, grid.y) + step(grid.y, lineThickness);
    float vLine = step(1.0 - lineThickness, grid.x) + step(grid.x, lineThickness);

    // Combine lines
    float wireframe = clamp(hLine + vLine, 0.0, 1.0);

    // Add diagonal lines for more complexity
    float2 diagGrid = fract((uv + float2(uv.y, -uv.x)) * gridSize * 0.5);
    float diagLine = step(1.0 - lineThickness, diagGrid.x) + step(diagGrid.x, lineThickness);
    wireframe = clamp(wireframe + diagLine * 0.5, 0.0, 1.0);

    // Animate color along the grid
    float colorShift = sin(time + (uv.x + uv.y) * 5.0) * 0.5 + 0.5;

    // Create gradient colors
    float3 color1 = float3(0.0, 0.8, 1.0);  // Cyan
    float3 color2 = float3(0.5, 0.0, 1.0);  // Purple
    float3 gridColor = mix(color1, color2, colorShift);

    // Background color (dark)
    float3 bgColor = float3(0.0, 0.0, 0.05);

    // Mix grid and background
    float3 finalColor = mix(bgColor, gridColor, wireframe);

    // Add pulse effect to intersections
    float2 intersection = step(0.95, float2(hLine, vLine));
    float pulse = sin(time * 4.0) * 0.5 + 0.5;
    float isIntersection = intersection.x * intersection.y;
    finalColor += float3(1.0, 1.0, 1.0) * isIntersection * pulse * 0.5;

    // Set the base color
    params.surface().set_base_color(half3(finalColor));

    // Emit light from the grid lines
    params.surface().set_emissive_color(half3(finalColor * wireframe * 2.0));

    // Smooth surface
    params.surface().set_roughness(0.8);
    params.surface().set_metallic(0.3);

    // Make background slightly transparent for depth effect
    float alpha = 0.3 + wireframe * 0.7;
    params.surface().set_opacity(half(alpha));
}
