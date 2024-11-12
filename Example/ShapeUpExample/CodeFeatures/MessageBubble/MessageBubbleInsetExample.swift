//
//  MessageBubble5Example.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-24.
//

import ShapeUp
import SwiftUI

struct MessageBubbleInsetExample: View {
    var messageBubble: CornerCustom {
        CornerCustom { rect in
            rect.corners(.rounded(20))
                .addingNotch(
                    .triangle(depth: -20, cornerStyles: [
                        .rounded(10),
                        .point,
                        .rounded(10)
                    ]),
                    afterCornerIndex: 2
                )
        }
    }
    
    let colors: [Color] = [.suCyan, .suPink, .suWhite, .suYellow]
    
    var body: some View {
        ZStack {
            messageBubble
                .inset(by: -15)
                .fill(Color.suPurple)
            
            ForEach(Array(zip(colors.indices, colors)), id: \.0) { (i, color) in
                messageBubble
                    .inset(by: CGFloat((i * 5) - 10))
                    .stroke(color, lineWidth: 3)
            }
        }
        .frame(width: 200, height: 120)
    }
}

struct MessageBubbleInsetExample_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubbleInsetExample()
    }
}
