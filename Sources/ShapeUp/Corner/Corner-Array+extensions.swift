//
//  Corner-Array+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension Array where Element == Corner {
    var cornerStyles: [CornerStyle] {
        self.map({ $0.style })
    }
    
    var isFlattenable: Bool {
        self.contains(where: { $0.style.isFlattenable })
    }
    
    var flattened: [Corner] {
        var corners: [Corner]
        var newCorners = self
        while newCorners.isFlattenable {
            corners = newCorners
            newCorners = []
            for (i, corner) in corners.enumerated() {
                let previousCorner = i == 0 ? corners.last! : corners[i - 1]
                let nextCorner = i == corners.count - 1 ? corners.first! : corners[i + 1]
                newCorners += corner.flattened(previousCorner: previousCorner, nextCorner: nextCorner)
            }
        }
        
        return newCorners
    }
    
    func rotated(_ angle: Angle, anchor: CGPoint = .zero) -> [Corner] {
        self.map({ $0.rotated(angle, anchor: anchor) })
    }
    
    func mirrored(mirrorLineStart: CGPoint, mirrorLineEnd: CGPoint) -> [Corner] {
        self.map({ $0.mirrored(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) })
    }
    
    var bounds: CGRect {
        vectors.bounds
    }
    
    var center: CGPoint {
        vectors.center.point
    }
    
    func flipHorizontal(around x: CGFloat? = nil) -> [Corner] {
        let mirrorX = x ?? center.x
        return mirrored(mirrorLineStart: CGPoint(x: mirrorX, y: 0), mirrorLineEnd: CGPoint(x: mirrorX, y: 1))
    }
    
    func flipVertical(around y: CGFloat? = nil) -> [Corner] {
        let mirrorY = y ?? center.y
        return mirrored(mirrorLineStart: CGPoint(x: 0, y: mirrorY), mirrorLineEnd: CGPoint(x: 1, y: mirrorY))
    }
    // Works for shapes drawn clockwise without a duplicate point at the end
    func inset(by insetAmount: CGFloat) -> [Corner] {
        guard self.count >= 3 || insetAmount != 0 else {
            return self
        }
        
        let corners = self.flattened
        var insetCorners = [Corner]()
        for (i, corner) in corners.enumerated() {
            let previousCorner = i == 0 ? corners.last! : corners[i - 1]
            let nextCorner = i == corners.count - 1 ? corners.first! : corners[i + 1]
            insetCorners.append(corner.inset(insetAmount, previousCorner: previousCorner, nextCorner: nextCorner))
        }
        
        return insetCorners
    }
    
    func path() -> Path {
        var path = Path()
        path.addCornerShape(self)
        return path
    }
    
    mutating func applyStyles(_ styles: [CornerStyle?]) {
        self = self.applyingStyles(styles)
    }
    // nil values will keep old style
    func applyingStyles(_ styles: [CornerStyle?]) -> [Corner] {
        guard !styles.isEmpty else {
            return self
        }
        
        let styles = styles + Array<CornerStyle?>(repeating: nil, count: Swift.max(0, self.count - styles.count))
        
        var newCorners = [Corner]()
        for (i, corner) in self.enumerated() {
            newCorners.append(corner.applyingStyle(styles[i] ?? corner.style))
        }
        return newCorners
    }
    
    mutating func applyStyle(_ style: CornerStyle) {
        self = self.applyingStyle(style)
    }
    
    func applyingStyle(_ style: CornerStyle) -> [Corner] {
        self.map({$0.applyingStyle(style)})
    }
    
    mutating func addNotches(_ notches: [Notch?]) {
        self = self.addingNotches(notches)
    }
    
    func addingNotches(_ notches: [Notch?]) -> [Corner] {
        guard self.count >= 2 else {
            return self
        }
        
        // Pad notches with nil values to match point count
        let notches = notches + Array<Notch?>(repeating: nil, count: Swift.max(self.count - notches.count, 0))
        var newCorners = [Corner]()
        for (i, corner) in self.enumerated() {
            let nextCorner = i == self.count - 1 ? self.first! : self[i + 1]
            newCorners.append(corner)
            if let notch = notches[i] {
                newCorners += notch.between(start: corner, end: nextCorner)
            }
        }
        return newCorners
    }
    
    mutating func addNotch(_ notch: Notch, afterCornerIndex cornerIndex: Int) {
        self = self.addingNotch(notch, afterCornerIndex: cornerIndex)
    }
    
    func addingNotch(_ notch: Notch, afterCornerIndex cornerIndex: Int) -> [Corner] {
        self.addingNotches(Array<Notch?>(repeating: nil, count: cornerIndex) + [notch])
    }
    
    func addingSegment(notch: Notch? = nil, to corner: Corner) -> [Corner] {
        guard let lastCorner = self.last else {
            return self
        }
        
        return self + (notch?.between(start: lastCorner, end: corner) ?? []) + [corner]
    }
}
