//
//  Corner+Dimensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-15.
//

import SwiftUI

extension Corner {
    /// A collection of calculated dimensions relating to corner with known previous and next points.
    ///
    /// Used for creating paths, insetting, flattening, etc.
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
        
        /// The maximum length that a corner can cut off. (The length of the shorter of the two lines from the corner point)
        public let maxCutLength: CGFloat
        
        /// The maximum radius that can be applied to this corner using the max cut length.
        public let maxRadius: CGFloat
        
        /// The radius as a non-relative value.
        public let absoluteRadius: CGFloat
        
        /// The length from the corner point to the corner start or end.
        public let cutLength: CGFloat
        
        /// The point where the corner shape starts.
        public let cornerStart: CGPoint
        
        /// The point where the corner shape ends.
        public let cornerEnd: CGPoint
        
        /// Center point of the radius used to cut the corner.
        public let radiusCenter: CGPoint
        
        /// Difference between the corner radius (used to determine the cut length) and the concave radius (used to draw a concave cut arc). Zero is default.
        public let radiusOffset: CGFloat
        
        /// The radius of the concave cut arc.
        public let concaveRadius: CGFloat
        
        /// The point where some corner shapes cut in to. Also used to draw concave arcs
        public let cutoutPoint: CGPoint
        
        /// The point where the concave arc starts when the corner start does not intersect the concave radius. Nil value if not used or same as the corner start.
        public let concaveStart: CGPoint?
        
        /// The point where the concave arc ends when the corner end does not intersect the concave radius. Nil value if not used or same as the corner end.
        public let concaveEnd: CGPoint?
        
        /// Center point of circle that forms a concave cut. This will be the corner point for non-concave corners.
        public let concaveRadiusCenter: CGPoint
        
        /// Creates a set of saved dimensions based on the corner style and provided previous and next points.
        ///
        /// Used for creating paths, insetting, flattening, etc.
        ///
        /// Values are saved when object is created so that duplicate calculations are avoided.
        /// - Parameters:
        ///   - previousPoint: Point before the corner.
        ///   - nextPoint: Point after the corner.
        public init<T: Vector2Representable, U: Vector2Representable>(corner: Corner, previousPoint: T, nextPoint: U) {
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
            
            concaveEnd = Self.concaveEnd(concaveStart: concaveStart, cornerPoint: corner.point, radiusCenter: radiusCenter)
            
            concaveRadiusCenter = Self.concaveRadiusCenter(concaveStart: concaveStart ?? cornerStart, cutoutPoint: cutoutPoint, concaveRadius: concaveRadius, reflexMultiplier: reflexMultiplier)
        }
    }
}

