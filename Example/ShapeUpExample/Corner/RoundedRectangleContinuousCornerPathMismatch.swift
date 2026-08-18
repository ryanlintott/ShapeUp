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
//
// Three layers are stacked back to front:
//   pink   - the path rebuilt from the elements `Path.forEach` reports
//   cyan   - the true continuous path from private CoreGraphics
//   black  - the `RoundedRectangle` path drawn directly
//
// Cyan showing means the reported elements are geometrically wrong.
// Pink showing where cyan does not means SwiftUI rasterizes its own
// `.roundedRect` storage differently from any explicit element list.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
struct RoundedRectangleContinuousCornerPathMismatch: View {
    @State private var radius: CGFloat = 91
    @State private var antialiased = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
"""
Continuous corners drawn directly do not match path elements.

Pink shows the path rebuilt from the elements SwiftUI reports. Cyan shows the true continuous path from private CoreGraphics. Black is the RoundedRectangle drawn directly.
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
                
                if let truePath = Path.trueContinuousRoundedRect(in: rect, cornerRadius: radius) {
                    truePath
                        .fill(
                            .suCyan,
                            style: FillStyle(antialiased: antialiased)
                        )
                }
                
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
    /// The true continuous rounded rectangle path, the one Core Animation uses for
    /// `CACornerCurve.continuous` and the one SwiftUI's renderer draws.
    ///
    /// The elements reported by `Path.forEach` match this exactly until the corner
    /// radius passes `min(width, height) / 2 / 1.528665`, the point where adjacent
    /// corners start to overlap. Past that the reported elements clamp to a flat
    /// tangent at the midpoint while the real path blends the two corners together.
    ///
    /// - Warning: This calls a private CoreGraphics symbol. It is here to work out
    ///   what the real path is, and must not ship in the ShapeUp package itself.
    static func trueContinuousRoundedRect(in rect: CGRect, cornerRadius: CGFloat) -> Path? {
        typealias MakePath = @convention(c) (CGRect, CGFloat, CGFloat, UnsafePointer<CGAffineTransform>?) -> Unmanaged<CGPath>?
        
        guard
            let handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_LAZY),
            let symbol = dlsym(handle, "CGPathCreateWithContinuousRoundedRect")
        else { return nil }
        
        let makePath = unsafeBitCast(symbol, to: MakePath.self)
        let radius = min(cornerRadius, min(rect.width, rect.height) / 2)
        
        guard let cgPath = makePath(rect, radius, radius, nil)?.takeRetainedValue() else { return nil }
        
        return Path(cgPath)
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
