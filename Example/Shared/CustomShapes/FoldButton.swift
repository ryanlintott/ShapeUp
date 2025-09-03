//
//  FoldButton.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-30.
//

import ShapeUp
import SwiftUI

struct FoldButton: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            CornerRectangle()
                .applyingStyle(.rounded(radius: .relative(0.5)))
                .applyingStyle(.point, to: .topRight)
                .fill(.purple)
                .frame(width: 300)
            
            RelativeCornerCustom {
                [
                    .topLeft.rounded(radius: .relative(0.5)),
                    .topRight.rounded(radius: .relative(1.0)),
                    .relative(x: 1, y: -0.5),
                    .topRight,
                    .bottomRight.rounded(radius: .relative(0.5)),
                    .bottomLeft.rounded(radius: .relative(0.4))
                ]
            }
            .fill(.blue)
            .frame(width: 100)            
        }
        .frame(height: 50)
    }
}

struct ReplyButton_Previews: PreviewProvider {
    static var previews: some View {
        FoldButton()
    }
}
