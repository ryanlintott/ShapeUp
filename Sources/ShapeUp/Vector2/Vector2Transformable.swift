//
//  Vector2Transformable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public protocol Vector2Transformable: Vector2Representable {
    /// Repositions while keeping other properties untouched.
    /// - Returns: The same object, respositioned to a new point.
    func repositioned<T: Vector2Representable>(to point: T) -> Self
}

public extension Vector2Transformable {
    /// Moves a Vector2Transformable type without modifying other properties.
    /// - Parameter distance: A vector representing the movement.
    /// - Returns: The same object, moved by the provided distance.
    func moved<T: Vector2Representable>(_ distance: T) -> Self {
        let vector = self.vector + distance.vector
        return repositioned(to: vector)
    }
    
    /// Moves a Vector2Transformable type without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: The same object, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        moved(Vector2(dx: dx, dy: dy))
    }
    
    /// Rotates a Vector2Transformable type without modifying other properties.
    /// - Parameter angle: Angle of rotation. Clockwise is positive for SwiftUI.
    /// - Parameter anchor: Anchor point for the rotation.
    /// - Returns: The same object, rotated around the provided anchor by the provided angle.
    func rotated<T: Vector2Representable>(_ angle: Angle, anchor: T) -> Self {
        // Get relative position
        let p = self.vector - anchor.vector
        // Get sin and cos of angle
        let s = CGFloat(sin(angle.radians))
        let c = CGFloat(cos(angle.radians))
        // Rotate the point about zero
        let pRotated = Vector2(dx: p.dx * c - p.dy * s, dy: p.dx * s + p.dy * c)
        // Move point back to anchor and return the object repositioned to the point.
        return repositioned(to: pRotated + anchor.vector)
    }
    
    /// Rotates a Vector2Transformable type without modifying other properties.
    /// - Parameter angle: Rotation angle.
    /// - Returns: The same object, rotated around zero by the provided angle.
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: CGPoint.zero)
    }
    
    /// Flips a Vector2Transformable type without modifying other properties.
    ///
    /// If start and end are equal, points are unchanged.
    /// - Parameter mirrorLineStart: Start point of mirror line.
    /// - Parameter mirrorLineEnd: End point of mirror line.
    /// - Returns: The same object, flipped across the provided line.
    func flipped<T: Vector2Representable, U: Vector2Representable>(mirrorLineStart: T, mirrorLineEnd: U) -> Self {
        // If the mirror line is just a point, don't make any changes.
        if mirrorLineStart.point == mirrorLineEnd.point { return self }
        
        let vector = self.vector
        let vectorToPoint = vector - mirrorLineStart.vector
        let angle = Angle.threePoint(mirrorLineEnd, mirrorLineStart, self) * 2
        return repositioned(to: vector - vectorToPoint + vectorToPoint.rotated(-angle))
    }
    
    /// Inset position of a corner defined by straight lines between previous point, this point, and next point.
    ///
    /// Positive inset goes to the right of the line from previous point to this one.
    /// - Parameters:
    ///   - amount: Inset amount.
    ///   - previousPoint: Point before this one used to determine the corner angle.
    ///   - nextPoint: Point after this one used to determine the corner angle.
    /// - Returns: Position of this corner after being inset.
    func insetPoint(_ amount: CGFloat, previousPoint: CGPoint? = nil, nextPoint: CGPoint? = nil) -> CGPoint {
        let insetVector: Vector2
        
        switch (previousPoint, nextPoint) {
        case (nil, nil):
            // Inset not possible as there is no line.
            insetVector = .zero
        case let (nil, .some(nextPoint)):
            // Find the vector from this point to the next one and then inset to the right.
            insetVector = (nextPoint.vector - self.vector).normalized.rotated(.degrees(90)) * amount
        case let (.some(previousPoint), nil):
            // Find the vector from the previous point to this one and then inset to the right.
            insetVector = (self.vector - previousPoint.vector).normalized.rotated(.degrees(90)) * amount
            return ((self.vector - previousPoint.vector).normalized.rotated(.degrees(90)) * amount).point
        case let (.some(previousPoint), .some(nextPoint)):
            // Positive clockwise angle of this corner.
            let angle = Angle.threePoint(nextPoint, self, previousPoint)
            // Half of the magnitude of the min rotation corner angle
            let halvedRadiusAngle = angle.nonReflexCoterminal.positive.halved
            // Vector from the corner to the previous corner
            let nextVector = nextPoint.vector - self.vector
            
            // Length from corner to inset corner
            let insetLength = amount / sin(halvedRadiusAngle.radians)
            
            // Vector from corner to inset corner
            insetVector = nextVector.normalized.rotated(angle.halved) * insetLength
            
        }
        return (self.vector + insetVector).point
    }
}
