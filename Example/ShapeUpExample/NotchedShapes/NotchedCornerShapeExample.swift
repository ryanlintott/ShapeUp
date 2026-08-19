//
//  NotchedCornerShapeExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-19.
//

import ShapeUp
import SwiftUI

struct NotchedCornerShape: CornerShape {
    var insetAmount: CGFloat = .zero
    let closed: Bool = true
    
    func corners(in rect: CGRect) -> [Corner] {
        rect[.topLeft]
            .moved(dy: 40)
            .rounded(radius: .relative(0.4))
        
        Notch(length: .relative(0.3), depth: .relative(0.1)) {
            RelativeCorners {
                (0.0, 0.0)
                (0.2, 0.6)
                (0.8, -0.6)
                (1.0, 0.0)
            }
            .defaultCornerStyle(.rounded(radius: .absolute(15), style: .continuous))
        }
        
        rect[.topRight]
            .concave(radius: .relative(0.5))
        
        Corners {
            rect[.right]
            
            rect[.bottom]
                .cutout(
                    radius: .relative(0.3),
                    cornerStyle: .straight(radius: .absolute(6))
                )
            
            rect[.left]
        }
        .scaledPositions(x: 0.4, anchor: .center)
        .rotated(.degrees(20), anchor: .center)
        .defaultCornerStyle(.rounded(radius: .relative(0.3)))
    }
}

struct NotchedCornerShapeExample: View {
    var body: some View {
        ZStack {
            NotchedCornerShape()
                .fill(.suPink)
            
            NotchedCornerShape()
                .inset(by: -8)
                .strokeBorder(lineWidth: 4)
        }
            .frame(width: 300, height: 300)
            .navigationTitle("NotchedPentagon")
    }
}

#Preview {
    NotchedCornerShapeExample()
}
