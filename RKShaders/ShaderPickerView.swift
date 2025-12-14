//
//  ShaderPickerView.swift
//  RKShaders
//
//  SwiftUI menu overlay for selecting shaders
//

import SwiftUI

struct ShaderPickerView: View {
    @ObservedObject var shaderManager: ShaderManager
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()

                VStack(alignment: .trailing, spacing: 12) {
                    // Toggle button - Made more prominent
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 20, weight: .semibold))
                            Text(shaderManager.currentShader.name)
                                .font(.system(size: 17, weight: .bold))
                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.purple.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                )
                        )
                        .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 4)
                    }

                    // Shader options (shown when expanded)
                    if isExpanded {
                        VStack(spacing: 8) {
                            ForEach(ShaderLibrary.allShaders) { shader in
                                ShaderOptionButton(
                                    shader: shader,
                                    isSelected: shader == shaderManager.currentShader,
                                    action: {
                                        shaderManager.switchShader(to: shader)
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isExpanded = false
                                        }
                                    }
                                )
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 50)

            Spacer()
        }
    }
}

struct ShaderOptionButton: View {
    let shader: ShaderDefinition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(shader.name)
                        .font(.system(size: 16, weight: .bold))

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                    }
                }

                Text(shader.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(.white)
            .frame(width: 240)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.5),
                                    Color.purple.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.7),
                                    Color.black.opacity(0.6)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ShaderPickerView(shaderManager: ShaderManager())
        .background(Color.gray)
}
