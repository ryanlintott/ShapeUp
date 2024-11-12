//
//  Corner.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

/// A point with a specified corner style used to draw corner shapes.
///
/// Corners in an array are used instead of generating a path in ``CornerShape``, or when creating one inline with ``CornerCustom``.
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
/// They can generate a path using ``Swift/Array/path(closed:)``also be easily added to a path in a SwiftUI `Shape` using ``SwiftUICore/Path/addClosedCornerShape(_:)``, ``SwiftUICore/Path/addOpenCornerShape(_:previousPoint:nextPoint:moveToStart:)``.
///
///     struct MyShape: Shape {
///         let corners: [Corner]
///
///         func path(in rect: CGRect) -> Path {
///             let corners = [
///                 Corner(x: rect.minX, y: rect.minY),
///                 Corner(x: rect.midX, y: rect.midY),
///                 Corner(x: rect.maxX, y: rect.minY),
///                 Corner(x: rect.maxX, y: rect.midY)
///             ]
///             .corners([
///                 .straight(radius: .relative(0.2)),
///                 .cutout(radius: .relative(0.2), cornerStyles: [
///                     .rounded(radius: .relative(0.4)),
///                     .point,
///                     .straight(radius: .relative(0.4))
///                 ]),
///                 .cutout(radius: .relative(0.2), cornerStyles: [.rounded(radius: .relative(0.2))]),
///                 .rounded(radius: 20)
///             ])
///
///                 var path = Path()
///                 path.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.maxY))
///                 path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.midY))
///
///                 path.addOpenCornerShape(
///                 corners,
///                 previousPoint: CGPoint(x: rect.minX, y: rect.midY),
///                 nextPoint: CGPoint(x: rect.midX, y: rect.midY),
///                 moveToStart: false
///                 )
///
///         path.addQuadCurve(to: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.midY))
///
///         return path
///         }
///     }
///
public struct Corner: Hashable, Codable, Sendable {
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
    public init(_ style: CornerStyle? = nil, point: some Vector2Representable) {
        x = point.vector.dx
        y = point.vector.dy
        self.style = style ?? .point
    }
}
