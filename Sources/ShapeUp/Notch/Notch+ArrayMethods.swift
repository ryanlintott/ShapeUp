//
//  Notch+ArrayMethods.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension Array where Element == CGPoint {
    mutating func addNotches(_ notches: [Notch?]) {
        self = self.addingNotches(notches)
    }
    
    func addingNotches(_ notches: [Notch?]) -> [CGPoint] {
        guard self.count >= 2 else {
            return self
        }
        // Pad notches with nil values to match point count
        let notches = notches + Array<Notch?>(repeating: nil, count: Swift.max(0, self.count - notches.count))
        var notchedPoints = [CGPoint]()
        for (i, point) in self.enumerated() {
            notchedPoints += [point]
            let nextPoint = i == self.count - 1 ? self.first! : self[i + 1]
            if let notch = notches[i] {
                notchedPoints += notch.between(start: point, end: nextPoint)
            }
        }
        return notchedPoints
    }
}
