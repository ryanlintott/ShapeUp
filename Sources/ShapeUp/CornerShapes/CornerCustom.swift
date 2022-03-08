//
//  CornerCustom.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

/// A custom insettable shape built out of corners, aligned inside the frame of the view containing it.
///
/// This shape can be used in a SwiftUI View directly (similar to `RoundedRectangle`)
///
///     CornerCustom { rect in
///         [
///             Corner(x: rect.midX, y: rect.minY),
///             Corner(.rounded(radius: 5), x: rect.maxX, y: rect.maxY),
///             Corner(.rounded(radius: 5), x: rect.minX, y: rect.maxY)
///         ]
///     }
///     .fill()
///
public struct CornerCustom: CornerShape {
    public let closed: Bool
    public var insetAmount: CGFloat = 0
    
    internal var corners: (CGRect) -> [Corner]
    
    /// Creates a custom insettable shape out of corners.
    /// - Parameters:
    ///  - closed: A boolean determining if the shape should be closed. Default is true.
    ///  - corners: Corners used to draw a single closed shape.
    public init(closed: Bool = true, _ corners: @escaping (CGRect) -> [Corner]) {
        self.closed = closed
        self.corners = corners
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        corners(rect)
    }
}
