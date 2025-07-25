//
//  Corner+Dimensions+inset.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Corner.Dimensions {
    /// Returns the point, radius and radius offset for the inset corner.
    /// - Parameter insetAmount: Amount to inset.
    /// - Returns: The point, radius and radius offset for the inset corner.
    internal func insetValues(_ insetAmount: CGFloat) -> (point: CGPoint, radius: CGFloat, radiusOffset: CGFloat) {
        // The same inset point works for all cases
        let insetPoint = corner.insetPoint(insetAmount, previousPoint: previousPoint, nextPoint: nextPoint)
        // Inset radius value will be set in the switch below
        let insetRadius: CGFloat
        // Default radius inset works for most cases
        let radiusInset = insetAmount * reflexMultiplier
        // Default concave inset radius only changed
        var insetRadiusOffset: CGFloat? = nil
        
        switch corner.style {
        case .point, .cutout, .custom:
            // Inset radius is unchanged
            insetRadius = absoluteRadius
            
        case .rounded:
            // radius shrinks with inset on non-reflex corners
            insetRadius = absoluteRadius - radiusInset
            
        case .concave:
            // Radius doesn't change
            insetRadius = absoluteRadius
            // Radius offset just stores the inset value so the corner can be calculated correctly.
            insetRadiusOffset = radiusOffset + insetAmount
        case .straight:
            // The cornerStart of the new inset point
            let insetStart = cornerStart.insetPoint(insetAmount, previousPoint: previousPoint, nextPoint: cornerEnd)
            // The cornerEnd of the new inset point
            let insetEnd = cornerEnd.insetPoint(insetAmount, previousPoint: cornerStart, nextPoint: nextPoint)
            
            // If radius is negative, the straight cut is pointing the other way and the corner crosses over.
            let straightCutSignMultiplier = absoluteRadius >= 0 ? 1.0 : -1
            // Compare these two vectors to see if the straight cut after the inset matches the same orientation
            let insetStraightCutSignMatchingMultiplier = (insetStart.vector - cornerStart.vector).magnitude < (insetEnd.vector - cornerStart.vector).magnitude ? 1.0 : -1
            // Create a sign multiplier based on the straight cut sign before and after the inset
            let insetStraightCutSignMultiplier = straightCutSignMultiplier * insetStraightCutSignMatchingMultiplier
            // The positive length of the line between inset start and end
            let straightCutLength = (insetEnd.vector - insetStart.vector).magnitude * insetStraightCutSignMultiplier
            // The radius angle will be the same for the inset. It can be used with half the straight cut line to determine the inset radius
            insetRadius = (straightCutLength * 0.5) / abs(sin(halvedRadiusAngle.radians))
        }
        return (point: insetPoint, radius: insetRadius, radiusOffset: insetRadiusOffset ?? 0)
    }
    
    /// Creates an inset version of this corner adjusting any nested corner styles.
    ///
    /// Some corner styles may change to .point if the radius drops below zero
    /// - Parameters:
    ///   - inset: Amount of the inset.
    /// - Returns: An inset version of this corner.
    public func corner(inset: CGFloat) -> Corner {
        if inset == 0 { return corner }
        
        let insetValues = insetValues(inset)
        let insetPoint = insetValues.point
        let insetRadius = RelatableValue.absolute(insetValues.radius)
        
        let insetCornerStyle: CornerStyle
        
        switch corner.style {
        case .point:
            insetCornerStyle = .point
            
        case .rounded:
            insetCornerStyle = .rounded(radius: insetRadius)
            
        case .concave:
            insetCornerStyle = .concave(radius: insetRadius, radiusOffset: insetValues.radiusOffset)
            
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
            let insetSubcorners = subCorners
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .corners(inset: inset)
            /// The Rhombus is the same size, just moved to the new inset location.
                .relative(
                    to: CGFrame(
                        origin: insetPoint.moved(-startVector),
                        xAxis: startVector,
                        yAxis: endVector
                    )
                )
            
            insetCornerStyle = .custom(radius: insetRadius, relativeCorners: insetSubcorners)
        }
        
        return insetPoint.corner(insetCornerStyle)
    }
}
