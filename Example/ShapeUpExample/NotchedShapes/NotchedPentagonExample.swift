//
//  NotchedPentagonExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-09.
//

import ShapeUp
import SwiftUI

struct NotchedPentagonExample: View {
    var body: some View {
        CornerCustom { rect in
            CornerPentagon(
                pointHeight: .relative(0.2),
                topTaper: .relative(0.15),
                bottomTaper: .zero
            )
            .corners(in: rect)
            .applyingStyle(.rounded(20))
            .addingNotches([
                .triangle(depth: .relative(0.2)),
                nil,
                nil,
                .triangle(depth: .relative(0.2)),
                .rectangle(length: 20, depth: 10, cornerStyle: .rounded(.relative(0.4)))
            ])
        }
        .fill(Color.suYellow)
        .frame(width: 300, height: 300)
        .navigationTitle("NotchedPentagon")
    }
}

struct NotchedPentagonExample_Previews: PreviewProvider {
    static var previews: some View {
        NotchedPentagonExample()
    }
}
