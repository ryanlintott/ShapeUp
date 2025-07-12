//
//  RelativeCorner.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-20.
//

import Foundation

public struct RelativeCorner: Hashable, Codable, Sendable, CornerStyled {
    public var anchorPoint: RectAnchor
    public var style: CornerStyle
    
    /// Create a corner with a specified style and anchor point.
    /// - Parameters:
    ///   - anchorPoint: Location of corner based on an anchor point.
    ///   - style: Corner style. Default is .point.
    public init(anchorPoint: RectAnchor, _ style: CornerStyle? = nil) {
        self.anchorPoint = anchorPoint
        self.style = style ?? .point
    }
    
    /// Create a corner with a specified style and anchor point.
    /// - Parameters:
    ///   - x: Relative x location of corner based on top left anchor point.
    ///   - y: Relative y location of corner based on top left anchor point.
    ///   - style: Corner style. Default is .point.
    public init(x: CGFloat, y: CGFloat, _ style: CornerStyle? = nil) {
        self.anchorPoint = .relative(x: x, y: y)
        self.style = style ?? .point
    }
}

public extension RelativeCorner {
    func corner(in rect: CGRect) -> Corner {
        .init(style, point: anchorPoint.point(in: rect))
    }
    
    func corner(in frame: CGFrame) -> Corner {
        .init(style, point: anchorPoint.point(in: frame))
    }
    
    /// Creates a corner at the same position but with the supplied style.
    /// - Parameter style: Corner style to apply.
    /// - Returns: A corner at the same position but with the supplied style.
    func applyingStyle(_ style: CornerStyle) -> Self {
        if style == self.style {
            return self
        }
        return .init(anchorPoint: anchorPoint, style)
    }
}
