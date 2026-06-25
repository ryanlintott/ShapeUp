//
//  CornerShapeExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2021-08-13.
//

import ShapeUp
import SwiftUI

struct TestClosedShape: CornerShape {
    let closed: Bool
    var insetAmount: CGFloat = 0
    
    func corners(in rect: CGRect) -> [Corner] {
        rect[.topLeft].rounded(radius: .relative(0.3))
        rect[.center].straight(radius: .relative(0.1))
        rect[.topRight].cutout(radius: 20)
        rect[.bottomRight].concave(radius: .relative(0.3))
        rect[0.2, 0.9]
        
        // Old method
//        [
//            Corner(.rounded(radius: .relative(0.3)), x: rect.minX, y: rect.minY),
//            Corner(.straight(radius: .relative(0.1)), x: rect.midX, y: rect.midY),
//            Corner(.cutout(radius: 20), x: rect.maxX, y: rect.minY),
//            Corner(.concave(radius: .relative(0.3)), x: rect.maxX, y: rect.maxY),
//            Corner(x: rect.midX, y: rect.maxY),
//        ]
    }
    
    static let code: String =
"""
struct TestClosedShape: CornerShape {
  let closed: Bool
  var insetAmount: CGFloat = 0

  func corners(in rect: CGRect) -> [Corner] {
    rect[.topLeft]
        .rounded(radius: .relative(0.3))

    rect[.center]
        .straight(radius: .relative(0.1))

    rect[.topRight]
        .cutout(radius: 20)

    rect[.bottomRight]
        .concave(radius: .relative(0.3))

    rect[0.2, 0.9]
  }
}
"""
}

struct CornerShapeExample: View {
    @State private var closed = true
    @State private var insetAmount: CGFloat = 0
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Build `CornerShape` from an array of `Corner` elements easily generated from relative `RectAnchor` positions and it automatically cornforms to `InsettableShape`.")
                    
                    ZStack {
                        TestClosedShape(closed: closed, insetAmount: insetAmount)
                            .fill(Color.suCyan)
                        
                        TestClosedShape(closed: closed, insetAmount: insetAmount)
                            .stroke(Color.suPink, lineWidth: 12)
                    }
                    .frame(width: 200, height: 150)
                    .border(.suBlack)
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    Text(TestClosedShape.code)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.vertical, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
                } header: {
                    Text("Shape Style")
                        .font(.headline)
                }
            }
        }
        .padding()
        .navigationTitle("CornerShape")
    }
}

struct CornerShapeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CornerShapeExample()
        }
    }
}

