//
//  MazeDropStoreMockup.swift
//  RKShaders
//
//  High-fidelity UI mockup for MazeDrop iOS game
//

import SwiftUI

struct MazeDropStoreMockup: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(alignment: .top) {
                    Text("MAZEDROP")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "0A1A2F"))

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "0A1A2F"))
                        Text("Coins: 124")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "0A1A2F"))
                    }
                }
                .padding(.top, 20)

                // FEATURED Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("FEATURED")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "0A1A2F").opacity(0.6))
                        .padding(.leading, 4)

                    VStack(spacing: 12) {
                        FeaturedCard(
                            icon: AnyView(DarkCubeIcon()),
                            title: "Dark Cube",
                            price: "42"
                        )

                        FeaturedCard(
                            icon: AnyView(DarkScorecardIcon()),
                            title: "Dark Mode Scorecard",
                            price: nil
                        )

                        FeaturedCard(
                            icon: AnyView(DarkGlowIcon()),
                            title: "Dark Mode Player Glow",
                            price: nil
                        )
                    }
                }

                // PLAYER Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("PLAYER")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "0A1A2F").opacity(0.6))
                        .padding(.leading, 4)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        PlayerTile(
                            icon: AnyView(SphereIcon(color: .red, size: 44)),
                            title: "Larger Sphere",
                            subtitle: nil,
                            price: "10"
                        )

                        PlayerTile(
                            icon: AnyView(SphereIcon(color: .red, size: 36)),
                            title: "Red Ball",
                            subtitle: nil,
                            price: "5"
                        )

                        PlayerTile(
                            icon: AnyView(SphereIcon(color: .green, size: 36)),
                            title: "Green Ball",
                            subtitle: nil,
                            price: "5"
                        )

                        PlayerTile(
                            icon: AnyView(SphereIcon(color: .white, size: 36, isOutline: true)),
                            title: "Design Your Own Ball",
                            subtitle: "Unlimited Color Customizations",
                            price: nil
                        )
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
    }
}

// MARK: - Featured Card Component
struct FeaturedCard: View {
    let icon: AnyView
    let title: String
    let price: String?

    var body: some View {
        HStack(spacing: 16) {
            icon
                .frame(width: 56, height: 56)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "0A1A2F"))

            Spacer()

            if let price = price {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "0A1A2F").opacity(0.7))
                    Text(price)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "0A1A2F"))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Player Tile Component
struct PlayerTile: View {
    let icon: AnyView
    let title: String
    let subtitle: String?
    let price: String?

    var body: some View {
        VStack(spacing: 12) {
            icon
                .frame(height: 60)

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0A1A2F"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "0A1A2F").opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }

            if let price = price {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "0A1A2F").opacity(0.7))
                    Text(price)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "0A1A2F"))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Icon Components
struct DarkCubeIcon: View {
    var body: some View {
        ZStack {
            // Simple 3D-ish cube
            Path { path in
                // Front face
                path.move(to: CGPoint(x: 16, y: 36))
                path.addLine(to: CGPoint(x: 40, y: 36))
                path.addLine(to: CGPoint(x: 40, y: 12))
                path.addLine(to: CGPoint(x: 16, y: 12))
                path.closeSubpath()

                // Top face
                path.move(to: CGPoint(x: 16, y: 12))
                path.addLine(to: CGPoint(x: 28, y: 6))
                path.addLine(to: CGPoint(x: 52, y: 6))
                path.addLine(to: CGPoint(x: 40, y: 12))
                path.closeSubpath()

                // Right face
                path.move(to: CGPoint(x: 40, y: 12))
                path.addLine(to: CGPoint(x: 52, y: 6))
                path.addLine(to: CGPoint(x: 52, y: 30))
                path.addLine(to: CGPoint(x: 40, y: 36))
                path.closeSubpath()
            }
            .fill(Color(hex: "0A1A2F"))
        }
        .frame(width: 56, height: 56)
    }
}

struct DarkScorecardIcon: View {
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "0A1A2F"))
                    .frame(width: 40, height: 6)
            }
        }
        .frame(width: 56, height: 56)
    }
}

struct DarkGlowIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "0A1A2F").opacity(0.8),
                            Color(hex: "0A1A2F").opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 8,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
        }
        .frame(width: 56, height: 56)
    }
}

struct SphereIcon: View {
    let color: Color
    let size: CGFloat
    var isOutline: Bool = false

    var body: some View {
        Circle()
            .fill(
                isOutline
                    ? RadialGradient(
                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size/2
                    )
                    : RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(1),
                            color.opacity(0.7)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size/2
                    )
            )
            .overlay(
                isOutline
                    ? Circle()
                        .strokeBorder(Color(hex: "0A1A2F").opacity(0.3), lineWidth: 2)
                    : nil
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    MazeDropStoreMockup()
}
