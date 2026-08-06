//
//  Array+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-06.
//

import Foundation

extension Array {
    /// Updates existing elements in place using values at matching indices.
    ///
    /// Extra new values are ignored, and existing elements without a matching new value are preserved.
    mutating func update<T>(with newValues: [T], using updateElement: (_ element: inout Element, _ newValue: T) -> Void) {
        let updateCount = Swift.min(count, newValues.count)

        for index in 0..<updateCount {
            updateElement(&self[index], newValues[index])
        }
    }
}
