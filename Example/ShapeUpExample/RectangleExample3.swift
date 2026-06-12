//
//  RectangleExample3.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2025-05-26.
//

import ShapeUp
import SwiftUI

struct RectangleExample3: View {
    var body: some View {
        CornerRectangle()
            .cornerStyles(
                [
                    .topLeft: .rounded(radius: 50),
                    .topRight: .rounded(radius: .relative(0.5)),
                    .bottomRight: .cutout(radius: 40),
                    .bottomLeft: .custom(
                        radius: .relative(0.3),
                        relativeCorners: [
                            .topLeft.rounded(radius: .relative(0.5)),
                            .relative(x: 0.4, y: -0.3).concave(radius: .relative(0.3)),
                            .relative(x: 0.6, y: 0.8),
                            .bottomRight.rounded(radius: .relative(0.5)),
                        ]
                    )
                ]
            )
            .padding()
            .frame(height: 400)
            .foregroundColor(.suPink)
    }
}

#Preview {
    RectangleExample3()
}
