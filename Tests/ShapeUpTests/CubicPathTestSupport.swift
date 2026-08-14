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
