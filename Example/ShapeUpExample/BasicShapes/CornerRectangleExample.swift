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
                .topLeft: .straight(radius: 60),
                .topRight: .cutout(radius: .relative(0.2)),
                .bottomRight: .rounded(radius: .relative(0.6)),
                .bottomLeft: .concave(radius: .relative(0.2))
            ])
                .fill(Color.suCyan)
                .frame(width: 200, height: 100)
            
            CornerRectangle()
                .applyingStyle(.straight(radius: 20))
                .strokeBorder(Color.suPink, lineWidth: 8)
                .frame(width: 200, height: 100)
            
            CornerRectangle()
                .applyingStyle(.rounded(radius: 30), shapeCorners: [.bottomLeft, .bottomRight])
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
