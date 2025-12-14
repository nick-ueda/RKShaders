# RealityKit Shaders Library

A collection of reusable Metal shaders for RealityKit projects with an easy-to-use management system.

## Available Shaders

### 1. Fire Shader (`FireShader.metal`)
Animated fire effect with two shader functions:
- `fireSurfaceShader` - Core fire effect
- `fireEnvelopeShader` - Outer flame envelope (optional)
- Includes particle system support

### 2. Water Shader (`WaterShader.metal`)
Rippling water surface with reflections:
- `waterSurfaceShader` - Animated water with waves and noise

### 3. Plasma Shader (`PlasmaShader.metal`)
Colorful plasma energy effect:
- `plasmaSurfaceShader` - Rainbow plasma with animated patterns

### 4. Wireframe Shader (`WireframeShader.metal`)
Animated wireframe grid:
- `wireframeSurfaceShader` - Grid lines with pulsing intersections

### 5. Hologram Shader (`HologramShader.metal`)
Sci-fi holographic projection:
- `hologramSurfaceShader` - Scanlines, glitches, and transparency

## How to Use in Your RealityKit Project

### Quick Start (Copy Individual Shaders)

1. **Copy the shader file** you want (e.g., `WaterShader.metal`) to your project
2. **Apply it to an entity**:

```swift
import RealityKit
import Metal

// Get Metal library
let device = MTLCreateSystemDefaultDevice()!
let library = device.makeDefaultLibrary()!

// Create mesh
let mesh = MeshResource.generateSphere(radius: 0.5)

// Create material with shader
let material = try! CustomMaterial(
    from: SimpleMaterial(),
    surfaceShader: CustomMaterial.SurfaceShader(
        named: "waterSurfaceShader",  // Use shader name
        in: library
    )
)

// Create entity
let entity = ModelEntity(mesh: mesh, materials: [material])
```

### Full System Integration (Recommended)

For the complete shader switching system, copy these files to your project:

#### Required Files:
1. `ShaderDefinition.swift` - Defines shader metadata
2. `ShaderManager.swift` - Handles shader application and switching
3. `ShaderPickerView.swift` - SwiftUI menu overlay
4. All `.metal` shader files you want to use

#### Integration Steps:

1. **Add to your ContentView**:

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var shaderManager = ShaderManager()

    var body: some View {
        ZStack {
            RealityKitView(shaderManager: shaderManager)
                .ignoresSafeArea()

            ShaderPickerView(shaderManager: shaderManager)
        }
    }
}
```

2. **Update your RealityKitView**:

```swift
struct RealityKitView: UIViewRepresentable {
    @ObservedObject var shaderManager: ShaderManager

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Setup camera and scene
        setupScene(arView: arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update when shader changes
        if let sceneAnchor = uiView.scene.anchors
            .first(where: { $0.name == "sceneAnchor" }) as? AnchorEntity {

            let sphereMesh = MeshResource.generateSphere(radius: 0.5)
            let outerSphereMesh = MeshResource.generateSphere(radius: 0.65)

            shaderManager.applyShadersToScene(
                sceneAnchor: sceneAnchor,
                sphereMesh: sphereMesh,
                outerSphereMesh: outerSphereMesh
            )
        }
    }

    private func setupScene(arView: ARView) {
        let sceneAnchor = AnchorEntity(world: .zero)
        sceneAnchor.name = "sceneAnchor"

        let sphereMesh = MeshResource.generateSphere(radius: 0.5)
        let outerSphereMesh = MeshResource.generateSphere(radius: 0.65)

        shaderManager.applyShadersToScene(
            sceneAnchor: sceneAnchor,
            sphereMesh: sphereMesh,
            outerSphereMesh: outerSphereMesh
        )

        arView.scene.addAnchor(sceneAnchor)
    }
}
```

## Adding Custom Shaders

### 1. Create a new `.metal` file

```metal
#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void myCustomShader(realitykit::surface_parameters params)
{
    float2 uv = params.geometry().uv0();
    float time = params.uniforms().time();

    // Your shader code here
    float3 color = float3(uv.x, uv.y, sin(time));

    params.surface().set_base_color(half3(color));
    params.surface().set_roughness(0.5);
    params.surface().set_metallic(0.0);
    params.surface().set_opacity(1.0);
}
```

### 2. Add to `ShaderLibrary` in `ShaderDefinition.swift`

```swift
static let myCustomShader = ShaderDefinition(
    id: "custom",
    name: "Custom Effect",
    description: "My custom shader description",
    surfaceShaderName: "myCustomShader",
    envelopeShaderName: nil,
    hasParticles: false
)

static let allShaders: [ShaderDefinition] = [
    fire,
    water,
    plasma,
    wireframe,
    hologram,
    myCustomShader  // Add here
]
```

### 3. Done!

Your shader will automatically appear in the picker menu.

## Shader Parameters Reference

### Available from RealityKit:
- `params.geometry().uv0()` - UV coordinates (float2)
- `params.uniforms().time()` - Animated time (float)
- `params.geometry().normal()` - Surface normal (float3)
- `params.geometry().position()` - World position (float3)

### Surface Properties You Can Set:
- `set_base_color(half3)` - Base color (RGB)
- `set_emissive_color(half3)` - Glow/emission
- `set_roughness(half)` - Surface roughness (0-1)
- `set_metallic(half)` - Metallic property (0-1)
- `set_opacity(half)` - Transparency (0-1)

## Tips for Reusability

1. **Keep shaders self-contained** - Each shader file should work independently
2. **Use descriptive names** - Name shader functions clearly (e.g., `waterSurfaceShader`)
3. **Comment your code** - Explain parameters and techniques used
4. **Test on different geometries** - Shaders should work on spheres, boxes, etc.
5. **Optimize for mobile** - Keep noise functions and loops minimal

## Project Structure

```
YourProject/
├── ShaderDefinition.swift      # Shader metadata
├── ShaderManager.swift          # Shader application logic
├── ShaderPickerView.swift       # UI overlay
├── ContentView.swift            # Main view
└── Shaders/
    ├── FireShader.metal
    ├── WaterShader.metal
    ├── PlasmaShader.metal
    ├── WireframeShader.metal
    └── HologramShader.metal
```

## License

Feel free to use these shaders in your RealityKit projects!
