//
//  Corner+Dimensions+continuous.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-13.
//

import SwiftUI

extension Corner.Dimensions {
    /// Adds a continuous corner.
    ///
    /// A symmetric curvature profile fitted to SwiftUI's continuous rounded 90-degree
    /// corner. Scaling its tangent rotation and
    /// arc length by the requested turning angle produces an intrinsic curve
    /// without shearing the reference profile. The result retains the measured
    /// curvature scale and zero-curvature edge joins at every angle.
    internal func addContinuousCorner(to path: inout Path) {
        let radiusAngle = abs(halvedRadiusAngle.radians * 2)

        let segmentCount = 16
        let segmentSpan = 1 / CGFloat(segmentCount)
        let normalizedCutLength = Self.normalizedContinuousCutLength(
            radiusAngle: radiusAngle
        )
        let scale = normalizedCutLength > 1e-12
            ? cutLength / normalizedCutLength
            : 0
        let samples = (0...segmentCount).map {
            continuousCornerSample(
                at: CGFloat($0) * segmentSpan,
                radiusAngle: radiusAngle,
                scale: scale
            )
        }

        for index in 0..<segmentCount {
            let start = samples[index]
            let end = samples[index + 1]
            var control1 = start.point.moved(
                start.derivative * (segmentSpan / 3)
            )
            var control2 = end.point.moved(
                -end.derivative * (segmentSpan / 3)
            )

            if index == 0 {
                control2 = start.tangentIntersection(with: end) ?? control2
            } else if index == segmentCount - 1 {
                control1 = start.tangentIntersection(with: end) ?? control1
            }

            path.addCurve(
                to: end.point,
                control1: control1,
                control2: control2
            )
        }
    }

    /// Returns the edge-length ratio between an intrinsic continuous corner and
    /// a circular corner with the same nominal radius and angle.
    internal static func continuousCutLengthMultiplier(for angle: Angle) -> CGFloat {
        let cornerAngle = angle.nonReflexCoterminal.positive.radians
        let radiusAngle = min(max(.pi - cornerAngle, 0), .pi)

        if radiusAngle <= 1e-12 {
            return straightCornerCutLengthMultiplier
        }

        if .pi - radiusAngle <= 1e-12 {
            return zeroCornerCutLengthMultiplier
        }

        let circularCutLength = tan(radiusAngle / 2)
        let continuousCutLength = continuousCutLengthPerRadius
            * normalizedContinuousCutLength(radiusAngle: radiusAngle)
        return continuousCutLength / circularCutLength
    }

    /// Returns a point on the intrinsic curve before cubic approximation.
    internal func continuousCornerPoint(at parameter: CGFloat) -> CGPoint {
        let radiusAngle = abs(halvedRadiusAngle.radians * 2)
        let normalizedCutLength = Self.normalizedContinuousCutLength(
            radiusAngle: radiusAngle
        )
        let scale = normalizedCutLength > 1e-12
            ? cutLength / normalizedCutLength
            : 0
        return continuousCornerSample(
            at: parameter,
            radiusAngle: radiusAngle,
            scale: scale
        ).point
    }
}

private extension Corner.Dimensions {
    /// Edge length at SwiftUI's measured 90-degree constraint threshold for a
    /// nominal radius of one point.
    static let continuousCutLengthPerRadius: CGFloat = 1.5286649465560913

    /// Cut-length multiplier at a straight corner, where the turning angle is
    /// zero.
    static let straightCornerCutLengthMultiplier =
        continuousCutLengthPerRadius
        * 2
        * normalizedStraightCutLengthSlope

    /// Cut-length multiplier at a zero-degree corner, where the turning angle
    /// is 180 degrees.
    static let zeroCornerCutLengthMultiplier: CGFloat = {
        let end = integratedContinuousVector(
            through: 1,
            signedRadiusAngle: .pi
        )
        return continuousCutLengthPerRadius * end.dy / 2
    }()

    /// Curvature samples fitted to an unconstrained 128-point SwiftUI corner
    /// rendered at 8x across four quarter-pixel phases. The samples are
    /// symmetric, and their zero endpoints produce zero-curvature edge joins.
    static let referenceCurvatureSamples: [CGFloat] = [
        0,
        0.126143061267713,
        0.130089752883054,
        0.612090852614914,
        0.877096759961826,
        1.5369790112525,
        2.0743885519563,
        1.77042874091634,
        1.72155742814922,
        1.77042874091634,
        2.0743885519563,
        1.5369790112525,
        0.877096759961826,
        0.612090852614914,
        0.130089752883054,
        0.126143061267713,
        0
    ]

