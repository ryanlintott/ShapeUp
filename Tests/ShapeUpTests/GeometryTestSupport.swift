//
//  GeometryTestSupport.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-08-18.
//

import SwiftUI

/// Approximate comparisons and finiteness checks shared by the corner path and
/// inset test suites.
///
/// Both suites drive corners through 0 and 180 degrees, where exact equality is
/// never the right assertion, so they need the same handful of helpers.

extension CGPoint {
    var isFinite: Bool {
        x.isFinite && y.isFinite
    }

    func isApproximatelyEqual(to other: Self, tolerance: CGFloat) -> Bool {
        abs(x - other.x) <= tolerance && abs(y - other.y) <= tolerance
    }
}

extension CGFloat {
    func isApproximatelyEqual(to other: Self, tolerance: Self) -> Bool {
        abs(self - other) <= tolerance
    }
}

extension CGRect {
    /// A null rectangle is only approximately equal to another null rectangle,
    /// since it has no meaningful origin or size to compare.
    func isApproximatelyEqual(to other: Self, tolerance: CGFloat) -> Bool {
        if isNull || other.isNull {
            return isNull == other.isNull
        }

        return minX.isApproximatelyEqual(to: other.minX, tolerance: tolerance)
            && minY.isApproximatelyEqual(to: other.minY, tolerance: tolerance)
            && width.isApproximatelyEqual(to: other.width, tolerance: tolerance)
            && height.isApproximatelyEqual(to: other.height, tolerance: tolerance)
    }
}

extension Path {
    /// Every point named by the path's elements, including control points.
    var points: [CGPoint] {
        var points: [CGPoint] = []
        forEach { element in
            switch element {
            case let .move(to: point), let .line(to: point):
                points.append(point)
            case let .quadCurve(to: point, control: control):
                points.append(contentsOf: [point, control])
            case let .curve(to: point, control1: control1, control2: control2):
                points.append(contentsOf: [point, control1, control2])
            case .closeSubpath:
                break
            }
        }
        return points
    }

    /// A null bounding rect counts as finite; an empty path has no bounds to
    /// blow up.
    var hasFiniteBounds: Bool {
        let bounds = boundingRect
        return bounds.isNull || [
            bounds.minX,
            bounds.minY,
            bounds.width,
            bounds.height
        ].allSatisfy(\.isFinite)
    }
}
