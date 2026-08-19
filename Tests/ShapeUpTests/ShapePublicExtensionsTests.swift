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

    @available(
        *,
        deprecated,
        message: "Exercises compatibility behavior until scaleToFit is removed."
    )
    @Test(
        "scaleToFit preserves the requested aspect ratio inside its frame",
        arguments: [
            ScaleToFitSample(
                name: "tall shape inside a tall frame",
                frame: CGRect(x: 0, y: 0, width: 100, height: 200),
                aspectRatio: 0.5,
                expectedBounds: CGRect(x: 0, y: 0, width: 100, height: 200)
            ),
            ScaleToFitSample(
                name: "square shape inside a tall frame",
                frame: CGRect(x: 0, y: 0, width: 100, height: 200),
                aspectRatio: 1,
                expectedBounds: CGRect(x: 0, y: 50, width: 100, height: 100)
            ),
            ScaleToFitSample(
                name: "wide shape inside a tall frame",
                frame: CGRect(x: 0, y: 0, width: 100, height: 200),
                aspectRatio: 2,
                expectedBounds: CGRect(x: 0, y: 75, width: 100, height: 50)
            ),
            ScaleToFitSample(
                name: "tall shape inside a square frame",
                frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                aspectRatio: 0.5,
                expectedBounds: CGRect(x: 25, y: 0, width: 50, height: 100)
            ),
            ScaleToFitSample(
                name: "square shape inside a square frame",
                frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                aspectRatio: 1,
                expectedBounds: CGRect(x: 0, y: 0, width: 100, height: 100)
            ),
            ScaleToFitSample(
                name: "wide shape inside a square frame",
                frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                aspectRatio: 2,
                expectedBounds: CGRect(x: 0, y: 25, width: 100, height: 50)
            ),
            ScaleToFitSample(
                name: "tall shape inside a wide frame",
                frame: CGRect(x: 0, y: 0, width: 200, height: 100),
                aspectRatio: 0.5,
                expectedBounds: CGRect(x: 75, y: 0, width: 50, height: 100)
            ),
            ScaleToFitSample(
                name: "square shape inside a wide frame",
                frame: CGRect(x: 0, y: 0, width: 200, height: 100),
                aspectRatio: 1,
                expectedBounds: CGRect(x: 50, y: 0, width: 100, height: 100)
            ),
            ScaleToFitSample(
                name: "wide shape inside a wide frame",
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
