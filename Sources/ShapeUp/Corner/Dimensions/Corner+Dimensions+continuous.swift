//
//  Corner+Dimensions+continuous.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-13.
//

import SwiftUI

extension Corner.Dimensions {
    /// The angle the corner curve turns through.
    ///
    /// Zero at a straight corner and 180 degrees at a zero-degree corner.
    internal var turnAngle: CGFloat {
        abs(halvedRadiusAngle.radians * 2)
    }

    /// The arc length of the corner curve.
    ///
    /// A circular corner has an arc length of `absoluteRadius * turnAngle`.
    /// This is the same law scaled by the profile constant, which is what keeps
    /// the corner's curvature, and so its visual radius, matched to a circular
    /// corner at every angle.
    private var continuousArcLength: CGFloat {
        ContinuousCornerProfile.arcLengthPerRadiusRadian * absoluteRadius * turnAngle
    }

    /// Adds a continuous corner.
    ///
    /// The corner is a length of ``ContinuousCornerProfile`` positioned in this
    /// corner, then approximated by evenly spaced cubic curves.
    internal func addContinuousCorner(to path: inout Path) {
        let segmentCount = 16
        let samples = continuousCornerSamples(count: segmentCount)
        // A cubic matching the curve's tangents spans a third of a segment.
        let controlLength = continuousArcLength / CGFloat(segmentCount * 3)

        for index in 0..<segmentCount {
            let start = samples[index]
            let end = samples[index + 1]
            var control1 = start.point.moved(start.tangent * controlLength)
            var control2 = end.point.moved(-end.tangent * controlLength)

            // The profile starts and ends with zero curvature. Placing both
            // control points of the first and last segments on their edge line
            // carries that through to the cubic, so the corner meets its edges
            // without a curvature jump.
            if index == 0 {
                control2 = start.tangentIntersection(with: end) ?? control2
            } else if index == segmentCount - 1 {
                control1 = start.tangentIntersection(with: end) ?? control1
            }

            path.addCurve(to: end.point, control1: control1, control2: control2)
        }
    }

    /// Returns a point on the corner curve before its cubic approximation.
    /// - Parameter parameter: Position along the curve as a fraction of its arc
    ///   length.
    /// - Returns: A point on the corner curve.
    internal func continuousCornerPoint(at parameter: CGFloat) -> CGPoint {
        let offset = ContinuousCornerProfile.offset(
            at: parameter,
            turnAngle: signedTurnAngle
        )
        return positioned(offset: offset)
    }

    /// Returns the edge-length ratio between a continuous corner and a circular
    /// corner with the same nominal radius and angle.
    /// - Parameter angle: Corner angle.
    /// - Returns: A multiple of the circular corner's edge length.
    internal static func continuousCutLengthMultiplier(for angle: Angle) -> CGFloat {
        let cornerAngle = angle.nonReflexCoterminal.positive.radians
        return ContinuousCornerProfile.cutLengthMultiplier(
            turnAngle: min(max(.pi - cornerAngle, 0), .pi)
        )
    }
}

private extension Corner.Dimensions {
    /// The turn angle signed so that reflex corners turn clockwise.
    var signedTurnAngle: CGFloat {
        turnAngle * reflexMultiplier
    }

    /// The rotation from the profile's reference frame into this corner.
    var profileRotation: Angle {
        startVector.direction ?? .zero
    }

    /// Returns a profile offset positioned in this corner.
    /// - Parameter offset: An offset as a fraction of the curve's arc length.
    /// - Returns: A point on the corner curve.
    func positioned(offset: Vector2) -> CGPoint {
        cornerStart.moved((offset * continuousArcLength).rotated(profileRotation))
    }

    /// Returns evenly spaced points and unit tangents along the corner curve.
    /// - Parameter count: The number of equal spans to divide the curve into.
    ///   One more sample than this is returned.
    /// - Returns: Points on the corner curve paired with unit tangents.
    func continuousCornerSamples(count: Int) -> [CurveSample] {
        let rotation = profileRotation

        return ContinuousCornerProfile
            .samples(count: count, turnAngle: signedTurnAngle)
            .map {
                CurveSample(
                    point: positioned(offset: $0.offset),
                    tangent: $0.tangent.rotated(rotation)
                )
            }
    }
}

private struct CurveSample {
    let point: CGPoint
    let tangent: Vector2

    /// Returns the point where this sample's tangent line crosses another's.
    ///
    /// A nil value means the two tangents are parallel.
    /// - Parameter other: Another sample on the same curve.
    /// - Returns: The point where the two tangent lines cross.
    func tangentIntersection(with other: Self) -> CGPoint? {
        let denominator = tangent.crossProduct(with: other.tangent)
        guard abs(denominator) > 1e-12 else { return nil }

        let tangentScale = (other.point.vector - point.vector)
            .crossProduct(with: other.tangent) / denominator
        return point.moved(tangent * tangentScale)
    }
}
