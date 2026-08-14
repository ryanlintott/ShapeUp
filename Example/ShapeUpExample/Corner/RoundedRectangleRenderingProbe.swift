//
//  RoundedRectangleRenderingProbe.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-14.
//

import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
struct RoundedRectangleRenderingProbe: View {
    enum Stage: String, CaseIterable, Identifiable {
        case direct
        case specializedPath
        case rebuiltPath
        case shapeUp

        var id: Self { self }

        var letter: String {
            switch self {
            case .direct: "A"
            case .specializedPath: "B"
            case .rebuiltPath: "C"
            case .shapeUp: "D"
            }
        }

        var title: String {
            switch self {
            case .direct: "Direct RoundedRectangle"
            case .specializedPath: "RoundedRectangle Path"
            case .rebuiltPath: "Rebuilt cubic Path"
            case .shapeUp: "ShapeUp fitted profile"
            }
        }
    }

    enum Comparison: String, CaseIterable, Identifiable {
        case directToSpecializedPath
        case specializedToRebuiltPath
        case rebuiltPathToShapeUp
        case directToShapeUp

        var id: Self { self }

        var label: String {
            "\(backgroundStage.letter)–\(foregroundStage.letter)"
        }

        var backgroundStage: Stage {
            switch self {
            case .directToSpecializedPath, .directToShapeUp: .direct
            case .specializedToRebuiltPath: .specializedPath
            case .rebuiltPathToShapeUp: .rebuiltPath
            }
        }

        var foregroundStage: Stage {
            switch self {
            case .directToSpecializedPath: .specializedPath
            case .specializedToRebuiltPath: .rebuiltPath
            case .rebuiltPathToShapeUp, .directToShapeUp: .shapeUp
            }
        }

        static let pipeline: [Self] = [
            .directToSpecializedPath,
            .specializedToRebuiltPath,
            .rebuiltPathToShapeUp
        ]
    }

    struct PixelDifference {
        let changedPixels: Int
        let materiallyChangedPixels: Int
        let maximumDifference: Int
    }

    struct AnalysisConfiguration: Hashable {
        let radius: CGFloat
        let insetAmount: CGFloat
        let offset: CGFloat
        let antialiased: Bool
        let displayScale: CGFloat
    }

    private let probeSide: CGFloat = 329
    private let probeMargin: CGFloat = 8

    @Environment(\.displayScale) private var displayScale

    @State private var selectedComparison = Comparison.directToShapeUp
    @State private var swapsLayers = true
    @State private var antialiased = false
    @State private var radius: CGFloat = 91
    @State private var insetAmount: CGFloat = 2
    @State private var offset: CGFloat = 0
    @State private var analysisResults: [Comparison: PixelDifference] = [:]
    @State private var analysisError: String?

    private var backgroundStage: Stage {
        swapsLayers
            ? selectedComparison.foregroundStage
            : selectedComparison.backgroundStage
    }

    private var foregroundStage: Stage {
        swapsLayers
            ? selectedComparison.backgroundStage
            : selectedComparison.foregroundStage
    }

    private var analysisConclusion: String {
        for comparison in Comparison.pipeline {
            if let result = analysisResults[comparison],
               result.materiallyChangedPixels > 0 {
                return "The first material pixel difference appears at \(comparison.label)."
            }
        }

        if let directDifference = analysisResults[.directToShapeUp],
           directDifference.materiallyChangedPixels > 0 {
            return "Only the combined A–D comparison has a material pixel difference."
        }

        if analysisResults.isEmpty {
            return "Run the independent mask analysis to locate the first differing stage."
        }

        return "No material pixel difference was found. Any reported changes are one grayscale step."
    }

