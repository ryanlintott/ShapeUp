//
//  RectAnchorRepresentable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-15.
//

import SwiftUI

public protocol RectAnchorRepresentable {
    var anchorPoint: RectAnchor { get }
}

public protocol RectAnchorTransformable: RectAnchorRepresentable {
    /// Repositions this object while keeping other properties untouched.
    /// - Returns: The same object, moved to a new anchor point.
    func repositioned(to anchorPoint: some RectAnchorRepresentable) -> Self
}

// # MARK: Private extensions to use Vector2Transformable logic inside RectAnchorTransformable.

fileprivate extension RectAnchor {
    var vector: Vector2 {
        point(in: .one).vector
    }
}

fileprivate extension Vector2 {
    var anchorPoint: RectAnchor {
        .relative(x: vector.dx, y: vector.dy)
    }
}

fileprivate extension RectAnchorTransformable {
    func repositioned(to point: some Vector2Representable) -> Self {
        repositioned(to: point.vector.anchorPoint)
    }
}

// # MARK: Methods to move, rotate, flip, inset and scale RectAnchorTransformable types.

public extension RectAnchorTransformable {
    /// Moves the position of this object without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: The same object, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        repositioned(to: anchorPoint.vector.moved(dx: dx, dy: dy))
    }
    
    /// Rotates the position of this object without modifying other properties.
    /// - Parameter angle: Angle of rotation. Clockwise is positive for SwiftUI.
    /// - Parameter anchor: Anchor point for the rotation.
    /// - Returns: The same object, rotated around the provided anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: some RectAnchorRepresentable) -> Self {
        repositioned(to: anchorPoint.vector.rotated(angle, anchor: anchor.anchorPoint.vector))
    }
    
    /// Rotates the position of this object around the origin without modifying other properties.
    /// - Parameter angle: Rotation angle.
    /// - Returns: The same object, rotated around the origin by the provided angle.
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: RectAnchor.topLeft)
    }
    
    /// Flips the position of this object across a mirror line without modifying other properties.
    ///
    /// If the start and end points of the mirror line are equal, the position is unchanged.
    /// - Parameter mirrorLineStart: Start point of mirror line.
    /// - Parameter mirrorLineEnd: End point of mirror line.
    /// - Returns: The same object, flipped across the provided mirror line.
    func flipped(mirrorLineStart: some Vector2Representable, mirrorLineEnd: some Vector2Representable) -> Self {
        repositioned(to: anchorPoint.vector.flipped(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd))
    }
    
    /// Inset position of this object defined by straight lines between the position of the previous object, this object, and the next object.
    ///
    /// Positive inset goes to the right of the line from previous point to this one. This assumes a shape drawn in a clockwise manner.
    /// - Parameters:
    ///   - amount: Inset amount.
    ///   - previousPoint: Point before this one used to determine the corner angle.
    ///   - nextPoint: Point after this one used to determine the corner angle.
    /// - Returns: Position of this point after being inset.
    func insetAnchorPoint(_ amount: CGFloat, previousAnchorPoint: RectAnchor? = nil, nextAnchorPoint: RectAnchor? = nil) -> RectAnchor {
        anchorPoint
            .vector
            .insetPoint(
                amount,
                previousPoint: previousAnchorPoint?.point(in: .one),
                nextPoint: nextAnchorPoint?.point(in: .one)
            )
            .vector
            .anchorPoint
    }
    
    /// Returns the position after being scaled from the origin.
    /// - Parameters:
    ///   - scale: Used to scale the position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: Position after being scaled from the origin.
    func scaledPosition(_ scale: CGSize, anchor: some RectAnchorRepresentable = RectAnchor.topLeft) -> Self {
        repositioned(to: anchorPoint.vector.scaledPosition(scale, anchor: anchor.anchorPoint.vector))
    }
    
    /// Returns the position after being scaled from the origin.
    /// - Parameters:
    ///   - x: Used to scale the x position.
    ///   - y: Used to scale the y position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: Position after being scaled from the origin.
    func scaledPosition(x: CGFloat = 1, y: CGFloat = 1, anchor: some RectAnchorRepresentable = RectAnchor.topLeft) -> Self {
        scaledPosition(.init(width: x, height: y), anchor: anchor)
    }
}
