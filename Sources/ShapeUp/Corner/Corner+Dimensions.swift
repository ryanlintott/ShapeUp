//
//  Corner+Dimensions.swift
//  
//
//  Created by Ryan Lintott on 2022-02-15.
//

import SwiftUI

extension Corner {
    func dimensions(previousPoint: CGPoint, nextPoint: CGPoint) -> Self.Dimensions {
        .init(corner: self, previousPoint: previousPoint, nextPoint: nextPoint)
    }
    
    public struct Dimensions {
        /// The corner used to create these dimensions.
        public let corner: Corner
        
        /// The point before the corner.
        public let previousPoint: CGPoint
        
        /// The point after the corner.
        public let nextPoint: CGPoint
        
        /// Angle of the corner from previous point to corner to next point.
        public let angle: Angle
        
        /// A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
        public let reflexMultiplier: CGFloat
        
        /// Half of the non-reflex version of the corner angle.
        public let halvedNonReflexAngle: Angle
        
        /// Half of the angle from corner start to corner end with the anchor at radius center
        public let halvedRadiusAngle: Angle
        
        /// Vector from the corner to the previous corner
        public let previousVector: Vector2
        
        /// Vector from the corner to the next corner
        public let nextVector: Vector2
        
        /// The maximum cut length from the corner. Any further and it would go beyond the next or previous corner.
        public let maxCutLength: CGFloat
        
        /// The maximum radius that results from using the maximum cut length.
        public let maxRadius: CGFloat
        
        /// The radius as a non-relative actual value.
        public let absoluteRadius: CGFloat
        
        /// The length from the corner point to the corner start or end.
        public let cutLength: CGFloat
        
        /// The point where the corner shape starts.
        public let cornerStart: CGPoint
        
        /// The point where the corner shape ends.
        public let cornerEnd: CGPoint
        
        /// Center point of the radius used to cut the corner
        public let radiusCenter: CGPoint
        
        /// Difference between the corner radius (used to determine the cut length) and the concave radius (used to draw a concave cut arc). Zero is default.
        public let radiusOffset: CGFloat
        
        /// The point where the concave arc starts. Nil value if not used or same as the corner start.
        public let concaveStart: CGPoint?
        
        /// The point where the concave arc ends. Nil value if not used or same as the corner end.
        public let concaveEnd: CGPoint?
        
        /// The radius of the concave cut arc.
        public let concaveRadius: CGFloat
        
        /// The point where some corner shapes cut in to. Also used to draw concave arcs
        public let cutoutPoint: CGPoint
        
        /// Center point of circle that forms a concave cut. This will be the corner point for non-concave corners.
        public let concaveRadiusCenter: CGPoint
        
        init<T: Vector2Representable, U: Vector2Representable>(corner: Corner, previousPoint: T, nextPoint: U) {
            self.corner = corner
            
            self.previousPoint = previousPoint.point
            
            self.nextPoint = nextPoint.point
            
            angle = Angle.threePoint(nextPoint, corner, previousPoint)
            
            reflexMultiplier = Self.reflexMultiplier(angle: angle)
            
            halvedNonReflexAngle = Self.halvedNonReflexAngle(angle: angle)
            
            halvedRadiusAngle = Self.halvedRadiusAngle(halvedNonReflexAngle: halvedNonReflexAngle)
            
            previousVector = Self.previousVector(previousPoint: self.previousPoint, cornerPoint: corner.point)
            
            nextVector = Self.nextVector(nextPoint: self.nextPoint, cornerPoint: corner.point)
            
            maxCutLength = Self.maxCutLength(previousVector: previousVector, nextVector: nextVector)
            
            maxRadius = Self.maxRadius(maxCutLength: maxCutLength, halvedRadiusAngle: halvedRadiusAngle)
            
            absoluteRadius = Self.absoluteRadius(radius: corner.radius, maxRadius: maxRadius)
            
            cutLength = Self.cutLength(absoluteRadius: absoluteRadius, halvedNonReflexAngle: halvedNonReflexAngle)
            
            cornerStart = Self.cornerStart(cornerPoint: corner.point, previousVector: previousVector, cutLength: cutLength)
            
            cornerEnd = Self.cornerEnd(cornerPoint: corner.point, nextVector: nextVector, cutLength: cutLength)
            
            radiusCenter = Self.radiusCenter(cornerStart: cornerStart, absoluteRadius: absoluteRadius, previousVector: previousVector, reflexMultiplier: reflexMultiplier)
            
            radiusOffset = Self.radiusOffset(style: corner.style)
            
            concaveRadius = Self.concaveRadius(absoluteRadius: absoluteRadius, radiusOffset: radiusOffset)
            
            cutoutPoint = Self.cutoutPoint(corner: corner, cornerStart: cornerStart, cornerEnd: cornerEnd, nextVector: nextVector, previousVector: previousVector, cutLength: cutLength, absoluteRadius: absoluteRadius, halvedRadiusAngle: halvedRadiusAngle, radiusOffset: radiusOffset, concaveRadius: concaveRadius, reflexMultiplier: reflexMultiplier)
            
            concaveStart = Self.concaveStart(absoluteRadius: absoluteRadius, concaveRadius: concaveRadius, cornerStart: cornerStart, cutLength: cutLength, nextVector: nextVector, halvedNonReflexAngle: halvedNonReflexAngle, reflexMultiplier: reflexMultiplier)
            
            concaveEnd = Self.concaveEnd(concaveStart: concaveStart, corner: corner, radiusCenter: radiusCenter)
            
            concaveRadiusCenter = Self.concaveRadiusCenter(concaveStart: concaveStart ?? cornerStart, cutoutPoint: cutoutPoint, concaveRadius: concaveRadius, reflexMultiplier: reflexMultiplier)
        }
    }
}

