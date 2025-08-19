//
//  Corner+Dimensions+concave.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-03.
//

import SwiftUI

/// Formulas used to backsolve inset concave corners.
public extension Corner.Dimensions {
    /// Difference between the corner radius (used to determine the cut length) and the concave radius (used to draw a concave cut arc). Zero is default.
    /// - Parameter style: Corner style.
    /// - Returns: Difference between the corner radius (used to determine the cut length) and the concave radius (used to draw a concave cut arc). Zero is default.
    static func concaveInset(style: CornerStyle) -> CGFloat {
        switch style {
        case let .concave(_, concaveInset): concaveInset
        default: .zero
        }
    }
    
    /// Returns the radius of the concave cut arc.
    /// - Parameters:
    ///   - absoluteRadius: The non-relative radius used to size the corner.
    ///   - concaveInset: The difference between the radius and the concave radius.
    ///   - reflexMultiplier: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Returns: The radius of the concave cut arc.
    static func concaveRadius(absoluteRadius: CGFloat, concaveInset: CGFloat, reflexMultiplier: CGFloat) -> CGFloat {
        max(0, absoluteRadius + (concaveInset * reflexMultiplier))
    }
    
    static func concaveRadiusCenter(
        cornerPoint: CGPoint,
        previousPoint: CGPoint,
        nextPoint: CGPoint,
        absoluteRadius: CGFloat,
        concaveInset: CGFloat,
        cornerStart: CGPoint,
        cornerEnd: CGPoint,
        radiusCenter: CGPoint
    ) -> CGPoint {
        if abs(concaveInset) > 1e-12 {
            let offsetPoints = [previousPoint, cornerPoint, nextPoint]
                .insetPoints(-concaveInset)
            
            let offsetPrevious = offsetPoints[0]
            let offsetCorner = offsetPoints[1].corner(.concave(radius: .absolute(absoluteRadius), concaveInset: 0))
            let offsetNext = offsetPoints[2]
            
            return offsetCorner
                .dimensions(previousPoint: offsetPrevious, nextPoint: offsetNext)
                .concaveRadiusCenter
        } else {
            return radiusCenter.flipped(mirrorLineStart: cornerStart, mirrorLineEnd: cornerEnd)
        }
    }
    
    static func concaveStart(
        cornerPoint: CGPoint,
        previousPoint: CGPoint,
        absoluteRadius: CGFloat,
        cornerStart: CGPoint,
        cutLength: CGFloat,
        nextVector: Vector2,
        concaveRadius: CGFloat,
        concaveRadiusCenter: CGPoint,
        concaveInset: CGFloat,
    ) -> CGPoint? {
        // Both concave radius and absolute radius must be greater than zero otherwise there will be no concave starting point.
        guard concaveRadius > 0, absoluteRadius > 0 else { return nil }
        
        // If there's no inset, the corner start is the concave start
        guard concaveInset > 0 else { return cornerStart }
        
        if concaveRadius > absoluteRadius {
            // Get the intersection points of the concave circle and the line from previous point to corner point.
            let intersections = GeoMath.intersectionPoints(
                line: (point1: cornerPoint, point2: previousPoint),
                circle: (center: concaveRadiusCenter, radius: concaveRadius)
            )
            
            // Get the intersection along the line between the corner and the previous point by finding the first corner to intersection vector that points in the same direction as the previous vector.
            return intersections
                .filter {
                    // make sure the intersection is on the line
                    // There should be one or zero results
                    ($0.vector - previousPoint.vector).magnitudeSquared < (cornerPoint.vector - previousPoint.vector).magnitudeSquared
                }
                .first
        } else {
            // The concave start should be along the next vector by an amount equal to 1 minus the ratio of concave to absolute radius. When equal to the absolute radius the concave start will be the same as the corner start. When equal to zero the concave start will be right at the cutout point (though if it is zero this function returns nil).
            return cornerStart.moved(
                (nextVector.normalized * cutLength) * (1 - (concaveRadius / absoluteRadius))
            )
        }
    }
    
    /// Returns the point where the concave arc ends when the corner end does not intersect the concave radius. Nil value if not used or same as the corner end.
    /// - Parameters:
    ///   - concaveStart: The point where the concave arc starts when the corner start does not intersect the concave radius. Nil value if not used or same as the corner start.
    ///   - cornerPoint: Corner point.
    ///   - radiusCenter: Center point of the radius used to cut the corner.
    /// - Returns: The point where the concave arc ends when the corner end does not intersect the concave radius. Nil value if not used or same as the corner end.
    static func concaveEnd(concaveStart: CGPoint?, cornerPoint: CGPoint, radiusCenter: CGPoint) -> CGPoint? {
        concaveStart?.flipped(mirrorLineStart: cornerPoint, mirrorLineEnd: radiusCenter)
    }
}
