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
    
    var cornerShape: CornerRectangle {
        CornerRectangle()
            .defaultCornerStyle(.rounded(radius: .absolute(radius), style: .continuous))
    }
    
    var roundedRectangle: RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
    
    func roundedRectangleElements(in rect: CGRect) -> some Shape {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .path(in: rect)
            .rebuiltFromElements()
    }
    
    func overlay(_ shape1: some Shape, on shape2: some Shape, size: CGSize, alignment: Alignment) -> some View {
        ZStack {
            shape2
                .fill(
                    .suPink,
                    style: FillStyle(antialiased: antialiased)
                )
            
            shape1
                .fill(
                    .suBlack,
                    style: FillStyle(antialiased: antialiased)
                )
        }
        .mask(alignment: alignment) {
            Rectangle()
                .frame(maxWidth: size.width / 2, maxHeight: size.height / 2)
        }
    }
    
    func overlayText(_ string: String, size: CGSize) -> some View {
        Text(string)
            .foregroundStyle(.suWhite)
            .frame(maxWidth: size.width / 2, maxHeight: size.height / 2)
    }
    
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
                let size = geometry.size
                let rect = CGRect(origin: .zero, size: size)
                
                overlay(cornerShape, on: roundedRectangle, size: size, alignment: .topLeading)
                    .overlay(alignment: .topLeading) {
                        overlayText("CornerShape on RoundedRect", size: size)
                    }
                
                overlay(roundedRectangle, on: cornerShape, size: size, alignment: .topTrailing)
                    .overlay(alignment: .topTrailing) {
                        overlayText("RoundedRect on CornerShape", size: size)
                    }
                
                overlay(cornerShape, on: roundedRectangleElements(in: rect), size: size, alignment: .bottomLeading)
                    .overlay(alignment: .bottomLeading) {
                        overlayText("CornerShape on Path Elements", size: size)
                    }
                
                overlay(roundedRectangleElements(in: rect), on: cornerShape, size: size, alignment: .bottomTrailing)
                    .overlay(alignment: .bottomTrailing) {
                        overlayText("Path Elements on CornerShape", size: size)
                    }
            }
            .font(.caption)
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
