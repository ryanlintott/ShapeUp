//
//  RoundedRectangleContinuousCornerPathMismatch.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-17.
//

import SwiftUI

// FEEDBACK REPRODUCTION CASE
//
// `RoundedRectangle(cornerRadius:style: .continuous).path(in:)` renders
// differently depending on whether the returned `Path` is used directly
// or rebuilt from its own elements (via `Path.forEach`) into a brand new
// `Path` containing the exact same sequence of moves/lines/curves.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
struct RoundedRectangleContinuousCornerPathMismatch: View {
    @State private var radius: CGFloat = 91
    @State private var antialiased = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
"""
Continuous corners drawn directly do not match path elements.

The visible pink edges show the difference between a RoundedRectangle with continuous corners and the exact path elements for that same rounded rectangle.
"""
            )
            .font(.callout)
            
            GeometryReader { geometry in
                let rect = CGRect(origin: .zero, size: geometry.size)
                
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .path(in: rect)
                    .rebuiltFromElements()
                    .fill(
                        .suPink,
                        style: FillStyle(antialiased: antialiased)
                    )
                
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .path(in: rect)
                    .fill(
                        .suBlack,
                        style: FillStyle(antialiased: antialiased)
                    )
            }
            .padding()
            .background(.suBlack)
                        
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Radius: \(radius, format: .number)")
                    Slider(value: $radius, in: 0...100, step: 1)
                }
                
                Toggle("Antialiased", isOn: $antialiased)
            }
        }
        
        .padding()
        .navigationTitle("Continuous Corner Path")
    }
}

extension Path {
    func rebuiltFromElements() -> Path {
        var newPath: Path = .init()
        
        forEach { element in
            switch element {
            case let .move(to: point):
                newPath.move(to: point)
            case let .line(to: point):
                newPath.addLine(to: point)
            case let .quadCurve(to: point, control: control):
                newPath.addQuadCurve(to: point, control: control)
            case let .curve(to: point, control1: control1, control2: control2):
                newPath.addCurve(to: point, control1: control1, control2: control2)
            case .closeSubpath:
                newPath.closeSubpath()
            }
        }
        
        return newPath
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
#Preview {
    NavigationView {
        RoundedRectangleContinuousCornerPathMismatch()
    }
}
