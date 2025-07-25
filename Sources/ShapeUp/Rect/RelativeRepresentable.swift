//
//  File.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-14.
//

import Foundation

public protocol RelativeRepresentable: Vector2Representable {
    /// A relative version of this type.
    associatedtype RelativeValue
    
    /// Converts this object to one with a relative coordinate.
    /// - Parameter anchor: Relative coordinate to use instead of the current coordinate.
    /// - Returns: A relative version of this object using the specified coordinate.
    func repositioned(to anchor: RectAnchor) -> RelativeValue
}

extension RelativeRepresentable {
    /// Converts this object to one that is relative to the specified rectangle.
    /// - Parameter rect: Rectangle used for relative position.
    /// - Returns: A relative version of this object anchored to the specified rectangle.
    public func relative(to rect: CGRect) -> RelativeValue {
        relative(to: CGFrame(rect))
    }
    
    /// Converts this object to one that is relative to the specified frame.
    /// - Parameter rect: Rectangle used for relative position.
    /// - Returns: A relative version of this object anchored to the specified frame.
    public func relative(to frame: CGFrame) -> RelativeValue {
        repositioned(to: frame[vector.point])
    }
}

extension Array where Element: RelativeRepresentable {
    /// Converts this array of objects to an array of objects relative to the specified rectangle.
    /// - Parameter rect: Rectangle used for relative position.
    /// - Returns: A relative version of this object anchored to the specified rectangle.
    public func relative(to rect: CGRect) -> [Element.RelativeValue] {
        map { $0.relative(to: rect) }
    }
    
    /// Converts this array of objects to an array of objects relative to the specified frame.
    /// - Parameter frame: Frame used for relative position.
    /// - Returns: A relative version of this object anchored to the specified frame.
    public func relative(to frame: CGFrame) -> [Element.RelativeValue] {
        map { $0.relative(to: frame) }
    }
    
    /// Converts this array of objects to an array of objects relative to their own bounds.
    var relativeToBounds: [Element.RelativeValue] {
        relative(to: bounds)
    }
}
