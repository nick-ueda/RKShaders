//
//  ContentView.swift
//  RKShaders
//
//  Created by Nick Ueda on 12/12/25.
//

import SwiftUI
import RealityKit
import Metal
import UIKit

struct ContentView: View {
    var body: some View {
        RealityKitView()
            .ignoresSafeArea()
    }
}

struct RealityKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Disable AR session for non-AR mode
        arView.automaticallyConfigureSession = false

        // Create a non-AR camera
        setupNonARCamera(arView: arView)

        // Create the scene
        setupScene(arView: arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    private func setupNonARCamera(arView: ARView) {
        // Set black background
        arView.environment.background = .color(.black)

        // Create a perspective camera
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60

        // Position camera to look at the sphere
        // Camera at (0, 0, 3) looking at origin where sphere will be
        cameraEntity.position = [0, 0, 3]
        cameraEntity.look(at: [0, 0, 0], from: cameraEntity.position, relativeTo: nil)

        // Create an anchor for the camera
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)
    }

    private func setupScene(arView: ARView) {
        // Create an anchor for our scene
        let sceneAnchor = AnchorEntity(world: .zero)

        // Create a sphere with fire shader
        let sphereMesh = MeshResource.generateSphere(radius: 0.5)

        // Create custom material with fire shader
        let material = try! CustomMaterial(from: SimpleMaterial(), surfaceShader: CustomMaterial.SurfaceShader(named: "fireSurfaceShader", in: MetalLibLoader.library))

        let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        sphereEntity.position = [0, 0, 0]

        sceneAnchor.addChild(sphereEntity)

        // Add outer fire envelope shell (slightly larger, transparent)
        let outerSphereMesh = MeshResource.generateSphere(radius: 0.65)
        let outerMaterial = try! CustomMaterial(from: SimpleMaterial(), surfaceShader: CustomMaterial.SurfaceShader(named: "fireEnvelopeShader", in: MetalLibLoader.library))

        let outerSphereEntity = ModelEntity(mesh: outerSphereMesh, materials: [outerMaterial])
        outerSphereEntity.position = [0, 0, 0]

        sceneAnchor.addChild(outerSphereEntity)

        // Add particle emitter for flame effect
        let particleEntity = createFireParticles()
        sceneAnchor.addChild(particleEntity)

        // Add directional light
        let directionalLight = DirectionalLight()
        directionalLight.light.color = .white
        directionalLight.light.intensity = 5000
        directionalLight.position = [1, 2, 1]
        directionalLight.look(at: [0, 0, 0], from: directionalLight.position, relativeTo: nil)

        sceneAnchor.addChild(directionalLight)

        // Add ambient light for better visibility
        let ambientLight = PointLight()
        ambientLight.light.color = .white
        ambientLight.light.intensity = 2000
        ambientLight.light.attenuationRadius = 10
        ambientLight.position = [0, 0, 2]

        sceneAnchor.addChild(ambientLight)

        // Add the scene anchor to the view
        arView.scene.addAnchor(sceneAnchor)
    }

    private func createFireParticles() -> ModelEntity {
        let particleEntity = ModelEntity()

        var particles = ParticleEmitterComponent()

        // Set emitter shape to sphere surface
        particles.emitterShape = .sphere
        particles.emitterShapeSize = [0.6, 0.6, 0.6]
        particles.birthLocation = .surface

        // Speed at component level
        particles.speed = 0.2

        // Configure main emitter for fire effect
        particles.mainEmitter.birthRate = 200
        particles.mainEmitter.lifeSpan = 1.2
        particles.mainEmitter.lifeSpanVariation = 0.4
        particles.mainEmitter.size = 0.04
        particles.mainEmitter.sizeVariation = 0.02

        // Fire color: Start red-orange, fade to yellow, then transparent
        particles.mainEmitter.color = .evolving(
            start: .single(UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0)),
            end: .single(UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 0.0))
        )

        // Spread particles outward and upward
        particles.emissionDirection = [0, 1, 0]  // Upward
        particles.mainEmitter.spreadingAngle = Float.pi / 3  // 60 degrees spread

        // Add upward acceleration (like heat rising)
        particles.mainEmitter.acceleration = [0, 0.3, 0]

        // Particle appearance over lifetime
        particles.mainEmitter.dampingFactor = 0.5
        particles.mainEmitter.noiseStrength = 0.1
        particles.mainEmitter.noiseAnimationSpeed = 2.0

        // Enable blending for fire effect
        particles.mainEmitter.blendMode = .alpha

        // Start emitting
        particles.isEmitting = true

        particleEntity.components.set(particles)
        particleEntity.position = [0, 0, 0]

        return particleEntity
    }
}

// Helper to load Metal library
enum MetalLibLoader {
    static var library: MTLLibrary = {
        let device = MTLCreateSystemDefaultDevice()!
        return device.makeDefaultLibrary()!
    }()
}

#Preview {
    ContentView()
}
