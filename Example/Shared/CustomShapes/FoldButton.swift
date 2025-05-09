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
            Rectangle()
                .applyingStyle(.rounded(.relative(0.5)))
                .applyingStyle(.point, shapeCorners: [.topRight])
                .fill(.purple)
                .frame(width: 300)
            
            CornerCustom { rect in
                [
                    rect[.topLeft].corner(.rounded(.absolute(rect.height * 0.5))),
                    rect[.topRight].corner(.rounded(.relative(1))),
                    rect[1, -0.5].corner(.point),
                    rect[.bottomRight].corner(.rounded(.absolute(rect.height * 0.5))),
                    rect[.bottomLeft].corner(.rounded(.absolute(rect.height * 0.5)))
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
