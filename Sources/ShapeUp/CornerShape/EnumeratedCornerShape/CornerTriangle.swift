//
//  CornerTriangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-08.
//

import SwiftUI

/**
A triangular shape with an adjustable top point and individually stylable corners, aligned inside the frame of the view containing it.

The top point is positioned relative to the top left corner and the value is a `RelatableValue` relative to the width of the frame provided. The default is in the middle.

This shape can either be used in a SwiftUI View like any other `InsettableShape`

    CornerTriangle(topPoint: .relative(0.6), styles: [
        .top: .straight(radius: 10),
        .bottomRight: .rounded(radius: .relative(0.3)),
        .bottomLeft: .concave(radius: .relative(0.2))
    ])
    .fill()

The corners can be accessed directly for use in a more complex shape
 
    public func corners(in rect: CGRect) -> [Corner] {
        CornerTriangle(topPoint: 30)
            .corners(in: rect)
            .inset(by: 10)
            .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
    }
*/
public struct CornerTriangle: EnumeratedCornerShape {
    public let closed = true
    public var insetAmount: CGFloat = 0
    
    /// An enumeration to indicate the three corners of a triangle.
    public enum ShapeCorner: EnumeratedCorner {
        case top
        case bottomRight
        case bottomLeft
    }
    
    public var topPoint: RelatableValue
    public var styles: [ShapeCorner: CornerStyle?]
    
    /// Creates a 2d triangular shape with specified top point and styles for each corner.
    /// - Parameters:
    ///   - topPoint: Position of the top point from the top left corner of the frame. Relative values are relative to width.
    ///   - styles: A dictionary describing the style of each shape corner.
    nonisolated public init(topPoint: RelatableValue = .relative(0.5), styles: [ShapeCorner: CornerStyle] = [:]) {
        self.topPoint = topPoint
        self.styles = styles
    }
    
    public func points(in rect: CGRect) -> [ShapeCorner: CGPoint] {
        [
            .top: rect.point(.topLeft).moved(dx: topPoint.value(using: rect.width)),
            .bottomRight: rect.point(.bottomRight),
            .bottomLeft: rect.point(.bottomLeft)
        ]
    }
}

/// Animatable Extension
extension CornerTriangle {
    nonisolated public var animatableData: AnimatablePair<CGFloat, RelatableValue> {
        get {
            .init(insetAmount, topPoint)
        }
        set {
            insetAmount = newValue.first
            topPoint = newValue.second
        }
    }
}
