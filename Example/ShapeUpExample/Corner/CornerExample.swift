//
//  CornerExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2023-05-19.
//

import ShapeUp
import SwiftUI

struct CornerExample: View {
    let shapes = ["Rectangle", "Triangle", "Pentagon"]
    let styles: [CornerStyle] = [.point, .rounded(.zero), .concave(.zero), .straight(.zero), .cutout(.zero)]
    let radii: [RelatableValue] = [.absolute(.zero), .relative(.zero)]
    
    @State private var shape = "Rectangle"
    @State private var style = CornerStyle.rounded(.zero)
    @State private var relativeRadius = true
    @State private var relative = 0.2
    @State private var absolute = 25.0
    
    var adjustedStyle: CornerStyle {
        style.changingRadius(to: relativeRadius ? .relative(relative) : .absolute(absolute))
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Make shapes using `Corner`, pick a `style` and set the `radius` using either `absolute` or `relative` values.")
            }
            
            Color.clear.overlay(
                Group {
                    switch shape {
                    case "Rectangle":
                        CornerRectangle()
                            .applyingStyle(adjustedStyle)
                    case "Triangle":
                        CornerTriangle()
                            .applyingStyle(adjustedStyle)
                    default:
                        CornerPentagon(pointHeight: .relative(0.3), bottomTaper: .relative(0.2))
                            .applyingStyle(adjustedStyle)
                    }
                }
            )
            .foregroundColor(Color.suPink)
            .padding()
            
            Picker("Base Shape", selection: $shape) {
                ForEach(shapes, id: \.self) { shape in
                    Text(shape)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("CornerStyle", selection: $style) {
                ForEach(styles, id: \.self) { style in
                    Text(style.name)
                }
            }
            .pickerStyle(.segmented)
            
            Group {
                Section {
                    Picker("Radius", selection: $relativeRadius) {
                        Text("Relative").tag(true)
                        Text("Absolute").tag(false)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    if relativeRadius {
                        CrossPlatformStepper(
                            label: "Radius",
                            value: $relative,
                            minValue: 0,
                            maxValue: 1,
                            step: 0.1,
                            decimalPlaces: 1
                        )
                    } else {
                        CrossPlatformStepper(
                            label: "Radius",
                            value: $absolute,
                            minValue: 0,
                            maxValue: 300,
                            step: 10,
                            decimalPlaces: 0
                        )
                    }
                }
                
                #if !os(tvOS)
                if relativeRadius {
                    Slider(value: $relative, in: 0...0.5) {
                        Text("Relative Value")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("0.5")
                    }
                } else {
                    Slider(value: $absolute, in: 0...150) {
                        Text("Absolute Value")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("150")
                    }
                }
                #endif
            }
            .disabled(style == .point)

        }
        .padding()
        .navigationTitle("Corner")
    }
}

struct CornerExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CornerExample()
        }
    }
}
