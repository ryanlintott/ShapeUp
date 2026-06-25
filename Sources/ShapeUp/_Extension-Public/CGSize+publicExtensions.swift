//
//  CGSize+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-09.
//

import SwiftUI

extension CGSize {
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
    public func scaled(x: CGFloat, y: CGFloat) -> Self {
        CGSize(width: width * x, height: height * y)
    }
    
    /// Scales the size by a specified amount.
    /// - Parameter scale: Scale amount
    /// - Returns: Size scaled by a specified amount.
    public func scaled(_ scale: CGFloat) -> Self {
        CGSize(width: width * scale, height: height * scale)
    }
}
