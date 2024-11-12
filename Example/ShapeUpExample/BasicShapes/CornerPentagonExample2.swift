//
//  CornerPentagonExample2.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2023-05-20.
//

import ShapeUp
import SwiftUI

struct CornerPentagonExample2: View {
    @State private var pointHeight = 0.6
    @State private var topTaper = 0.6
    @State private var bottomTaper = 0.6
    @State private var inset = 0.0
    
    var body: some View {
        VStack {
            Color.clear.overlay(
                CornerPentagon(
                    pointHeight: .relative(pointHeight),
                    topTaper: .relative(topTaper),
                    bottomTaper: .relative(bottomTaper)
                )
                .applyingStyle(.rounded(.relative(0.2)))
                .inset(by: inset)
                .fill(Color.suCyan)
                .animation(.default, value: pointHeight)
                .animation(.default, value: topTaper)
                .animation(.default, value: bottomTaper)
                .animation(.default, value: inset)
            )
            
            CrossPlatformStepper(
                label: "Point Height",
                value: $pointHeight,
                minValue: 0,
                maxValue: 1,
                step: 0.1,
                decimalPlaces: 1
            )
            
            CrossPlatformStepper(
                label: "Top Taper",
                value: $topTaper,
                minValue: 0,
                maxValue: 1,
                step: 0.1,
                decimalPlaces: 1
            )
            
            CrossPlatformStepper(
                label: "Bottom Taper",
                value: $bottomTaper,
                minValue: 0,
                maxValue: 1,
                step: 0.1,
                decimalPlaces: 1
            )
            
            CrossPlatformStepper(
                label: "Inset",
                value: $inset,
                minValue: -30,
                maxValue: 30,
                step: 10
            )
        }
        .padding()
        .navigationTitle("CornerPentagon")
    }
}

struct CornerPentagonExample2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CornerPentagonExample2()
        }
    }
}
