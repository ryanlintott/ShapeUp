//
//  Vector2Transformable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public protocol Vector2Transformable: Vector2Representable {
    /// Repositions this object while keeping other properties untouched.
    /// - Parameter point: Object will be repositioned to this point.
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
    /// - Parameter anchor: Anchor point for the rotation. Default is (0,0)
    /// - Returns: The same object, rotated around the provided anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: some Vector2Representable = Vector2.zero) -> Self {
        let theta = angle.minPositiveCoterminal.radians
        if theta < 1e-12 { return self }
        
        // Get relative position
        let p = self.vector - anchor.vector
        // Get sin and cos of negative theta for positive clockwise rotations
        let s = CGFloat(sin(theta))
        let c = CGFloat(cos(theta))
        // Rotate the point about zero
        let pRotated = Vector2(dx: p.dx * c - p.dy * s, dy: p.dx * s + p.dy * c)
        // Move point back to anchor and return the object repositioned to the point.
        return repositioned(to: pRotated + anchor.vector)
    }
    
    /// Flips the position of this object across a mirror line without modifying other properties.
    ///
    /// If the start and end points of the mirror line are equal, the position is unchanged.
    /// - Parameter mirrorLineStart: Start point of mirror line.
    /// - Parameter mirrorLineEnd: End point of mirror line.
    /// - Returns: The same object, flipped across the provided mirror line.
    func flipped(mirrorLineStart: some Vector2Representable, mirrorLineEnd: some Vector2Representable) -> Self {
        // If the mirror line is just a point, don't make any changes.
        guard (mirrorLineStart.vector - mirrorLineEnd.vector).magnitudeSquared > 1e-12 else { return self }
        
        let pointToMirrorStart = self.vector - mirrorLineStart.vector
        let mirrorEndToMirrorStart = mirrorLineEnd.vector - mirrorLineStart.vector
        let pointToMirrorPoint = pointToMirrorStart.perpendicularComponent(to: mirrorEndToMirrorStart) * -2
        return moved(pointToMirrorPoint)
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
    @available(*, deprecated: 100000, renamed: "scaledPosition(_:)")
    func scaledPosition(scale: CGSize) -> CGPoint {
        .init(vector: vector * scale)
    }
    
    /// Returns the position after being scaled from the origin.
    /// - Parameters:
    ///   - width: Used to scale the x position.
    ///   - height: Used to scale the y position.
    /// - Returns: Position after being scaled from the origin.
    @available(*, deprecated: 100000, renamed: "scaledPosition(x:y:)")
    func scaledPosition(width: CGFloat? = nil, height: CGFloat? = nil) -> CGPoint {
        scaledPosition(scale: .init(width: width ?? 1, height: height ?? 1))
    }
    
    /// Scales the position of this object without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same object, scaled by the specified amount.
    func scaledPosition(_ scale: CGSize, anchor: some Vector2Representable = CGPoint.zero) -> Self {
        repositioned(to: (vector - anchor.vector) * scale + anchor.vector)
    }
    
    /// Scales the position of this object without modifying other properties.
    /// - Parameters:
    ///   - x: Used to scale the x position.
    ///   - y: Used to scale the y position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same object, scaled by the specified amount.
    func scaledPosition(x: CGFloat = 1, y: CGFloat = 1, anchor: some Vector2Representable = CGPoint.zero) -> Self {
        scaledPosition(.init(width: x, height: y), anchor: anchor)
    }
    
    /// Scales the position of this object without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same object, scaled by the specified amount.
    func scaledPosition(_ scale: CGFloat, anchor: some Vector2Representable = CGPoint.zero) -> Self {
        scaledPosition(.init(width: scale, height: scale), anchor: anchor)
    }
    
    /// Repositions the object from one frame of reference to another.
    /// - Parameters:
    ///   - source: Initial frame of reference.
    ///   - destination: Resulting frame of reference.
    /// - Returns: The same object, repositioned from one frame of reference to another.
    func repositioned(from source: some CGFrameRepresentable, to destination: some CGFrameRepresentable) -> Self {
        repositioned(to: destination[vector.point.relative(to: source)])
    }
}
