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
    /// Converts this object to one that is relative to the specified frame.
    /// - Parameter frame: Frame used for relative position.
    /// - Returns: A relative version of this object anchored to the specified frame.
    public func relative(to frame: some CGFrameRepresentable) -> RelativeValue {
        /// Vector from origin to the point.
        let relativeVector = vector - frame.origin.vector
        
        let denominator = frame.xAxis.crossProduct(with: frame.yAxis)
        guard abs(denominator) > 1e-8 else { return repositioned(to: .topLeft) }
        
        let x = relativeVector.crossProduct(with: frame.yAxis) / denominator
        let y = frame.xAxis.crossProduct(with: relativeVector) / denominator
        
        return repositioned(to: .relative(x: x, y: y))
    }
}

extension Array where Element: RelativeRepresentable {
    /// Converts this array of objects to an array of objects relative to the specified frame.
    /// - Parameter frame: Frame used for relative position.
    /// - Returns: A relative version of this object anchored to the specified frame.
    public func relative(to frame: some CGFrameRepresentable) -> [Element.RelativeValue] {
        map { $0.relative(to: frame) }
    }
    
    /// Converts this array of objects to an array of objects relative to their own bounds.
    var relativeToBounds: [Element.RelativeValue] {
        relative(to: bounds)
    }
}
