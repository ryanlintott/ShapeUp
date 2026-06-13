//
//  RelativeCornerArrayBuilder.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-08-19.
//

import Foundation

/// Builds an array of ``RelativeCorner`` from  ``RelativeCorner``,  `RectAnchor` and `(CGFloat, CGFloat)` types
@resultBuilder
public enum RelativeCornerArrayBuilder { }

public extension RelativeCornerArrayBuilder {
    static func buildEither(first component: [RelativeCorner]) -> [RelativeCorner] {
        component
    }
    
    static func buildEither(second component: [RelativeCorner]) -> [RelativeCorner] {
        component
    }
    
    static func buildOptional(_ component: [RelativeCorner]?) -> [RelativeCorner] {
        component ?? []
    }
    
    static func buildExpression(_ expression: RectAnchor) -> [RelativeCorner] {
        [expression.relativeCorner]
    }
    
    static func buildExpression(_ expression: [RectAnchor]) -> [RelativeCorner] {
        expression.relativeCorners
    }
    
    static func buildExpression(_ expression: (x: CGFloat, y: CGFloat)) -> [RelativeCorner] {
        [.relative(x: expression.x, y: expression.y)]
    }
    
    static func buildExpression(_ expression: [(x: CGFloat, y: CGFloat)]) -> [RelativeCorner] {
        expression.map { .relative(x: $0.x, y: $0.y) }
    }
    
    static func buildExpression(_ expression: RelativeCorner) -> [RelativeCorner] {
        [expression]
    }
    
    static func buildExpression(_ expression: [RelativeCorner]) -> [RelativeCorner] {
        expression
    }
    
    static func buildBlock(_ components: [RelativeCorner]...) -> [RelativeCorner] {
        components.flatMap { $0 }
    }
    
    @available(*, unavailable, message: "Corner is not compatible with RelativeCornerArrayBuilder. Use RelativeCorner, RectAnchor, or a Tuple (CGFloat, CGFloat)")
    static func buildExpression(_ expression: Corner) -> [RelativeCorner] {
        fatalError()
    }
    
    @available(*, unavailable, message: "Corner is not compatible with RelativeCornerArrayBuilder. Use RelativeCorner, RectAnchor, or a Tuple (CGFloat, CGFloat)")
    static func buildExpression(_ expression: [Corner]) -> [RelativeCorner] {
        fatalError()
    }
}

/// An object used to easily create an array of corners using a trailing closure.
public enum RelativeCorners {
    /// Builds an array of relative corners from a trailing closure.
    /// - Parameter corners: A closure that builds the relative corners.
    /// - Returns: The relative corners produced by the closure.
    public func callAsFunction(@RelativeCornerArrayBuilder _ corners: () -> [RelativeCorner]) -> [RelativeCorner] {
        corners()
    }
}
