//
//  RelativeCornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-26.
//

import SwiftUI

public struct RelativeCornerShape: CornerShape {
    public var closed: Bool
    public var insetAmount: CGFloat = 0
    public var relativeCorners: [RelativeCorner]
    
    public init(closed: Bool = true, _ relativeCorners: [RelativeCorner]) {
        self.closed = closed
        self.relativeCorners = relativeCorners
    }
    
    public init(_ relativeCorners: RelativeCorner...) {
        self.closed = true
        self.relativeCorners = relativeCorners
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        relativeCorners.corners(in: rect)
    }
}

public extension RelativeCornerShape {
    func closed(_ isClosed: Bool) -> Self {
        if closed == isClosed { return self }
        var copy = self
        copy.closed = isClosed
        return copy
    }
    
    func applyingStyle(_ cornerStyle: CornerStyle) -> Self {
        var copy = self
        copy.relativeCorners.applyStyle(cornerStyle)
        return copy
    }
}

#Preview {
    VStack {
        RelativeCornerShape(
            .relative(x: 0, y: 0.5),
            .relative(x: 0.3, y: 0.8).rounded(radius: 40),
            .topRight.cutout(radius: 10),
            .relative(x: 1, y: 0.3),
            .relative(x: 0.3, y: 1).rounded(radius: 40),
        )
        .fill()
        
        RelativeCornerShape(
            [
                .relative(x: 0.2, y: 0.5),
                .relative(x: 0.3, y: 0.8).rounded(radius: 40),
                .topRight,
                .relative(x: 1, y: 0.1),
                .relative(x: 0.3, y: 1).rounded(radius: 40),
            ]
                .moved(dx: 0.2)
                .rotated(.degrees(20))
                .scaledPositions(x: 0.5, y: 0.5, anchor: .topLeft)
                .flippedVertically(across: 0.5)
        )
        .fill()
    }
}