    static let referenceParameterNodes: [CGFloat] =
        referenceCurvatureSamples.indices.map {
            CGFloat($0) / CGFloat(referenceCurvatureSamples.count - 1)
        }

    static let referenceCurvatureIntegral = integratedReferenceCurvature(
        through: 1
    )

    /// Normalizes the 90-degree profile endpoint to `(1, 1)`.
    static let normalizedReferenceSpeed: CGFloat = {
        let end = integratedUnitReferenceVector(through: 1)
        return 2 / (end.dx + end.dy)
    }()

    /// Nodes and weights for eight-point Gauss-Legendre integration.
    static let integrationNodes: [CGFloat] = [
        -0.9602898564975363,
        -0.7966664774136267,
        -0.525532409916329,
        -0.1834346424956498,
        0.1834346424956498,
        0.525532409916329,
        0.7966664774136267,
        0.9602898564975363
    ]

    static let integrationWeights: [CGFloat] = [
        0.1012285362903763,
        0.2223810344533745,
        0.3137066458778873,
        0.362683783378362,
        0.362683783378362,
        0.3137066458778873,
        0.2223810344533745,
        0.1012285362903763
    ]

    /// Evaluates the intrinsic continuous corner and its derivative.
    func continuousCornerSample(
        at parameter: CGFloat,
        radiusAngle: CGFloat,
        scale: CGFloat
    ) -> CurveSample {
        let signedRadiusAngle = radiusAngle * reflexMultiplier
        let rotation = startVector.direction ?? .zero
        let localPoint = Self.integratedContinuousVector(
            through: parameter,
            signedRadiusAngle: signedRadiusAngle
        )
        let localDerivative = Self.continuousDerivative(
            at: parameter,
            signedRadiusAngle: signedRadiusAngle
        )

        return CurveSample(
            point: cornerStart.moved(
                (localPoint * scale).rotated(rotation)
            ),
            derivative: (localDerivative * scale).rotated(rotation)
        )
    }

    static func normalizedContinuousCutLength(radiusAngle: CGFloat) -> CGFloat {
        guard radiusAngle > 1e-12 else { return 0 }

        if radiusAngle < 1e-6 {
            return radiusAngle * normalizedStraightCutLengthSlope
        }

        let end = integratedContinuousVector(
            through: 1,
            signedRadiusAngle: radiusAngle
        )
        let radiusAngleSine = sin(radiusAngle)
        guard abs(radiusAngleSine) > 1e-12 else { return .infinity }
        return end.dx - (end.dy * cos(radiusAngle) / radiusAngleSine)
    }

    static var normalizedStraightCutLengthSlope: CGFloat {
        let length = integratedReferenceValue { derivative in
            derivative.magnitude
        }
        let tangentMoment = integratedReferenceValue { derivative in
            derivative.magnitude * atan2(derivative.dy, derivative.dx)
        }
        return ((2 / .pi) * length)
            - ((4 / (.pi * .pi)) * tangentMoment)
    }

    /// Integrates the transformed reference velocity to produce a point on the
    /// normalized curve.
    static func integratedContinuousVector(
        through parameter: CGFloat,
        signedRadiusAngle: CGFloat
    ) -> Vector2 {
        integratedReferenceVector(through: parameter) { derivative in
            // Applying the same factor to tangent rotation and arc length keeps
            // curvature (turning per unit length) at the reference scale.
            let angleScale = signedRadiusAngle / (.pi / 2)
            let targetTangent = atan2(derivative.dy, derivative.dx)
                * angleScale
            let targetSpeed = derivative.magnitude * abs(angleScale)
            return Vector2(
                dx: targetSpeed * cos(targetTangent),
                dy: targetSpeed * sin(targetTangent)
            )
        }
    }

    static func continuousDerivative(
        at parameter: CGFloat,
        signedRadiusAngle: CGFloat
    ) -> Vector2 {
        let derivative = referenceDerivative(at: parameter)
        let angleScale = signedRadiusAngle / (.pi / 2)
        let targetTangent = atan2(derivative.dy, derivative.dx)
            * angleScale
        let targetSpeed = derivative.magnitude * abs(angleScale)
        return Vector2(
            dx: targetSpeed * cos(targetTangent),
            dy: targetSpeed * sin(targetTangent)
        )
    }

