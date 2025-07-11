//
//  NotchedRectangleExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2021-08-13.
//

import ShapeUp
import SwiftUI

struct NotchedRectangleExample: View {
    var body: some View {
        CornerCustom { rect in
            rect
                .corners([
                    .rounded(20),
                    .cutout(.relative(0.3)),
                    .straight(70),
                    .rounded(20)
                ])
                .addingNotches(
                    [
                        .rectangle(depth: 50, cornerStyle: .rounded(10)),
                        nil,
                        .triangle(position: .relative(0.5), length: .relative(0.2), depth: .relative(0.1)),
                        .custom(depth: 60, relativeCorners: [
                            .init(.top),
                            .init(.bottomLeft),
                            .init(.bottom, .rounded(15)),
                            .init(.topRight)
                        ])
                    ]
                )
        }
        .strokeBorder(Color.suPink, style: StrokeStyle(lineWidth: 20))
        .frame(width: 300, height: 300)
        .navigationTitle("NotchedRectangle")
    }
}

struct NotchedRectangleExample_Previews: PreviewProvider {
    static var previews: some View {
        NotchedRectangleExample()
    }
}
