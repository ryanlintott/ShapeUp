//
//  RelativeShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-26.
//

import SwiftUI

struct RelativeShape: CornerShape {
    var closed: Bool
    var insetAmount: CGFloat = 0
    var relativeCorners: [RelativeCorner]
    
    init(closed: Bool = true, _ relativeCorners: [RelativeCorner]) {
        self.closed = closed
        self.relativeCorners = relativeCorners
    }
    
    func corners(in rect: CGRect) -> [Corner] {
        relativeCorners.corners(in: rect)
    }
}

#Preview {
    RelativeShape([
        .init(.left),
        .init(x: 0.3, y: 0.8, .rounded(40)),
        .init(.topRight),
        .init(x: 1, y: 0.1),
        .init(x: 0.3, y: 1, .rounded(40)),
    ])
        .fill()
}
