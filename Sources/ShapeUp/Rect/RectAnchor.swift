//
//  RectAnchor.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/// An enumeration to indicate an anchor location on a rectangle.
public enum RectAnchor: Sendable, Equatable, Hashable, Codable {
    case center
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
    
    /// Relative to a rectangle with a width and height of 1 and an origin at the top left.
    /// - Parameters:
    ///   - x: The horizontal position relative to the rectangle width.
    ///   - y: The vertical position relative to the rectangle height.
    case relative(x: CGFloat, y: CGFloat)
}

extension RectAnchor {
    /// Hash value is based on the relative point instead of the enum values so `.center` and `.relative(x: 0.5, y: 0.5)` are equal
    public func hash(into hasher: inout Hasher) {
        hasher.combine(relativePoint.vector)
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.relativePoint == rhs.relativePoint
    }
    
    /// Creates a relative anchor from a point.
    /// - Parameter point: A point containing the relative x and y coordinates.
    /// - Returns: A relative anchor at the specified coordinates.
    public static func relative(_ point: CGPoint) -> RectAnchor {
        .relative(x: point.x, y: point.y)
    }
    
    /// Creates a point in the location of an anchor.
    /// - Parameter rect: Rectangle where anchor is positioned.
    /// - Returns: The point where the anchor is located.
    public func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeft:
            CGPoint(x: rect.minX, y: rect.minY)
        case .top:
            CGPoint(x: rect.midX, y: rect.minY)
        case .topRight:
            CGPoint(x: rect.maxX, y: rect.minY)
        case .left:
            CGPoint(x: rect.minX, y: rect.midY)
        case .center:
            CGPoint(x: rect.midX, y: rect.midY)
        case .right:
            CGPoint(x: rect.maxX, y: rect.midY)
        case .bottomLeft:
            CGPoint(x: rect.minX, y: rect.maxY)
        case .bottom:
            CGPoint(x: rect.midX, y: rect.maxY)
        case .bottomRight:
            CGPoint(x: rect.maxX, y: rect.maxY)
        case let .relative(x, y):
            CGPoint(x: rect.minX + (x * rect.width), y: rect.minY + (y * rect.height))
        }
    }
    
    /// Creates a point in the location of an anchor inside the UV coordinates of the specified corner dimensions.
    /// - Parameter frame: Frame in the shape of a rhombus with U and V coordinates on which the relative x and y coordinates of this anchor will be mapped.
    /// - Returns: A point in the location of an anchor inside the UV coordinates of the specified corner dimensions.
    public func point(in frame: CGFrame) -> CGPoint {
        frame[self]
    }
    
    var relativePoint: CGPoint {
        self.point(in: .one)
    }
    
    /// A relative corner at the same position with the default style and no offset.
    var relativeCorner: RelativeCorner {
        RelativeCorner(anchor: self)
    }
    
    /// An array of four edges clockwise starting with top
    @available(*, deprecated, message: "Use `self.points(.top, .right, .bottom, .left)`.")
    public static let edgeAnchors: [Self] = [.top, .right, .bottom, .left]
    
    @available(*, deprecated, renamed: "vertices")
    public static let vertexAnchors: [Self] = [.topLeft, .topRight, .bottomRight, .bottomLeft]
    
    /// An array of four corners clockwise starting from top left.
    public static let vertices: [Self] = [.topLeft, .topRight, .bottomRight, .bottomLeft]
}
