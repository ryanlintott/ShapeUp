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
    /// A symmetric superformula curve supplies zero endpoint curvature. A
    /// smooth calibration towards SwiftUI's measured continuous profile makes
    /// the 90-degree result exact. Other angles use a fixed cubic approximation
    /// that preserves the blended curve's zero-curvature edge joins and
    /// degenerate limits.
    ///
    /// The superformula construction is based on Máté Homolya's continuous
    /// curvature notes: https://observablehq.com/@mateh/continuous-curvature
    internal func addContinuousCorner(to path: inout Path) {
        let radiusAngle = abs(halvedRadiusAngle.radians * 2)

        if abs(radiusAngle - (.pi / 2)) <= 1e-12 {
            addSwiftUIContinuousProfile(to: &path)
            return
        }

        let segmentCount = 8
        let segmentSpan = 1 / CGFloat(segmentCount)
        let samples = (0...segmentCount).map {
            continuousCornerSample(at: CGFloat($0) * segmentSpan)
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

    /// Amount of SwiftUI's measured 90-degree continuous profile used at an angle.
    internal static func swiftUIContinuousProfileBlendAmount(
        for angle: Angle
    ) -> CGFloat {
        pow(sin(angle.radians), 2)
    }

    /// Returns a point on the calibrated curve before cubic approximation.
    internal func continuousCornerPoint(at parameter: CGFloat) -> CGPoint {
        continuousCornerSample(at: parameter).point
    }
}

private extension Corner.Dimensions {
    static let swiftUIContinuousProfileSegments: [CubicBezierSegment] = [
        .init(
            start: CGPoint(x: 0, y: 0),
            control1: CGPoint(x: 0.287947295605812, y: 0),
            control2: CGPoint(x: 0.431918019060667, y: 0),
            end: CGPoint(x: 0.586898367051846, y: 0.049004460293631)
        ),
        .init(
            start: CGPoint(x: 0.586898367051846, y: 0.049004460293631),
            control1: CGPoint(x: 0.756111361045391, y: 0.110593238314637),
            control2: CGPoint(x: 0.889406761685363, y: 0.243888638954609),
            end: CGPoint(x: 0.950995539706369, y: 0.413101632948154)
        ),
        .init(
            start: CGPoint(x: 0.950995539706369, y: 0.413101632948154),
            control1: CGPoint(x: 1, y: 0.568081980939333),
            control2: CGPoint(x: 1, y: 0.712052704394188),
            end: CGPoint(x: 1, y: 1)
        )
    ]

    /// Segment parameter spans make the measured SwiftUI continuous-profile
    /// cubics C1 when evaluated as one normalized curve.
    static let swiftUIContinuousProfileParameterBreakpoints: [CGFloat] = [
        0,
        0.3217664000779776,
        0.6782335999220224,
        1
    ]

    /// The symmetric superformula component exponent that best fits SwiftUI's
    /// normalized 90-degree continuous profile while retaining zero endpoint
    /// curvature.
    static let superformulaComponentExponent: CGFloat = 3.345

    /// Adds the captured three-cubic SwiftUI continuous profile without approximation.
    func addSwiftUIContinuousProfile(to path: inout Path) {
        let cornerFrame = frame

        for segment in Self.swiftUIContinuousProfileSegments {
            path.addCurve(
                to: cornerFrame[segment.end.x, segment.end.y],
                control1: cornerFrame[
                    segment.control1.x,
                    segment.control1.y
                ],
                control2: cornerFrame[
                    segment.control2.x,
                    segment.control2.y
                ]
            )
        }
    }

    /// Evaluates the continuous corner and its derivative by blending a
    /// symmetric superformula curve with SwiftUI's continuous profile.
    func continuousCornerSample(at parameter: CGFloat) -> CurveSample {
        let radiusAngle = abs(halvedRadiusAngle.radians * 2)
        let signedRadiusAngle = radiusAngle * reflexMultiplier
        let rotation = (startVector.direction ?? .zero)
            - .degrees(90 * reflexMultiplier)
        let halfRadiusAngleTangent = tan(halvedRadiusAngle.radians)
        let baseRadius = abs(halfRadiusAngleTangent) > 1e-12
            ? cutLength / halfRadiusAngleTangent
            : 0

        let componentExponent = Self.superformulaComponentExponent
        let angularFrequency = (2 * .pi) / radiusAngle
        let radialExponent = (
            componentExponent * angularFrequency * angularFrequency
        ) / 16
        let phase = parameter * (.pi / 2)
        let cosine = max(cos(phase), 0)
        let sine = max(sin(phase), 0)
        let cosinePower = pow(cosine, componentExponent)
        let sinePower = pow(sine, componentExponent)
        let sum = cosinePower + sinePower
        let radialScale = pow(sum, -1 / radialExponent)
        let phaseDerivative = CGFloat.pi / 2
        let sumDerivative = componentExponent * phaseDerivative * (
            (pow(sine, componentExponent - 1) * cosine)
                - (pow(cosine, componentExponent - 1) * sine)
        )
        let radialScaleDerivative = radialScale
            * (-1 / radialExponent)
            * (sumDerivative / sum)
        let theta = parameter * signedRadiusAngle
        let thetaDerivative = signedRadiusAngle
        let localPoint = Vector2(
            dx: baseRadius * ((radialScale * cos(theta)) - 1),
            dy: baseRadius * radialScale * sin(theta)
        )
        let localDerivative = Vector2(
            dx: baseRadius * (
                (radialScaleDerivative * cos(theta))
                    - (radialScale * thetaDerivative * sin(theta))
            ),
            dy: baseRadius * (
                (radialScaleDerivative * sin(theta))
                    + (radialScale * thetaDerivative * cos(theta))
            )
        )
        let superformulaSample = CurveSample(
            point: cornerStart.moved(localPoint.rotated(rotation)),
            derivative: localDerivative.rotated(rotation)
        )
        let swiftUIContinuousProfileSample = swiftUIContinuousProfileSample(at: parameter)

        // This calibration is exact at 90 degrees and fades with zero slope at
        // both degenerate limits, where the superformula curve is authoritative.
        let swiftUIContinuousProfileBlendAmount = Self.swiftUIContinuousProfileBlendAmount(for: angle)
        return superformulaSample.interpolated(
            towards: swiftUIContinuousProfileSample,
            amount: swiftUIContinuousProfileBlendAmount
        )
    }

    /// Evaluates SwiftUI's normalized 90-degree continuous cubic profile after
    /// mapping it into the supplied corner's coordinate frame.
    func swiftUIContinuousProfileSample(
        at parameter: CGFloat
    ) -> CurveSample {
        let breakpoints = Self.swiftUIContinuousProfileParameterBreakpoints
        let index = parameter < breakpoints[1]
            ? 0
            : parameter < breakpoints[2] ? 1 : 2
        let lowerBound = breakpoints[index]
        let upperBound = breakpoints[index + 1]
        let segmentSpan = upperBound - lowerBound
        let localParameter = (parameter - lowerBound) / segmentSpan
        let segment = Self.swiftUIContinuousProfileSegments[index]
        let point = segment.point(at: localParameter)
        let derivative = segment.derivative(at: localParameter).vector
            / segmentSpan
        let cornerFrame = frame

        return CurveSample(
            point: cornerFrame[point.x, point.y],
            derivative: (cornerFrame.xAxis * derivative.dx)
                + (cornerFrame.yAxis * derivative.dy)
        )
    }
}

private struct CurveSample {
    let point: CGPoint
    let derivative: Vector2

    func interpolated(towards other: Self, amount: CGFloat) -> Self {
        .init(
            point: point.moved((other.point.vector - point.vector) * amount),
            derivative: derivative + ((other.derivative - derivative) * amount)
        )
    }

    func tangentIntersection(with other: Self) -> CGPoint? {
        let denominator = derivative.crossProduct(with: other.derivative)
        guard abs(denominator) > 1e-12 else { return nil }

        let tangentScale = (other.point.vector - point.vector)
            .crossProduct(with: other.derivative) / denominator
        return point.moved(derivative * tangentScale)
    }
}

private struct CubicBezierSegment {
    let start: CGPoint
    let control1: CGPoint
    let control2: CGPoint
    let end: CGPoint

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

    func derivative(at parameter: CGFloat) -> CGPoint {
        let inverse = 1 - parameter
        return .init(
            x: (3 * pow(inverse, 2) * (control1.x - start.x))
                + (6 * inverse * parameter * (control2.x - control1.x))
                + (3 * pow(parameter, 2) * (end.x - control2.x)),
            y: (3 * pow(inverse, 2) * (control1.y - start.y))
                + (6 * inverse * parameter * (control2.y - control1.y))
                + (3 * pow(parameter, 2) * (end.y - control2.y))
        )
    }
}
