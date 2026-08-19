//
//  ContinuousCornerProfileSamplesTests.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-08-18.
//

#if os(macOS)
@testable import ShapeUp
import SwiftUI
import Testing

/// Checks the two measurements behind ``ContinuousCornerProfile``'s curvature:
/// that it matches the shape SwiftUI draws, and that the path elements it was
/// deliberately not derived from really are unusable for this representation.
struct ContinuousCornerProfileSamplesTests {
    /// The profile's 90-degree corner, measured from the corner point and
    /// divided by the radius, which is the frame the raster probe reports in.
    static func cornerOutline(radius: CGFloat = 20) -> [(x: Double, y: Double)] {
        let dimensions = Corner(
            .rounded(radius: .absolute(radius), style: .continuous),
            point: CGPoint(x: 100, y: 100)
        ).dimensions(
            previousPoint: CGPoint(x: 100, y: 0),
            nextPoint: CGPoint(x: 0, y: 100)
        )
        return (0...4000).map { step in
            let point = dimensions.continuousCornerPoint(at: CGFloat(step) / 4000)
            return (
                x: Double(abs(point.x - 100) / radius),
                y: Double(abs(point.y - 100) / radius)
            )
        }
    }

    /// The corner has to track the shape it was fitted to.
    ///
    /// Measured live rather than against stored numbers, so this stays honest if
    /// SwiftUI's rendering ever changes.
    @MainActor
    @Test("The corner matches the shape SwiftUI draws")
    func matchesRenderedShape() throws {
        guard #available(macOS 13, *) else { return }
        let measured = try ContinuousCornerRasterProbe.measuredCorner()
            .filter { $0.x > 0.01 && $0.y > 0.01 }
        let outline = Self.cornerOutline()

        let worst = measured.map { point in
            outline.map { hypot($0.x - point.x, $0.y - point.y) }.min() ?? .infinity
        }.max() ?? .infinity

        // The probe itself is good to about 0.0004, so the fit should be close
        // to that rather than merely in the right neighbourhood.
        #expect(worst < 0.001)
    }

    /// Why the curvature is fitted to the rendering rather than read off
    /// SwiftUI's path elements.
    ///
    /// The profile varies curvature smoothly between samples, so it cannot
    /// reproduce a curvature jump. Apple's path has one at each interior join,
    /// which rules that route out however exact those elements are.
    @Test("Path elements are not curvature continuous at their interior joins")
    func pathElementsHaveCurvatureJumps() throws {
        let radius: CGFloat = 100
        let path = RoundedRectangle(cornerRadius: radius, style: .continuous)
            .path(in: CGRect(x: 0, y: 0, width: 1000, height: 1000))

        // One corner's cubic segments, in units of the radius.
        var segments: [[CGPoint]] = []
        var current = CGPoint.zero
        path.forEach { element in
            switch element {
            case let .move(to: point): current = point
            case let .line(to: point): current = point
            case let .curve(to: point, control1: c1, control2: c2):
                if max(current.x, point.x) < 300, max(current.y, point.y) < 300 {
                    segments.append([current, c1, c2, point].map {
                        CGPoint(x: $0.x / radius, y: $0.y / radius)
                    })
                }
                current = point
            case let .quadCurve(to: point, control: _): current = point
            case .closeSubpath: break
            }
        }
        try #require(segments.count == 3)

        // Curvature of a cubic at its ends.
        func startCurvature(_ p: [CGPoint]) -> Double {
            let a = p[1].vector - p[0].vector, b = p[2].vector - p[1].vector
            return (2.0 / 3.0) * abs(a.crossProduct(with: b)) / pow(a.magnitude, 3)
        }
        func endCurvature(_ p: [CGPoint]) -> Double {
            let a = p[3].vector - p[2].vector, b = p[2].vector - p[1].vector
            return (2.0 / 3.0) * abs(a.crossProduct(with: b)) / pow(a.magnitude, 3)
        }

        // Where the corner meets its straight edges the curvature really is
        // zero, which is what makes it a continuous corner at all.
        #expect(startCurvature(segments[0]) < 1e-9)
        #expect(endCurvature(segments[2]) < 1e-9)

        // The two interior joins are a different matter.
        for index in 0..<2 {
            let before = endCurvature(segments[index])
            let after = startCurvature(segments[index + 1])
            let jump = abs(after - before) / max(before, after)
            #expect(jump > 0.3)
        }
    }
}
#endif
