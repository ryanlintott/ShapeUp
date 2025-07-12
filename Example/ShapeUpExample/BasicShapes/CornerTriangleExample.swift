//
//  CornerTriangleExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-09.
//

import ShapeUp
import SwiftUI

struct CornerTriangleExample: View {
    var body: some View {
        VStack {
            CornerTriangle(topPoint: .relative(0.6), styles: [
                .top: .straight(radius: 10),
                .bottomRight: .rounded(radius: .relative(0.3)),
                .bottomLeft: .concave(radius: .relative(0.2))
            ])
                .fill(Color.suCyan)
                .frame(width: 200, height: 100)
            
            CornerTriangle(topPoint: .zero)
                .applyingStyle(.concave(radius: 10))
                .strokeBorder(Color.suPink, lineWidth: 8)
                .frame(width: 200, height: 100)
            
            CornerTriangle()
                .applyingStyle(.rounded(radius: 10), shapeCorners: [.top, .bottomRight])
                .fill(Color.suYellow)
                .frame(width: 200, height: 100)
        }
        .navigationTitle("CornerTriangle")
    }
}

struct CornerTriangleExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CornerTriangleExample()
        }
    }
}

