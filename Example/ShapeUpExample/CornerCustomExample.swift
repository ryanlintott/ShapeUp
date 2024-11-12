//
//  CornerCustomExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-10.
//

import ShapeUp
import SwiftUI

struct CornerCustomExample: View {
    @State private var inset = 10.0
    
    var body: some View {
        VStack {
            CornerCustom { rect in
                [
                    Corner(.straight(.relative(0.4)),x: rect.minX, y: rect.minY),
                    Corner(.rounded(.relative(0.1)), x: rect.midX, y: rect.midY),
                    Corner(.concave(20),x: rect.maxX, y: rect.minY),
                    Corner(.cutout(.relative(0.3)),x: rect.maxX, y: rect.maxY),
                    Corner(.concave(40), x: rect.midX, y: rect.midY + (rect.height * 0.1)),
                    Corner(x: rect.minX, y: rect.maxY)
                ]
            }
            .inset(by: inset)
                .fill(Color.suPink)
                .frame(width: 200, height: 150)
                .animation(.default, value: inset)
            
            CrossPlatformStepper(
                label: "Inset",
                value: $inset,
                minValue: -30,
                maxValue: 30,
                step: 10
            )
            
            Text("Closed Shape")
            
            CornerCustom(closed: false) { rect in
                rect[
                    (0.0, 1.0),
                    (0.0, 0.4),
                    (0.4, 0.7),
                    (0.4, 0.1),
                    (0.7, 0.3),
                    (1.0, 0),
                    (0.8, 1.0)
                ]
                    .corners([
                        nil,
                        .rounded(.relative(0.4)),
                        .concave(.relative(0.3)),
                        .straight(.relative(0.3)),
                        .cutout(.relative(0.1))
                    ])
            }
                .stroke(Color.suYellow, lineWidth: 10)
                .frame(width: 200, height: 150)
            
            Text("Open Shape")
        }
        .navigationTitle("CornerCustom")
    }
}

struct CornerCustomExample_Previews: PreviewProvider {
    static var previews: some View {
        CornerCustomExample()
    }
}
