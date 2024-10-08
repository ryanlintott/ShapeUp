//
//  BasicCompareExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-10.
//

import ShapeUp
import SwiftUI

struct SwiftUIBasicShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.25))
        
        let cutLengthSquared: Double = sqrt(pow(rect.width * 0.25, 2) + pow(rect.height * 0.25, 2))
        let radius = (rect.width / rect.height) * cutLengthSquared

        path.addArc(
            tangent1End: CGPoint(x: rect.midX, y: rect.minY),
            tangent2End: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.minY + rect.height * 0.25),
            radius: radius
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ShapeUpBasicShape: CornerShape {
    let closed: Bool = true
    var insetAmount: CGFloat = 0
    
    func corners(in rect: CGRect) -> [Corner] {
        [
            Corner(x: rect.minX, y: rect.midY),
            Corner(.rounded(radius: .relative(0.5)), x: rect.midX, y: rect.minY),
            Corner(x: rect.maxX, y: rect.midY),
            Corner(x: rect.midX, y: rect.maxY)
        ]
    }
}

struct BasicCompareExample: View {
    var body: some View {
        VStack {
            SwiftUIBasicShape()
                .fill(Color.suPurple)
            
            Text("SwiftUI Shape - 30 lines of code\n(Not insettable)")
            
            ShapeUpBasicShape()
                .fill(Color.suPink)
            
            Text("ShapeUp CornerShape - 12 lines of code\n(Insettable)")
            
            CornerCustom { $0.points(.top, .right, .bottom, .left).corners([.rounded(radius: .relative(0.5))]) }
                .fill(Color.suCyan)
            
            Text("ShapeUp CornerCustom - 1 line of code\n(Insettable)")
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct BasicCompareExample_Previews: PreviewProvider {
    static var previews: some View {
        BasicCompareExample()
    }
}
