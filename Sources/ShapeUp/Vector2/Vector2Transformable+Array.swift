//
//  Vector2Transformable+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public extension Array where Element: Vector2Transformable {
    /// Moves an array of points without modifying other properties.
    /// - Parameter distance: A vector representing the distance to move.
    /// - Returns: The same array of points, moved by the provided distance.
    func moved(_ distance: some Vector2Representable) -> Self {
        map { $0.moved(distance)}
    }
    
    /// Moves a Vector2Transformable type without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: The same object, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        moved(Vector2(dx: dx, dy: dy))
    }
    
    /// Rotates an array of points around an anchor point.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Anchor point for the rotation.
    /// - Returns: The same array of points rotated around the provided anchor point by the provided angle.
    func rotated(_ angle: Angle, anchor: some Vector2Representable) -> Self {
        map { $0.rotated(angle, anchor: anchor) }
    }
    
    /// Rotates an array of points around zero.
    /// - Parameter angle: Angle of rotation.
    /// - Returns: The same array of points rotated around zero by the provided angle.
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: Vector2.zero)
    }
    
    /// Rotates an array of points around a frame anchor.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Frame anchor point for the rotation.
    /// - Returns: The same array of points rotated around a frame anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: RectAnchor) -> Self {
        rotated(angle, anchor: anchorPoint(anchor))
    }
    
    /// Flips an array of points across a mirror line.
    ///
    /// If start and end are equal, points are unchanged.
    /// - Parameters:
    ///   - mirrorLineStart: Start point of mirror line.
    ///   - mirrorLineEnd: End point of mirror line.
    /// - Returns: The same array of points flipped across a mirror line.
    func flipped(mirrorLineStart: some Vector2Representable, mirrorLineEnd: some Vector2Representable) -> Self {
        map({ $0.flipped(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) })
    }
    
    /// Flips an array of points across a mirror line defined by anchor points on the bounding frame.
    ///
    /// If start and end are equal, points are unchanged.
    /// - Parameters:
    ///   - mirrorLineStart: Start point of the mirror line.
    ///   - mirrorLineEnd: End point of the mirror line.
    /// - Returns: The same array of points flipped across a mirror line.
    func flipped(mirrorLineStart: RectAnchor, mirrorLineEnd: RectAnchor) -> Self {
        flipped(mirrorLineStart: anchorPoint(mirrorLineStart), mirrorLineEnd: anchorPoint(mirrorLineEnd))
    }
    
    /// Flips an array of points horizontally.
    /// - Parameter x: X coordinate of the vertical mirror line.
    /// - Returns: The same array of points flipped horizontally across a vertical mirror line.
    func flippedHorizontally(across x: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: Vector2(dx: x, dy: .zero), mirrorLineEnd: Vector2(dx: x, dy: 1))
    }
    
    /// Flips an array of points horizontally.
    /// - Parameter anchor: This frame anchor sets the position of the vertical mirror line.
    /// - Returns: The same array of points flipped horizontally across a vertical mirror line.
    func flippedHorizontally(across anchor: RectAnchor) -> Self {
        flippedHorizontally(across: anchorPoint(anchor).x)
    }
    
    /// Flips an array of points vertically.
    /// - Parameter y: Y coordinate of the horizontal mirror line.
    /// - Returns: The same array of points flipped vertically across a horizontal mirror line.
    func flippedVertically(across y: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: Vector2(dx: .zero, dy: y), mirrorLineEnd: Vector2(dx: 1, dy: y))
    }
    
    /// Flips an array of points vertically..
    /// - Parameter anchor: This frame anchor sets the position of the horizontal mirror line.
    /// - Returns: The same array of points flipped vertically across a horizontal mirror line.
    func flippedVertically(across anchor: RectAnchor) -> Self {
        flippedVertically(across: anchorPoint(anchor).x)
    }
    
    /// Returns an array of points inset by a specified amount.
    ///
    /// Positive inset goes to the right of the line from previous point to this one. Points are considered an open shape so end points will be inset perpendicular to the line they're on.
    /// - Parameters:
    ///   - amount: Inset amount.
    /// - Returns: Array of points after they have been inset.
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
    
    func rescaledPoints(scale: CGSize) -> [CGPoint] {
        map { $0.rescaledPoint(scale: scale) }
    }
    
    func rescaledPoints(width: CGFloat? = nil, height: CGFloat? = nil) -> [CGPoint] {
        map { $0.rescaledPoint(width: width, height: height) }
    }
    
    func rescaledPoints(from source: CGRect, to destination: CGRect) -> [CGPoint] {
        map { $0.rescaledPoint(from: source, to: destination) }
    }
}
