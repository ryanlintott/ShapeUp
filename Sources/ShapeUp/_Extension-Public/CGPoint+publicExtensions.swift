//
//  CGPoint+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-09-22.
//

import SwiftUI

extension CGPoint: Vector2Transformable {
    public var vector: Vector2 {
        Vector2(dx: x, dy: y)
    }
    
    /// Creates a point based on the supplied vector.
    /// - Parameter vector: Vector placed at zero and used to determine point location.
    public init(vector: Vector2) {
        self = vector.point
    }
    
    public func repositioned(to point: some Vector2Representable) -> Self {
        /// This function is required for Vector2Transformable conformance. Other types (like Corner) have to pass on their other properties but CGPoint only has point information.
        point.vector.point
    }
}

extension CGPoint: RelativeRepresentable {
    public func repositioned(to anchorPoint: RectAnchor) -> RectAnchor {
        anchorPoint
    }
}

extension CGPoint: CornerRepresentable {
    public var corner: Corner {
        Corner(point: point)
    }
}

public extension CGPoint {
    /// Creates a rectangle using this point as an anchor.
    /// - Parameters:
    ///   - size: Size of the rectangle.
    ///   - anchor: Location of the anchor point in the rectangle. Relative sizes relate to the rectangle size.
    /// - Returns: A rectangle with the specified size and this point as the anchor.
    func rect(size: CGSize, anchor: RectAnchor = .topLeft) -> CGRect {
        let anchorVector = size.rect()[anchor].vector
        return CGRect(origin: point.moved(-anchorVector), size: size)
    }
    
    
    /// Creates a rectangle using this point as an anchor.
    /// - Parameters:
    ///   - width: Width of the rectangle.
    ///   - height: Height of the rectangle.
    ///   - anchor: Location of the anchor point in the rectangle. Relative sizes relate to the rectangle size.
    /// - Returns: A rectangle with the specified size and this point as the anchor.
    func rect(width: CGFloat, height: CGFloat, anchor: RectAnchor = .topLeft) -> CGRect {
        rect(size: .init(width: width, height: height), anchor: anchor)
    }
}

public extension Array<CGPoint> {
    /// Returns an array of corners matching the positions of the points with an applied corner style.
    ///
    /// If the style is nil and the array contains ``Corner`` the existing style will remain.
    /// - Parameter style: Style applied to all corners. Default is nil which renders as ``CornerStyle.point``.
    /// - Returns: An array of corners matching the positions of the points with an applied corner style.
    func corners(_ style: CornerStyle? = nil) -> [Corner] {
        map { $0.corner(style) }
    }
    
    /// Returns an array of corners matching the positions of the points with the array of corner styles applied.
    ///
    /// Nil style values will use existing styles if available. Styles array can be smaller than the point array. If it's larger extra values will be ignored.
    /// - Parameter styles: Styles applied to each point in order.
    /// - Returns: An array of corners matching the positions of the points with the array of corner styles applied.
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        corners()
            .applyingStyles(styles)
    }
    
    /// An array of corners matching the positions of the points.
    ///
    /// If the array contains ``Corner`` the existing style will remain otherwise a point style will be used.
    var corners: [Corner] {
        map(\.corner)
    }
}