    static func referenceDerivative(at parameter: CGFloat) -> Vector2 {
        unitReferenceDerivative(at: parameter) * normalizedReferenceSpeed
    }

    static func unitReferenceDerivative(at parameter: CGFloat) -> Vector2 {
        let tangent = referenceTangentFraction(at: parameter) * (.pi / 2)
        return Vector2(dx: cos(tangent), dy: sin(tangent))
    }

    static func referenceTangentFraction(at parameter: CGFloat) -> CGFloat {
        integratedReferenceCurvature(through: parameter)
            / referenceCurvatureIntegral
    }

    static func integratedReferenceCurvature(
        through parameter: CGFloat
    ) -> CGFloat {
        let upperBound = min(max(parameter, 0), 1)
        var result: CGFloat = 0

        for index in 0..<(referenceParameterNodes.count - 1) {
            let lower = referenceParameterNodes[index]
            let upper = referenceParameterNodes[index + 1]
            guard upperBound > lower else { break }

            let span = min(upperBound, upper) - lower
            let nodeSpan = upper - lower
            let lowerCurvature = referenceCurvatureSamples[index]
            let curvatureSlope = (
                referenceCurvatureSamples[index + 1] - lowerCurvature
            ) / nodeSpan
            result += (lowerCurvature * span)
                + (curvatureSlope * span * span / 2)

            if upperBound <= upper { break }
        }
        return result
    }

    static func integratedUnitReferenceVector(
        through parameter: CGFloat
    ) -> Vector2 {
        let upperBound = min(max(parameter, 0), 1)
        guard upperBound > 0 else { return .zero }

        var result = Vector2.zero
        for index in 0..<(referenceParameterNodes.count - 1) {
            let lower = referenceParameterNodes[index]
            let upper = min(referenceParameterNodes[index + 1], upperBound)
            guard upper > lower else { continue }
            result += integrateVector(from: lower, to: upper) {
                unitReferenceDerivative(at: $0)
            }
            if upper == upperBound { break }
        }
        return result
    }

    static func integratedReferenceVector(
        through parameter: CGFloat,
        transform: (Vector2) -> Vector2
    ) -> Vector2 {
        let upperBound = min(max(parameter, 0), 1)
        guard upperBound > 0 else { return .zero }

        var result = Vector2.zero
        let breakpoints = referenceParameterNodes
        for index in 0..<(breakpoints.count - 1) {
            let lower = breakpoints[index]
            let upper = min(breakpoints[index + 1], upperBound)
            guard upper > lower else { continue }
            result += integrateVector(from: lower, to: upper) {
                transform(referenceDerivative(at: $0))
            }
            if upper == upperBound { break }
        }
        return result
    }

    static func integratedReferenceValue(
        transform: (Vector2) -> CGFloat
    ) -> CGFloat {
        var result: CGFloat = 0
        let breakpoints = referenceParameterNodes
        for index in 0..<(breakpoints.count - 1) {
            result += integrateValue(
                from: breakpoints[index],
                to: breakpoints[index + 1]
            ) {
                transform(referenceDerivative(at: $0))
            }
        }
        return result
    }

    static func integrateVector(
        from lowerBound: CGFloat,
        to upperBound: CGFloat,
        value: (CGFloat) -> Vector2
    ) -> Vector2 {
        let midpoint = (lowerBound + upperBound) / 2
        let halfSpan = (upperBound - lowerBound) / 2
        return zip(integrationNodes, integrationWeights).reduce(.zero) {
            $0 + (value(midpoint + (halfSpan * $1.0)) * $1.1)
        } * halfSpan
    }

    static func integrateValue(
        from lowerBound: CGFloat,
        to upperBound: CGFloat,
        value: (CGFloat) -> CGFloat
    ) -> CGFloat {
        let midpoint = (lowerBound + upperBound) / 2
        let halfSpan = (upperBound - lowerBound) / 2
        return zip(integrationNodes, integrationWeights).reduce(0) {
            $0 + (value(midpoint + (halfSpan * $1.0)) * $1.1)
        } * halfSpan
    }
}

private struct CurveSample {
    let point: CGPoint
    let derivative: Vector2

    func tangentIntersection(with other: Self) -> CGPoint? {
        let denominator = derivative.crossProduct(with: other.derivative)
        guard abs(denominator) > 1e-12 else { return nil }

        let tangentScale = (other.point.vector - point.vector)
            .crossProduct(with: other.derivative) / denominator
        return point.moved(derivative * tangentScale)
    }
}
