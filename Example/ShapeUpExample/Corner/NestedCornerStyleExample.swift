//
//  NestedCornerStyleExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-09.
//

import ShapeUp
import SwiftUI

struct NestedCornerStyleExample: View {
    @State private var mainCornerStyleOption: MainCornerStyleOption = .straight
    @State private var mainCornerStyleRelativeRadius: CGFloat = 0.25
    @State private var nestedCornerStyleOption: NestedCornerStyleOption = .cutout
    @State private var nestedCornerStyleRelativeRadius: CGFloat = 0.25

    enum MainCornerStyleOption: String, CaseIterable, Identifiable {
        case straight
        case cutout
        var id: String { rawValue }
        
        func cornerStyle(radius: RelatableValue, cornerStyle: CornerStyle) -> CornerStyle {
            switch self {
            case .straight: .straight(radius: radius, cornerStyle: cornerStyle)
            case .cutout: .cutout(radius: radius, cornerStyle: cornerStyle)
            }
        }
    }

    enum NestedCornerStyleOption: String, CaseIterable, Identifiable {
        case none
        case rounded
        case straight
        case cutout
        case concave
        var id: String { rawValue }
        
        func cornerStyle(radius: RelatableValue) -> CornerStyle {
            switch self {
            case .none: .point
            case .rounded: .rounded(radius: radius)
            case .straight: .straight(radius: radius)
            case .cutout: .cutout(radius: radius)
            case .concave: .concave(radius: radius)
            }
        }
    }

    private var exampleStyle: CornerStyle {
        mainCornerStyleOption
            .cornerStyle(
                radius: .relative(mainCornerStyleRelativeRadius),
                cornerStyle: nestedCornerStyleOption
                    .cornerStyle(radius: .relative(nestedCornerStyleRelativeRadius))
            )
    }

    private var codeString: String {
        let radius = String(format: "%.2f", mainCornerStyleRelativeRadius)
        let nestedRadius = String(format: "%.2f", nestedCornerStyleRelativeRadius)
        
        if nestedCornerStyleOption == .none {
            return """
            CornerStyle
              .\(mainCornerStyleOption.rawValue)(
                radius: .relative(\(radius))
              )
            """
        }
        
        return """
            CornerStyle
              .\(mainCornerStyleOption.rawValue)(
                radius: .relative(\(radius)),
                cornerStyle: .\(nestedCornerStyleOption.rawValue)(
                  radius: .relative(\(nestedRadius))
                )
              )
            """
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Some corner styles can have nested styles")
                
                    CornerRectangle()
                        .defaultCornerStyle(exampleStyle)
                        .fill(Color.suPink)
                        .frame(width: 200, height: 140)
                        .padding()
                        .frame(maxWidth: .infinity)
                    
                    Text(codeString)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                }
            }
            
            VStack(alignment: .leading) {
                Section {
                    Picker("Main Corner Style", selection: $mainCornerStyleOption) {
                        ForEach(MainCornerStyleOption.allCases) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    CrossPlatformSlider(
                        label: "Radius",
                        value: $mainCornerStyleRelativeRadius,
                        minValue: 0,
                        maxValue: 0.5,
                        step: 0.05,
                        decimalPlaces: 2,
                        labelPrefix: true
                    )
                } header: {
                    Text("Main Corner Style")
                        .font(.headline)
                }
                
                Divider()

                Section {
                    Picker("Nested Corner Style", selection: $nestedCornerStyleOption) {
                        ForEach(NestedCornerStyleOption.allCases) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    CrossPlatformSlider(
                        label: "Radius",
                        value: $nestedCornerStyleRelativeRadius,
                        minValue: 0,
                        maxValue: 0.5,
                        step: 0.05,
                        decimalPlaces: 2,
                        labelPrefix: true
                    )
                    .disabled(nestedCornerStyleOption == .none)
                } header: {
                    Text("Nested Corner Style:")
                        .font(.headline)
                }
            }
        }
        .padding()
        .navigationTitle("Nested Corners")
    }
}

struct NestedCornerStyleExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NestedCornerStyleExample()
        }
    }
}