public extension Corner.Dimensions {
    /// Returns a multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Parameter angle: Corner angle
    /// - Returns: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    static func reflexMultiplier(angle: Angle) -> CGFloat {
        angle.type == .reflex ? -1 : 1
    }
    
    /// Returns an angle that is half of the non-reflex version of the corner angle.
    ///
    /// Positive values between 0 and 90 degrees
    /// - Parameter angle: Corner angle
    /// - Returns: An angle that is half of the non-reflex version of the corner angle.
    static func halvedNonReflexAngle(angle: Angle) -> Angle {
        angle.nonReflexCoterminal.positive.halved
    }
    
    /// Returns an angle that is half of the angle from corner start to corner end with the anchor at radius center.
    ///
    /// Positive values between 0 and 90 degrees
    /// - Parameter halvedNonReflexAngle: Half of the non-reflex version of the corner angle.
    /// - Returns: An angle that is half of the angle from corner start to corner end with the anchor at radius center.
    static func halvedRadiusAngle(halvedNonReflexAngle: Angle) -> Angle {
        halvedNonReflexAngle.complementary
    }
    
    /// Returns a vector from the corner to the previous corner.
    /// - Parameters:
    ///   - previousPoint: Previous point.
    ///   - cornerPoint: Corner point.
    /// - Returns: A vector from the corner to the previous corner.
    static func previousVector(previousPoint: CGPoint, cornerPoint: CGPoint) -> Vector2 {
        previousPoint.vector - cornerPoint.vector
    }
    
    /// Returns a vector from the corner to the next corner.
    /// - Parameters:
    ///   - nextPoint: Next Point.
    ///   - cornerPoint: Corner point.
    /// - Returns: A vector from the corner to the next corner
    static func nextVector(nextPoint: CGPoint, cornerPoint: CGPoint) -> Vector2 {
        nextPoint.vector - cornerPoint.vector
    }
    
    /// Returns the maximum length that a corner can cut off. (The lenght of the shorter of the two lines from the corner point)
    /// - Parameters:
    ///   - previousVector: Vector from corner to previous point.
    ///   - nextVector: Vector from corner to next point.
    /// - Returns: The maximum length that a corner can cut off. (The length of the shorter of the two lines from the corner point)
    static func maxCutLength(previousVector: Vector2, nextVector: Vector2) -> CGFloat {
        min(previousVector.magnitude, nextVector.magnitude)
    }
    
    /// Returns the maximum radius that can be applied to this corner using the max cut length.
    /// - Parameters:
    ///   - maxCutLength: Maximum length that a corner can cut off.
    ///   - halvedRadiusAngle: Half of the angle from corner start to corner end with the anchor at radius center.
    /// - Returns: The maximum radius that can be applied to this corner using the max cut length.
    static func maxRadius(maxCutLength: CGFloat, halvedRadiusAngle: Angle) -> CGFloat {
        abs(maxCutLength / tan(halvedRadiusAngle.radians))
    }
    
    /// Retruns the radius as a non-relative value.
    /// - Parameters:
    ///   - radius: Relatable radius value.
    ///   - maxRadius: The maximum radius that can be applied to this corner. (The length of the shorter of the two lines from the corner point)
    /// - Returns: The radius as a non-relative value.
    static func absoluteRadius(radius: RelatableValue, maxRadius: CGFloat) -> CGFloat {
        radius.value(using: maxRadius)
    }
    
    /// Returns the length from the corner point to the corner start or end.
    /// - Parameters:
    ///   - absoluteRadius: Radius as a non-relative value.
    ///   - halvedNonReflexAngle: Half of the non-reflex corner angle.
    /// - Returns: The length from the corner point to the corner start or end.
    static func cutLength(absoluteRadius: CGFloat, halvedNonReflexAngle: Angle) -> CGFloat {
        absoluteRadius / abs(tan(halvedNonReflexAngle.radians))
    }
    
    /// Returns the point where the corner shape starts.
    /// - Parameters:
    ///   - cornerPoint: Corner point.
    ///   - previousVector: Vector from corner to previous point.
    ///   - cutLength: Cut length from corner point to corner start.
    /// - Returns: The point where the corner shape starts.
    static func cornerStart(cornerPoint: CGPoint, previousVector: Vector2, cutLength: CGFloat) -> CGPoint {
        (cornerPoint.vector + (previousVector.normalized * cutLength)).point
    }
    
    /// Returns the point where the corner shape ends.
    /// - Parameters:
    ///   - cornerPoint: Corner point.
    ///   - nextVector: Vector from corner to next point.
    ///   - cutLength: Cut length from cotner point to corner end.
    /// - Returns: The point where the corner shape ends.
    static func cornerEnd(cornerPoint: CGPoint, nextVector: Vector2, cutLength: CGFloat) -> CGPoint {
        (cornerPoint.vector + (nextVector.normalized * cutLength)).point
    }
    
    /// Returns the center point of the radius used to cut the corner
    /// - Parameters:
    ///   - cornerStart: Point where the corner shape starts.
    ///   - absoluteRadius: Radius as a non-relative value.
    ///   - previousVector: Vector from corner to previous point.
    ///   - reflexMultiplier: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Returns: Center point of the radius used to cut the corner.
    static func radiusCenter(cornerStart: CGPoint, absoluteRadius: CGFloat, previousVector: Vector2, reflexMultiplier: CGFloat) -> CGPoint {
        (cornerStart.vector + (previousVector.normalized.rotated(.degrees(-90 * reflexMultiplier)) * absoluteRadius)).point
    }
    
    /// Difference between the corner radius (used to determine the cut length) and the concave radius (used to draw a concave cut arc). Zero is default.
    /// - Parameter style: Corner style.
    /// - Returns: Difference between the corner radius (used to determine the cut length) and the concave radius (used to draw a concave cut arc). Zero is default.
    static func radiusOffset(style: CornerStyle) -> CGFloat {
        switch style {
        case let .concave(_, radiusOffset):
            return radiusOffset
        default:
            return .zero
        }
    }
    
    /// Returns the radius of the concave cut arc.
    /// - Parameters:
    ///   - absoluteRadius: The non-relative radius used to size the corner.
    ///   - radiusOffset: The difference between the radius and the concave radius.
    /// - Returns: The radius of the concave cut arc.
    static func concaveRadius(absoluteRadius: CGFloat, radiusOffset: CGFloat) -> CGFloat {
        absoluteRadius + radiusOffset
    }
    
    /// Returns the point where some corner shapes cut in to. Also used to draw concave arcs.
    /// - Parameters:
    ///   - corner: Corner including style and point.
    ///   - cornerStart: The point where the corner shape starts.
    ///   - cornerEnd: The point where the corner shape ends.
    ///   - nextVector: Vector from the corner to the next point.
    ///   - previousVector: Vector from the corner to the previous point.
    ///   - cutLength: Length from corner to corner start (or corner to corner end)
    ///   - absoluteRadius: Non-relative radius used to size the corner.
    ///   - halvedRadiusAngle: Half of the angle from corner start to corner end with the anchor at radius center
    ///   - radiusOffset: Difference between the corner radius (used to determine the cut length) and the concave radius (used to draw a concave cut arc).
    ///   - concaveRadius: The radius of the concave cut arc.
    ///   - reflexMultiplier: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Returns: The point where some corner shapes cut in to. Also used to draw concave arcs.
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
    
    /// Returns the point where the concave arc starts when the corner start does not intersect the concave radius. Nil value if not used or same as the corner start.
    /// - Parameters:
    ///   - absoluteRadius: Non-relative radius used to size the corner.
    ///   - concaveRadius: The radius of the concave cut arc.
    ///   - cornerStart: The point where the corner shape starts.
    ///   - cutLength: Length from corner to corner start (or corner to corner end)
    ///   - nextVector: Vector from the corner to the next point.
    ///   - halvedNonReflexAngle: Half of the angle from corner start to corner end with the anchor at radius center
    ///   - reflexMultiplier: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Returns: The point where the concave arc starts when the corner start does not intersect the concave radius. Nil value if not used or same as the corner start.
    static func concaveStart(absoluteRadius: CGFloat, concaveRadius: CGFloat, cornerStart: CGPoint, cutLength: CGFloat, nextVector: Vector2, halvedNonReflexAngle: Angle, reflexMultiplier: CGFloat) -> CGPoint? {
        
        guard absoluteRadius > concaveRadius else { return nil }
        // Imagine a right angle triangle with a hypotenuse from the concave center to cutout center and the right angle at concave start.
        let concaveStartToCutout = concaveRadius / abs(tan(halvedNonReflexAngle.radians))
        let cornerStartToConcaveStart = cutLength - concaveStartToCutout
        let cornerStartToConcaveStartVector = nextVector.normalized * cornerStartToConcaveStart
        
        return (cornerStart.vector + cornerStartToConcaveStartVector).point
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
    
    /// Returns the center point of circle that forms a concave cut. This will be the corner point for non-concave corners.
    /// - Parameters:
    ///   - concaveStart: The point where the concave arc starts when the corner start does not intersect the concave radius. Nil value if not used or same as the corner start.
    ///   - cutoutPoint: The point where some corner shapes cut in to. Also used to draw concave arcs
    ///   - concaveRadius: The radius of the concave cut arc.
    ///   - reflexMultiplier: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Returns: Center point of circle that forms a concave cut. This will be the corner point for non-concave corners.
    static func concaveRadiusCenter(concaveStart: CGPoint, cutoutPoint: CGPoint, concaveRadius: CGFloat, reflexMultiplier: CGFloat) -> CGPoint {
        let negativeRadiusMultiplier = concaveRadius > 0 ? 1.0 : -1.0
        let concaveStartToRadiusCenter =
        (concaveStart.vector - cutoutPoint.vector).normalized.rotated(.degrees(90)) * concaveRadius * reflexMultiplier * negativeRadiusMultiplier
        return (concaveStart.vector + concaveStartToRadiusCenter).point
    }
}

