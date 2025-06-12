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
        .init(anchorPoint: .left),
        .init(.rounded(40), anchorPoint: .relative(0.3, 0.8)),
        .init(anchorPoint: .topRight),
        .init(anchorPoint: .relative(1, 0.1)),
        .init(.rounded(40), anchorPoint: .relative(0.3, 1)),
    ])
        .fill()
}
