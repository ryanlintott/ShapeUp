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
        Rectangle()
            .applyingStyles(
                [
                    .topLeft: .rounded(50),
                    .topRight: .rounded(.relative(0.5)),
                    .bottomRight: .cutout(40),
                    .bottomLeft: .custom(
                        .relative(0.3),
                        relativeCorners: [
                            .topLeft(.rounded(.relative(0.5))),
                            .relative(x: 0.4, y: -0.3, .concave(.relative(0.3))),
                            .relative(x: 0.6, y: 0.8),
                            .bottomRight(.rounded(.relative(0.5))),
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