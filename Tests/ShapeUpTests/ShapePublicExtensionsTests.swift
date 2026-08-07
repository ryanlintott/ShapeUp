//
//  ShapePublicExtensionsTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-07.
//

import ShapeUp
import SwiftUI
import Testing

struct ShapePublicExtensionsTests {
    struct ScaleToFitSample: CustomTestStringConvertible, Sendable {
        let name: String
        let frame: CGRect
        let aspectRatio: CGFloat
        let expectedBounds: CGRect

        var testDescription: String { name }
    }

    @Test(
        "scaleToFit preserves the requested aspect ratio inside its frame",
        arguments: [
            ScaleToFitSample(
                name: "square inside a wide frame",
                frame: CGRect(x: 0, y: 0, width: 200, height: 100),
                aspectRatio: 1,
                expectedBounds: CGRect(x: 50, y: 0, width: 100, height: 100)
            ),
            ScaleToFitSample(
                name: "square inside a tall frame",
                frame: CGRect(x: 0, y: 0, width: 100, height: 200),
                aspectRatio: 1,
                expectedBounds: CGRect(x: 0, y: 50, width: 100, height: 100)
            ),
            ScaleToFitSample(
                name: "matching aspect ratio",
                frame: CGRect(x: 0, y: 0, width: 200, height: 100),
                aspectRatio: 2,
                expectedBounds: CGRect(x: 0, y: 0, width: 200, height: 100)
            )
        ]
    )
    func scaleToFit(sample: ScaleToFitSample) {
        let bounds = Rectangle()
            .scaleToFit(sample.frame.size, aspectRatio: sample.aspectRatio)
            .path(in: sample.frame)
            .boundingRect

        #expect(bounds == sample.expectedBounds)
    }
}
