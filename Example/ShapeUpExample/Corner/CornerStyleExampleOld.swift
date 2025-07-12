//
//  CornerStyleExampleOld.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-10.
//

import ShapeUp
import SwiftUI

struct CornerStyleExampleOld: View {
    let styles: [CornerStyle] = [
        .point,
        .rounded(radius: 25),
        .concave(radius: 25),
        .straight(radius: 25),
        .cutout(radius: 25)
    ]
    
    var body: some View {
        VStack {
            ForEach(styles, id: \.self) { style in
                ZStack {
                    CornerTriangle()
                        .applyingStyles([.top: style])
                        .fill(Color.suPink)
                    
                    Text(style.name)
                }
                .padding(5)
                .padding(.horizontal, 50)
            }
        }
        .padding()
        .navigationTitle("CornerStyle")
    }
}

struct CornerStyleExampleOld_Previews: PreviewProvider {
    static var previews: some View {
        CornerStyleExampleOld()
    }
}
