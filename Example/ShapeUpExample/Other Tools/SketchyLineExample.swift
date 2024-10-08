//
//  SketchyLineExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2021-08-13.
//

import ShapeUp
import SwiftUI

struct SketchyLineExample: View {
    @State private var drawAmount: CGFloat = 1
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("An easy way to draw lines with edges that extend beyond the frame.")
                Text("Adjust the extension amount and offset of each line using `RelatableValue.absolute` or `.relative`.")
                Text("Animate the `drawAmount` and set the `drawDirection`")
            }
            
            Spacer()
            
            Text("Baseline")
                .font(.system(size: 32))
                .alignmentGuide(.bottom) { d in
                    d[.firstTextBaseline]
                }
                .background(
                    SketchyLines(lines: [
                        .leading(startExtension: -2, endExtension: 10),
                        .bottom(startExtension: 5, endExtension: 5, offset: .relative(0.05))
                    ], drawAmount: drawAmount)
                        .stroke(Color.suPink, lineWidth: 2)
                    , alignment: .bottom
                )
            
            Spacer()
            
            Text("Boxed In")
                .font(.system(size: 32))
                .padding(.horizontal, 5)
                .background(
                    SketchyLines(lines: [
                        .top(startExtension: 5, endExtension: 5, drawDirection: .toTopLeading),
                        .bottom(startExtension: 5, endExtension: 5),
                        .leading(startExtension: 5, endExtension: 5),
                        .trailing(startExtension: 5, endExtension: 5)
                    ], drawAmount: drawAmount)
                        .stroke(Color.suPink, lineWidth: 2)
                    , alignment: .bottom
                )
            
            Spacer()
            
            Button("Animate") {
                withAnimation {
                    drawAmount = drawAmount < 1 ? 1 : 0
                }
            }
            
            Spacer()
            
            CrossPlatformSlider(
                label: "Draw Amount",
                value: $drawAmount,
                minValue: 0,
                maxValue: 1,
                step: 0.1,
                labelPrefix: true
            )
        }
        .padding()
        .navigationTitle("SketchyLine")
    }
}

struct SketchyLineExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SketchyLineExample()
        }
    }
}
