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
    ///   - anchor: Location of corner based on an anchor point.
    ///   - offset: Absolute distance from the anchor point using the same x and y diretions of the frame of reference.
    ///   - style: Corner style. Default is .point.
    public init(anchor: RectAnchor, offset: some Vector2Representable = Vector2.zero, _ style: CornerStyle? = nil) {
        self.anchor = anchor
        self.offset = offset.vector
        self.style = style ?? .point
    }
    
    /// Create a corner with a `.point` style at the specified relative location.
    /// - Parameters:
    ///   - x: Relative x location of corner based on top left anchor point.
    ///   - y: Relative y location of corner based on top left anchor point.
    public init(x: CGFloat, y: CGFloat) {
        self.anchor = .relative(x: x, y: y)
        self.style = .point
        self.offset = .zero
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
            point: anchor.point(in: frame)
                .moved(frame.xAxis.normalized * offset.dx)
                .moved(frame.yAxis.normalized * offset.dy)
        )
    }
}

public extension RelativeCorner {
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
    
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        repositioned(anchor: anchor.moved(dx: dx, dy: dy))
    }
    
    func offset(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        repositioned(offset: offset.moved(dx: dx, dy: dy))
    }
    
    func rotated(_ angle: Angle, anchor: RectAnchor = .topLeft) -> Self {
        repositioned(
            anchor: self.anchor.rotated(angle, anchor: anchor),
            offset: offset.rotated(angle)
        )
    }
    
    func flipped(mirrorLineStart: RectAnchor, mirrorLineEnd: RectAnchor) -> Self {
        repositioned(
            anchor: anchor.flipped(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd),
            offset: offset.flipped(mirrorLineStart: Vector2.zero, mirrorLineEnd: mirrorLineEnd.vector - mirrorLineStart.vector)
        )
    }
    
    func scaledPosition(_ scale: CGSize, anchor: RectAnchor = .topLeft) -> Self {
        repositioned(
            anchor: self.anchor.scaledPosition(scale, anchor: anchor),
            offset: offset.scaledPosition(scale)
        )
    }
    
    func scaledPosition(x: CGFloat = 1, y: CGFloat = 1, anchor: RectAnchor = .topLeft) -> Self {
        scaledPosition(.init(width: x, height: y), anchor: anchor)
    }
    
    func scaledPosition(_ scale: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        scaledPosition(.init(width: scale, height: scale), anchor: anchor)
    }
}

public extension Array where Element == RelativeCorner {
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        map { $0.moved(dx: dx, dy: dy) }
    }
    
    func offset(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        map { $0.offset(dx: dx, dy: dy) }
    }
    
    func rotated(_ angle: Angle, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.rotated(angle, anchor: anchor) }
    }
    
    func flipped(mirrorLineStart: RectAnchor, mirrorLineEnd: RectAnchor) -> Self {
        map { $0.flipped(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) }
    }
    
    func flippedHorizontally(across x: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: .relative(x: x, y: .zero), mirrorLineEnd: .relative(x: x, y: 1))
    }
    
    func flippedVertically(across y: CGFloat = .zero) -> Self {
        flipped(mirrorLineStart: .relative(x: .zero, y: y), mirrorLineEnd: .relative(x: 1, y: y))
    }
    
    func scaledPositions(_ scale: CGSize, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
    
    func scaledPositions(x: CGFloat = 1, y: CGFloat = 1, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(x: x, y: y, anchor: anchor) }
    }
    
    func scaledPositions(_ scale: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        map { $0.scaledPosition(scale, anchor: anchor) }
    }
}
