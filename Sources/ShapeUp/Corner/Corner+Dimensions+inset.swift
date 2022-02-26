//
//  Corner+Dimensions+inset.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

public extension Corner.Dimensions {
    func insetValues(_ insetAmount: CGFloat) -> (point: CGPoint, radius: CGFloat, concaveRadius: CGFloat) {
        // Default insetPoint works for most cases
        var insetPoint = corner.insetPoint(insetAmount, previousPoint: previousPoint, nextPoint: nextPoint)
        // Inset radius is initialized to the current absolute radius value
        var insetRadius = absoluteRadius
        // Default radius inset works for most cases
        let radiusInset = insetAmount * reflexMultiplier
        // Default concave inset radius
        var insetConcaveRadius = concaveRadius
        
        switch corner.style {
        case .point, .cutout:
            // both of these values just use the default inset and unchanged radius
            break
        case .rounded:
            // radius shrinks with inset on non-reflex corners
            insetRadius -= radiusInset
        case .concave:
            insetConcaveRadius += radiusInset
            
#warning("Inset radius is based on the new inset point and the concave radius center (that never changes)")
            // radius grows with inset on non-reflext corners
            insetRadius = Self.absoluteRadius(cornerPoint: insetPoint, concaveRadiusCenter: concaveRadiusCenter, concaveRadius: insetConcaveRadius, halvedNonReflexAngle: halvedNonReflexAngle, previousVector: previousVector)
//            insetRadius += radiusInset
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
        return (point: insetPoint, radius: insetRadius, concaveRadius: insetConcaveRadius)
    }
    
    /// Creates an inset version of this corner adjusting any nested corner styles.
    ///
    /// Some corner styles may change to .point if the radius drops below zero
    /// - Parameters:
    ///   - inset: Amount of the inset.
    ///   - allowNegativeRadius: Boolean To set
    /// - Returns: An inset version of this corner.
    func corner(inset: CGFloat) -> Corner {
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
            let insetConcaveRadius = insetValues.concaveRadius
            let insetRadiusOffset = insetConcaveRadius - insetValues.radius
            
            insetCornerStyle = .concave(radius: insetRadius, radiusOffset: insetRadiusOffset)
            
        case let .straight(_, cornerStyles):
            let nestedCornerStyles = zip(cornerStyles, [cornerStart, cornerEnd])
                .map { style, vector in
                    vector.corner(style)
                }
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .map { $0.corner(inset: inset).style }

            insetCornerStyle = .straight(radius: insetRadius, cornerStyles: nestedCornerStyles)
            
        case let .cutout(_, cornerStyles):
            let nestedCornerStyles = zip(cornerStyles, [cornerStart, cutoutPoint, cornerEnd])
                .map { style, vector in
                    vector.corner(style)
                }
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .map { $0.corner(inset: inset).style }
            
            insetCornerStyle = .cutout(radius: insetRadius, cornerStyles: nestedCornerStyles)
        }
        
        return insetPoint.corner(insetCornerStyle)
    }
}
