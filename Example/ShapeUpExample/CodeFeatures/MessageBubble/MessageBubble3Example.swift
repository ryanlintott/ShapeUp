//
//  MessageBubble3Example.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct MessageBubble3: CornerShape {
    var closed: Bool = true
    var insetAmount: CGFloat = 0
    
    let cornerRadius: RelatableValue
    let pointSize: RelatableValue
    let pointRadius: RelatableValue

    func corners(in rect: CGRect) -> [Corner] {
        rect
            .corners(.rounded(cornerRadius))
            .addingNotch(
                .triangle(depth: -pointSize, cornerStyles: [
                    .rounded(pointRadius),
                    .point,
                    .rounded(pointRadius)
                ]),
                afterCornerIndex: 2
            )
    }
}

struct MessageBubble3Example: View {
    @State private var cornerRadius: RelatableValue = 20
    
    var body: some View {
        VStack {
            MessageBubble3(cornerRadius: cornerRadius, pointSize: 20, pointRadius: 10)
                .fill(Color.suPurple)
                .frame(width: 200, height: 120)
                .animation(.spring(), value: cornerRadius)
        }
    }
}

struct MessageBubble3Example_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble3Example()
    }
}

