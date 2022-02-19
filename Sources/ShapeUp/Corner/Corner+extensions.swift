//
//  Corner+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

extension Corner: Vector2Transformable {
    public var vector: Vector2 {
        Vector2(dx: x, dy: y)
    }
    
    public init(vector: Vector2) {
        x = vector.dx
        y = vector.dy
        style = .point
    }
    
    public func repositioned<T: Vector2Representable>(to point: T) -> Corner {
        Corner(style, point: point)
    }
}

extension Corner {
    /// Radius of corner based on the style.
    public var radius: RelatableValue {
        style.radius
    }
    
    /// Creates a corner at the same position but with the supplied style.
    /// - Parameter style: Corner style to apply.
    /// - Returns: A corner at the same position but with the supplied style.
    public func applyingStyle(_ style: CornerStyle) -> Corner {
        Corner(style, point: point)
    }
    
    /// Creates a corner with the same style at the same position but with a new supplied radius.
    /// - Parameter radius: Radius to apply to the corner.
    /// - Returns: A corner with the same style at the same position but with a new supplied radius.
    public func changingRadius(to radius: RelatableValue) -> Corner {
        applyingStyle(style.changingRadius(to: radius))
    }
    
    #warning("Should probably change previous and next to Vector2Representable")
    /// Creates an inset corner with adjusted style to match inset amount.
    ///
    /// Assumes a clockwise shape order from previous to next corners.
    /// - Parameters:
    ///   - insetAmount: Amount corner will be inset.
    ///   - previousCorner: Corner before this one in a shape.
    ///   - nextCorner: Corner after this one in a shape.
    /// - Returns: An inset corner with adjusted style to match inset amount.
    internal func inset(_ insetAmount: CGFloat, previousCorner: Corner, nextCorner: Corner) -> Corner {
        dimensions(previousPoint: previousCorner.point, nextPoint: nextCorner.point)
            .corner(inset: insetAmount)
    }
    
    #warning("Move this to Corner.Dimensions and reference here")
    /// Creates an array of corners representing this corner flattened one level.
    ///
    /// This function may need to be run recursively to acheive a fully flattened array of corners. Relative values are changed to absolute values and any corner styles that contain nested corner styles that are not points will be reduced to an array of corners with those corner styles.
    ///
    /// Assumes a clockwise shape order from previous to next corners.
    /// - Parameters:
    ///   - previousCorner: Corner before this one in a shape.
    ///   - nextCorner: Corner after this one in a shape.
    /// - Returns: An array of corners representing this corner flattened one level.
    internal func flatten(previousCorner: Corner, nextCorner: Corner) -> [Corner] {
        if self.style.isFlat {
            return [self]
        }
        
        let corner = self
        // Angle of the corner
        let angle = Angle.threePoint(nextCorner, corner, previousCorner)
        // Half of the anlge used by the rounded curve of the corner
        let halvedRadiusAngle = angle.nonReflexCoterminal.supplementary.halved
        
        // Vector from the corner to the previous corner
        let previousVector = previousCorner.vector - corner.vector
        // Vector from the corner to the next corner
        let nextVector = nextCorner.vector - corner.vector
        
        // The maximum cut length from the corner. Any further and it would go beyond the next or previous corner.
        let maxCutLength = min(previousVector.magnitude, nextVector.magnitude)
        
        // The maximum radius that results from using the maximum cut length.
        let maxRadius = maxCutLength * CGFloat(tan(halvedRadiusAngle.radians))
        // Absolute value of corner radius relative to maximum radius.
        let cornerRadius = corner.radius.value(using: maxRadius)
        // Cut length based on corner radius
        let cutLength = maxCutLength * cornerRadius / maxRadius
        
        let cornerCutStart = corner.vector + (previousVector.normalized * cutLength)
        let cornerCutEnd = corner.vector + (nextVector.normalized * cutLength)

        switch corner.style {
        case .point, .rounded, .concave:
            return [corner.changingRadius(to: .absolute(radius.value(using: maxRadius)))]
        case let .straight(_, cornerStyles):
            return [
                cornerCutStart,
                cornerCutEnd
            ]
            .corners(cornerStyles)
        case let .cutout(_, cornerStyles):
            return [
                cornerCutStart,
                cornerCutStart + (nextVector.normalized * cutLength),
                cornerCutEnd
            ]
            .corners(cornerStyles)
        }
    }
}
