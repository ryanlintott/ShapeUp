//
//  MessageBubble2Example.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct MessageBubble2: CornerShape {
    let closed: Bool = true
    var insetAmount: CGFloat = 0
    
    let cornerRadius: RelatableValue
    let pointSize: CGFloat
    let pointRadius: RelatableValue
    
    func corners(in rect: CGRect) -> [Corner] {
        let rightSide = [
            Corner(.rounded(radius: cornerRadius), x: rect.maxX, y: rect.minY),
            Corner(.rounded(radius: cornerRadius), x: rect.maxX, y: rect.maxY),
            Corner(.rounded(radius: pointRadius), x: rect.midX + (pointSize / 2), y: rect.maxY)
        ]
        
        return rightSide
            + [Corner(x: rect.midX, y: rect.maxY + pointSize)]
            + rightSide.flippedHorizontally(across: rect.midX).reversed()
    }
}

struct MessageBubble2Example: View {
    var body: some View {
        MessageBubble1(cornerRadius: 20, pointSize: 20, pointRadius: 10)
            .fill(Color.suPurple)
            .frame(width: 200, height: 120)
    }
}

struct MessageBubble2Example_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble2Example()
    }
}