public extension Corner.Dimensions {
    static func reflexMultiplier(angle: Angle) -> CGFloat {
        angle.type == .reflex ? -1 : 1
    }
    
    static func halvedNonReflexAngle(angle: Angle) -> Angle {
        angle.nonReflexCoterminal.positive.halved
    }
    
    static func halvedRadiusAngle(halvedNonReflexAngle: Angle) -> Angle {
        halvedNonReflexAngle.complementary
    }
    
    static func previousVector(previousPoint: CGPoint, cornerPoint: CGPoint) -> Vector2 {
        previousPoint.vector - cornerPoint.vector
    }
    
    static func nextVector(nextPoint: CGPoint, cornerPoint: CGPoint) -> Vector2 {
        nextPoint.vector - cornerPoint.vector
    }
    
    static func maxCutLength(previousVector: Vector2, nextVector: Vector2) -> CGFloat {
        min(previousVector.magnitude, nextVector.magnitude)
    }
    
    static func maxRadius(maxCutLength: CGFloat, halvedRadiusAngle: Angle) -> CGFloat {
        abs(maxCutLength / tan(halvedRadiusAngle.radians))
    }
    
    static func absoluteRadius(radius: RelatableValue, maxRadius: CGFloat) -> CGFloat {
        radius.value(using: maxRadius)
    }
    
    static func cutLength(absoluteRadius: CGFloat, halvedNonReflexAngle: Angle) -> CGFloat {
        absoluteRadius / abs(tan(halvedNonReflexAngle.radians))
    }
    
    static func cornerStart(cornerPoint: CGPoint, previousVector: Vector2, cutLength: CGFloat) -> CGPoint {
        (cornerPoint.vector + (previousVector.normalized * cutLength)).point
    }
    
    static func cornerEnd(cornerPoint: CGPoint, nextVector: Vector2, cutLength: CGFloat) -> CGPoint {
        (cornerPoint.vector + (nextVector.normalized * cutLength)).point
    }
    
    static func radiusCenter(cornerStart: CGPoint, absoluteRadius: CGFloat, previousVector: Vector2, reflexMultiplier: CGFloat) -> CGPoint {
        (cornerStart.vector + (previousVector.normalized.rotated(.degrees(-90 * reflexMultiplier)) * absoluteRadius)).point
    }
    
    static func radiusOffset(style: CornerStyle) -> CGFloat {
        switch style {
        case let .concave(_, radiusOffset):
            return radiusOffset
        default:
            return .zero
        }
    }
    
    static func concaveRadius(absoluteRadius: CGFloat, radiusOffset: CGFloat) -> CGFloat {
        absoluteRadius + radiusOffset
    }
    
