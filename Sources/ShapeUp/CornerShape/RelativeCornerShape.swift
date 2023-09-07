//
//  RelativeCornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-09-06.
//

import SwiftUI

struct RelativeCornerShape: CornerShape {
    public let closed: Bool
    public var insetAmount: CGFloat = 0
    
    public var animatableData: CGFloat {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    let relativeFrame: CGRect = .one
    public var relativeCorners: [Corner]
    
    /// Creates a custom insettable shape out of corners.
    /// - Parameters:
    ///  - closed: A boolean determining if the shape should be closed. Default is true.
    ///  - corners: Corners used to draw a single closed shape.
    public init(closed: Bool = true, _ corners: (CGRect) -> [Corner]) {
        self.closed = closed
        self.relativeCorners = corners(relativeFrame)
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        relativeCorners.rescaled(from: relativeFrame, to: rect)
    }
}
