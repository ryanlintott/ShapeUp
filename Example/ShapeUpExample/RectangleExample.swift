//
//  RectangleExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct RectangleExample: View {
    let styles: [CornerStyle] = [
        .rounded(30),
        .cutout(30),
        .straight(30),
        .concave(30)
    ]
    
    var body: some View {
        VStack {
            ForEach(styles, id: \.self) { style in
                Rectangle()
                    .applyingStyle(style)
                    .fill(Color.suPurple)
                    .padding()
            }
        }
    }
}

struct RectangleExample_Previews: PreviewProvider {
    static var previews: some View {
        RectangleExample()
    }
}
