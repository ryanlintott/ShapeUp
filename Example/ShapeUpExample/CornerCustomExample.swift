//
//  CornerCustomExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-10.
//

import ShapeUp
import SwiftUI

struct CornerCustomExample: View {
    @State private var inset = 10.0
    @State private var isClosed = true
    
    var shape: some CornerShape {
        CornerCustom { rect in
            rect[.topLeft]
                .rounded(radius: .relative(0.2))
            
            rect[.topRight]
                .rounded(radius: .relative(0.2))
            
            rect[0.2, 1.0]
        }
        .inset(by: inset)
        .closed(isClosed)
    }
    
    var code: String {
"""
CornerCustom { rect in
    rect[.topLeft]
        .rounded(radius: .relative(0.2))
    
    rect[.topRight]
        .rounded(radius: .relative(0.2))
    
    rect[0.2, 1.0]
}
.inset(by: inset)
.closed(isClosed)
"""
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("`CornerCustom` can be used to make a `CornerShape` inline without defining a new struct. The closure will not respond to any chaning properties but the inset or any other styles applied outside the closure can change and be animated.")
                    
                    ZStack {
                        shape
                            .fill(Color.suCyan)
                        
                        shape
                            .stroke(Color.suPink, lineWidth: 12)
                    }
                    .frame(width: 200, height: 150)
                    .border(Color.suBlack)
                    .padding(2)
                    .frame(maxWidth: .infinity)
                    
                    Text(code)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.vertical)
                }
                
                
            }
            
            VStack(alignment: .leading) {
                Section {
                    CrossPlatformStepper(
                        label: "Inset",
                        value: $inset,
                        minValue: -30,
                        maxValue: 30,
                        step: 10
                    )
                    
                    Toggle("Closed", isOn: $isClosed)
                } header: {
                    Text("Shape Style")
                        .font(.headline)
                }
            }
        }
        .animation(.default, value: inset)
        .padding()
        .navigationTitle("CornerCustom")
    }
}

#Preview {
    NavigationView {
        CornerCustomExample()
    }
}
