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
                        .rectangle(depth: 50, cornerStyle: .rounded(radius: 10)),
                        nil,
                        .triangle(position: .relative(0.5), length: .relative(0.2), depth: .relative(0.1)),
                        .custom(depth: 60) { rect in                            
                            [
                                Corner(x: rect.midX, y: rect.minY),
                                Corner(x: rect.minX, y: rect.maxY),
                                Corner(.rounded(radius: 15), x: rect.midX, y: rect.maxY),
                                Corner(x: rect.maxX, y: rect.minY)
                            ]
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
