//
//  RelativeCorner.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-20.
//

import SwiftUI

public struct RelativeCorner: Hashable, Codable, Sendable, CornerStyled {
    /// Location of the anchor point of this corner in a given rectangle or frame.
    public var anchor: RectAnchor
    /// Offset from the anchor point using the x and y directions of the rectangle or frame with absolute distances instead of relative.
    public var offset: Vector2
    public var style: CornerStyle
    
    /// Create a corner with a specified style and anchor point.
    /// - Parameters:
    ///   - style: Corner style. Default is .point.
    ///   - anchor: Location of corner based on an anchor point.
    ///   - offset: Absolute distance from the anchor point using the same x and y diretions of the frame of reference.
    internal init(_ style: CornerStyle? = nil, anchor: RectAnchor, offset: some Vector2Representable) {
        self.anchor = anchor
        self.offset = offset.vector
        self.style = style ?? .point
    }
    
    /// Create a corner with a specified style and anchor point.
    /// - Parameters:
    ///   - style: Corner style. Default is .point.
    ///   - anchor: Location of corner based on an anchor point.
    public init(_ style: CornerStyle? = nil, anchor: RectAnchor) {
        self = .init(style, anchor: anchor, offset: Vector2.zero)
    }
    
    /// Create a corner with a `.point` style at the specified relative location.
    /// - Parameters:
    ///   - style: Corner style. Default is .point.
    ///   - x: Relative x location of corner based on top left anchor point.
    ///   - y: Relative y location of corner based on top left anchor point.
    public init(_ style: CornerStyle? = nil, x: CGFloat, y: CGFloat) {
        self = .init(style, anchor: .relative(x: x, y: y))
    }
}

public extension RelativeCorner {
    func corner(in rect: CGRect) -> Corner {
        .init(
            style,
            point: anchor.point(in: rect)
                .moved(offset)
        )
    }
    
    func corner(in frame: CGFrame) -> Corner {
        .init(
            style,
            point: frame[anchor]
                .moved(frame.xAxis.normalized * offset.dx)
                .moved(frame.yAxis.normalized * offset.dy)
        )
    }
}

public extension RelativeCorner {
    /// Repositions this object to a new anchor point and/or offset.
    /// - Parameters:
    ///   - anchor: Anchor point will be repositioned here.
    ///   - offset: Offset amount will change to this value.
    /// - Returns: The same object, moved to a new position.
    func repositioned(anchor: RectAnchor? = nil, offset: (some Vector2Representable)? = nil as Vector2?) -> Self {
        var copy = self
        if let anchor {
            copy.anchor = anchor
        }
        if let offset {
            copy.offset = offset.vector
        }
        return copy
    }
    
    /// Moves the position of this object without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x. Relative amounts will adjust the anchor position and absolute values will change the offset.
    ///   - dy: Delta y. Relative amounts will adjust the anchor position and absolute values will change the offset.
    /// - Returns: The same object, moved by the provided distance.
    func moved(dx: RelatableValue = .zero, dy: RelatableValue = .zero) -> Self {
        repositioned(
            anchor: anchor.moved(dx: dx.components.relative, dy: dy.components.relative),
            offset: offset.moved(dx: dx.components.absolute, dy: dy.components.absolute)
        )
    }
    
    /// Rotates the position of this Relative Corner without modifying other properties.
    /// - Parameter angle: Angle of rotation. Clockwise is positive for SwiftUI.
    /// - Parameter anchor: Anchor point for the rotation. Default is `.topLeft`
    /// - Returns: The same object, rotated around the provided anchor by the provided angle.
    func rotated(_ angle: Angle, anchor: RectAnchor = .topLeft) -> Self {
        repositioned(
            anchor: self.anchor.rotated(angle, anchor: anchor),
            offset: offset.rotated(angle)
        )
    }
    
    /// Flips the anchor position and offset of this object across a mirror line without modifying other properties.
    ///
    /// If the start and end points of the mirror line are equal, the position is unchanged.
    /// - Parameter mirrorLineStart: Start anchor point of mirror line.
    /// - Parameter mirrorLineEnd: End anchor point of mirror line.
    /// - Returns: The same object, flipped across the provided mirror line.
    func flipped(mirrorLineStart: RectAnchor, mirrorLineEnd: RectAnchor) -> Self {
        repositioned(
            anchor: anchor.flipped(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd),
            offset: offset.flipped(mirrorLineStart: Vector2.zero, mirrorLineEnd: mirrorLineEnd.vector - mirrorLineStart.vector)
        )
    }
    
    /// Scales the position of this object without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the position.
    ///   - anchor: Anchor point for the rotation. Default is `.topLeft`
    /// - Returns: The same object, scaled by the specified amount.
    func scaledPosition(_ scale: CGSize, anchor: RectAnchor = .topLeft) -> Self {
        repositioned(
            anchor: self.anchor.scaledPosition(scale, anchor: anchor),
            offset: offset.scaledPosition(scale)
        )
    }
    
    /// Scales the position of this object without modifying other properties.
    /// - Parameters:
    ///   - x: Used to scale the x position.
    ///   - y: Used to scale the y position.
    ///   - anchor: Anchor point for the rotation. Default is `.topLeft`
    /// - Returns: The same object, scaled by the specified amount.
    func scaledPosition(x: CGFloat = 1, y: CGFloat = 1, anchor: RectAnchor = .topLeft) -> Self {
        scaledPosition(.init(width: x, height: y), anchor: anchor)
    }
    
    /// Scales the position of this objectwithout modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the position.
    ///   - anchor: Anchor point for the rotation. Default is `.topLeft`
    /// - Returns: The same object, scaled by the specified amount.
    func scaledPosition(_ scale: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        scaledPosition(.init(width: scale, height: scale), anchor: anchor)
    }
}

public extension Array where Element == RelativeCorner {
    /// Moves the positions of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - dx: Delta x. Relative amounts will adjust the anchor position and absolute values will change the offset.
    ///   - dy: Delta y. Relative amounts will adjust the anchor position and absolute values will change the offset.
    /// - Returns: The same array of objects, moved by the provided distance.
    func moved(dx: RelatableValue = .zero, dy: RelatableValue = .zero) -> Self {
        map { $0.moved(dx: dx, dy: dy) }
    }
    
    /// Rotates the position of this array of objects without modifying other properties.
    /// - Parameters:
    ///   - angle: Angle of rotation.
    ///   - anchor: Anchor point for the rotation in the relative coordinate system (not relative bounding box of this array of objects). Default is `.topLeft`
    /// - Returns: The same array of objects, rotated around the provided anchor point by the provided angle.
    func rotated(_ angle: Angle, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.rotated(angle, anchor: anchor) }
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
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale in the relative coordinate system (not relative bounding box of this array of objects). Default is `.topLeft`
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(_ scale: CGSize, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - x: Used to scale the x positions.
    ///   - y: Used to scale the y positions.
    ///   - anchor: Anchor point for the scale in the relative coordinate system (not relative bounding box of this array of objects). Default is `.topLeft`
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(x: CGFloat = 1, y: CGFloat = 1, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(x: x, y: y, anchor: anchor) }
    }
    
    /// Scales the position of these objects without modifying other properties.
    /// - Parameters:
    ///   - scale: Used to scale the positions.
    ///   - anchor: Anchor point for the scale in the relative coordinate system (not relative bounding box of this array of objects). Default is `.topLeft`
    /// - Returns: The same objects, scaled by the specified amount.
    func scaledPositions(_ scale: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
}
