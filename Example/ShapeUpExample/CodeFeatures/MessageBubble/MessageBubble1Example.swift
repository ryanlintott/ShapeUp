//
//  MessageBubble1Example.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct MessageBubble1: CornerShape {
    var closed: Bool = true
    var insetAmount: CGFloat = 0
    
    let cornerRadius: RelatableValue
    let pointSize: CGFloat
    let pointRadius: RelatableValue
    
    func corners(in rect: CGRect) -> [Corner] {
        [
            Corner(.rounded(cornerRadius), x: rect.minX, y: rect.minY),
            Corner(.rounded(cornerRadius), x: rect.maxX, y: rect.minY),
            Corner(.rounded(cornerRadius), x: rect.maxX, y: rect.maxY),
            Corner(.rounded(pointRadius), x: rect.midX + (pointSize / 2), y: rect.maxY),
            Corner(.point, x: rect.midX, y: rect.maxY + pointSize),
            Corner(.rounded(pointRadius), x: rect.midX - (pointSize / 2), y: rect.maxY),
            Corner(.rounded(cornerRadius), x: rect.minX, y: rect.maxY)
        ]
    }
}

struct MessageBubble1Example: View {
    var body: some View {
        MessageBubble1(cornerRadius: 20, pointSize: 20, pointRadius: 10)
            .fill(Color.suPurple)
            .frame(width: 200, height: 120)
    }
}

struct MessageBubble1Example_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble1Example()
    }
}
