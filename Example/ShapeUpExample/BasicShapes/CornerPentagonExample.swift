//
//  CornerPentagonExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-09.
//

import ShapeUp
import SwiftUI

struct CornerPentagonExample: View {
    var body: some View {
        VStack {
            CornerPentagon(
                pointHeight: .relative(0.3),
                topTaper: .relative(0.1),
                bottomTaper: .relative(0.3),
                styles: [
                    .topRight: .concave(30),
                    .bottomLeft: .straight(.relative(0.3))
                ]
            )
                .fill(Color.suCyan)
                .frame(width: 200, height: 100)
            
            CornerPentagon(pointHeight: 10)
                .applyingStyle(.concave(10))
                .strokeBorder(Color.suPink, lineWidth: 8)
                .frame(width: 200, height: 100)
            
            CornerPentagon(pointHeight: .relative(0.5), topTaper: .relative(0.3))
                .applyingStyle(.rounded(.relative(0.3)), shapeCorners: [.bottomLeft, .bottomRight])
                .fill(Color.suYellow)
                .frame(width: 200, height: 100)
        }
        .navigationTitle("CornerPentagon")
    }
}

struct CornerPentagonExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CornerPentagonExample()
        }
    }
}
