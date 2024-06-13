//
//  CornerCustom.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

/**
A custom open or closed insettable shape built out of corners, aligned inside the frame of the view containing it.

This shape can either be used in a SwiftUI View like any other `InsettableShape`

    CornerCustom { rect in
        [
            Corner(x: rect.midX, y: rect.minY),
            Corner(.rounded(radius: 5), x: rect.maxX, y: rect.maxY),
            Corner(.rounded(radius: 5), x: rect.minX, y: rect.maxY)
        ]
    }
    .fill()
 
    CornerCustom { rect in
        rect
            .points(.top, .bottomRight, .left)
            .corners(.rounded(radius: .relative(0.1)))
    }
    .strokeBorder(lineWidth: 10)
*/
@MainActor
public struct CornerCustom: CornerShape {
    public let closed: Bool
    public var insetAmount: CGFloat = 0
    
    public var animatableData: CGFloat {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    internal var corners: (CGRect) -> [Corner]
    
    /// Creates a custom insettable shape out of corners.
    /// - Parameters:
    ///  - closed: A boolean determining if the shape should be closed. Default is true.
    ///  - corners: Closure used to draw corners in a defined frame.
    public init(closed: Bool = true, _ corners: @escaping (CGRect) -> [Corner]) {
        self.closed = closed
        self.corners = corners
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        corners(rect)
    }
}
