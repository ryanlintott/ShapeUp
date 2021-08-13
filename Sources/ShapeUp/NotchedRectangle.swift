//
//  NotchedRectangle.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

extension View {
    func notchEdges(top: Notch? = nil, bottom: Notch? = nil, left: Notch? = nil, right: Notch? = nil) -> some View {
        clipShape(NotchedRectangle(top: top, bottom: bottom, left: left, right: right))
    }
    
    #if canImport(UIKit)
    func notchEdges(_ notch: Notch, edges: [UIRectEdge]) -> some View {
        clipShape(NotchedRectangle(notch, edges: edges))
    }
    #endif
}

@available (iOS 13, *)
struct NotchedRectangle: InsettableShape {
    typealias InsetShape = Self
    var insetAmount: CGFloat = 0
    
    let top: Notch?
    let bottom: Notch?
    let left: Notch?
    let right: Notch?
    let cornerStyles: [CornerStyle?]
    
    init(top: Notch? = nil, bottom: Notch? = nil, left: Notch? = nil, right: Notch? = nil, cornerStyles: [CornerStyle?] = []) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
        self.cornerStyles = cornerStyles
    }
    
    #if canImport(UIKit)
    init(_ notch: Notch, edges: [UIRectEdge], cornerStyles: [CornerStyle?] = []) {
        self.top = edges.contains(.top) ? notch : nil
        self.bottom = edges.contains(.bottom) ? notch : nil
        self.left = edges.contains(.left) ? notch : nil
        self.right = edges.contains(.right) ? notch : nil
        self.cornerStyles = cornerStyles
    }
    #endif
    
    func path(in rect: CGRect) -> Path {
        let path = rect
            .corners(cornerStyles)
            .addingNotches([top, right, bottom, left])
            .inset(by: insetAmount)
            .path()
        
        return path
    }
    
    func inset(by amount: CGFloat) -> InsetShape {
        var insetShape = self
        insetShape.insetAmount += amount
        return insetShape
    }
}

struct NotchedRectangle_Previews: PreviewProvider {
    static var previews: some View {
        NotchedRectangle(
            top: .rectangle(depth: .absolute(50), cornerStyle: .rounded(radius: .absolute(10))),
            bottom: .triangle(position: .relative(0.6), length: .relative(0.4), depth: .relative(0.1)),
            left: .custom(depth: .absolute(60), corners: { rect in
                let corners: [Corner] = [
                    Corner(x: rect.midX, y: rect.minY),
                    Corner(x: rect.minX, y: rect.maxY),
                    Corner(.rounded(radius: .absolute(15)), x: rect.midX, y: rect.maxY),
                    Corner(x: rect.maxX, y: rect.minY)
                ]
                return corners
            }),
            cornerStyles: [
                .rounded(radius: .absolute(20)),
                .cutout(radius: .absolute(30)),
                .straight(radius: .absolute(70)),
                .rounded(radius: .absolute(20))
            ]
        )
        .strokeBorder(style: StrokeStyle(lineWidth: 20))
//            .fill(Color.blue)
            .frame(width: 300, height: 300)
    }
}
