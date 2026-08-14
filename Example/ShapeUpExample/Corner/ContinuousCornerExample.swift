//
//  ContinuousCornerExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-13.
//

import ShapeUp
import SwiftUI

struct ContinuousCornerExample: View {
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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Compare ShapeUp's `CornerRectangle` with SwiftUI's `RoundedRectangle` using the same radius, inset, and rounding style.")
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    if fillUsesCornerRectangle {
                        CornerRectangle()
                            .defaultCornerStyle(
                                .rounded(
                                    radius: .absolute(radius),
                                    style: fillRoundingStyle
                                )
                            )
                            .inset(by: insetAmount)
                            .fill(Color.suBlack)
                    } else {
                        RoundedRectangle(
                            cornerRadius: radius,
                            style: swiftUIRoundedCornerStyle(for: fillRoundingStyle)
                        )
                        .inset(by: insetAmount)
                        .fill(Color.suBlack)
                    }

                    if outlineUsesCornerRectangle {
                        CornerRectangle()
                            .defaultCornerStyle(
                                .rounded(
                                    radius: .absolute(radius),
                                    style: outlineRoundingStyle
                                )
                            )
                            .inset(by: insetAmount)
                            .strokeBorder(Color.suPink.opacity(0.5), lineWidth: 2)
                    } else {
                        RoundedRectangle(
                            cornerRadius: radius,
                            style: swiftUIRoundedCornerStyle(for: outlineRoundingStyle)
                        )
                        .inset(by: insetAmount)
                        .strokeBorder(Color.suPink.opacity(0.5), lineWidth: 2)
                    }
                }
                .aspectRatio(1.5, contentMode: .fit)
                .padding()
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "Filled \(fillShapeName) with \(fillRoundingStyle.rawValue) corners, outlined \(outlineShapeName) with \(outlineRoundingStyle.rawValue) corners"
                )
                .accessibilityValue("Radius \(Int(radius)), inset \(Int(insetAmount))")

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
