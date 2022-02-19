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
        
        /// The positive angle between the cutStartPoint and the corner point with the anchor at the center of the radius used to cut the corner.
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
        
        /// The point where some corner shapes cut in to.
        public let cutoutPoint: CGPoint
        
        init<T: Vector2Representable, U: Vector2Representable>(corner: Corner, previousPoint: T, nextPoint: U) {
            self.corner = corner
            
            self.previousPoint = previousPoint.point
            
            self.nextPoint = nextPoint.point
            
            angle = Angle.threePoint(nextPoint, corner, previousPoint)
            
            reflexMultiplier = angle.type == .reflex ? -1 : 1
            
            halvedRadiusAngle = angle.nonReflexCoterminal.supplementary.halved
            
            previousVector = previousPoint.vector - corner.vector
            
            nextVector = nextPoint.vector - corner.vector
            
            maxCutLength = min(previousVector.magnitude, nextVector.magnitude)
            
            maxRadius = abs(maxCutLength / tan(halvedRadiusAngle.radians))
            
            absoluteRadius = corner.radius.value(using: maxRadius)
            
            cutLength = maxCutLength * absoluteRadius / maxRadius
            
            cornerStart = (corner.vector + (previousVector.normalized * cutLength)).point
            
            cornerEnd = (corner.vector + (nextVector.normalized * cutLength)).point
            
            cutoutPoint = (cornerStart.vector + (nextVector.normalized * cutLength)).point
        }
    }
}

#warning("Maybe don't need these")
//public extension Corner.Dimensions {
//    static func reflexMultiplier(angle: Angle) -> CGFloat {
//        angle.type == .reflex ? -1 : 1
//    }
//    
//    // The positive angle between the cutStartPoint and the corner point with the anchor at the center of the radius used to cut the corner.
//    static func halvedRadiusAngle(angle: Angle) -> Angle {
//        angle.nonReflexCoterminal.supplementary.halved
//    }
//    
//    // Vector from the corner to the previous corner
//    static func previousVector(previousPoint: CGPoint, corner: Corner) -> Vector2 {
//        previousPoint.vector - corner.vector
//    }
//    
//    // Vector from the corner to the next corner
//    static func nextVector(nextPoint: CGPoint, corner: Corner) -> Vector2 {
//        nextPoint.vector - corner.vector
//    }
//    
//    // The maximum cut length from the corner. Any further and it would go beyond the next or previous corner.
//    static func maxCutLength(previousVector: Vector2, nextVector: Vector2) -> CGFloat {
//        min(previousVector.magnitude, nextVector.magnitude)
//    }
//    
//    // The maximum radius that results from using the maximum cut length.
//    static func maxRadius(maxCutLength: CGFloat, halvedRadiusAngle: Angle) -> CGFloat {
//        maxCutLength / tan(halvedRadiusAngle.radians)
//    }
//    
//    static func absoluteRadius(corner: Corner, maxRadius: CGFloat) -> CGFloat {
//        corner.radius.value(using: maxRadius)
//    }
//    
//    static func cutLength(maxCutLength: CGFloat, absoluteRadius: CGFloat, maxRadius: CGFloat) -> CGFloat {
//        abs(maxCutLength * absoluteRadius / maxRadius)
//    }
//    
//    static func cornerStart(corner: Corner, previousVector: Vector2, cutLength: CGFloat) -> CGPoint {
//        (corner.vector + (previousVector.normalized * cutLength)).point
//    }
//    
//    static func cornerEnd(corner: Corner, nextVector: Vector2, cutLength: CGFloat) -> CGPoint {
//        (corner.vector + (nextVector.normalized * cutLength)).point
//    }
//    
//    static func cutoutPoint(cornerStart: CGPoint, nextVector: Vector2, cutLength: CGFloat) -> CGPoint {
//        (cornerStart.vector + (nextVector.normalized * cutLength)).point
//    }
//}
