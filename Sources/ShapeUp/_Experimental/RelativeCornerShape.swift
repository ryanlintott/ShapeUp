//
//  RelativeCornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-09-06.
//

import SwiftUI

/// A CornerShape that stores corners based on relative positions. This would be useful for creating shapes with an array of animated corner positions.
internal struct RelativeCornerShape: CornerShape {
    public let closed: Bool
    public var insetAmount: CGFloat = 0
    
    nonisolated public var animatableData: CGFloat {
        get {
            insetAmount
        }
        set {
            insetAmount = newValue
        }
    }
    
    let relativeFrame: CGRect = .one
    public var relativeCorners: [Corner]
    
    /// Creates a custom insettable shape out of corners.
    /// - Parameters:
    ///  - closed: A boolean determining if the shape should be closed. Default is true.
    ///  - corners: Corners used to draw a single closed shape.
    nonisolated public init(closed: Bool = true, _ corners: (CGRect) -> [Corner]) {
        self.closed = closed
        self.relativeCorners = corners(relativeFrame)
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        relativeCorners.repositioned(from: relativeFrame, to: rect)
    }
}
