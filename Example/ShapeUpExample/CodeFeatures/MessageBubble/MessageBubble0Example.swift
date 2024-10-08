//
//  MessageBubble0Example.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct MessageBubble0: Shape {
    let cornerRadius: CGFloat
    let pointSize: CGFloat
    let pointRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.midX, y: rect.maxY), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: rect.midX + (pointSize / 2), y: rect.maxY), tangent2End: CGPoint(x: rect.midX, y: rect.maxY + pointSize), radius: pointRadius)
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY + pointSize))
        path.addArc(tangent1End: CGPoint(x: rect.midX - (pointSize / 2), y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: pointRadius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.midX, y: rect.minY), radius: cornerRadius)
        path.closeSubpath()
        return path
    }
}

struct MessageBubble0Example: View {
    var body: some View {
        MessageBubble0(cornerRadius: 20, pointSize: 20, pointRadius: 10)
            .fill(Color.suPurple)
            .frame(width: 200, height: 120)
    }
}

struct MessageBubble0Example_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble0Example()
    }
}
