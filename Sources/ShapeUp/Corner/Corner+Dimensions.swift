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
            
            previousVector = Self.previousVector(previousPoint: self.previousPoint, corner: corner)
            
            nextVector = Self.nextVector(nextPoint: self.nextPoint, corner: corner)
            
            maxCutLength = Self.maxCutLength(previousVector: previousVector, nextVector: nextVector)
            
            maxRadius = Self.maxRadius(maxCutLength: maxCutLength, halvedRadiusAngle: halvedRadiusAngle)
            
            absoluteRadius = Self.absoluteRadius(corner: corner, maxRadius: maxRadius)
            
            cutLength = Self.cutLength(maxCutLength: maxCutLength, absoluteRadius: absoluteRadius, maxRadius: maxRadius)
            
            cornerStart = Self.cornerStart(corner: corner, previousVector: previousVector, cutLength: cutLength)
            
            cornerEnd = Self.cornerEnd(corner: corner, nextVector: nextVector, cutLength: cutLength)
            
            radiusCenter = Self.radiusCenter(cornerStart: cornerStart, absoluteRadius: absoluteRadius, previousVector: previousVector, reflexMultiplier: reflexMultiplier)
            
            radiusOffset = Self.radiusOffset(corner: corner)
            
            concaveRadius = Self.concaveRadius(absoluteRadius: absoluteRadius, radiusOffset: radiusOffset)
            
            cutoutPoint = Self.cutoutPoint(corner: corner, cornerStart: cornerStart, cornerEnd: cornerEnd, nextVector: nextVector, previousVector: previousVector, cutLength: cutLength, absoluteRadius: absoluteRadius, halvedRadiusAngle: halvedRadiusAngle, radiusOffset: radiusOffset, concaveRadius: concaveRadius, reflexMultiplier: reflexMultiplier)
            
            concaveStart = Self.concaveStart(radiusOffset: radiusOffset, cornerStart: cornerStart, nextVector: nextVector, halvedRadiusAngle: halvedRadiusAngle, reflexMultiplier: reflexMultiplier)
            
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
    
    static func previousVector(previousPoint: CGPoint, corner: Corner) -> Vector2 {
        previousPoint.vector - corner.vector
    }
    
    static func nextVector(nextPoint: CGPoint, corner: Corner) -> Vector2 {
        nextPoint.vector - corner.vector
    }
    
    static func maxCutLength(previousVector: Vector2, nextVector: Vector2) -> CGFloat {
        min(previousVector.magnitude, nextVector.magnitude)
    }
    
    static func maxRadius(maxCutLength: CGFloat, halvedRadiusAngle: Angle) -> CGFloat {
        abs(maxCutLength / tan(halvedRadiusAngle.radians))
    }
    
    static func absoluteRadius(corner: Corner, maxRadius: CGFloat) -> CGFloat {
        corner.radius.value(using: maxRadius)
    }
    
    static func cutLength(maxCutLength: CGFloat, absoluteRadius: CGFloat, maxRadius: CGFloat) -> CGFloat {
        guard maxRadius != .zero else { return .zero }
        return maxCutLength * absoluteRadius / maxRadius
    }
    
    static func cornerStart(corner: Corner, previousVector: Vector2, cutLength: CGFloat) -> CGPoint {
        (corner.vector + (previousVector.normalized * cutLength)).point
    }
    
    static func cornerEnd(corner: Corner, nextVector: Vector2, cutLength: CGFloat) -> CGPoint {
        (corner.vector + (nextVector.normalized * cutLength)).point
    }
    
    static func radiusCenter(cornerStart: CGPoint, absoluteRadius: CGFloat, previousVector: Vector2, reflexMultiplier: CGFloat) -> CGPoint {
        (cornerStart.vector + (previousVector.normalized.rotated(.degrees(-90 * reflexMultiplier)) * absoluteRadius)).point
    }
    
    static func radiusOffset(corner: Corner) -> CGFloat {
        switch corner.style {
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
            #warning("Check to make sure I'm not using this to draw mirror lines with the corner point")
            return corner.point
        case .straight:
            return (cornerStart.vector + halfStraightVector).point
        case .cutout:
            // mirrored point
            return (cornerStart.vector + (nextVector.normalized * cutLength)).point
        case .concave:
            if radiusOffset > 0 {
                // Imagine a right angle triangle between the corner start, the concave radius center and the straight cut midpoint.
                let halfStraightLength = halfStraightVector.magnitude
                let concaveRadiusCenterToStraightMiddle = sqrt(pow(concaveRadius, 2) - pow(halfStraightLength, 2))
                
                // This is a similar triangle (same angles) to one between the corner cut, the corner start, and the straight cut middle.
                let straightMiddleToCutoutLength = pow(halfStraightLength, 2) / concaveRadiusCenterToStraightMiddle
                
                let straightMiddleToCutoutVector =  halfStraightVector.normalized.rotated(.degrees(90)) * straightMiddleToCutoutLength * reflexMultiplier
                return (cornerStart.vector + halfStraightVector + straightMiddleToCutoutVector).point
            } else {
                return (cornerStart.vector + (nextVector.normalized * cutLength)).point
            }
        }
    }
                
    /// Start point of concave corner
    static func concaveStart(radiusOffset: CGFloat?, cornerStart: CGPoint, nextVector: Vector2, halvedRadiusAngle: Angle, reflexMultiplier: CGFloat) -> CGPoint? {
        guard let radiusOffset = radiusOffset else { return nil }
        guard radiusOffset < 0 else { return nil }
        // Imagine a triangle from the
        let cutoutBeforeCurveLength = abs(radiusOffset / tan(halvedRadiusAngle.complementary.radians))
        let cutoutBeforeCurveVector = nextVector.normalized * cutoutBeforeCurveLength
        return (cornerStart.vector + cutoutBeforeCurveVector).point
    }
    
    static func concaveEnd(concaveStart: CGPoint?, corner: Corner, radiusCenter: CGPoint) -> CGPoint? {
        concaveStart?.flipped(mirrorLineStart: corner, mirrorLineEnd: radiusCenter)
    }
    
    static func concaveRadiusCenter(concaveStart: CGPoint, cutoutPoint: CGPoint, concaveRadius: CGFloat, reflexMultiplier: CGFloat) -> CGPoint {
        let concaveStartToRadiusCenter =
        (concaveStart.vector - cutoutPoint.vector).normalized.rotated(.degrees(90 * reflexMultiplier)) * concaveRadius
        return (concaveStart.vector + concaveStartToRadiusCenter).point
    }
    
    static func absoluteRadius(cornerPoint: CGPoint, concaveRadiusCenter: CGPoint, concaveRadius: CGFloat, halvedNonReflexAngle: Angle, previousVector: Vector2) -> CGFloat {
        let cornerToConcaveRadiusCenter = (concaveRadiusCenter.vector - cornerPoint.vector).magnitude
        // Imagine a triangle between corner point, concave start and concave radius
        // Cut this triangle into two right angle triangles with a line from concave radius center
        let cutLengthA = abs(cos(halvedNonReflexAngle.radians)) * cornerToConcaveRadiusCenter
        let cutLineSquared = pow(cornerToConcaveRadiusCenter, 2) - pow(cutLengthA, 2)
        let cutLengthB = sqrt(pow(concaveRadius, 2) - cutLineSquared)
        let cutLength = cutLengthA + cutLengthB
        
        return tan(halvedNonReflexAngle.radians) * cutLength
    }
}
