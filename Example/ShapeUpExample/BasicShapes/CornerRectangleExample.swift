//
//  CornerRectangleExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2021-08-13.
//

import ShapeUp
import SwiftUI

struct CornerRectangleExample: View {
    var body: some View {
        VStack {
            CornerRectangle([
                .topLeft: .straight(60),
                .topRight: .cutout(.relative(0.2)),
                .bottomRight: .rounded(.relative(0.6)),
                .bottomLeft: .concave(.relative(0.2))
            ])
                .fill(Color.suCyan)
                .frame(width: 200, height: 100)
            
            CornerRectangle()
                .applyingStyle(.straight(20))
                .strokeBorder(Color.suPink, lineWidth: 8)
                .frame(width: 200, height: 100)
            
            CornerRectangle()
                .applyingStyle(.rounded(30), shapeCorners: [.bottomLeft, .bottomRight])
                .fill(Color.suYellow)
                .frame(width: 100, height: 100)
        }
        .navigationTitle("CornerRectangle")
    }
}

struct CornerRectangleExample_Previews: PreviewProvider {
    static var previews: some View {
        CornerRectangleExample()
    }
}
