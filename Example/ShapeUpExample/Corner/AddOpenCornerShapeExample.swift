//
//  AddOpenCornerShapeExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-02-11.
//

import ShapeUp
import SwiftUI

struct OpenCornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: rect[0.25, 1])
        path.addQuadCurve(
            to: rect[.left],
            control: rect[.center]
        )
        
        path.addOpenCornerShape(nextPoint: rect[.center]) {
            rect[.topLeft].straight(radius: .relative(0.2))
            
            rect[.center].cutout(radius: .relative(0.2), cornerStyles: [
                .rounded(radius: .relative(0.4)),
                .point,
                .straight(radius: .relative(0.4))
            ])
            
            rect[.topRight].cutout(radius: .relative(0.2), cornerStyles: [
                .rounded(radius: .relative(0.2))
            ])
            
            rect[.right].rounded(radius: 20)
        }
        
        path.addQuadCurve(
            to: rect[0.75, 1],
            control: rect[.center]
        )

        return path
    }
}

struct AddOpenCornerShapeExample: View {
    var code: String {
"""
var path = Path()
path.move(to: rect[0.25, 1])
path.addQuadCurve(
    to: rect[.left],
    control: rect[.center]
)

// nextPoint is required to draw the style of the last corner correctly.
path.addOpenCornerShape(nextPoint: rect[.center]) {
                        // Add corners here
    rect[.topLeft]
        .straight(radius: .relative(0.2))
    
    rect[.center]
        .cutout(
            radius: .relative(0.2),
            cornerStyles: [
                .rounded(radius: .relative(0.4)),
                .point,
                .straight(radius: .relative(0.4))
            ]
        )
    
    rect[.topRight]
        .cutout(
            radius: .relative(0.2),
            cornerStyles: [
                .rounded(radius: .relative(0.2))
            ]
        )
    
    rect[.right]
        .rounded(radius: 20)
}
"""
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Corners can also be added to any `Path`")
                    
                    OpenCornerShape()
                        .stroke(Color.suPink, lineWidth: 10)
                        .frame(width: 200, height: 200)
                        .padding()
                        .frame(maxWidth: .infinity)
                    
                    Text(code)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.vertical, 6)
                }
            }
        }
        .padding()
        .navigationTitle("AddOpenCornerShape")
    }
}

struct AddOpenCornerShapeExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddOpenCornerShapeExample()
        }
    }
}
