//
//  RoundedRectangleRenderingStageView.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-14.
//

import ShapeUp
import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
struct RoundedRectangleRenderingStageView: View {
    let stage: RoundedRectangleRenderingProbe.Stage
    let radius: CGFloat
    let insetAmount: CGFloat
    let antialiased: Bool
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let rect = CGRect(origin: .zero, size: geometry.size)

            switch stage {
            case .direct:
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .inset(by: insetAmount)
                    .fill(
                        color,
                        style: FillStyle(antialiased: antialiased)
                    )
            case .specializedPath:
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .inset(by: insetAmount)
                    .path(in: rect)
                    .fill(
                        color,
                        style: FillStyle(antialiased: antialiased)
                    )
            case .rebuiltPath:
                rebuiltPath(
                    from: RoundedRectangle(
                        cornerRadius: radius,
                        style: .continuous
                    )
                    .inset(by: insetAmount)
                    .path(in: rect)
                )
                .fill(
                    color,
                    style: FillStyle(antialiased: antialiased)
                )
            case .shapeUp:
                CornerRectangle()
                    .defaultCornerStyle(
                        .rounded(radius: .absolute(radius), style: .continuous)
                    )
                    .inset(by: insetAmount)
                    .fill(
                        color,
                        style: FillStyle(antialiased: antialiased)
                    )
            }
        }
    }

    private func rebuiltPath(from source: Path) -> Path {
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
}
