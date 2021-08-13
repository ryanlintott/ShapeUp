//
//  CornerCutRectangle.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

extension View {
    func cutCorners(topLeft: CornerStyle? = nil, topRight: CornerStyle? = nil, bottomLeft: CornerStyle? = nil, bottomRight: CornerStyle? = nil) -> some View {
        clipShape(
            CornerShape { rect in
                rect.corners([bottomLeft, topLeft, topRight, bottomRight])
            }
        )
    }

    #if canImport(UIKit)
    func cutCorners(_ style: CornerStyle, corners: [UIRectCorner]) -> some View {
        clipShape(
            CornerShape { rect in
                rect.corners(style)
            }
        )
    }
    #endif
}

struct CornerCutRectangle: InsettableCornerShape {
    var insetAmount: CGFloat = 0
    
    let topLeft: CornerStyle?
    let topRight: CornerStyle?
    let bottomLeft: CornerStyle?
    let bottomRight: CornerStyle?
    
    init(topLeft: CornerStyle? = nil, topRight: CornerStyle? = nil, bottomLeft: CornerStyle? = nil, bottomRight: CornerStyle? = nil) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    #if canImport(UIKit)
    init(_ style: CornerStyle, corners: [UIRectCorner] = [.allCorners]) {
        let all = corners.contains(.allCorners)
        self.topLeft = all || corners.contains(.topLeft) ? style : nil
        self.topRight = all || corners.contains(.topRight) ? style : nil
        self.bottomLeft = all || corners.contains(.bottomLeft) ? style : nil
        self.bottomRight = all || corners.contains(.bottomRight) ? style : nil
    }
    #endif

    func path(in rect: CGRect) -> Path {
        let path = rect
            .corners([
                topLeft,
                topRight,
                bottomRight,
                bottomLeft
            ])
            .inset(by: insetAmount)
            .path()
        
        return path
    }
}
