//
//  CornerRectangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/**
A rectangular `CornerShape` similar to `RoundedRectangle` with individually stylable corners, aligned inside the frame of the view containing it.

This shape can either be used in a SwiftUI View like any other `InsettableShape`

    CornerRectangle([
        .topLeft: .straight(radius: 60),
        .topRight: .cutout(radius: .relative(0.2)),
        .bottomRight: .rounded(radius: .relative(0.8)),
        .bottomLeft: .concave(radius: .relative(0.2))
    ])
    .fill()

The corners can be accessed directly for use in a more complex shape

    public func corners(in rect: CGRect) -> [Corner] {
        CornerRectangle([.topLeft: .rounded(radius: 20)])
            .corners(in: rect)
            .inset(by: 10)
            .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
    }
*/
public struct CornerRectangle: EnumeratedCornerShape {
    public let closed = true
    public var insetAmount: CGFloat = 0
    
    public enum ShapeCorner: EnumeratedCorner {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    public var styles: [ShapeCorner : CornerStyle?]
    
    /// Creates a 2d rectangular shape with specified styles for each corner.
    /// - Parameters:
    ///   - styles: A dictionary describing the style of each shape corner.
    public init(_ styles: [ShapeCorner: CornerStyle] = [:]) {
        self.styles = styles
    }
    
    public func points(in rect: CGRect) -> [ShapeCorner : CGPoint] {
        [
            .topLeft: rect.point(.topLeft),
            .topRight: rect.point(.topRight),
            .bottomRight: rect.point(.bottomRight),
            .bottomLeft: rect.point(.bottomLeft)
        ]
    }
}

/// Animatable Extension
extension CornerRectangle {
    public var animatableData: CGFloat {
        get {
            insetAmount
        }
        set {
            insetAmount = newValue
        }
    }
}
