//
//  RectAnchorArrayBuilder.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-06-11.
//

import Foundation

/// Builds an array of ``RectAnchor`` from both ``RectAnchor`` and `(CGFloat, CGFloat)` types
@resultBuilder
public enum RectAnchorArrayBuilder { }

public extension RectAnchorArrayBuilder {
    static func buildEither(first component: [RectAnchor]) -> [RectAnchor] {
        component
    }
    
    static func buildEither(second component: [RectAnchor]) -> [RectAnchor] {
        component
    }
    
    static func buildOptional(_ component: [RectAnchor]?) -> [RectAnchor] {
        component ?? []
    }
    
    static func buildExpression(_ expression: RectAnchor) -> [RectAnchor] {
        [expression]
    }
    
    static func buildExpression(_ expression: [RectAnchor]) -> [RectAnchor] {
        expression
    }
    
    static func buildExpression(_ expression: (x: CGFloat, y: CGFloat)) -> [RectAnchor] {
        [.relative(x: expression.x, y: expression.y)]
    }
    
    static func buildExpression(_ expression: [(x: CGFloat, y: CGFloat)]) -> [RectAnchor] {
        expression.map { .relative(x: $0.x, y: $0.y) }
    }
    
    static func buildBlock(_ components: [RectAnchor]...) -> [RectAnchor] {
        components.flatMap { $0 }
    }
}
