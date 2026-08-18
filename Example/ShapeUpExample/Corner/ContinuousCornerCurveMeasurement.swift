//
//  ContinuousCornerCurveMeasurement.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-17.
//

import SwiftUI

// MEASUREMENT HARNESS
//
// A single continuous `RoundedRectangle` drawn alone on a flat background, so
// its silhouette can be read straight off a screenshot. Nothing is stacked on
// top of it, which is what contaminated earlier comparisons: two overlapping
// fills always let the lower one bleed through the upper one's antialiased
// edge, regardless of whether the two shapes agree.
//
// The shape touches its frame on all four sides, so the silhouette's own
// bounding box recovers the rect it was built from. That makes the render
// self registering and removes any need to know where the view was laid out.
//
// `phase` nudges the shape by quarter device pixels. Averaging the four phases
// cancels the bias that comes from the boundary landing at a fixed position
// relative to the pixel grid.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
struct ContinuousCornerCurveMeasurement: View {
    static let sizes: [CGFloat] = [380, 300, 220]
    static let radii: [CGFloat] = [110, 87, 64]

    @State private var phase: Int = 0
    @State private var sizeIndex: Int = 0

    /// Screen scale, needed to turn a quarter pixel into points.
    @Environment(\.displayScale) private var displayScale

    private var size: CGFloat { Self.sizes[sizeIndex] }
    private var radius: CGFloat { Self.radii[sizeIndex] }

    /// A quarter device pixel, expressed in points.
    private var phaseOffset: CGFloat {
        CGFloat(phase) / (4 * displayScale)
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Color.white

                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.black)
                    .frame(width: size, height: size)
                    .offset(x: phaseOffset, y: phaseOffset)
            }
            .frame(height: size + 40)

            VStack(spacing: 8) {
                Button("Phase: \(phase)/4 px") {
                    phase = (phase + 1) % 4
                }

                Button("Size: \(size, format: .number)  Radius: \(radius, format: .number)") {
                    sizeIndex = (sizeIndex + 1) % Self.sizes.count
                    phase = 0
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
        .padding(.vertical)
        .navigationTitle("Corner Curve Measurement")
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
#Preview {
    NavigationView {
        ContinuousCornerCurveMeasurement()
    }
}
