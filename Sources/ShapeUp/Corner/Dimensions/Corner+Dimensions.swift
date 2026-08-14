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
    ///
    /// - Warning: This type is deprecated and will become internal in a future
    ///   release. Use `Array<Corner>.path(closed:)`, `Array<Corner>.inset(by:)`,
    ///   or the `Path` corner-shape methods instead.
    @available(
        *,
        deprecated,
        message: "Corner.Dimensions will become internal in a future release. Use Array<Corner>.path(closed:), Array<Corner>.inset(by:), or Path corner-shape methods instead."
    )
    public struct Dimensions: Sendable {
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
        
        /// The effective radius as a non-relative value, fitted to the adjacent segments.
        public let absoluteRadius: CGFloat
        
        /// The length from the corner point to the corner start or end.
        public let cutLength: CGFloat
        
        /// The point where the corner shape starts.
        public let cornerStart: CGPoint
        
        /// The point where the corner shape ends.
        public let cornerEnd: CGPoint
        
        /// Center point of the radius used to cut the corner.
        public let radiusCenter: CGPoint
        
        /// The inset value for a concave corner. This is required for drawing inset concave corners and is not used for other corner types.
        public let concaveInset: CGFloat
        
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
        ///   - corner: Corner between previous and next point.
        ///   - previousPoint: Point before the corner.
        ///   - nextPoint: Point after the corner.
        public init(corner: Corner, previousPoint: some Vector2Representable, nextPoint: some Vector2Representable) {
            self.corner = corner
            
            self.previousPoint = previousPoint.point
            
            self.nextPoint = nextPoint.point
            
            /// All of the following values are calculated in the init and saved instead of using calculated properties that would need to be calculated many more times.
            angle = Angle.threePoint(nextPoint, corner, previousPoint)
            
            reflexMultiplier = Self.reflexMultiplier(angle: angle)
            
            halvedNonReflexAngle = Self.halvedNonReflexAngle(angle: angle)
            
            halvedRadiusAngle = Self.halvedRadiusAngle(halvedNonReflexAngle: halvedNonReflexAngle)
            
            previousVector = Self.previousVector(
                previousPoint: self.previousPoint,
                cornerPoint: corner.point
            )
            
            nextVector = Self.nextVector(
                nextPoint: self.nextPoint,
                cornerPoint: corner.point
            )
            
            maxCutLength = Self.maxCutLength(
                previousVector: previousVector,
                nextVector: nextVector
            )
            
            let cutLengthMultiplier = Self.cutLengthMultiplier(
                for: corner.style,
                angle: angle
            )

            maxRadius = Self.maxRadius(
                maxCutLength: maxCutLength,
                halvedRadiusAngle: halvedRadiusAngle
            ) / cutLengthMultiplier
            
            cutLength = Self.cutLength(
                radius: corner.radius,
                maxRadius: maxRadius,
                maxCutLength: maxCutLength,
                cutLengthMultiplier: cutLengthMultiplier
            )

            absoluteRadius = Self.absoluteRadius(
                cutLength: cutLength,
                maxRadius: maxRadius,
                maxCutLength: maxCutLength
            )
            
            cornerStart = Self.cornerStart(
                cornerPoint: corner.point,
                previousVector: previousVector,
                cutLength: cutLength
            )
            
            cornerEnd = Self.cornerEnd(
                cornerPoint: corner.point,
                nextVector: nextVector,
                cutLength: cutLength
            )
            
            cutoutPoint = Self.cutoutPoint(
                corner: corner,
                cornerStart: cornerStart,
                cornerEnd: cornerEnd,
                nextVector: nextVector,
                cutLength: cutLength
            )
            
            let hasDegenerateAngle = angle.isApproximatelyZero()
                || angle.isApproximatelyStraight()

            radiusCenter = hasDegenerateAngle
                ? corner.point
                : Self.radiusCenter(
                    cornerStart: cornerStart,
                    absoluteRadius: absoluteRadius,
                    previousVector: previousVector,
                    reflexMultiplier: reflexMultiplier
                )
            
            /// Only used for concave corners
            concaveInset = Self.concaveInset(style: corner.style)
            
            concaveRadius = Self.concaveRadius(
                absoluteRadius: absoluteRadius,
                concaveInset: concaveInset,
                reflexMultiplier: reflexMultiplier
            )
            
            if hasDegenerateAngle {
                // Degenerate corner limits are drawn without an arc. Avoid the
                // circle and inset calculations, which are singular at 0 and 180 degrees.
                concaveRadiusCenter = corner.point
                concaveStart = nil
                concaveEnd = nil
            } else {
                concaveRadiusCenter = Self.concaveRadiusCenter(
                    cornerPoint: corner.point,
                    previousPoint: previousPoint.point,
                    nextPoint: nextPoint.point,
                    absoluteRadius: absoluteRadius,
                    concaveInset: concaveInset,
                    cornerStart: cornerStart,
                    cornerEnd: cornerEnd,
                    radiusCenter: radiusCenter
                )

                concaveStart = Self.concaveStart(
                    cornerPoint: corner.point,
                    previousPoint: previousPoint.point,
                    absoluteRadius: absoluteRadius,
                    cornerStart: cornerStart,
                    cutLength: cutLength,
                    nextVector: nextVector,
                    concaveRadius: concaveRadius,
                    concaveRadiusCenter: concaveRadiusCenter,
                    concaveInset: concaveInset,
                    reflexMultiplier: reflexMultiplier
                )

                concaveEnd = Self.concaveEnd(
                    concaveStart: concaveStart,
                    cornerPoint: corner.point,
                    radiusCenter: radiusCenter
                )
            }
        }
    }
}

