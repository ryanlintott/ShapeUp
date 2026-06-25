//
//  RelativeRepresentable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-14.
//

import Foundation

/// A type that can be converted to another type with the same properties and a position relative to a coordinate frame.
protocol RelativeRepresentable: Vector2Representable {
    /// A relative version of this type.
    associatedtype RelativeValue
    
    /// Converts this object to one that is relative to the specified frame.
    /// - Parameter frame: Frame used for relative position.
    /// - Returns: Relative versions of the array elements anchored to the specified frame.
    func relative(to frame: some CGFrameRepresentable) -> RelativeValue
}

extension Array where Element: RelativeRepresentable {
    /// Converts this array of objects to an array of objects relative to the specified frame.
    /// - Parameter frame: Frame used for relative position.
    /// - Returns: A relative version of this object anchored to the specified frame.
    func relative(to frame: some CGFrameRepresentable) -> [Element.RelativeValue] {
        map { $0.relative(to: frame) }
    }
    
    /// Converts this array of objects to an array of objects relative to their own bounds.
    var relativeToBounds: [Element.RelativeValue] {
        relative(to: bounds)
    }
}
