//
//  CornerExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2023-05-19.
//

import ShapeUp
import SwiftUI

struct CustomCornerShapeExample: CornerShape {
    let closed: Bool = true
    var insetAmount: CGFloat = 0
    var style: CornerStyle
    
    init(style: CornerStyle) {
        self.style = style
    }
    
    var animatableData: AnimatablePair<CGFloat, CornerStyle.AnimatableData> {
        get {
            .init(insetAmount, style.animatableData)
        }
        set {
            insetAmount = newValue.first
            style.animatableData = newValue.second
        }
    }
    
    func corners(in rect: CGRect) -> [Corner] {
        rect[
            .topLeft,
            .center,
            .topRight,
            .bottomRight,
            .bottomLeft
        ].corners(style)
    }
}

struct CornerExample: View {
    enum ExampleShape: String, CaseIterable, Identifiable {
        case rectangle
        case triangle
        case pentagon
        case custom
        
        var id: Self { self }
    }
    
    let shapes = ExampleShape.allCases
    
    let styles: [CornerStyle] = [
        .point,
        .rounded(.zero),
        .concave(.zero),
        .straight(.zero),
        .cutout(.zero),
        .custom(.zero, anchorPoints: [.topLeft, .left, .center, .bottomLeft, .bottomRight])
    ]
    let radii: [RelatableValue] = [.absolute(.zero), .relative(.zero)]
    
    @State private var shape: ExampleShape = .rectangle
    @State private var style: CornerStyle = .rounded(.zero)
    @State private var relativeRadius = true
    @State private var relative = 0.2
    @State private var absolute = 25.0
    @State private var inset = 0.0
    
    var adjustedStyle: CornerStyle {
        style.changingRadius(to: relativeRadius ? .relative(relative) : .absolute(absolute))
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Make shapes using `Corner`, pick a `style` and set the `radius` using either `absolute` or `relative` values.")
            }
            
            ZStack {
                VStack {
                    ForEach(0...2, id: \.self) { _ in
                        Image(.shapeUpLogo)
                            .resizable()
                            .scaledToFit()
                    }
                }
                
                CornerExampleShapeView(shape: shape, adjustedStyle: adjustedStyle, inset: inset)
                    .accentColor(.suPink.opacity(0.1))
                    .padding()
            }
            
            Picker("Base Shape", selection: $shape) {
                ForEach(shapes) { shape in
                    Text(shape.rawValue)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("CornerStyle", selection: $style) {
                ForEach(styles, id: \.self) { style in
                    Text(style.name)
                }
            }
            .pickerStyle(.segmented)
            
            CrossPlatformStepper(
                label: "Inset: ",
                value: $inset,
                minValue: -50,
                maxValue: 50,
                step: 5,
                decimalPlaces: 0
            )
            
            #if !os(tvOS)
            Slider(value: $inset, in: -50...50) {
                Text("Inset")
            } minimumValueLabel: {
                Text("-50")
            } maximumValueLabel: {
                Text("50")
            }
            #endif
            
            VStack {
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
                
                Picker("Radius", selection: $relativeRadius) {
                    Text("Relative").tag(true)
                    Text("Absolute").tag(false)
                }
                .pickerStyle(.segmented)
                
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
        .accentColor(.suPink)
        .animation(.default, value: inset)
        .animation(.default, value: shape)
        .animation(.default, value: style)
        .animation(.default, value: relativeRadius)
        .animation(.default, value: relative)
        .animation(.default, value: absolute)
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
