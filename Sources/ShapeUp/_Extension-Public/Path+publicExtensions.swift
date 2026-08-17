//
//  Path+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-25.
//

import SwiftUI

public extension Path {
    /// Adds the shape described by an array of corners to a path.
    /// - Parameters:
    ///   - corners: Array of corners that define the shape to add.
    ///   - previousPoint: Previous point in the path used to determine the look of the first corner. Default is the last corner point.
    ///   - nextPoint: Next point in the path used to determine the look of the last corner. Default is the first corner point.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currently is to the first corner.
    mutating func addOpenCornerShape(
        _ corners: [Corner],
        previousPoint: CGPoint? = nil,
        nextPoint: CGPoint? = nil,
        moveToStart: Bool = true
    ) {
        addOpenCornerShape(
            previousPoint: previousPoint,
            nextPoint: nextPoint,
            moveToStart: moveToStart
        ) {
            corners
        }
    }
    
    /// Adds the shape described by an array of corners to a path.
    /// - Parameters:
    ///   - previousPoint: Previous point in the path used to determine the look of the first corner. Default is the last corner point.
    ///   - nextPoint: Next point in the path used to determine the look of the last corner. Default is the first corner point.
    ///   - moveToStart: An optional boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currently is to the first corner. If this value is nil it will be true if no current point exists on the path and false if one does.
    ///   - corners: Closure that returns an array of corners that define the shape to add.
    mutating func addOpenCornerShape(
        previousPoint: CGPoint? = nil,
        nextPoint: CGPoint? = nil,
        moveToStart: Bool? = nil,
        @CornerArrayBuilder _ corners: () -> [Corner]
    ) {
        let moveToStart = moveToStart ?? (currentPoint == nil)
        
        corners()
            .dimensions(
                previousPoint: previousPoint ?? (moveToStart ? nil : currentPoint),
                nextPoint: nextPoint
            )
            .addOpenCornerShape(to: &self, moveToStart: moveToStart)
    }
    
    /// Adds a closed shape described by an array of corners to a path.
    ///
    /// Moves to the start of the shape and then draws to the end
    /// - Parameters:
    ///  - corners: Array of corners that define the shape to add.
    mutating func addClosedCornerShape(_ corners: [Corner]) {
        addClosedCornerShape { corners }
    }
    
    /// Adds a closed shape described by an array of corners to a path.
    ///
    /// Moves to the start of the shape and then draws to the end
    /// - Parameters:
    ///  - corners: Closure that returns an array of corners that define the shape to add.
    mutating func addClosedCornerShape(@CornerArrayBuilder _ corners: () -> [Corner]) {
        corners().addCornerShape(to: &self)
    }

    /// Adds a continuous curve to the path, specified with a radius and two
    /// tangent lines.
    ///
    /// This mirrors `addArc(tangent1End:tangent2End:radius:transform:)`, but
    /// draws a continuous corner curve instead of a circular arc: a curve
    /// with the same nominal radius, fitted to SwiftUI's continuous rounded
    /// corner at 90 degrees and generalized to work at any angle with
    /// zero-curvature joins where it meets each tangent line. See
    /// ``CornerStyle/RoundingStyle/continuous`` for more on how the curve is
    /// defined.
    ///
    /// The current point, `tangent1End`, and `tangent2End` describe two
    /// tangent lines the same way they do for `addArc`. If the current point
    /// isn't already at the curve's starting tangent point, a straight line
    /// is added to it first. If there's no current point, this moves to
    /// `tangent1End` and returns without drawing a curve, the same as moving
    /// to the start of any other shape.
    ///
    /// - Note: A continuous curve reaches farther from `tangent1End` along
    ///   each tangent line than a circular arc with the same radius would.
    /// - Parameters:
    ///   - tangent1End: A point that, with the current point, defines the
    ///     first tangent line.
    ///   - tangent2End: A point that, with `tangent1End`, defines the second
    ///     tangent line.
    ///   - radius: The nominal radius of the curve.
    mutating func addContinuousCurve(
        tangent1End: CGPoint,
        tangent2End: CGPoint,
        radius: CGFloat
    ) {
        guard let currentPoint else {
            move(to: tangent1End)
            return
        }

        // Matching Corner.Dimensions' convention, where the corner turns from
        // the next point back to the previous point.
        let angle = Angle.threePoint(tangent2End, tangent1End, currentPoint)
        let halvedNonReflexAngle = Corner.Dimensions.halvedNonReflexAngle(angle: angle)
        let halvedTurnAngle = Corner.Dimensions.halvedTurnAngle(
            halvedNonReflexAngle: halvedNonReflexAngle
        )
        let reflexMultiplier = Corner.Dimensions.reflexMultiplier(angle: angle)

        let previousVector = currentPoint.vector - tangent1End.vector
        let cutLength = radius
            * abs(tan(halvedTurnAngle.radians))
            * Corner.Dimensions.continuousCutLengthMultiplier(for: angle)

        let curveStart = tangent1End.moved(previousVector.normalized * cutLength)

        // A relative tolerance well above Path's own coordinate storage
        // precision, since an already-correct current point read back from
        // the path can differ from a freshly recomputed one by more than
        // ordinary floating-point noise.
        let connectionTolerance = max(cutLength, radius, 1) * 1e-4
        if (curveStart.vector - currentPoint.vector).magnitude > connectionTolerance {
            addLine(to: curveStart)
        }

        ContinuousCornerProfile.addCurve(
            to: &self,
            from: curveStart,
            direction: (-previousVector).direction ?? .zero,
            turnAngle: halvedTurnAngle.doubled.radians * reflexMultiplier,
            radius: radius
        )
    }
}
