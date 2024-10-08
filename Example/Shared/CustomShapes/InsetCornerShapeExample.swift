//
//  InsetCornerShapeExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-02-11.
//

import ShapeUp
import SwiftUI

struct InsetCornerShape: CornerShape {
    var closed = true
    var insetAmount: CGFloat = 0
    
    func corners(in rect: CGRect) -> [Corner] {
        [
            Corner(x: rect.minX, y: rect.minY),
            Corner(x: rect.midX, y: rect.midY),
            Corner(x: rect.maxX, y: rect.minY),
            Corner(x: rect.maxX, y: rect.maxY),
            Corner(x: rect.minX, y: rect.maxY)
        ]
            .applyingStyle(.concave(radius: 25))
    }
}

struct InsetCornerShapeExample: View {
    var body: some View {
        ZStack {
            InsetCornerShape()
                .strokeBorder(Color.suCyan, lineWidth: 15)
        }
            .frame(width: 200, height: 200)
            .navigationTitle("InsetCornerShape")
    }
}

struct InsetCornerShapeExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InsetCornerShapeExample()
        }
    }
}
