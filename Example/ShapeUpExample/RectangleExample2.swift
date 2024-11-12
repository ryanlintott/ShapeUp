//
//  RectangleExample2.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct RectangleExample2: View {
    var body: some View {
        Rectangle()
            .applyingStyles([
                .topLeft: .rounded(100),
                .topRight: .concave(80),
                .bottomRight: .straight(50),
                .bottomLeft: .cutout(50)
            ])
            .fill(Color.suPurple)
            .padding()
            .frame(height: 400)
    }
}

struct RectangleExample2_Previews: PreviewProvider {
    static var previews: some View {
        RectangleExample2()
    }
}
