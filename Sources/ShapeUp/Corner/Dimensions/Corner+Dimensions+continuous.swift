//
//  Corner+Dimensions+continuous.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-13.
//

import SwiftUI

extension Corner.Dimensions {
    /// The arc length of the corner curve.
    ///
    /// A circular corner has an arc length of `absoluteRadius * turnAngle`.
    /// This is the same law scaled by the profile constant, which is what keeps
    /// the corner's curvature, and so its visual radius, matched to a circular
    /// corner at every angle.
    private var continuousArcLength: CGFloat {
        ContinuousCornerProfile.arcLengthPerRadiusRadian * absoluteRadius * turnAngle.radians
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
    /// The turn angle in radians, signed so that reflex corners turn
    /// clockwise.
    ///
    /// ``ContinuousCornerProfile`` works in raw radians rather than ``Angle``
    /// since it's a self-contained numerical curve, not corner geometry.
    var signedTurnAngle: CGFloat {
        turnAngle.radians * reflexMultiplier
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
}
