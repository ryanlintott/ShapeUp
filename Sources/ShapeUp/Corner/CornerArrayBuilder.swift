//
//  CornerArrayBuilder.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-08-19.
//

import SwiftUI
import Foundation

/// Builds an array of corners from both ``Corner`` and `CGPoint` values.
@resultBuilder
public enum CornerArrayBuilder { }

public extension CornerArrayBuilder {
    static func buildEither(first component: [Corner]) -> [Corner] {
        component
    }
    
    static func buildEither(second component: [Corner]) -> [Corner] {
        component
    }
    static func buildOptional(_ component: [Corner]?) -> [Corner] {
        component ?? []
    }
    
    static func buildExpression(_ expression: CGPoint) -> [Corner] {
        [expression.corner]
    }
    
    static func buildExpression(_ expression: Corner) -> [Corner] {
        [expression]
    }
    
    static func buildExpression(_ expression: [Corner]) -> [Corner] {
        expression
    }
    
    static func buildExpression(_ expression: [CGPoint]) -> [Corner] {
        expression.corners
    }
    
    static func buildBlock(_ components: [Corner]...) -> [Corner] {
        components.flatMap { $0 }
    }
    
    @available(*, unavailable, message: "RelativeCorner is not compatible with CornerArrayBuilder. Use Corner or CGPoint")
    static func buildExpression(_ expression: RelativeCorner) -> [Corner] {
        fatalError()
    }
    
    @available(*, unavailable, message: "RelativeCorner is not compatible with CornerArrayBuilder. Use Corner or CGPoint")
    static func buildExpression(_ expression: [RelativeCorner]) -> [Corner] {
        fatalError()
    }
}

/// An array of ``Corner`` values.
public typealias Corners = [Corner]

extension Corners {
    /// Builds an array of corners from a trailing closure.
    /// - Parameter corners: A closure that builds the corners.
    public init(@CornerArrayBuilder _ corners: () -> [Corner]) {
        self = corners()
    }
}

struct CornerArrayBuilderShapeExample: CornerShape {
    var insetAmount: CGFloat = .zero
    var closed = true
    var radius: CGFloat
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
   
    func corners(in rect: CGRect) -> [Corner] {
        Corners {
            rect[.topLeft]
            
            rect[.topRight]
        }
        .cornerStyle(.rounded(radius: .absolute(radius)))
        
        rect[.bottomRight]
        
        rect[.bottomRight]
            .moved(dx: -radius, dy: -radius)
            .rounded(radius: .absolute(radius))
        
        rect[.bottomLeft]
            .moved(dy: -radius)
            .rounded(radius: .absolute(radius))
    }
}

#if !os(tvOS)
@available(iOS 17, watchOS 10, macOS 14, tvOS 17, *)
#Preview {
    @Previewable @State var radius = 20.0
    
    VStack {
        CornerArrayBuilderShapeExample(radius: radius)
            .frame(maxWidth: 200, maxHeight: 200)
            .animation(.default, value: radius)
        
        Stepper("Radius", value: $radius, in: 0...50, step: 5)
        Slider(value: $radius, in: 0...50)
    }
}
#endif
