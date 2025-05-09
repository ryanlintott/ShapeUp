//
//  CGSize+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-09.
//

import SwiftUI

extension CGSize {
    /// Returns a rectangle matching this size with a specified origin.
    /// - Parameter origin: Top left point of the rectangle.
    /// - Returns: A rectangle matching this size with a specified origin.
    public func rect(origin: CGPoint = .zero) -> CGRect {
        CGRect(origin: origin, size: self)
    }
    
    /// Returns a rectangle matching this size with a specified origin.
    /// - Parameters:
    ///   - x: X coordinate of the top left point of the rectangle.
    ///   - y: Y coordinate of the top left point of the rectangle.
    /// - Returns: A rectangle matching this size with a specified origin.
    public func rect(x: CGFloat, y: CGFloat) -> CGRect {
        CGRect(origin: .init(x: x, y: y), size: self)
    }
}
