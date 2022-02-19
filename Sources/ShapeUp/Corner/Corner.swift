//
//  Corner.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

/// A point with a specified corner style used to draw corner shapes
///
/// Can be used to draw closed corner shapes using `CSCustom`
///
///     CSCustom { rect in
///         [
///             Corner(x: rect.midX, y: rect.minY),
///             Corner(.rounded(radius: 5), x: rect.maxX, y: rect.maxY),
///             Corner(.rounded(radius: 5), x: rect.minX, y: rect.maxY)
///         ]
///     }
///     .fill()
///
/// Or you can create closed paths using `.path()`
///
///     struct MyShape: Shape {
///         let corners: [Corner]
///
///         func path(in rect: CGRect) -> Path {
///             corners.path()
///         }
///     }
///
public struct Corner: Equatable {
    public var x: CGFloat
    public var y: CGFloat
    public var style: CornerStyle
    
    /// Create a corner with a specified style and two-dimensional point.
    /// - Parameters:
    ///   - style: Corner style. Default is .point.
    ///   - x: x coordinate of corner.
    ///   - y: y coordinate of corner.
    public init(_ style: CornerStyle? = nil, x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
        self.style = style ?? .point
    }
    
    /// Create a corner with a specified style and two-dimensional point.
    /// - Parameters:
    ///   - style: Corner style. Default is .point.
    ///   - point: Location of corner.
    public init<T: Vector2Representable>(_ style: CornerStyle? = nil, point: T) {
        x = point.vector.dx
        y = point.vector.dy
        self.style = style ?? .point
    }
}
