//
//  CubicPathTestSupport.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-13.
//

import ShapeUp
import SwiftUI

enum CubicPathTestSupport {
    struct CubicBezierSegment {
        let start: CGPoint
        let end: CGPoint
        let control1: CGPoint
        let control2: CGPoint

        func point(at parameter: CGFloat) -> CGPoint {
            let inverse = 1 - parameter
            return .init(
                x: (pow(inverse, 3) * start.x)
                    + (3 * pow(inverse, 2) * parameter * control1.x)
                    + (3 * inverse * pow(parameter, 2) * control2.x)
                    + (pow(parameter, 3) * end.x),
                y: (pow(inverse, 3) * start.y)
                    + (3 * pow(inverse, 2) * parameter * control1.y)
                    + (3 * inverse * pow(parameter, 2) * control2.y)
                    + (pow(parameter, 3) * end.y)
            )
        }

        func derivative(at parameter: CGFloat) -> Vector2 {
            let inverse = 1 - parameter
            return (
                ((control1.vector - start.vector) * pow(inverse, 2))
                    + ((control2.vector - control1.vector) * (2 * inverse * parameter))
                    + ((end.vector - control2.vector) * pow(parameter, 2))
            ) * 3
        }

        func secondDerivative(at parameter: CGFloat) -> Vector2 {
            let inverse = 1 - parameter
            return ((
                (
                    control2.vector
                        - (control1.vector * 2)
                        + start.vector
                ) * inverse
            ) + (
                end.vector
                    - (control2.vector * 2)
                    + control1.vector
            ) * parameter) * 6
        }

        func curvatureRadius(at parameter: CGFloat) -> CGFloat {
            let derivative = derivative(at: parameter)
            let secondDerivative = secondDerivative(at: parameter)
            let crossProduct = abs(
                derivative.crossProduct(with: secondDerivative)
            )
            guard crossProduct > 1e-12 else { return .infinity }
            return pow(derivative.magnitude, 3) / crossProduct
        }
    }

    static func segments(in path: Path) -> [CubicBezierSegment] {
        var currentPoint = CGPoint.zero
        var segments: [CubicBezierSegment] = []

        path.forEach { element in
            switch element {
            case let .move(to: point), let .line(to: point):
                currentPoint = point
            case let .curve(to: end, control1: control1, control2: control2):
                segments.append(.init(
                    start: currentPoint,
                    end: end,
                    control1: control1,
                    control2: control2
                ))
                currentPoint = end
            case let .quadCurve(to: end, control: _):
                currentPoint = end
            case .closeSubpath:
                break
            }
        }

        return segments
    }

    static func distance(from point: CGPoint, to other: CGPoint) -> CGFloat {
        (point.vector - other.vector).magnitude
    }

    /// Returns the distance from a point to the nearest position on a polyline.
    ///
    /// Measuring against the whole polyline rather than matching parameters
    /// keeps this a test of shape, not of how a curve is parameterized.
    static func distance(from point: CGPoint, toPolyline polyline: [CGPoint]) -> CGFloat {
        zip(polyline, polyline.dropFirst())
            .map { distance(from: point, toSegmentFrom: $0, to: $1) }
            .min() ?? .infinity
    }

    static func distance(
        from point: CGPoint,
        toSegmentFrom start: CGPoint,
        to end: CGPoint
    ) -> CGFloat {
        let segment = end.vector - start.vector
        let lengthSquared = segment.magnitudeSquared
        guard lengthSquared > 0 else { return distance(from: point, to: start) }

        let offset = point.vector - start.vector
        let projection = (
            (offset.dx * segment.dx) + (offset.dy * segment.dy)
        ) / lengthSquared
        let clamped = min(max(projection, 0), 1)
        return (offset - (segment * clamped)).magnitude
    }

    static func distance(
        from point: CGPoint,
        toLineFrom start: CGPoint,
        through end: CGPoint
    ) -> CGFloat {
        let line = end.vector - start.vector
        guard line.magnitude > 0 else { return distance(from: point, to: start) }
        return abs(
            line.crossProduct(with: point.vector - start.vector)
        ) / line.magnitude
    }
}
