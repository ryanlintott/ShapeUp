//
//  ContinuousCornerExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-13.
//

import ShapeUp
import SwiftUI

struct ContinuousCornerExample: View {
    private static let swiftUIContinuousCutLengthPerRadius: CGFloat =
        1.5286649465560913

    @State private var fillUsesCornerRectangle = true
    @State private var fillRoundingStyle = CornerStyle.RoundingStyle.continuous
    @State private var outlineUsesCornerRectangle = false
    @State private var outlineRoundingStyle = CornerStyle.RoundingStyle.continuous
    @State private var radius: CGFloat = 50
    @State private var insetAmount: CGFloat = 10

    private func swiftUIRoundedCornerStyle(
        for style: CornerStyle.RoundingStyle
    ) -> SwiftUI.RoundedCornerStyle {
        switch style {
        case .circular: .circular
        case .continuous: .continuous
        }
    }

    private var fillShapeName: String {
        fillUsesCornerRectangle ? "CornerRectangle" : "RoundedRectangle"
    }

    private var outlineShapeName: String {
        outlineUsesCornerRectangle ? "CornerRectangle" : "RoundedRectangle"
    }

    private var continuousConstraintThreshold: CGFloat {
        let effectiveRadius = max(radius - insetAmount, 0)
        guard effectiveRadius > 0 else { return 0 }

        return (2 * insetAmount)
            + (2 * Self.swiftUIContinuousCutLengthPerRadius * effectiveRadius)
    }

    /// Rebuilds specialized paths from their elements so both shapes use the
    /// same path storage and rasterization precision in the comparison.
    private func comparisonPath(from source: Path) -> Path {
        var path = Path()

        source.forEach { element in
            switch element {
            case let .move(to: point):
                path.move(to: point)
            case let .line(to: point):
                path.addLine(to: point)
            case let .quadCurve(to: point, control: control):
                path.addQuadCurve(to: point, control: control)
            case let .curve(to: point, control1: control1, control2: control2):
                path.addCurve(
                    to: point,
                    control1: control1,
                    control2: control2
                )
            case .closeSubpath:
                path.closeSubpath()
            }
        }

        return path
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Compare ShapeUp's `CornerRectangle` with SwiftUI's `RoundedRectangle` using the same radius, inset, and rounding style. Pink shows where the filled path extends beyond the outline path. Both paths use the same rendering precision.")
                    .frame(maxWidth: .infinity, alignment: .leading)

                GeometryReader { geometry in
                    let rect = CGRect(origin: .zero, size: geometry.size)
                    let renderedSideLength = min(
                        geometry.size.width,
                        geometry.size.height
                    )
                    let isContinuousCornerConstrained =
                        renderedSideLength < continuousConstraintThreshold

                    ZStack {
                        if fillUsesCornerRectangle {
                            comparisonPath(
                                from: CornerRectangle()
                                    .defaultCornerStyle(
                                        .rounded(
                                            radius: .absolute(radius),
                                            style: fillRoundingStyle
                                        )
                                    )
                                    .inset(by: insetAmount)
                                    .path(in: rect)
                            )
                            .fill(
                                Color.suPink,
                                style: FillStyle(antialiased: false)
                            )
                        } else {
                            comparisonPath(
                                from: RoundedRectangle(
                                    cornerRadius: radius,
                                    style: swiftUIRoundedCornerStyle(
                                        for: fillRoundingStyle
                                    )
                                )
                                .inset(by: insetAmount)
                                .path(in: rect)
                            )
                            .fill(
                                Color.suPink,
                                style: FillStyle(antialiased: false)
                            )
                        }

                        if outlineUsesCornerRectangle {
                            comparisonPath(
                                from: CornerRectangle()
                                    .defaultCornerStyle(
                                        .rounded(
                                            radius: .absolute(radius),
                                            style: outlineRoundingStyle
                                        )
                                    )
                                    .inset(by: insetAmount)
                                    .path(in: rect)
                            )
                            .fill(
                                Color.suBlack,
                                style: FillStyle(antialiased: false)
                            )
                        } else {
                            comparisonPath(
                                from: RoundedRectangle(
                                    cornerRadius: radius,
                                    style: swiftUIRoundedCornerStyle(
                                        for: outlineRoundingStyle
                                    )
                                )
                                .inset(by: insetAmount)
                                .path(in: rect)
                            )
                            .fill(
                                Color.suBlack,
                                style: FillStyle(antialiased: false)
                            )
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(
                                isContinuousCornerConstrained
                                    ? "SwiftUI continuous: constrained"
                                    : "SwiftUI continuous: unconstrained"
                            )
                            .fontWeight(.semibold)

                            Text(
                                "Rendered side: \(renderedSideLength, format: .number.precision(.fractionLength(1))) pt"
                            )
                            Text(
                                "Constraint threshold: \(continuousConstraintThreshold, format: .number.precision(.fractionLength(1))) pt"
                            )
                        }
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(
                            Color.suBlack.opacity(0.85),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .padding(8)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        "Filled \(fillShapeName) with \(fillRoundingStyle.rawValue) corners, outlined \(outlineShapeName) with \(outlineRoundingStyle.rawValue) corners"
                    )
                    .accessibilityValue(
                        "Radius \(Int(radius)), inset \(Int(insetAmount)), rendered side \(Int(renderedSideLength)), continuous constraint threshold \(Int(continuousConstraintThreshold)), \(isContinuousCornerConstrained ? "constrained" : "unconstrained")"
                    )
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .background(Color.suBlack)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("Filled: **\(fillShapeName), \(fillRoundingStyle.rawValue)**\nOutline: **\(outlineShapeName), \(outlineRoundingStyle.rawValue)**")
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading) {
                    Text("Filled Shape")
                        .font(.headline)

                    Picker("Filled Shape Type", selection: $fillUsesCornerRectangle) {
                        Text("CornerRectangle").tag(true)
                        Text("RoundedRectangle").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Picker("Filled Rounding Style", selection: $fillRoundingStyle) {
                        Text("Circular").tag(CornerStyle.RoundingStyle.circular)
                        Text("Continuous").tag(CornerStyle.RoundingStyle.continuous)
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading) {
                    Text("Outline Shape")
                        .font(.headline)

                    Picker("Outline Shape Type", selection: $outlineUsesCornerRectangle) {
                        Text("CornerRectangle").tag(true)
                        Text("RoundedRectangle").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Picker("Outline Rounding Style", selection: $outlineRoundingStyle) {
                        Text("Circular").tag(CornerStyle.RoundingStyle.circular)
                        Text("Continuous").tag(CornerStyle.RoundingStyle.continuous)
                    }
                    .pickerStyle(.segmented)
                }

                CrossPlatformSlider(
                    label: "Radius",
                    value: $radius,
                    minValue: 0,
                    maxValue: 100,
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
            }
            .padding()
        }
        .accentColor(.suPink)
        .navigationTitle("Continuous Corners")
    }
}

#Preview {
    NavigationView {
        ContinuousCornerExample()
    }
}
