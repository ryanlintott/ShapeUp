//
//  Array+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-06.
//

import Foundation

extension Array {
    /// Updates each element in the array using the item from the same position in the provided array according to the provided transformation.
    func update<T>(with newValues: [T], using transform: @Sendable (_ element: Element, _ newValue: T) -> Element) -> Self {
        if newValues.isEmpty { return self }
        
        /// Create an array of values equal in length to the existing array.
        let newValuesMatchingCount = newValues.map(Optional.init) + Array<T?>(repeating: nil, count: Swift.max(count - newValues.count, 0))
        
        return zip(self, newValuesMatchingCount)
            .map { element, newValue in
                if let newValue {
                    return transform(element, newValue)
                } else {
                    return element
                }
            }
    }
}
