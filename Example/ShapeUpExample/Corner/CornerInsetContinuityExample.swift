//
//  CornerInsetContinuityExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-07-14.
//

import ShapeUp
import SwiftUI

struct CornerInsetContinuityExample: View {
    private static let styles: [CornerStyle] = [
        .point,
        .rounded(radius: .relative(0.4)),
        .concave(radius: .relative(0.4)),
        .straight(
            radius: .relative(0.4),
            cornerStyle: .rounded(radius: .relative(0.3))
        ),
        .cutout(
            radius: .relative(0.4),
            cornerStyles: [
                .rounded(radius: .relative(0.3)),
                .point,
                .concave(radius: .relative(0.3))
            ]
        ),
        .custom(
            radius: .relative(0.4),
            relativeCorners: [
                RelativeCorner(.rounded(radius: .relative(0.3)), x: 0, y: 0),
                RelativeCorner(.concave(radius: .relative(0.3)), x: 0.35, y: 1),
                RelativeCorner(.straight(radius: .relative(0.3)), x: 1, y: 1)
            ]
        )
    ]

    @State private var angleDegrees: CGFloat = 15
    @State private var style: CornerStyle = Self.styles[1]
    @State private var insetAmount: CGFloat = 12
    
    var shape: some CornerShape {
        CornerInsetContinuityShape(
            angleDegrees: angleDegrees,
            style: style
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Test how each corner style behaves when angles and insets change.")
                    .frame(maxWidth: .infinity, alignment: .leading)

                diagram
                    .padding()
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(12)
                    .aspectRatio(1, contentMode: .fit)

                HStack(spacing: 20) {
                    Text("Angle: \(Int(angleDegrees.rounded()))°")
                    Text("Inset: \(Int(insetAmount.rounded()))")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)

                Picker("Corner Style", selection: $style) {
                    ForEach(Self.styles, id: \.self) { style in
                        Text(style.name)
                    }
                }
                .pickerStyle(.segmented)

                CrossPlatformSlider(
                    label: "Angle",
                    value: $angleDegrees,
                    minValue: -370,
                    maxValue: 370,
                    step: 1,
                    labelPrefix: true
                )

                CrossPlatformSlider(
                    label: "Inset",
                    value: $insetAmount,
                    minValue: -40,
                    maxValue: 40,
                    step: 1,
                    labelPrefix: true
                )

                HStack {
                    Button("Animate through 0°") {
                        animate(through: 0)
                    }

                    Button("Animate through 180°") {
                        animate(through: 180)
                    }
                }
            }
            .padding()
        }
        .accentColor(.suPink)
        .navigationTitle("Corner Inset Continuity")
    }

    var diagram: some View {
        GeometryReader { proxy in
            let points = CornerInsetContinuityShape.controlPoints(
                in: proxy.frame(in: .local),
                angleDegrees: angleDegrees
            )

            ZStack {
                shape
                    .stroke(
                        Color.secondary,
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                    )

                shape
                    .inset(by: insetAmount)
                    .fill(Color.suPink.opacity(0.2))

                shape
                    .inset(by: insetAmount)
                    .stroke(Color.suPink, lineWidth: 3)

                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    Text("\(index)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.suBlack))
                        .position(point)
                        .accessibilityLabel("Point \(index)")
                }
            }
        }
    }

    func animate(through angle: CGFloat) {
        let destination = angleDegrees <= angle ? angle + 5 : angle - 5
        withAnimation(.linear(duration: 2)) {
            angleDegrees = destination
        }
    }
}

#Preview {
    NavigationView {
        CornerInsetContinuityExample()
    }
}
