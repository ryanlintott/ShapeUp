//
//  CornerCustomExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-10.
//

import ShapeUp
import SwiftUI

struct CornerCustomExample: View {
    @State private var bottomOffset = 0.2
    @State private var inset = 10.0
    @State private var isClosed = true
    
    var body: some View {
        VStack {
            VStack {
                CornerCustom { rect in
                    Corner(x: rect.minX, y: rect.minY)
                    Corner(x: rect.maxX, y: rect.minY)
                    Corner(x: rect.minX + rect.width * 0.2, y: rect.maxY)
                }
                .applyingStyle(.rounded(radius: .relative(0.2)))
                .inset(by: inset)
                .closed(isClosed)
                .stroke(lineWidth: 2)
                
                CornerCustom { rect in
                    rect[.topLeft]
                    rect[.topRight]
                    rect[0.2, 1.0]
                }
                .applyingStyle(.rounded(radius: .relative(0.2)))
                .inset(by: inset)
                .closed(isClosed)
                .stroke(lineWidth: 2)
                
                RelativeCornerCustom {
                    RelativeCorner.topLeft
                        .moved(dx: .relative(0.2))
                        .moved(dy: 10)
                    RelativeCorner.topRight
                    RelativeCorner(x: bottomOffset, y: 1.0)
                }
                .applyingStyle(.rounded(radius: .relative(0.2)))
                .inset(by: inset)
                .closed(isClosed)
                .stroke(lineWidth: 2)
                
                RelativeCornerCustom(.topLeft, .topRight, .relative(x: bottomOffset, y: 1.0))
                    .applyingStyle(.rounded(radius: .relative(0.2)))
                    .inset(by: inset)
                    .closed(isClosed)
                    .stroke(lineWidth: 2)
                
                RelativeCornerCustom {
                    RelativeCorners {
                        RelativeCorner.topLeft.concave(radius: .relative(0.2))
                            .moved(dx: 10, dy: 10)
                        
                        RelativeCorner.topRight.rounded(radius: .relative(0.3))
                        RelativeCorner(x: bottomOffset, y: 1.0).straight(radius: 20)
                    }
                    .moved(dx: 0.1)
                    .flippedVertically(across: 0.5)
                    .reversed()
                }
                .inset(by: inset)
                .closed(isClosed)
                .stroke(lineWidth: 2)
                
                VStack {
                    CrossPlatformStepper(
                        label: "Inset",
                        value: $inset,
                        minValue: -30,
                        maxValue: 30,
                        step: 10
                    )
                    
                    CrossPlatformStepper(
                        label: "BottomOffset",
                        value: $bottomOffset,
                        minValue: 0.0,
                        maxValue: 1.0,
                        step: 0.2,
                        decimalPlaces: 1
                    )
                    
                    Toggle("Closed", isOn: $isClosed)
                }
            }
            .animation(.default, value: bottomOffset)
            .animation(.default, value: inset)
            .foregroundColor(.suPink)
            .padding()
            
        }
        .navigationTitle("CornerCustom")
    }
}

struct CornerCustomExample_Previews: PreviewProvider {
    static var previews: some View {
        CornerCustomExample()
    }
}
