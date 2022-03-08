//
//  CornerPentagon.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/// A pentagon shape pointing upwards with individually stylable corners, aligned inside the frame of the view containing it.
///
/// This shape can either be used in a SwiftUI View directly (similar to `RoundedRectangle`)
///
///     CornerPentagon(pointHeight: .relative(0.2), topTaper: .relative(0.15), bottomTaper: .zero)
///         .fill()
///
/// Or the corners can be accessed directly for use in a more complex shape
///
///     public func corners(in rect: CGRect) -> [Corner] {
///         CornerPentagon(pointHeight: .relative(0.2), topTaper: .relative(0.15), bottomTaper: .zero)
///             .corners(in: rect)
///             .inset(by: 10)
///             .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
///     }
///
public struct CornerPentagon: CornerShape {
    public var closed = true
    public var insetAmount: CGFloat = 0
    
    public var pointHeight: RelatableValue
    public var topTaper: RelatableValue
    public var bottomTaper: RelatableValue
    
    /// Creates a 2d pentagon shape with corners that can be styled.
    /// - Parameters:
    ///   - pointHeight: The vertical distance from the central point to the two points on either side.
    ///   - topTaper: The horizontal inset of the two points closest to the top.
    ///   - bottomTaper: The horizontal inset of the bottom two points.
    public init(pointHeight: RelatableValue, topTaper: RelatableValue = .zero, bottomTaper: RelatableValue = .zero) {
        self.pointHeight = pointHeight
        self.topTaper = topTaper
        self.bottomTaper = bottomTaper
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        let sidePoints = [
            Corner(x: rect.minX + bottomTaper.value(using: rect.width / 2), y: rect.maxY),
            Corner(x: rect.minX + topTaper.value(using: rect.width / 2), y: rect.minY + pointHeight.value(using: rect.height))
        ]
        return sidePoints
        + [Corner(x: rect.midX, y: rect.minY)]
        + sidePoints.flippedHorizontally(across: rect.midX).reversed()
    }
}
