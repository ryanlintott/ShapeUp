//
//  Corner+Dimensions+concave.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-03.
//

import SwiftUI

/// Formulas used to backsolve inset concave corners.
extension Corner.Dimensions {
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
    
    /// Returns the center point of the concave arc.
    /// - Parameters:
    ///   - cornerPoint: The original corner point.
    ///   - previousPoint: The point before the corner.
    ///   - nextPoint: The point after the corner.
    ///   - absoluteRadius: The non-relative radius used to size the corner.
    ///   - concaveInset: The difference between the corner radius and concave radius.
    ///   - cornerStart: The start point of the corner.
    ///   - cornerEnd: The end point of the corner.
    ///   - radiusCenter: The center point of the radius used to cut the corner.
    /// - Returns: The center point of the concave arc.
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
    
    /// Returns the point where the concave arc starts.
    /// - Parameters:
    ///   - cornerPoint: The original corner point.
    ///   - previousPoint: The point before the corner.
    ///   - absoluteRadius: The non-relative radius used to size the corner.
    ///   - cornerStart: The start point of the corner.
    ///   - cutLength: The distance from the corner point to the corner start.
    ///   - nextVector: The vector from the corner point to the next point.
    ///   - concaveRadius: The radius of the concave arc.
    ///   - concaveRadiusCenter: The center point of the concave arc.
    ///   - concaveInset: The difference between the corner radius and concave radius.
    ///   - reflexMultiplier: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Returns: The point where the concave arc starts, or nil when no arc is needed.
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
        reflexMultiplier: CGFloat
    ) -> CGPoint? {
        // Both concave radius and absolute radius must be greater than zero otherwise there will be no concave starting point.
        guard concaveRadius > 0, absoluteRadius > 0 else { return nil }
        
        // If there's no inset, the corner start is the concave start
        guard concaveInset * reflexMultiplier > 0 else { return cornerStart }
        
        if concaveRadius > absoluteRadius {
            // Get the intersection points of the concave circle and the line from previous point to corner point.
            let intersections = GeoMath.intersectionPoints(
                line: (point1: cornerPoint, point2: previousPoint),
                circle: (center: concaveRadiusCenter, radius: concaveRadius)
            )
            
            // The circle crosses this line twice: once on the incoming edge and once on the extension past the corner. Keeping whichever intersection is nearer to the previous point than the corner is rules out that second root.
            return intersections
                .filter {
                    // There should be one or zero results.
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