    private var analysisConfiguration: AnalysisConfiguration {
        .init(
            radius: radius,
            insetAmount: insetAmount,
            offset: offset,
            antialiased: antialiased,
            displayScale: displayScale
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Compare each boundary between SwiftUI's direct `RoundedRectangle` renderer and ShapeUp's explicit cubic path. Pink shows where the background stage extends beyond the black foreground stage.")

                Text(analysisConclusion)
                    .font(.headline)

                GeometryReader { geometry in
                    let size = geometry.size

                    ZStack {
                        RoundedRectangleRenderingStageView(
                            stage: backgroundStage,
                            radius: radius,
                            insetAmount: insetAmount,
                            antialiased: antialiased,
                            color: .suPink
                        )
                        .offset(x: offset, y: offset)

                        RoundedRectangleRenderingStageView(
                            stage: foregroundStage,
                            radius: radius,
                            insetAmount: insetAmount,
                            antialiased: antialiased,
                            color: .suBlack
                        )
                        .offset(x: offset, y: offset)
                    }
                    .frame(width: size.width, height: size.height)
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .background(Color.suBlack)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "Rendering comparison \(backgroundStage.letter) behind \(foregroundStage.letter)"
                )

                Picker("Rendering Boundary", selection: $selectedComparison) {
                    ForEach(Comparison.allCases) { comparison in
                        Text(comparison.label).tag(comparison)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Swap foreground and background", isOn: $swapsLayers)
                Toggle("Antialias paths", isOn: $antialiased)

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

                CrossPlatformSlider(
                    label: "Fractional Offset",
                    value: $offset,
                    minValue: -0.5,
                    maxValue: 0.5,
                    step: 0.05,
                    labelPrefix: true
                )

                Button("Analyze Independent Masks", systemImage: "waveform.path.ecg") {
                    analyzeMasks()
                }
                .buttonStyle(.borderedProminent)

                GroupBox("Independent Mask Analysis") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(
                            "Rendered at \(probeSide, format: .number) pt and \(displayScale, format: .number)× display scale."
                        )
                        .font(.caption)

                        ForEach(Comparison.allCases) { comparison in
                            HStack(alignment: .firstTextBaseline) {
                                Text(comparison.label)
                                    .fontWeight(.semibold)

                                Spacer()

                                if let result = analysisResults[comparison] {
                                    Text(
                                        "\(result.materiallyChangedPixels) material, \(result.changedPixels) total, max \(result.maximumDifference)"
                                    )
                                    .monospacedDigit()
                                } else {
                                    Text("Not analyzed")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.caption)
                        }

                        if let analysisError {
                            Text(analysisError)
                                .foregroundStyle(.red)
                        } else {
                            Text(analysisConclusion)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Stage.allCases) { stage in
                        Text("**\(stage.letter):** \(stage.title)")
                    }
                }
            }
            .padding()
        }
        .accentColor(.suPink)
        .navigationTitle("Rendering Probe")
        .task(id: analysisConfiguration) {
            analysisResults = [:]
            analysisError = nil
            try? await Task.sleep(for: .milliseconds(200))
            guard Task.isCancelled == false else { return }
            analyzeMasks()
        }
    }

    private func analyzeMasks() {
        var masks: [Stage: [UInt8]] = [:]
        for stage in Stage.allCases {
            guard let mask = renderedMask(for: stage) else {
                analysisResults = [:]
                analysisError = "ImageRenderer could not create every stage mask."
                return
            }
            masks[stage] = mask
        }

        analysisResults = Dictionary(uniqueKeysWithValues: Comparison.allCases.compactMap {
            guard
                let background = masks[$0.backgroundStage],
                let foreground = masks[$0.foregroundStage]
            else {
                return nil
            }
            return ($0, difference(between: background, and: foreground))
        })
        analysisError = nil
    }

    private func renderedMask(for stage: Stage) -> [UInt8]? {
        let canvasSide = probeSide + (probeMargin * 2)
        let renderer = ImageRenderer(
            content: RoundedRectangleRenderingStageView(
                stage: stage,
                radius: radius,
                insetAmount: insetAmount,
                antialiased: antialiased,
                color: .white
            )
            .frame(width: probeSide, height: probeSide)
            .offset(x: offset, y: offset)
            .frame(width: canvasSide, height: canvasSide)
            .background(.black)
        )
        renderer.scale = displayScale
        guard let image = renderer.cgImage else { return nil }

        let width = image.width
        let height = image.height
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }
        context.setFillColor(gray: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.draw(
            image,
            in: CGRect(x: 0, y: 0, width: width, height: height)
        )
        guard let data = context.data else { return nil }

        return Array(
            UnsafeBufferPointer(
                start: data.assumingMemoryBound(to: UInt8.self),
                count: width * height
            )
        )
    }

    private func difference(
        between lhs: [UInt8],
        and rhs: [UInt8]
    ) -> PixelDifference {
        guard lhs.count == rhs.count else {
            return .init(
                changedPixels: max(lhs.count, rhs.count),
                materiallyChangedPixels: max(lhs.count, rhs.count),
                maximumDifference: 255
            )
        }

        var changedPixels = 0
        var materiallyChangedPixels = 0
        var maximumDifference = 0
        for (left, right) in zip(lhs, rhs) {
            let difference = abs(Int(left) - Int(right))
            if difference > 0 { changedPixels += 1 }
            if difference > 1 { materiallyChangedPixels += 1 }
            maximumDifference = max(maximumDifference, difference)
        }

        return .init(
            changedPixels: changedPixels,
            materiallyChangedPixels: materiallyChangedPixels,
            maximumDifference: maximumDifference
        )
    }
}

#Preview {
    if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
        NavigationView {
            RoundedRectangleRenderingProbe()
        }
    } else {
        Text("Rendering probe requires a newer OS.")
    }
}
