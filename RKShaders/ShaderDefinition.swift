//
//  ShaderDefinition.swift
//  RKShaders
//
//  Reusable shader definition structure for organizing and managing shaders
//

import Foundation
import RealityKit
import Metal

/// Represents a single shader configuration that can be applied to RealityKit entities
struct ShaderDefinition: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let surfaceShaderName: String
    let envelopeShaderName: String?  // Optional outer layer shader
    let hasParticles: Bool

    static func == (lhs: ShaderDefinition, rhs: ShaderDefinition) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Collection of all available shaders for easy reuse across RK projects
enum ShaderLibrary {
    static let fire = ShaderDefinition(
        id: "fire",
        name: "Fire",
        description: "Animated fire effect with particles",
        surfaceShaderName: "fireSurfaceShader",
        envelopeShaderName: "fireEnvelopeShader",
        hasParticles: true
    )

    static let water = ShaderDefinition(
        id: "water",
        name: "Water",
        description: "Rippling water surface with reflections",
        surfaceShaderName: "waterSurfaceShader",
        envelopeShaderName: nil,
        hasParticles: false
    )

    static let plasma = ShaderDefinition(
        id: "plasma",
        name: "Plasma",
        description: "Colorful plasma energy effect",
        surfaceShaderName: "plasmaSurfaceShader",
        envelopeShaderName: nil,
        hasParticles: false
    )

    static let wireframe = ShaderDefinition(
        id: "wireframe",
        name: "Wireframe",
        description: "Animated wireframe grid",
        surfaceShaderName: "wireframeSurfaceShader",
        envelopeShaderName: nil,
        hasParticles: false
    )

    static let hologram = ShaderDefinition(
        id: "hologram",
        name: "Hologram",
        description: "Sci-fi holographic effect",
        surfaceShaderName: "hologramSurfaceShader",
        envelopeShaderName: nil,
        hasParticles: false
    )

    /// All available shaders in the library
    static let allShaders: [ShaderDefinition] = [
        fire,
        water,
        plasma,
        wireframe,
        hologram
    ]
}
