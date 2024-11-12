//
//  CornerShapeView.swift
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
        [
            Corner(.rounded(.relative(0.3)),x: rect.minX, y: rect.minY),
            Corner(.straight(.relative(0.1)), x: rect.midX, y: rect.midY),
            Corner(.cutout(20),x: rect.maxX, y: rect.minY),
            Corner(.concave(.relative(0.3)),x: rect.maxX, y: rect.maxY),
            Corner(x: rect.midX, y: rect.maxY),
        ]
    }
}

struct TestOpenShape: CornerShape {
    let closed: Bool
    var insetAmount: CGFloat = 0
    
    func corners(in rect: CGRect) -> [Corner] {
        [
            rect[.bottomLeft, .point],
            rect[.left, .rounded(.relative(0.4))],
            rect[.bottom, .concave(.relative(0.3))],
            rect[.top, .straight(.relative(0.3))],
            rect[.right, .cutout(.relative(0.1))],
            rect[.topRight, .point]
        ]
    }
}

struct CornerShapeExample: View {
    @State private var closed = true
    @State private var insetAmount: CGFloat = 0
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Create any array of `Corner` using")
                Text("`corners(in: CGRect) -> [Corner]`").padding(.vertical, 4)
                Text("instead of the `Shape` function")
                Text("`path(in: CGRect) -> Path`").padding(.vertical, 4)
                Text("to make a `CornerShape` that can be open or closed and is insettable automatically!")
            }
            Spacer()
            
            ZStack {
                TestClosedShape(closed: closed, insetAmount: insetAmount)
                    .fill(Color.suCyan)
                
                TestClosedShape(closed: closed, insetAmount: insetAmount)
                    .stroke(Color.suPink, lineWidth: 12)
            }
            .frame(width: 200, height: 150)
            
            Spacer()
            
            ZStack {
                TestOpenShape(closed: closed)
                    .inset(by: insetAmount)
                    .fill(Color.suYellow)
                
                TestOpenShape(closed: closed)
                    .inset(by: insetAmount)
                    .stroke(Color.suPurple, lineWidth: 12)
            }
            .frame(width: 200, height: 150)
            
            Spacer()
            
            Picker("Shape Style", selection: $closed) {
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
