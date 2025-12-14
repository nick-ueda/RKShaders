//
//  ShaderManager.swift
//  RKShaders
//
//  Manages shader application and switching for RealityKit entities
//

import Foundation
import RealityKit
import Metal
import Combine
import UIKit

/// Observable class that manages the current shader and applies it to RealityKit entities
class ShaderManager: ObservableObject {
    @Published var currentShader: ShaderDefinition = ShaderLibrary.fire

    private let metalLibrary: MTLLibrary

    init() {
        // Load the Metal library
        let device = MTLCreateSystemDefaultDevice()!
        self.metalLibrary = device.makeDefaultLibrary()!
    }

    /// Apply the current shader to a sphere entity and its parent anchor
    func applyShadersToScene(sceneAnchor: AnchorEntity, sphereMesh: MeshResource, outerSphereMesh: MeshResource) {
        // Remove all existing children
        sceneAnchor.children.removeAll()

        // Generate random rotation axis (normalized)
        let randomAxis = simd_normalize(SIMD3<Float>(
            Float.random(in: -1...1),
            Float.random(in: -1...1),
            Float.random(in: -1...1)
        ))

        // Random rotation speed (radians per second)
        let rotationSpeed = Float.random(in: 0.3...0.8)

        // Create main sphere with surface shader
        let material = createMaterial(shaderName: currentShader.surfaceShaderName)
        let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        sphereEntity.position = [0, 0, 0]
        sceneAnchor.addChild(sphereEntity)

        // Add continuous rotation to main sphere
        addContinuousRotation(to: sphereEntity, axis: randomAxis, speed: rotationSpeed)

        // Add envelope sphere if shader has one
        if let envelopeShaderName = currentShader.envelopeShaderName {
            let envelopeMaterial = createMaterial(shaderName: envelopeShaderName)
            let outerSphereEntity = ModelEntity(mesh: outerSphereMesh, materials: [envelopeMaterial])
            outerSphereEntity.position = [0, 0, 0]
            sceneAnchor.addChild(outerSphereEntity)

            // Add same rotation to outer sphere
            addContinuousRotation(to: outerSphereEntity, axis: randomAxis, speed: rotationSpeed)
        }

        // Add particles if shader uses them
        if currentShader.hasParticles {
            let particleEntity = createFireParticles()
            sceneAnchor.addChild(particleEntity)
        }

        // Add lights
        addLights(to: sceneAnchor)
    }

    /// Create a custom material with the specified shader
    private func createMaterial(shaderName: String) -> CustomMaterial {
        return try! CustomMaterial(
            from: SimpleMaterial(),
            surfaceShader: CustomMaterial.SurfaceShader(
                named: shaderName,
                in: metalLibrary
            )
        )
    }

    /// Create fire particle emitter (used for fire shader)
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

    /// Add standard lights to the scene
    private func addLights(to anchor: AnchorEntity) {
        // Add directional light
        let directionalLight = DirectionalLight()
        directionalLight.light.color = .white
        directionalLight.light.intensity = 5000
        directionalLight.position = [1, 2, 1]
        directionalLight.look(at: [0, 0, 0], from: directionalLight.position, relativeTo: nil)

        anchor.addChild(directionalLight)

        // Add ambient light for better visibility
        let ambientLight = PointLight()
        ambientLight.light.color = .white
        ambientLight.light.intensity = 2000
        ambientLight.light.attenuationRadius = 10
        ambientLight.position = [0, 0, 2]

        anchor.addChild(ambientLight)
    }

    /// Add continuous rotation animation to an entity
    private func addContinuousRotation(to entity: Entity, axis: SIMD3<Float>, speed: Float) {
        // Create a rotation around the specified axis
        let rotationAngle = Float.pi * 2 // Full rotation (360 degrees)
        let duration: TimeInterval = TimeInterval(rotationAngle / speed)

        // Create start and end rotation quaternions
        let startRotation = simd_quatf(angle: 0, axis: axis)
        let endRotation = simd_quatf(angle: rotationAngle, axis: axis)

        // Create transforms
        var startTransform = entity.transform
        startTransform.rotation = startRotation

        var endTransform = entity.transform
        endTransform.rotation = endRotation

        // Create rotation animation from start to end
        let animation = FromToByAnimation(
            name: "continuousRotation",
            from: startTransform,
            to: endTransform,
            duration: duration,
            timing: .linear,
            isAdditive: true,  // Make it additive for continuous rotation
            bindTarget: .transform
        )

        // Generate and play the animation on infinite repeat
        if let animationResource = try? AnimationResource.generate(with: animation) {
            entity.playAnimation(animationResource.repeat())
        }
    }

    /// Switch to a new shader
    func switchShader(to shader: ShaderDefinition) {
        currentShader = shader
    }
}
