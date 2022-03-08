//
//  Corner+Dimensions+flattened.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-02.
//

import Foundation

extension Corner.Dimensions {
    /// An flattened array of corners based on these dimensions.
    ///
    /// Corner radius will change to an absolute value. Nested corner styles will change to an array of corners with those styles. This process is recursive leaving no corners with nested corner styles or relative radius values.
    internal var flattened: [Corner] {
        switch corner.style {
        case .point, .rounded, .concave:
            if case .relative = corner.radius {
                return [corner.changingRadius(to: .absolute(absoluteRadius))]
            }
            return [corner]
        case .straight, .cutout:
            return subCorners.flattened
        }
    }
    
    /// Returns an array of corners based on these corner dimensions flattened by the number of levels provided.
    ///
    /// Corner radius will change to an absolute value. Nested styles will change to an array of corners with those styles. For each level higher than one this process will be repeated for those new nested corners.
    /// - Parameter levels: Number of levels to flatten.
    /// - Returns: An array of corners based on these corner dimensions flattened by the number of levels provided.
    internal func flattened(levels: Int) -> [Corner] {
        guard levels > 0 else { return [corner] }
        
        switch corner.style {
        case .point, .rounded, .concave:
            if case .relative = corner.radius {
                return [corner.changingRadius(to: .absolute(absoluteRadius))]
            }
            return [corner]
        case .straight, .cutout:
            return subCorners.flattened(levels: levels - 1)
        }
    }
}
