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
        map { $0.moved(distance) }
    }
    
    /// Moves the positions of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: The same array of objects, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        moved(Vector2(dx: dx, dy: dy))
    }
    
    /// Moves objects from one relative position to a new location.
    /// - Parameters:
    ///   - anchor: Start point of the move relative to the bounds of the object locations.
    ///   - location: End location of anchor point.
    /// - Returns: The same array of objects, moved from the anchor provided to the end location.
    func moved(anchor: RectAnchor = .topLeft, to location: some Vector2Representable) -> Self {
        let vector = location.vector - bounds[anchor].vector
        return moved(vector)
    }
    
    /// Moves the objects from one relative position to another relative position.
    /// - Parameters:
    ///   - anchor: Start point of the move relative to the bounds of the object locations.
    ///   - location: End point of the move relative to the bounds of the object locations.
    /// - Returns: The same array of objects, moved from one provided anchor point to another.
    func moved(anchor: RectAnchor = .topLeft, to location: RectAnchor) -> Self {
        moved(anchor: anchor, to: bounds[location])
    }
    
    /// Rotates the position of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Anchor point for the rotation. Default is (0,0)
    /// - Returns: The same array of objects, rotated around the provided anchor point by the provided angle.
    func rotated(_ angle: Angle, anchor: some Vector2Representable = Vector2.zero) -> Self {
        map { $0.rotated(angle, anchor: anchor) }
    }
    
    /// Rotates the position of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Anchor point for the rotation based on the bounding frame.
    /// - Returns: The same array of objects, rotated around the provided anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: RectAnchor) -> Self {
        rotated(angle, anchor: bounds[anchor])
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
        flipped(mirrorLineStart: bounds[mirrorLineStart], mirrorLineEnd: bounds[mirrorLineEnd])
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
        flippedHorizontally(across: bounds[anchor].x)
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
        flippedVertically(across: bounds[anchor].y)
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
    @available(*, deprecated: 100000, renamed: "scaledPositions(_:)")
    func scaledPositions(scale: CGSize) -> [CGPoint] {
        map { $0.scaledPosition(scale: scale) }
    }
    
    /// Returns positions after being scaled from the origin.
    /// - Parameters:
    ///   - width: Used to scale the x positions.
    ///   - height: Used to scale the y positions.
    /// - Returns: Positions after being scaled from the origin.
    @available(*, deprecated: 100000, renamed: "scaledPositions(x:y:)")
    func scaledPositions(width: CGFloat? = nil, height: CGFloat? = nil) -> [CGPoint] {
        map { $0.scaledPosition(width: width, height: height) }
    }
    
    /// Returns positions after being scaled from the origin.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(_ scale: CGSize, anchor: some Vector2Representable = CGPoint.zero) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - x: Used to scale the x positions.
    ///   - y: Used to scale the y positions.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(x: CGFloat = 1, y: CGFloat = 1, anchor: some Vector2Representable = CGPoint.zero) -> Self {
        map { $0.scaledPosition(x: x, y: y, anchor: anchor) }
    }
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale.
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(_ scale: CGFloat, anchor: some Vector2Representable = CGPoint.zero) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale within the bounds frame.
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(_ scale: CGSize, anchor: RectAnchor) -> Self {
        map { $0.scaledPosition(scale, anchor: bounds[anchor]) }
    }
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - x: Used to scale the x positions.
    ///   - y: Used to scale the y positions.
    ///   - anchor: Anchor point for the scale within the bounds frame.
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(x: CGFloat = 1, y: CGFloat = 1, anchor: RectAnchor) -> Self {
        map { $0.scaledPosition(x: x, y: y, anchor: bounds[anchor]) }
    }
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale within the bounds frame.
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(_ scale: CGFloat, anchor: RectAnchor) -> Self {
        map { $0.scaledPosition(scale, anchor: bounds[anchor]) }
    }
    
    /// Repositions these objects from one frame of reference to another.
    /// - Parameters:
    ///   - source: Initial frame of reference for the position.
    ///   - destination: Resulting frame of reference.
    /// - Returns: The same objects repositioned from one frame of reference to another.
    func repositioned(from source: CGRect, to destination: CGRect) -> Self {
        map { $0.repositioned(from: source, to: destination) }
    }
}
