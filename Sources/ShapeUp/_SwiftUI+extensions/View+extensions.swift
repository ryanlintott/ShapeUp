//
//  View+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-17.
//

import SwiftUI

public extension View {
    func cutCorners(topLeft: CornerStyle? = nil, topRight: CornerStyle? = nil, bottomLeft: CornerStyle? = nil, bottomRight: CornerStyle? = nil) -> some View {
        clipShape(
            CSCustom { rect in
                rect.corners([bottomLeft, topLeft, topRight, bottomRight])
            }
        )
    }
    
    func notchEdges(top: Notch? = nil, bottom: Notch? = nil, left: Notch? = nil, right: Notch? = nil) -> some View {
        clipShape(CSNotchedRectangle(top: top, bottom: bottom, left: left, right: right))
    }

    func cutCorners(_ style: CornerStyle, corners: Set<RectCorner>) -> some View {
        clipShape(
            CSCustom { rect in
                rect.corners(style)
            }
        )
    }

    func notchEdges(_ notch: Notch, edges: Set<RectEdge>) -> some View {
        clipShape(CSNotchedRectangle(notch, edges: edges))
    }
}