public extension Corner.Dimensions {
    /// Returns a multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    /// - Parameter angle: Corner angle
    /// - Returns: A multiplier that is -1 for reflex angles and +1 for non-reflex angles.
    static func reflexMultiplier(angle: Angle) -> CGFloat {
        angle.minPositiveCoterminal > .degrees(180) ? -1 : 1
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
    
    /// Returns the maximum length that a corner can cut off. (The length of the shorter of the two lines from the corner point)
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
        maxCutLength * abs(tan(halvedRadiusAngle.complementary.radians))
    }
    
    /// Returns the radius as a non-relative value.
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
        cornerPoint
            .moved(previousVector.normalized * cutLength)
    }
    
    /// Returns the point where the corner shape ends.
    /// - Parameters:
    ///   - cornerPoint: Corner point.
    ///   - nextVector: Vector from corner to next point.
    ///   - cutLength: Cut length from corner point to corner end.
    /// - Returns: The point where the corner shape ends.
    static func cornerEnd(cornerPoint: CGPoint, nextVector: Vector2, cutLength: CGFloat) -> CGPoint {
        cornerPoint
            .moved(nextVector.normalized * cutLength)
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
    
    /// Returns the point where some corner shapes cut in to.
    /// - Parameters:
    ///   - corner: Corner including style and point.
    ///   - cornerStart: The point where the corner shape starts.
    ///   - cornerEnd: The point where the corner shape ends.
    ///   - nextVector: Vector from the corner to the next point.
    ///   - cutLength: Length from corner to corner start (or corner to corner end)
    /// - Returns: The point where some corner shapes cut in to. Also used to draw concave arcs.
    static func cutoutPoint(
        corner: Corner,
        cornerStart: CGPoint,
        cornerEnd: CGPoint,
        nextVector: Vector2,
        cutLength: CGFloat
    ) -> CGPoint {
        let halfStraightVector = (cornerEnd.vector - cornerStart.vector) / 2
        switch corner.style {
        case .automatic, .point, .rounded, .custom:
            return corner.point
        case .straight:
            return cornerStart.moved(halfStraightVector)
        case .cutout, .concave:
            // mirrored point
            return cornerStart.moved(nextVector.normalized * cutLength)
        }
    }
}

private extension Corner.Dimensions {
    /// Returns the additional edge length used by a continuous rounded corner.
    static func cutLengthMultiplier(for style: CornerStyle, angle: Angle) -> CGFloat {
        switch style {
        case .rounded(_, .continuous):
            continuousCutLengthMultiplier(for: angle)
        case .automatic, .point, .rounded, .concave, .straight, .cutout, .custom:
            1
        }
    }

    /// Resolves a finite cut length before deriving the drawable radius.
    ///
    /// Working in cut lengths avoids dividing a relative radius by zero at a
    /// zero-degree corner. Clamping also gives absolute radii a finite fitted
    /// limit when their requested cut would extend beyond an adjacent segment.
    static func cutLength(
        radius: RelatableValue,
        maxRadius: CGFloat,
        maxCutLength: CGFloat,
        cutLengthMultiplier: CGFloat
    ) -> CGFloat {
        guard maxCutLength > 0 else { return 0 }

        // At zero degrees maxRadius is zero, so the relative component cannot
        // be recovered by multiplying it by maxRadius. Handle that analytic
        // limit directly and let a positive absolute component fit the segment.
        guard maxRadius > 0 else {
            let components = radius.components
            if components.absolute > 0 { return maxCutLength }
            if components.absolute < 0 { return 0 }
            return min(
                max(components.relative * cutLengthMultiplier, 0),
                1
            ) * maxCutLength
        }

        // Continuous corners need more edge length than circular corners with
        // the same nominal radius. Keep relative values referenced to the
        // unscaled radius so changing rounding style does not change the radius.
        let requestedRadius = radius.value(
            using: maxRadius * cutLengthMultiplier
        )
        guard requestedRadius > 0 else { return 0 }
        guard requestedRadius < maxRadius else { return maxCutLength }

        return (requestedRadius / maxRadius) * maxCutLength
    }

    /// Derives the fitted radius from cut length without a tangent division.
    static func absoluteRadius(
        cutLength: CGFloat,
        maxRadius: CGFloat,
        maxCutLength: CGFloat
    ) -> CGFloat {
        guard cutLength > 0, maxCutLength > 0 else { return 0 }
        return (cutLength / maxCutLength) * maxRadius
    }
}
