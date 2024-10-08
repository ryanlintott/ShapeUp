//
//  MessageBubbleExamples.swift
//  ShapeUpExample
//
//  Created by Eidinger, Marco on 3/27/22.
//

import ShapeUp
import SwiftUI

struct MessageBubbleExamples: View {
    @State private var insetAmount: CGFloat = 0
    @State private var cornerRadius: CGFloat = 20
    @State private var pointSize: CGFloat = 20
    @State private var pointRadius: CGFloat = 10
    
    let color: Color = .suPink
    let textColor: Color = .suWhite
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 50) {
                    MessageBubble0(
                        cornerRadius: cornerRadius,
                        pointSize: pointSize,
                        pointRadius: pointRadius
                    )
                    .fill(color)
                    .aspectRatio(1.5, contentMode: .fit)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("SwiftUI `Shape`")
                            Text("Not insettable.")
                        }
                            .foregroundColor(textColor)
                            .padding()
                    )
                    
                    MessageBubble1(
                        cornerRadius: .absolute(cornerRadius),
                        pointSize: pointSize,
                        pointRadius: .absolute(pointRadius)
                    )
                    .inset(by: insetAmount)
                    .fill(color)
                    .aspectRatio(1.5, contentMode: .fit)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("Changed to `CornerShape`")
                            Text("Insettable without extra code.")
                            Text("Corner radii can be relative to shape scale.")
                        }
                            .foregroundColor(textColor)
                            .padding()
                    )
                    
                    MessageBubble2(
                        cornerRadius: .absolute(cornerRadius),
                        pointSize: pointSize,
                        pointRadius: .absolute(pointRadius)
                    )
                    .inset(by: insetAmount)
                    .fill(color)
                    .aspectRatio(1.5, contentMode: .fit)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("`flippedHorizontally` used so only half the corners need to be specified.")
                        }
                            .foregroundColor(textColor)
                            .padding()
                    )
                    
                    MessageBubble3(
                        cornerRadius: .absolute(cornerRadius),
                        pointSize: .absolute(pointSize),
                        pointRadius: .absolute(pointRadius)
                    )
                    .inset(by: insetAmount)
                    .fill(color)
                    .aspectRatio(1.5, contentMode: .fit)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("`rect.corners` used to draw the main shape and `.addingNotch` used to add the point.")
                        }
                            .foregroundColor(textColor)
                            .padding()
                    )
                    
                    MessageBubble4(
                        cornerRadius: .absolute(cornerRadius),
                        pointSize: .absolute(pointSize),
                        pointRadius: .absolute(pointRadius),
                        insetAmount: insetAmount
                    )
                    .foregroundColor(color)
                    .aspectRatio(1.5, contentMode: .fit)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("`CornerCustom` shape created inline in a SwiftUI view.")
                            Text("")
                        }
                            .foregroundColor(textColor)
                            .padding()
                    )
                }
                .frame(maxWidth: 400)
                .padding()
            }
            
            CrossPlatformSlider(
                label: "Corner Radius",
                value: $cornerRadius,
                minValue: 0,
                maxValue: 80,
                step: 10,
                labelPrefix: true
            )
            
            CrossPlatformSlider(
                label: "Point Size",
                value: $pointSize,
                minValue: 0,
                maxValue: 50,
                step: 10,
                labelPrefix: true
            )
            
            CrossPlatformSlider(
                label: "Point Radius",
                value: $pointRadius,
                minValue: 0,
                maxValue: 40,
                step: 10,
                labelPrefix: true
            )
            
            CrossPlatformSlider(
                label: "Inset",
                value: $insetAmount,
                minValue: -10,
                maxValue: 10,
                step: 2,
                labelPrefix: true
            )
        }
        .padding()
        .navigationTitle("Drawing Methods")
    }
}

struct MessageBubbleExamples_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MessageBubbleExamples()
        }
    }
}

