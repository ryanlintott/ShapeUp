//
//  MessageBubble4Example.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct MessageBubble4: View {
    let cornerRadius: RelatableValue
    let pointSize: RelatableValue
    let pointRadius: RelatableValue
    let insetAmount: CGFloat
    
    var body: some View {
        CornerCustom { rect in
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
        .inset(by: insetAmount)
    }
}
