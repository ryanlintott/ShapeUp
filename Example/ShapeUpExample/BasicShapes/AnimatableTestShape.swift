//
//  AnimatableTestShape.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2024-08-09.
//

import SwiftUI

struct AnimatableTestShape: Shape {
    var insetAmount: Double
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect.insetBy(dx: insetAmount, dy: insetAmount))
        return path
    }
}

#Preview {
    AnimatableTestShape(insetAmount: 2)
        .fill()
}
