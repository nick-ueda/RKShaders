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
    @StateObject private var shaderManager = ShaderManager()

    var body: some View {
        ZStack {
            RealityKitView(shaderManager: shaderManager)
                .ignoresSafeArea()

            ShaderPickerView(shaderManager: shaderManager)
                .allowsHitTesting(true)
        }
        .statusBar(hidden: true)
    }
}

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var shaderManager: ShaderManager

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

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update scene when shader changes
        if let sceneAnchor = uiView.scene.anchors.first(where: { $0.name == "sceneAnchor" }) as? AnchorEntity {
            let sphereMesh = MeshResource.generateSphere(radius: 0.5)
            let outerSphereMesh = MeshResource.generateSphere(radius: 0.65)
            shaderManager.applyShadersToScene(
                sceneAnchor: sceneAnchor,
                sphereMesh: sphereMesh,
                outerSphereMesh: outerSphereMesh
            )
        }
    }

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
        sceneAnchor.name = "sceneAnchor"

        // Create meshes
        let sphereMesh = MeshResource.generateSphere(radius: 0.5)
        let outerSphereMesh = MeshResource.generateSphere(radius: 0.65)

        // Apply initial shader using shader manager
        shaderManager.applyShadersToScene(
            sceneAnchor: sceneAnchor,
            sphereMesh: sphereMesh,
            outerSphereMesh: outerSphereMesh
        )

        // Add the scene anchor to the view
        arView.scene.addAnchor(sceneAnchor)
    }

}

#Preview {
    ContentView()
}
