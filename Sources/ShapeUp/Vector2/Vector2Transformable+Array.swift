//
//  Vector2Transformable+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public extension Array where Element: Vector2Transformable {
    /// Moves the positions of this array of objects without modifying other properties.
    /// - Parameter distance: A vector representing the distance to move.
    /// - Returns: The same array of objects, moved by the provided distance.
    func moved(_ distance: some Vector2Representable) -> Self {
        map { $0.moved(distance)}
    }
    
    /// Moves the positions of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: The same array of objects, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        moved(Vector2(dx: dx, dy: dy))
    }
    
    /// Rotates the position of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Anchor point for the rotation.
    /// - Returns: The same array of objects, rotated around the provided anchor point by the provided angle.
    func rotated(_ angle: Angle, anchor: some Vector2Representable) -> Self {
        map { $0.rotated(angle, anchor: anchor) }
    }
    
    /// Rotates the position of this array of objects around the origin without modifying other properties.
    /// - Parameter angle: Rotation angle.
    /// - Returns: The same array of objects rotated around the origin by the provided angle.
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: Vector2.zero)
    }
    
    /// Rotates the position of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Anchor point for the rotation based on the bounding frame.
    /// - Returns: The same array of objects, rotated around the provided anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: RectAnchor) -> Self {
        rotated(angle, anchor: anchorPoint(anchor))
    }
    
    /// Flips the positions of this array of objects across a mirror line without modifying other properties.
    ///
    /// If the start and end points of the mirror line are equal, the positions are unchanged.
    /// - Parameters:
    ///   - mirrorLineStart: Start point of mirror line.
    ///   - mirrorLineEnd: End point of mirror line.
    /// - Returns: The same array of objects flipped across the provided mirror line.
    func flipped(mirrorLineStart: some Vector2Representable, mirrorLineEnd: some Vector2Representable) -> Self {
        map({ $0.flipped(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) })
    }
    
    /// Flips the positions of this array of objects across a mirror line without modifying other properties.
    ///
    /// If the start and end points of the mirror line are equal, the positions are unchanged.
    /// - Parameters:
    ///   - mirrorLineStart: Start point of the mirror line based on the bounding frame.
    ///   - mirrorLineEnd: End point of the mirror line based on the bounding frame.
    /// - Returns: The same array of objects flipped across the provided mirror line.
    func flipped(mirrorLineStart: RectAnchor, mirrorLineEnd: RectAnchor) -> Self {
        flipped(mirrorLineStart: anchorPoint(mirrorLineStart), mirrorLineEnd: anchorPoint(mirrorLineEnd))
    }
    
    /// Flips the positions of this array of objects horizontally without modifying other properties.
    /// - Parameter x: X coordinate of the vertical mirror line.
    /// - Returns: The same array of objects flipped horizontally across a vertical mirror line.
    func flippedHorizontally(across x: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: Vector2(dx: x, dy: .zero), mirrorLineEnd: Vector2(dx: x, dy: 1))
    }
    
    /// Flips the positions of this array of objects horizontally without modifying other properties.
    /// - Parameter anchor: The position of the vertical mirror line based on the bounding frame.
    /// - Returns: The same array of objects flipped horizontally across a vertical mirror line.
    func flippedHorizontally(across anchor: RectAnchor) -> Self {
        flippedHorizontally(across: anchorPoint(anchor).x)
    }
    
    /// Flips the positions of this array of objects vertically without modifying other properties.
    /// - Parameter y: Y coordinate of the horizontal mirror line.
    /// - Returns: The same array of objects flipped vertically across a horizontal mirror line.
    func flippedVertically(across y: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: Vector2(dx: .zero, dy: y), mirrorLineEnd: Vector2(dx: 1, dy: y))
    }
    
    /// Flips the positions of this array of objects vertically without modifying other properties.
    /// - Parameter anchor: The position of the horizontal mirror line based on the bounding frame.
    /// - Returns: The same array of points flipped vertically across a horizontal mirror line.
    func flippedVertically(across anchor: RectAnchor) -> Self {
        flippedVertically(across: anchorPoint(anchor).x)
    }
    
    /// Returns positions inset by a specified amount.
    ///
    /// Positive inset goes to the right of the line from previous point to this one. Points are considered an open shape so end points will be inset perpendicular to the line they're on.
    /// - Parameters:
    ///   - amount: Inset amount.
    /// - Returns: Array of object positions after they have been inset.
    func insetPoints(_ amount: CGFloat) -> [CGPoint] {
        // Must be at least 2 points to inset.
        guard self.count > 1 else { return points }
        
        return self.enumerated().compactMap { i, point -> CGPoint in
            let previousPoint = i == 0 ? nil : self[i - 1].point
            let nextPoint = i == self.count - 1 ? nil : self[i + 1].point
            
            let insetPoint = point.insetPoint(amount, previousPoint: previousPoint, nextPoint: nextPoint)
            return insetPoint
        }
    }
    
    /// Returns positions after being scaled from the origin.
    /// - Parameter scale: Used to scale the positions.
    /// - Returns: Positions after being scaled from the origin.
    func scaledPositions(scale: CGSize) -> [CGPoint] {
        map { $0.scaledPosition(scale: scale) }
    }
    
    /// Returns positions after being scaled from the origin.
    /// - Parameters:
    ///   - width: Used to scale the x positions.
    ///   - height: Used to scale the y positions.
    /// - Returns: Positions after being scaled from the origin.
    func scaledPositions(width: CGFloat? = nil, height: CGFloat? = nil) -> [CGPoint] {
        map { $0.scaledPosition(width: width, height: height) }
    }
    
    /// Returns positions after being moved from one frame of reference to another.
    /// - Parameters:
    ///   - source: Initial frame of reference for the position.
    ///   - destination: Resulting frame of reference.
    /// - Returns: Positions after being moved from one frame of reference to another.
    func repositioned(from source: CGRect, to destination: CGRect) -> Self {
        map { $0.repositioned(from: source, to: destination) }
    }
}
