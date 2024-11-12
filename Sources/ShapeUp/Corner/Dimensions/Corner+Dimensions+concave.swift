//
//  Corner+Dimensions+concave.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-03.
//

import SwiftUI

/// Formulas used to backsolve inset concave corners.
public extension Corner.Dimensions {
    /// Returns the cut length for a concave corner with the following specifications.
    ///
    /// Used for backsolving after insetting a concave corner.
    /// - Parameters:
    ///   - cornerPoint: Point where the previous line and next line would meet.
    ///   - previousPoint: Any point on the previous line that's used to determine the direction of the previous line.
    ///   - concaveRadiusCenter: The center point of the concave radius used to cut the corner.
    ///   - concaveRadius: Concave radius used to cut the corner.
    ///   - halvedNonReflexAngle: Half of the non reflex angle of the corner.
    ///   - reflexMultiplier: A value equal to one for non-reflex corners and -1 for reflex corners.
    /// - Returns: The cut length for a concave corner with the following specifications.
    static func cutLength(cornerPoint: CGPoint, previousPoint: CGPoint, concaveRadiusCenter: CGPoint, concaveRadius: CGFloat, halvedNonReflexAngle: Angle, reflexMultiplier: CGFloat) -> CGFloat {
        // If the corner angle is zero or 90 then none of these calculations will work so just return a concave corner with zero radius.
        guard halvedNonReflexAngle.positive > .zero && halvedNonReflexAngle.positive < .degrees(90) else {
            return .zero
        }
        
        guard cornerPoint != concaveRadiusCenter else {
            // if corner point is the concave radius center then the concave radius in the cut length
            return concaveRadius
        }
        // Get the intersection points of the concave circle and the line from previous point to corner point.
        let intersections = GeoMath.intersectionPoints(
            line: (point1: cornerPoint, point2: previousPoint),
            circle: (center: concaveRadiusCenter, radius: concaveRadius)
        )
        
        // If one of the intersections equals the corner point
        guard !intersections.contains(where: { $0 == cornerPoint }) else {
            guard
                let first = intersections.first,
                let last = intersections.last
            else {
                // If there's only one intersection and it equals the corner point then the cut length is zero. (This should not be possible)
                return .zero
            }
            
            // If one of the intersections is the same as the corner point then the cut length equals the length of the line between the intersections
            return (last.vector - first.vector).magnitude
        }
        
        
        // Get the start point of the concave curve if there is one
        let cornerStart = intersections
            .first {
                // Get the direction from concave radius center to intersection point
                // and corner to cut point
                guard
                    let direction = ($0.vector - concaveRadiusCenter.vector).direction,
                    let cornerToCutDirection = (previousPoint.vector - cornerPoint.vector).rotated(-halvedNonReflexAngle * reflexMultiplier).direction
                else {
                    // These valus should never be nil but if they are, there's no intersections.
                    return false
                }
                
                // If the angle between the direction and corner cut direction is less than the halved radius angle then the intersection point should be used as the corner start.
                // If this isn't true, it means there should be a line from the corner start, in to meet the concave curve start.
                return direction.minRotation(from: cornerToCutDirection).positive <= halvedNonReflexAngle.complementary
            }
        
        if let cornerStart = cornerStart {
            return (cornerPoint.vector - cornerStart.vector).magnitude
        }
        
        // imagine a right angle triangle with the hypotenuse from concave center to cutout point and the right angle intersecting with the line from cutout point to corner start. (it may also be negative
        // Positive values are between cutout and corner, negative valuse are on the other side of cutout.
        let concaveCenterToCutout = concaveRadius / abs(sin(halvedNonReflexAngle.radians))
        // The vector from corner point to concave radius center
        let cornerToConcaveCenter = concaveRadiusCenter.vector - cornerPoint.vector
        // The vector from concave center to cutout
        let concaveCenterToCutoutVector = cornerToConcaveCenter.normalized * concaveCenterToCutout
        // The vector from corner to cutout
        let cornerToCutout = cornerToConcaveCenter + concaveCenterToCutoutVector
        // The vector from corner to the straight line between corner start and corner end
        let cornerToStraight = cornerToCutout * 0.5
        
        // cutLength
        return cornerToStraight.magnitude / abs(cos(halvedNonReflexAngle.radians))
    }
    
    /// Returns the non-relative radius value of a corner with the provided dimensions.
    /// - Parameters:
    ///   - cutLength: Length from the corner to the corner start.
    ///   - halvedNonReflexAngle: An angle that is half of the non-reflex version of the corner angle.
    /// - Returns: The non-relative radius value of a corner with the provided dimensions.
    static func absoluteRadius(cutLength: CGFloat, halvedNonReflexAngle: Angle) -> CGFloat {
        abs(tan(halvedNonReflexAngle.radians)) * cutLength
    }
    
    /// Returns the difference between the radius and the concave radius.
    /// - Parameters:
    ///   - concaveRadius: The radius of the concave cut arc.
    ///   - absoluteRadius: The non-relative radius used to size the corner.
    /// - Returns: The difference between the radius and the concave radius.
    static func radiusOffset(concaveRadius: CGFloat, absoluteRadius: CGFloat) -> CGFloat {
        concaveRadius - absoluteRadius
    }
}
