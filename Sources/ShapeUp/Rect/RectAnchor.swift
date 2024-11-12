//
//  RectAnchor.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/// An enumeration to indicate the type of anchor
public enum AnchorType: Sendable {
    /// Anchor positioned on a vertex
    case vertex
    /// Anchor positioned on an edge
    case edge
    /// Anchor positioned in the center
    case center
    /// Anchor is inside the shape
    case interior
    /// Anchor is outside the shape
    case exterior
}

/// An enumeration to indicate an anchor location on a rectangle.
///
/// Cases start with Center and are in clockwise order from top left.
public enum RectAnchor: CaseIterable, Sendable, Equatable, Hashable {
    public static let allCases: [RectAnchor] = [.center, .topLeft, .top, .topRight, .right, .bottomRight, .bottom, .bottomLeft, .left]
    
    case center
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
    case relative(_ x: CGFloat, _ y: CGFloat)
    
    static func relative(_ point: CGPoint) -> RectAnchor {
        .relative(point.x, point.y)
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
    
    public var relativePoint: CGPoint {
        point(in: .one)
    }
    
    /// The type of the anchor.
    public var type: AnchorType {
        switch (relativePoint.x, relativePoint.y) {
        case (0.5, 0.5): .center
        case (0, 0), (1, 0), (1, 1), (0, 1): .vertex
        case (0...1, 0), (1, 0...1), (0...1, 1), (0, 0...1): .edge
        case (0...1, 0...1): .interior
        default: .exterior
        }
    }
    
    /// An array of four edges clockwise starting with top
    @available(*, deprecated, message: "This conveneince parameter was likely never used.")
    public static var edgeAnchors: [Self] {
        [.top, .right, .bottom, .left]
    }
    
    @available(*, deprecated, renamed: "vertices")
    public static var vertexAnchors: [Self] {
        [.topLeft, .topRight, .bottomRight, .bottomLeft]
    }
    
    /// An array of four corners clockwise starting from top left.
    public static var vertices: [Self] {
        [.topLeft, .topRight, .bottomRight, .bottomLeft]
    }
}
