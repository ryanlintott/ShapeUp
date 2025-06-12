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
    ///   - style: Corner style. Default is .point.
    ///   - point: Location of corner based on an anchor point.
    public init(_ style: CornerStyle? = nil, anchorPoint: RectAnchor) {
        self.style = style ?? .point
        self.anchorPoint = anchorPoint
    }
    
    /// Create a corner with a specified style and anchor point.
    /// - Parameters:
    ///   - style: Corner style. Default is .point.
    ///   - point: Location of corner based on an anchor point.
    public init(_ style: CornerStyle? = nil, x: CGFloat, y: CGFloat) {
        self.style = style ?? .point
        self.anchorPoint = .relative(x, y)

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
        return .init(style, anchorPoint: anchorPoint)
    }
}

public extension Collection<RelativeCorner> {
    func corners(in rect: CGRect) -> [Corner] {
        map { $0.corner(in: rect) }
    }
    
    func corners(in frame: CGFrame) -> [Corner] {
        map { $0.corner(in: frame) }
    }
}
