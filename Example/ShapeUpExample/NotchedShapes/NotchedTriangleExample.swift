//
//  NotchedTriangleExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-09.
//

import ShapeUp
import SwiftUI

struct NotchedTriangleExample: View {
    var body: some View {
        CornerCustom { rect in
            CornerTriangle()
                .corners(in: rect)
                .applyingStyle(.rounded(radius: 20))
                .addingNotches([
                    .triangle(depth: .relative(0.2)),
                    nil,
                    .rectangle(length: 50, depth: 30, cornerStyle: .rounded(radius: .relative(0.4)))
                ])
        }
        .fill(Color.suPurple)
        .frame(width: 300, height: 300)
        .navigationTitle("NotchedTriangle")
    }
}

struct NotchedTriangleExample_Previews: PreviewProvider {
    static var previews: some View {
        NotchedTriangleExample()
    }
}
