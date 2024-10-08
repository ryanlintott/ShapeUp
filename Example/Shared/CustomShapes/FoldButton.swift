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
                .applyingStyle(.rounded(radius: .relative(0.5)))
                .applyingStyle(.point, shapeCorners: [.topRight])
                .fill(.purple)
                .frame(width: 300)
            
            CornerCustom { rect in
                rect
                    .points(relativeLocations: [
                        (0,0),
                        (1,0),
                        (1,-0.5),
                        (1,1),
                        (0,1)
                    ])
                    .corners([
                        .rounded(radius: .absolute(rect.height * 0.5)),
                        .rounded(radius: .relative(1)),
                        .point,
                        .rounded(radius: .absolute(rect.height * 0.5)),
                        .rounded(radius: .absolute(rect.height * 0.5))
                    ])
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
