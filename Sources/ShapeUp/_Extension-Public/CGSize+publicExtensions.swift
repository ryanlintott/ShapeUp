//
//  CGSize+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-09.
//

import SwiftUI

extension CGSize {
    /// Returns a rectangle matching this size with an anchor point at a specified location.
    /// - Parameters:
    ///   - location: Location of anchor point.
    ///   - anchor: Anchor point on rectangle.
    /// - Returns: A rectangle matching this size with an anchor point at a specified location.
    public func rect(at location: some Vector2Representable = CGPoint.zero, anchor: RectAnchor = .topLeft) -> CGRect {
        location.point.rect(size: self, anchor: anchor)
    }
    
    /// Returns a rectangle matching this size with a zero origin.
    public var rect: CGRect {
        rect()
    }
    
    /// Scales the size by a specified amount.
    /// - Parameter scale: Scale amount
    /// - Returns: Size scaled by a specified amount.
    public func scaled(_ scale: CGSize) -> Self {
        CGSize(width: width * scale.width, height: height * scale.height)
    }
    
    /// Scales the size by specified x and y amounts.
    /// - Parameters:
    ///   - x: X scale amount
    ///   - y: Y scale amount
    /// - Returns: Size scaled by specified x and y amounts
    public func scaled(_ x: CGFloat, _ y: CGFloat) -> Self {
        CGSize(width: width * x, height: height * y)
    }
    
    /// Scales the size by a specified amount.
    /// - Parameter scale: Scale amount
    /// - Returns: Size scaled by a specified amount.
    public func scaled(_ scale: CGFloat) -> Self {
        CGSize(width: width * scale, height: height * scale)
    }
}
