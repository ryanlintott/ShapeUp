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
                    .rounded(radius: 20),
                    .cutout(radius: .relative(0.3)),
                    .straight(radius: 70),
                    .rounded(radius: 20)
                ])
                .addingNotches(
                    [
                        Notch(depth: 50).defaultCornerStyle(.rounded(radius: 10)),
                        nil,
                        Notch(.triangle, position: .relative(0.5), length: .relative(0.2), depth: .relative(0.1)),
                        Notch(depth: 60) {
                            RelativeCorner.top
                            RelativeCorner.bottomLeft
                            RelativeCorner.bottom.rounded(radius: 15)
                            RelativeCorner.topRight
                        }
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
