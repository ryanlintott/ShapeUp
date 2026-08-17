//
//  Corner+Dimensions+inset.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Corner.Dimensions {
    /// Returns the radius for the inset corner style.
    /// - Parameter insetAmount: The amount to inset this corner.
    /// - Returns: The radius for the inset corner style.
    internal func insetRadius(for insetAmount: CGFloat) -> CGFloat {
        switch corner.style {
        case .automatic, .point, .cutout, .custom:
            // Inset radius is unchanged
            return absoluteRadius
        case .rounded:
            // radius shrinks with inset on non-reflex corners
            return absoluteRadius - (insetAmount * reflexMultiplier)
        case .concave:
            // Radius doesn't change
            return absoluteRadius
        case .straight:
            // The cornerStart of the new inset point
            let insetStart = cornerStart.insetPoint(
                insetAmount,
                previousPoint: previousPoint,
                nextPoint: cornerEnd
            )
            // The cornerEnd of the new inset point
            let insetEnd = cornerEnd.insetPoint(
                insetAmount,
                previousPoint: cornerStart,
                nextPoint: nextPoint
            )
            
            // If radius is negative, the straight cut is pointing the other way and the corner crosses over.
            let straightCutSignMultiplier = absoluteRadius >= 0 ? 1.0 : -1
            // Compare these two vectors to see if the straight cut after the inset matches the same orientation
            let insetStraightCutSignMatchingMultiplier = (insetStart.vector - cornerStart.vector).magnitude < (insetEnd.vector - cornerStart.vector).magnitude ? 1.0 : -1
            // Create a sign multiplier based on the straight cut sign before and after the inset
            let insetStraightCutSignMultiplier = straightCutSignMultiplier * insetStraightCutSignMatchingMultiplier
            // The positive length of the line between inset start and end
            let straightCutLength = (insetEnd.vector - insetStart.vector).magnitude * insetStraightCutSignMultiplier
            // The turn angle will be the same for the inset. It can be used with half the straight cut line to determine the inset radius
            let radiusAngleSine = abs(sin(halvedTurnAngle.radians))
            return radiusAngleSine > 1e-12
                ? (straightCutLength * 0.5) / radiusAngleSine
                : absoluteRadius
        }
    }
    
    /// Creates an inset version of this corner adjusting any nested corner styles.
    ///
    /// At zero degrees, the corner remains unchanged. At 180 degrees, the
    /// corner translates while preserving its style.
    ///
    /// Some corner styles may change to .point if the radius drops below zero
    /// - Parameter inset: Amount of the inset.
    /// - Returns: An inset version of this corner.
    internal func corner(inset: CGFloat) -> Corner {
        if inset == 0 || angle.isApproximatelyZero() { return corner }

        let insetPoint = corner.insetPoint(
            inset,
            previousPoint: previousPoint,
            nextPoint: nextPoint
        )

        // At 180 degrees an inset simply translates the corner while preserving its style.
        if angle.isApproximatelyStraight() {
            return insetPoint.corner(corner.style)
        }

        let insetRadius = RelatableValue.absolute(insetRadius(for: inset))
        
        let insetCornerStyle: CornerStyle
        
        switch corner.style {
        case .automatic:
            insetCornerStyle = .automatic

        case .point:
            insetCornerStyle = .point
            
        case let .rounded(_, style):
            insetCornerStyle = .rounded(radius: insetRadius, style: style)
            
        case .concave:
            insetCornerStyle = .concave(
                radius: insetRadius,
                concaveInset: concaveInset + inset
            )
            
        case .straight:
            let nestedCornerStyles = subCorners
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .corners(inset: inset)
                .cornerStyles

            insetCornerStyle = .straight(radius: insetRadius, cornerStyles: nestedCornerStyles)
            
        case .cutout:
            let nestedCornerStyles = subCorners
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .corners(inset: inset)
                .cornerStyles
            
            insetCornerStyle = .cutout(radius: insetRadius, cornerStyles: nestedCornerStyles)
            
        case .custom:
            let frame = CGFrame(
                origin: insetPoint.moved(-startVector),
                xAxis: startVector,
                yAxis: endVector
            )
            let insetSubcorners = subCorners
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .corners(inset: inset)
            /// The frame is the same size, just moved to the new inset location.
                .map { $0.relative(to: frame) }
            
            insetCornerStyle = .custom(radius: insetRadius, relativeCorners: insetSubcorners)
        }
        
        return insetPoint.corner(insetCornerStyle)
    }
}
