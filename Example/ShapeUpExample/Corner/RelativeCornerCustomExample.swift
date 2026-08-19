//
//  RelativeCornerCustomExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2025-09-19.
//

import ShapeUp
import SwiftUI

struct CustomRelativeCornerShape: CornerShape {
    let closed: Bool
    var insetAmount: CGFloat = 0

    func corners(in rect: CGRect) -> [Corner] {
        rect[.topLeft].rounded(radius: 0.25)
        rect[0.25, 0.35].straight(radius: 0.08)
        rect[.topRight].cutout(radius: 16)
        rect[.bottomRight].concave(radius: 0.3)
    }
}

struct RelativeCornerCustomExample: View {
    @State private var closed = true
    @State private var insetAmount: CGFloat = 0
    @State private var cornerX: CGFloat = 0.2
    @State private var cornerY: CGFloat = 0.9

    var shape: some CornerShape {
        RelativeCornerCustom {
            RelativeCorner.topLeft.rounded(radius: .relative(0.3))
            
            RelativeCorner.center.straight(radius: .relative(0.1))
            
            RelativeCorner.topRight.cutout(radius: 20)
            
            RelativeCorner.bottomRight.concave(radius: .relative(0.3))
            
            RelativeCorner(x: cornerX, y: cornerY)
        }
        .inset(by: insetAmount)
        .closed(closed)
    }
    
    var code: String {
"""
RelativeCornerCustom {
  RelativeCorner.topLeft
    .rounded(radius: .relative(0.3))
    
  RelativeCorner.center
    .straight(radius: .relative(0.1))
    
  RelativeCorner.topRight
    .cutout(radius: 20)
    
  RelativeCorner.bottomRight
    .concave(radius: .relative(0.3))

  RelativeCorner(x: \(String(format: "%.2f", cornerX)), y: \(String(format: "%.2f", cornerY)))
}
.inset(by: insetAmount)
.closed(closed)
"""
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Similar to `CornerCustom`, `RelativeCornerCustom` creates a corner shape but without access to the rect. This means all corners must have relative positions but the benefit is everything can be animated.")
                    
                    ZStack {
                        shape
                            .fill(Color.suCyan)
                        
                        shape
                            .stroke(Color.suPink, lineWidth: 12)
                    }
                    .frame(width: 200, height: 150)
                    .border(Color.suBlack)
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    Text(code)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.vertical)
                }
            }

            VStack(alignment: .leading) {
                Section {
                    Picker("Shape Options", selection: $closed) {
                        Text("Closed").tag(true)
                        Text("Open").tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    CrossPlatformSlider(
                        label: "Inset Amount",
                        value: $insetAmount,
                        minValue: -30,
                        maxValue: 30,
                        step: 5,
                        labelPrefix: true
                    )
                    
                    Button("Animate Corner") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            cornerX = .random(in: 0.1...0.5)
                            cornerY = .random(in: 0.5...0.9)
                        }
                    }
                } header: {
                    Text("Shape Style")
                        .font(.headline)
                }
            }
            .padding()
        }
        .navigationTitle("RelativeCorner")
    }
}

#Preview {
    NavigationView {
        RelativeCornerCustomExample()
    }
}
