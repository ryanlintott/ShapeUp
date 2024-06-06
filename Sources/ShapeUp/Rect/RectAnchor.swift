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
}

/// An enumeration to indicate an anchor location on a rectangle.
///
/// Cases start with Center and are in clockwise order from top left.
public enum RectAnchor: CaseIterable, Sendable {
    case center
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
    
    /// Creates a point in the location of an anchor.
    /// - Parameter rect: Rectangle where anchor is positioned.
    /// - Returns: The point where the anchor is located.
    public func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: rect.minX, y: rect.minY)
        case .top:
            return CGPoint(x: rect.midX, y: rect.minY)
        case .topRight:
            return CGPoint(x: rect.maxX, y: rect.minY)
        case .left:
            return CGPoint(x: rect.minX, y: rect.midY)
        case .center:
            return CGPoint(x: rect.midX, y: rect.midY)
        case .right:
            return CGPoint(x: rect.maxX, y: rect.midY)
        case .bottomLeft:
            return CGPoint(x: rect.minX, y: rect.maxY)
        case .bottom:
            return CGPoint(x: rect.midX, y: rect.maxY)
        case .bottomRight:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }
    
    /// The type of the anchor.
    public var type: AnchorType {
        switch self {
        case .center: return .center
        case .topLeft, .topRight, .bottomRight, .bottomLeft: return .vertex
        case .top, .right, .bottom, .left: return .edge
        }
    }
    
    /// Edge anchors in clockwise order from the top left.
    public static var edgeAnchors: [Self] {
        allCases.filter { $0.type == .edge }
    }
    
    /// Corner anchors in clockwise order from the top left.
    public static var vertexAnchors: [Self] {
        allCases.filter { $0.type == .vertex }
    }
}
