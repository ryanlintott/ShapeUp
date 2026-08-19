//
//  CornerShapeExample2.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2025-07-23.
//

import SwiftUI
import ShapeUp

struct CornerShapeExample2: CornerShape {
    var insetAmount: CGFloat = .zero
    var closed = true
    var radius: CGFloat
   
    func corners(in rect: CGRect) -> [Corner] {
        [
            rect[.topLeft].rounded(radius: .absolute(radius)),
            rect[.topRight].rounded(radius: .absolute(radius)),
            rect[.bottomRight],
            rect[.bottomRight].moved(dx: -radius, dy: -radius),
            rect[.bottomLeft].moved(dy: -radius).rounded(radius: .absolute(radius))
        ]
    }
}

#Preview {
    CornerShapeExample2(radius: 20)
        .frame(maxWidth: 200, maxHeight: 200)
}
