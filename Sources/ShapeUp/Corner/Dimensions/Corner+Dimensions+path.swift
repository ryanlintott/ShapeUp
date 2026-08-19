//
//  Corner+Dimensions+path.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Corner.Dimensions {
    /// Either moves or adds a line to a provided point.
    /// - Parameters:
    ///   - path: Path that will be modified.
    ///   - point: Point that will either be moved to or have a line added towards.
    ///   - moveToStart: A boolean value determining if the point should be moved to. If this value is false a line will be added from wherever the path currently is to the point.
    internal func startCornerShape(on path: inout Path, at point: CGPoint, moveToStart: Bool) {
        moveToStart ? path.move(to: point) : path.addLine(to: point)
    }
    
    /// Adds a corner shape to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currently is to the first corner.
    internal func addCornerShape(to path: inout Path, moveToStart: Bool) {
        if cutLength <= 0 {
            // A non-positive effective radius has no styled geometry.
            startCornerShape(on: &path, at: corner.point, moveToStart: moveToStart)
            return
        }

        let isZero = angle.isApproximatelyZero()
        let isStraight = angle.isApproximatelyStraight()

        // Draw the corner based on the style.
        switch corner.style {
            // Custom corners with no subcorners should draw as points.
        case .automatic, .point:
            // Start drawing this corner shape
            startCornerShape(on: &path, at: corner.point, moveToStart: moveToStart)
            
        case let .rounded(_, style):
            // Start drawing this corner shape
            startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)

            if isStraight {
                // The infinite-radius limit of the arc is a straight line.
                path.addLine(to: cornerEnd)
            } else if isZero == false {
                switch style {
                case .continuous:
                    // Draw a continuous curve from cornerStart to cornerEnd.
                    path.addContinuousCurve(
                        tangent1End: corner.point,
                        tangent2End: cornerEnd,
                        radius: absoluteRadius
                    )
                case .circular:
                    if angle.isApproximatelyStraight(tolerance: 0.01) {
                        // SwiftUI's tangent arc becomes numerically unstable when
                        // the radius grows toward infinity. This cubic has the same
                        // endpoints and tangents and converges to the limit line.
                        path.addCurve(
                            to: cornerEnd,
                            control1: cornerStart.moved(startVector.normalized * cubicArcControlLength),
                            control2: cornerEnd.moved(-endVector.normalized * cubicArcControlLength)
                        )
                    } else {
                        // Draw a rounded arc from the cornerStart to cornerEnd.
                        path.addArc(
                            tangent1End: corner.point,
                            tangent2End: cornerEnd,
                            radius: absoluteRadius
                        )
                    }
                }
            }
            
        case .concave:
            if isZero {
                // The radius and chord both shrink to this tangent point.
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                return
            }

            if isStraight {
                // The infinite-radius limit of the arc is a straight line.
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                path.addLine(to: cornerEnd)
                return
            }

            guard absoluteRadius > 1e-12 else {
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                return
            }
            
            if concaveRadius > absoluteRadius {
                guard let concaveStart, let concaveEnd else {
                    // Sometimes the inset sides of a corner shrink the concave curve to nothing. In that case, draw a point.
                    startCornerShape(on: &path, at: corner.point, moveToStart: moveToStart)
                    return
                }
                
                startCornerShape(on: &path, at: concaveStart, moveToStart: moveToStart)
                path.addArc(
                    center: concaveRadiusCenter,
                    radius: concaveRadius,
                    startAngle: (concaveStart.vector - concaveRadiusCenter.vector).direction ?? .zero,
                    endAngle: (concaveEnd.vector - concaveRadiusCenter.vector).direction ?? .zero,
                    clockwise: reflexMultiplier > 0
                )
                path.addLine(to: concaveEnd)
                
            } else {
                guard let concaveStart, let concaveEnd else {
                    // If an inset corner with a small radius has no concave start or end then it's likely the radius is zero and it should draw as a cutout point.
                    startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                    path.addLine(to: cutoutPoint)
                    path.addLine(to: cornerEnd)
                    return
                }
                
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                path.addLine(to: concaveStart)
                if abs(concaveInset) <= 1e-12,
                   angle.isApproximatelyStraight(tolerance: 0.01) {
                    // Match the cubic used by near-straight rounded corners,
                    // with the two tangents swapped and negated to bend the
                    // other way. A zero concave inset puts the concave start
                    // and end on the corner start and end.
                    path.addCurve(
                        to: concaveEnd,
                        control1: concaveStart.moved(endVector.normalized * cubicArcControlLength),
                        control2: concaveEnd.moved(-startVector.normalized * cubicArcControlLength)
                    )
                } else {
                    path.addArc(tangent1End: cutoutPoint, tangent2End: concaveEnd, radius: concaveRadius)
                    // The tangent arc stops short of its second tangent point.
                    path.addLine(to: concaveEnd)
                }
                path.addLine(to: cornerEnd)
            }
        case let .straight(_, cornerStyles):
            if cornerStyles == [] || cornerStyles.allSatisfy({ $0 == .automatic || $0 == .point }) {
                // If all corner styles are simple points:
                // Start drawing this corner shape
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                // Draw a line to the corner end point.
                path.addLine(to: cornerEnd)
            } else {
                // If non-point corner styles are used
                subCorners
                    .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                    .addOpenCornerShape(to: &path, moveToStart: moveToStart)
            }
            
        case let .cutout(_, cornerStyles):
            if cornerStyles == [] || cornerStyles.allSatisfy({ $0 == .automatic || $0 == .point }) {
                // If all corner styles are simple points:
                // Start drawing this corner shape
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                // Draw a line to the corner cut point.
                path.addLine(to: cutoutPoint)
                // Draw a line to the corner end point.
                path.addLine(to: cornerEnd)
            } else {
                // If non-point corner styles are used
                subCorners
                    .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                    .addOpenCornerShape(to: &path, moveToStart: moveToStart)
            }
            
        case .custom:
            (subCorners.isEmpty ? [RelativeCorner.topRight.corner(in: frame)] : subCorners)
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .addOpenCornerShape(to: &path, moveToStart: moveToStart)
        }
    }

    /// Returns the distance from each circular arc endpoint to its cubic Bézier
    /// control point.
    ///
    /// The calculation uses cut length instead of radius so that it remains
    /// finite as the corner approaches 180 degrees and its circular radius
    /// approaches infinity.
    private var cubicArcControlLength: CGFloat {
        let quarterArcTangent = tan(halvedTurnAngle.halved.radians)
        return (2 * cutLength / 3) * (1 - (quarterArcTangent * quarterArcTangent))
    }

}
