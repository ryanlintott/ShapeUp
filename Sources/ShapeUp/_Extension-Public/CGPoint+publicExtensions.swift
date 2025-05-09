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
        point.point
    }
}

extension CGPoint {
    /// Creates a rectangle using this point as an anchor.
    /// - Parameters:
    ///   - size: Size of the rectangle.
    ///   - anchor: Location of the anchor point in the rectangle. Relative sizes relate to the rectangle size.
    /// - Returns: A rectangle with the specified size and this point as the anchor.
    public func rect(size: CGSize, anchor: RectAnchor = .topLeft) -> CGRect {
        let anchorVector = size.rect()[anchor].vector
        return CGRect(origin: self.moved(-anchorVector), size: size)
    }
    
    
    /// Creates a rectangle using this point as an anchor.
    /// - Parameters:
    ///   - width: Width of the rectangle.
    ///   - height: Height of the rectangle.
    ///   - anchor: Location of the anchor point in the rectangle. Relative sizes relate to the rectangle size.
    /// - Returns: A rectangle with the specified size and this point as the anchor.
    public func rect(width: CGFloat, height: CGFloat, anchor: RectAnchor = .topLeft) -> CGRect {
        rect(size: .init(width: width, height: height), anchor: anchor)
    }
}

