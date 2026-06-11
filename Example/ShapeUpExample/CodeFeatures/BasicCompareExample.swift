//
//  BasicCompareExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-10.
//

import ShapeUp
import SwiftUI

struct SwiftUIBasicShape: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.5))
        path.addArc(
            tangent1End: CGPoint(x: rect.midX, y: rect.minY),
            tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
            radius: radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.7),
            radius: radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.7),
            tangent2End: CGPoint(x: rect.minX, y: rect.maxY),
            radius: radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.midX, y: rect.minY),
            radius: radius
        )
        path.closeSubpath()
        return path
    }
}

struct ShapeUpBasicShape: CornerShape {
    let closed: Bool = true
    var insetAmount: CGFloat = 0
    var radius: RelatableValue
    
    func corners(in rect: CGRect) -> [Corner] {
        rect.points(
            .bottomLeft,
            .top,
            .bottomRight,
            .relative(x: 0.5, y: 0.7)
        )
        .corners(.rounded(radius: radius))
    }
}

struct BasicCompareExample: View {
    var radius: CGFloat = 20
    
    var body: some View {
        VStack {
            SwiftUIBasicShape(radius: radius)
                .fill(Color.suPurple)
            
            Text("SwiftUI Shape - 30 lines of code\n(Not insettable)")
            
            ShapeUpBasicShape(radius: .absolute(radius))
                .fill(Color.suPink)
            
            Text("ShapeUp CornerShape - 12 lines of code\n(Insettable with Animation)")
            
            RelativeCornerCustom(.bottomLeft, .top, .bottomRight, .relative(x: 0.5, y: 0.8))
                .applyingStyle(.rounded(radius: .absolute(radius)))
                .fill(Color.suCyan)
            
            Text("ShapeUp RelativeCornerShape - 2 lines of code\n(Insettable & Fully Animatable)")
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
