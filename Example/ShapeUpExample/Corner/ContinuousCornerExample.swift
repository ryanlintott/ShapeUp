//
//  ContinuousCornerExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-08-13.
//

import ShapeUp
import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
struct ContinuousCornerMatchExample: View {
    @State private var radius: CGFloat = 91
    @State private var antialiased = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
"""
Continuous corners drawn directly do not match path elements.

The visible pink edges show the difference between a RoundedRectangle with continuous corners and the exact path elements for that same rounded rectangle.
"""
            )
            .font(.callout)
            
            GeometryReader { geometry in
                CornerRectangle()
                    .defaultCornerStyle(.rounded(radius: .absolute(radius), style: .continuous))
                    .fill(
                        .suPink,
                        style: FillStyle(antialiased: antialiased)
                    )
                
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        .suBlack,
                        style: FillStyle(antialiased: antialiased)
                    )
            }
            .padding()
            .background(.suBlack)
                        
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Radius: \(radius, format: .number)")
                    Slider(value: $radius, in: 0...100, step: 1)
                }
                
                Toggle("Antialiased", isOn: $antialiased)
            }
        }
        
        .padding()
        .navigationTitle("Continuous Corner")
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
#Preview {
    NavigationView {
        ContinuousCornerMatchExample()
    }
}
