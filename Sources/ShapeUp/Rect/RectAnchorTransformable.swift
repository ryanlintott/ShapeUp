//
//  RectAnchorTransformable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-15.
//

import SwiftUI

public protocol RectAnchorTransformable {
    var anchor: RectAnchor { get }
    
    /// Repositions this object while keeping other properties untouched.
    /// - Parameter anchor: The new anchor to reposition to.
    /// - Returns: The same object, moved to a new anchor point.
    func repositioned(to anchor: RectAnchor) -> Self
}

// # MARK: Private extensions to use Vector2Transformable logic inside RectAnchorTransformable.

internal extension RectAnchor {
    var vector: Vector2 {
        point(in: .one).vector
    }
}

fileprivate extension Vector2 {
    var anchor: RectAnchor {
        .relative(x: vector.dx, y: vector.dy)
    }
}

fileprivate extension RectAnchorTransformable {
    func repositioned(to point: some Vector2Representable) -> Self {
        repositioned(to: point.vector.anchor)
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
        repositioned(to: anchor.vector.moved(dx: dx, dy: dy))
    }
    
    /// Rotates the position of this object without modifying other properties.
    /// - Parameters:
    ///   - angle: Angle of rotation. Clockwise is positive for SwiftUI.
    ///   - anchor: Anchor point for the rotation. Default is `.topLeft`
    /// - Returns: The same object, rotated around the provided anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: RectAnchor = .topLeft) -> Self {
        repositioned(to: self.anchor.vector.rotated(angle, anchor: anchor.anchor.vector))
    }
    
    /// Flips the position of this object across a mirror line without modifying other properties.
    ///
    /// If the start and end anchors of the mirror line are equal, the position is unchanged.
    /// - Parameters:
    ///   - mirrorLineStart: Start anchor point of mirror line.
    ///   - mirrorLineEnd: End anchor point of mirror line.
    /// - Returns: The same object, flipped across the provided mirror line.
    func flipped(mirrorLineStart: RectAnchor, mirrorLineEnd: RectAnchor) -> Self {
        repositioned(to: anchor.vector.flipped(mirrorLineStart: mirrorLineStart.vector, mirrorLineEnd: mirrorLineEnd.vector))
    }
    
    /// Returns the position after being scaled from the anchor point.
    /// - Parameters:
    ///   - scale: Used to scale the position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same object with position scaled from the anchor point.
    func scaledPosition(_ scale: CGSize, anchor: RectAnchor = .topLeft) -> Self {
        repositioned(to: self.anchor.vector.scaledPosition(scale, anchor: anchor.anchor.vector))
    }
    
    /// Returns the position after being scaled from the anchor point.
    /// - Parameters:
    ///   - x: Used to scale the x position.
    ///   - y: Used to scale the y position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same object with position scaled from the anchor point.
    func scaledPosition(x: CGFloat = 1, y: CGFloat = 1, anchor: RectAnchor = .topLeft) -> Self {
        scaledPosition(.init(width: x, height: y), anchor: anchor)
    }
    
    /// Returns the position after being scaled from the anchor point.
    /// - Parameters:
    ///   - scale: Used to scale the position.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same object with position scaled from the anchor point.
    func scaledPosition(_ scale: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        scaledPosition(.init(width: scale, height: scale), anchor: anchor)
    }
}

// # MARK: Array methods

public extension Array where Element: RectAnchorTransformable {
    var anchors: [RectAnchor] {
        map { $0.anchor }
    }
    
    /// Moves the positions of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: The same array of objects, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        map { $0.moved(dx: dx, dy: dy) }
    }
    
    /// Rotates the position of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Anchor point for the rotation.
    /// - Returns: The same array of objects, rotated around the provided anchor point by the provided angle.
    func rotated(_ angle: Angle, anchor: RectAnchor) -> Self {
        map { $0.rotated(angle, anchor: anchor) }
    }
    
    /// Rotates the position of this array of objects around the origin without modifying other properties.
    /// - Parameter angle: Rotation angle.
    /// - Returns: The same array of objects rotated around the origin by the provided angle.
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: .topLeft)
    }
    
    /// Flips the positions of this array of objects across a mirror line without modifying other properties.
    ///
    /// If the start and end points of the mirror line are equal, the positions are unchanged.
    /// - Parameters:
    ///   - mirrorLineStart: Start point of mirror line.
    ///   - mirrorLineEnd: End point of mirror line.
    /// - Returns: The same array of objects flipped across the provided mirror line.
    func flipped(mirrorLineStart: RectAnchor, mirrorLineEnd: RectAnchor) -> Self {
        map { $0.flipped(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) }
    }
    
    /// Flips the positions of this array of objects horizontally without modifying other properties.
    /// - Parameter x: X coordinate of the vertical mirror line.
    /// - Returns: The same array of objects flipped horizontally across a vertical mirror line.
    func flippedHorizontally(across x: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: .relative(x: x, y: .zero), mirrorLineEnd: .relative(x: x, y: 1))
    }
    
    /// Flips the positions of this array of objects vertically without modifying other properties.
    /// - Parameter y: Y coordinate of the horizontal mirror line.
    /// - Returns: The same array of objects flipped vertically across a horizontal mirror line.
    func flippedVertically(across y: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: .relative(x: .zero, y: y), mirrorLineEnd: .relative(x: 1, y: y))
    }
    
    /// Returns the same array of objects with positions scaled from the anchor point.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same array of objects with positions scaled from the anchor point.
    func scaledPositions(_ scale: CGSize, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
    
    /// Returns the same array of objects with positions scaled from the anchor point.
    /// - Parameters:
    ///   - x: Used to scale the x positions.
    ///   - y: Used to scale the y positions.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same array of objects with positions scaled from the anchor point.
    func scaledPositions(x: CGFloat = 1, y: CGFloat = 1, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(x: x, y: y, anchor: anchor) }
    }
    
    /// Returns the same array of objects with positions scaled from the anchor point.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same array of objects with positions scaled from the anchor point.
    func scaledPositions(_ scale: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
}