    static func cutoutPoint(corner: Corner, cornerStart: CGPoint, cornerEnd: CGPoint, nextVector: Vector2, previousVector: Vector2, cutLength: CGFloat, absoluteRadius: CGFloat, halvedRadiusAngle: Angle, radiusOffset: CGFloat, concaveRadius: CGFloat, reflexMultiplier: CGFloat) -> CGPoint {
        let halfStraightVector = (cornerEnd.vector - cornerStart.vector) / 2
        switch corner.style {
        case .point, .rounded:
            return corner.point
        case .straight:
            return (cornerStart.vector + halfStraightVector).point
        case .cutout:
            // mirrored point
            return (cornerStart.vector + (nextVector.normalized * cutLength)).point
        case .concave:
            if radiusOffset <= 0 {
                return (cornerStart.vector + (nextVector.normalized * cutLength)).point
            } else {
                // Imagine a right angle triangle between the corner start, the concave radius center and the straight cut midpoint.
                let halfStraightLength = halfStraightVector.magnitude
                let concaveRadiusCenterToStraightMiddle = sqrt(pow(concaveRadius, 2) - pow(halfStraightLength, 2))
                
                // This is a similar triangle (same angles) to one between the corner cut, the corner start, and the straight cut middle.
                let straightMiddleToCutoutLength = pow(halfStraightLength, 2) / concaveRadiusCenterToStraightMiddle
                
                let cornerToHalfStraight = (cornerStart.vector + halfStraightVector) - corner.vector
                let cornerToCutout = cornerToHalfStraight + (cornerToHalfStraight.normalized * straightMiddleToCutoutLength)
                return (corner.vector + cornerToCutout).point
            }
        }
    }
    
    /// Start point of concave corner
    static func concaveStart(absoluteRadius: CGFloat, concaveRadius: CGFloat, cornerStart: CGPoint, cutLength: CGFloat, nextVector: Vector2, halvedNonReflexAngle: Angle, reflexMultiplier: CGFloat) -> CGPoint? {
        
        guard absoluteRadius > concaveRadius else { return nil }
        // Imagine a right angle triangle with a hypotenuse from the concave center to cutout center and the right angle at concave start.
        let concaveStartToCutout = concaveRadius / abs(tan(halvedNonReflexAngle.radians))
        let cornerStartToConcaveStart = cutLength - concaveStartToCutout
        let cornerStartToConcaveStartVector = nextVector.normalized * cornerStartToConcaveStart
        
        return (cornerStart.vector + cornerStartToConcaveStartVector).point
    }
    
    static func concaveEnd(concaveStart: CGPoint?, corner: Corner, radiusCenter: CGPoint) -> CGPoint? {
        concaveStart?.flipped(mirrorLineStart: corner, mirrorLineEnd: radiusCenter)
    }
    
    static func concaveRadiusCenter(concaveStart: CGPoint, cutoutPoint: CGPoint, concaveRadius: CGFloat, reflexMultiplier: CGFloat) -> CGPoint {
        let negativeRadiusMultiplier = concaveRadius > 0 ? 1.0 : -1.0
        let concaveStartToRadiusCenter =
        (concaveStart.vector - cutoutPoint.vector).normalized.rotated(.degrees(90)) * concaveRadius * reflexMultiplier * negativeRadiusMultiplier
        return (concaveStart.vector + concaveStartToRadiusCenter).point
    }
}

extension Corner.Dimensions {
    static func cutLength(cornerPoint: CGPoint, previousPoint: CGPoint, concaveRadiusCenter: CGPoint, concaveRadius: CGFloat, halvedNonReflexAngle: Angle, reflexMultiplier: CGFloat) -> CGFloat {
        // If the corner angle is zero or 90 then none of these calculations will work so just return a concave corner with zero radius.
        guard halvedNonReflexAngle.positive > .zero && halvedNonReflexAngle.positive < .degrees(90) else {
            return .zero
        }
        
        // Initialize the cut length then set it in the switch statement
        let cutLength: CGFloat
        
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
    
    static func absoluteRadius(cutLength: CGFloat, halvedNonReflexAngle: Angle) -> CGFloat {
        abs(tan(halvedNonReflexAngle.radians)) * cutLength
    }
    
    static func radiusOffset(concaveRadius: CGFloat, absoluteRadius: CGFloat) -> CGFloat {
        concaveRadius - absoluteRadius
    }
}
