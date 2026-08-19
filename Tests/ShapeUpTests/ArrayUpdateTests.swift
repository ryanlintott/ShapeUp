//
//  ArrayUpdateTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-06.
//

@testable import ShapeUp
import Testing

struct ArrayUpdateTests {
    private struct Sample: Sendable {
        let values: [Int]
        let newValues: [Int]
        let expected: [Int]
    }

    @Test(arguments: [
        Sample(values: [], newValues: [10], expected: []),
        Sample(values: [1, 2, 3], newValues: [], expected: [1, 2, 3]),
        Sample(values: [1, 2, 3], newValues: [10, 20, 30], expected: [10, 20, 30]),
        Sample(values: [1, 2, 3], newValues: [10, 20], expected: [10, 20, 3]),
        Sample(values: [1, 2], newValues: [10, 20, 30], expected: [10, 20]),
    ])
    private func updatesValuesAtMatchingIndices(_ sample: Sample) {
        var values = sample.values

        values.update(with: sample.newValues) { value, newValue in
            value = newValue
        }

        #expect(values == sample.expected)
    }
}
