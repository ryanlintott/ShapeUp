//
//  RelativeCornerArrayBuilder.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-08-19.
//

import Foundation

/// Builds an array of  Corners from both ``Corner`` and `CGPoint` types
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
        [expression.relativeCorner()]
    }
    
    static func buildExpression(_ expression: [RectAnchor]) -> [RelativeCorner] {
        expression.relativeCorners
    }
    
    static func buildExpression(_ expression: (x: CGFloat, y: CGFloat)) -> [RelativeCorner] {
        [RelativeCorner(x: expression.x, y: expression.y)]
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
}

/// An object used to easily create an array of corners using a trailing closure.
public struct RelativeCorners {
    public init() { }
    
    public func callAsFunction(@RelativeCornerArrayBuilder _ corners: () -> [RelativeCorner]) -> [RelativeCorner] {
        corners()
    }
}
