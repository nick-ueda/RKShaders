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

struct MetallicRedCircle: View {
    var body: some View {
        ZStack {
            // Base red circle with darker tone for metal
            Circle()
                .fill(
                    Color(red: 0.6, green: 0.1, blue: 0.1)
                )

            // Dark metallic gradient (high contrast shadows)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.clear, location: 0.4),
                            .init(color: Color.black.opacity(0.4), location: 0.7),
                            .init(color: Color.black.opacity(0.7), location: 1.0)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 100
                    )
                )

            // Bright metallic reflection zone
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.4), location: 0.0),
                            .init(color: Color.white.opacity(0.2), location: 0.3),
                            .init(color: Color.clear, location: 0.5)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .blendMode(.overlay)

            // Sharp specular highlight (key for metal look)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white, location: 0.0),
                            .init(color: Color.white.opacity(0.8), location: 0.2),
                            .init(color: Color.white.opacity(0.4), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
                .offset(x: -30, y: -30)
                .blendMode(.plusLighter)

            // Secondary smaller highlight
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.8), location: 0.0),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 16)
                .offset(x: -25, y: -25)
                .blendMode(.plusLighter)

            // Edge highlight (rim lighting)
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.6), location: 0.0),
                            .init(color: Color.clear, location: 0.3),
                            .init(color: Color.black.opacity(0.5), location: 0.5),
                            .init(color: Color.clear, location: 0.7),
                            .init(color: Color.white.opacity(0.6), location: 1.0)
                        ]),
                        center: .center
                    ),
                    lineWidth: 2
                )
        }
        .shadow(color: .black.opacity(0.5), radius: 20, x: 5, y: 10)
    }
}

struct ContentView: View {
    @StateObject private var shaderManager = ShaderManager()
    @State private var showStore = false

    var body: some View {
        ZStack {
//            RealityKitView(shaderManager: shaderManager)
//                .ignoresSafeArea()

            // Metallic red circle
            MetallicRedCircle()
                .frame(width: 200, height: 200)

            // Glassy store front icons
            VStack {
                HStack {
                    Spacer()

                    // Top-right store front icon
                    Button(action: {
                        showStore = true
                    }) {
                        Image(systemName: "storefront")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50)
                }

                Spacer()
            }
        }
        .statusBar(hidden: true)
        .sheet(isPresented: $showStore) {
            MazeDropStoreMockup()
        }
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
