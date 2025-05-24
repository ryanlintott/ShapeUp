//
//  File.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-20.
//

import Foundation

public struct RelativeCorner: Hashable, Codable, Sendable {
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
    func callAsFunction(in rect: CGRect) -> Corner {
        .init(style, point: anchorPoint(in: rect))
    }
    
    func callAsFunction(in cornerDimensions: Corner.Dimensions) -> Corner {
        .init(style, point: anchorPoint(in: cornerDimensions))
    }
    
    /// Radius of corner based on the style.
    public var radius: RelatableValue {
        get {
            style.radius
        }
        set {
            style.radius = newValue
        }
    }
    
    /// Creates a corner at the same position but with the supplied style.
    /// - Parameter style: Corner style to apply.
    /// - Returns: A corner at the same position but with the supplied style.
    public func applyingStyle(_ style: CornerStyle) -> Self {
        if style == self.style {
            return self
        }
        return .init(style, anchorPoint: anchorPoint)
    }
    
    /// Creates a corner with the same style at the same position but with a new supplied radius.
    /// - Parameter radius: Radius to apply to the corner.
    /// - Returns: A corner with the same style at the same position but with a new supplied radius.
    public func changingRadius(to radius: RelatableValue) -> Self {
        if radius == self.radius {
            return self
        }
        return applyingStyle(style.changingRadius(to: radius))
    }
}

public extension Collection<RelativeCorner> {
    func callAsFunction(in cornerDimensions: Corner.Dimensions) -> [Corner] {
        map {
            $0(in: cornerDimensions)
        }
    }
}
