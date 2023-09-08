//
//  Vector2Transformable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public protocol Vector2Transformable: Vector2Representable {
    /// Repositions this object while keeping other properties untouched.
    /// - Returns: The same object, moved to a new position.
    func repositioned(to point: some Vector2Representable) -> Self
}

public extension Vector2Transformable {
    /// Moves the position of this object without modifying other properties.
    /// - Parameter distance: A vector representing the movement.
    /// - Returns: The same object, moved by the provided distance.
    func moved(_ distance: some Vector2Representable) -> Self {
        let vector = self.vector + distance.vector
        return repositioned(to: vector)
    }
    
    /// Moves the position of this object without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: The same object, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        moved(Vector2(dx: dx, dy: dy))
    }
    
    /// Rotates the position of this object without modifying other properties.
    /// - Parameter angle: Angle of rotation. Clockwise is positive for SwiftUI.
    /// - Parameter anchor: Anchor point for the rotation.
    /// - Returns: The same object, rotated around the provided anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: some Vector2Representable) -> Self {
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
    
    /// Rotates the position of this object aroudn the origin without modifying other properties.
    /// - Parameter angle: Rotation angle.
    /// - Returns: The same object, rotated around the origin by the provided angle.
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: CGPoint.zero)
    }
    
    /// Flips the position of this object across a mirror line without modifying other properties.
    ///
    /// If the start and end points of the mirror line are equal, the position is unchanged.
    /// - Parameter mirrorLineStart: Start point of mirror line.
    /// - Parameter mirrorLineEnd: End point of mirror line.
    /// - Returns: The same object, flipped across the provided mirror line.
    func flipped(mirrorLineStart: some Vector2Representable, mirrorLineEnd: some Vector2Representable) -> Self {
        // If the mirror line is just a point, don't make any changes.
        if mirrorLineStart.point == mirrorLineEnd.point { return self }
        
        let vector = self.vector
        let vectorToPoint = vector - mirrorLineStart.vector
        let angle = Angle.threePoint(mirrorLineEnd, mirrorLineStart, self) * 2
        return repositioned(to: vector - vectorToPoint + vectorToPoint.rotated(-angle))
    }
    
    /// Inset position of this object defined by straight lines between the position of the previous object, this object, and the next object.
    ///
    /// Positive inset goes to the right of the line from previous point to this one. This assumes a shape drawn in a clockwise manner.
    /// - Parameters:
    ///   - amount: Inset amount.
    ///   - previousPoint: Point before this one used to determine the corner angle.
    ///   - nextPoint: Point after this one used to determine the corner angle.
    /// - Returns: Position of this point after being inset.
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
    
    /// Returns the position after being scaled from the origin.
    /// - Parameter scale: Used to scale the position.
    /// - Returns: Position after being scaled from the origin.
    func scaledPosition(scale: CGSize) -> CGPoint {
        .init(vector: vector * scale)
    }
    
    /// Returns the position after being scaled from the origin.
    /// - Parameters:
    ///   - width: Used to scale the x position.
    ///   - height: Used to scale the y position.
    /// - Returns: Position after being scaled from the origin.
    func scaledPosition(width: CGFloat? = nil, height: CGFloat? = nil) -> CGPoint {
        scaledPosition(scale: .init(width: width ?? 1, height: height ?? 1))
    }
    
    /// Repositions the object from one frame of reference to another.
    /// - Parameters:
    ///   - source: Initial frame of reference.
    ///   - destination: Resulting frame of reference.
    /// - Returns: The same object, repositioned from one frame of reference to another.
    func repositioned(from source: CGRect, to destination: CGRect) -> Self {
        let widthScale = source.width == 0 ? destination.width : destination.width / source.width
        let heightScale = source.height == 0 ? destination.height : destination.height / source.height

        let point = (source.origin.vector - point.vector).scaledPosition(width: widthScale, height: heightScale)
        return self.repositioned(to: point)
    }
}
