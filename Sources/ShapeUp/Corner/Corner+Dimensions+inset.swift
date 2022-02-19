//
//  Corner+Dimensions+inset.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

public extension Corner.Dimensions {
    func insetValues(_ insetAmount: CGFloat) -> (point: CGPoint, radius: CGFloat) {
        // Default insetPoint works for most cases
        var insetPoint = corner.insetPoint(insetAmount, previousPoint: previousPoint, nextPoint: nextPoint)
        // Inset radius is initialized to the current absolute radius value
        var insetRadius = absoluteRadius
        // Default radius inset works for most cases
        let radiusInset = insetAmount * reflexMultiplier
        
        switch corner.style {
        case .point, .cutout:
            // both of these values just use the default inset and unchanged radius
            break
        case .rounded:
            // radius shrinks with inset on non-reflex corners
            insetRadius -= radiusInset
        case .concave:
            // radius grows with inset on non-reflext corners
            insetRadius += radiusInset
        case .straight:
            // The cornerStart of the new inset point
            let insetStart = cornerStart.insetPoint(insetAmount, previousPoint: previousPoint, nextPoint: cornerEnd)
            // The cornerEnd of the new inset point
            let insetEnd = cornerEnd.insetPoint(insetAmount, previousPoint: cornerStart, nextPoint: nextPoint)
            // Compare these two vectors to see if the straight cut is positive or negative
            let isStraightCutPositive = (insetStart.vector - cornerStart.vector).magnitude < (insetEnd.vector - cornerStart.vector).magnitude
            // Create a sign multiplier based on the straight cut sign
            let straightCutSignMultiplier = isStraightCutPositive ? 1.0 : -1
            // The positive length of the line between inset start and end
            let straightCutLength = (insetEnd.vector - insetStart.vector).magnitude * straightCutSignMultiplier
            // The radius angle will be the same for the inset. It can be used with half the straight cut line to determine the inset radius
            insetRadius = (straightCutLength * 0.5) / abs(sin(halvedRadiusAngle.radians))
            // Cut length between the inset point and the inset corner start point
            let insetCutLength = insetRadius * abs(tan(halvedRadiusAngle.radians))
            // Vector pointing in the right direction with the correct length
            let insetCutVector = previousVector.normalized * -insetCutLength
            // Add inset start to inset cut vector to get the actual inset point
            insetPoint = (insetStart.vector + insetCutVector).point
        }
        return (point: insetPoint, radius: insetRadius)
    }
    
    /// Creates an inset version of this corner adjusting any nested corner styles.
    ///
    /// Some corner styles may change to .point if the radius drops below zero
    /// - Parameters:
    ///   - inset: Amount of the inset.
    ///   - allowNegativeRadius: Boolean To set
    /// - Returns: An inset version of this corner.
    func corner(inset: CGFloat, allowNegativeRadius: Bool? = nil) -> Corner {
        let allowNegativeRadius = allowNegativeRadius ?? false
        if inset == 0 { return corner }
        
        let insetValues = insetValues(inset)
        let insetPoint = insetValues.point
        let insetRadius = RelatableValue.absolute(allowNegativeRadius ? insetValues.radius : max(0, insetValues.radius))
        
        let insetCornerStyle: CornerStyle
        
        switch corner.style {
        case .point:
            insetCornerStyle = .point
            
        case .rounded:
            insetCornerStyle = .rounded(radius: insetRadius)
            
        case let .concave(_, radiusOffset):
            let radiusInset = inset * reflexMultiplier
            let insetRadiusOffset = (radiusOffset ?? 0) + radiusInset
            insetCornerStyle = .concave(radius: insetRadius, radiusOffset: insetRadiusOffset)
            
        case let .straight(_, cornerStyles):
            let nestedCornerStyles = zip(cornerStyles, [cornerStart, cornerEnd])
                .map { style, vector in
                    vector.corner(style)
                }
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .map { $0.corner(inset: inset, allowNegativeRadius: allowNegativeRadius).style }

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
