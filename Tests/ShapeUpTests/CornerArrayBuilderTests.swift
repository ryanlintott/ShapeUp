//
//  CornerArrayBuilderTests.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-07-16.
//

import ShapeUp
import SwiftUI
import Testing

struct CornerArrayBuilderTests {
    private let first = Corner(x: 0, y: 0)
    private let second = Corner(x: 100, y: 0)
    private let third = Corner(x: 100, y: 100)
    private let notch = Notch(.triangle, length: 20, depth: 10)

    @Test("A notch is expanded between its surrounding corners", arguments: [true, false])
    func conditionalInteriorNotch(isIncluded: Bool) {
        let corners = Corners {
            first
            if isIncluded {
                notch
            }
            second
            third
        }
        let expected = [first]
            + (isIncluded ? notch.between(start: first, end: second) : [])
            + [second, third]

        #expect(corners == expected)
    }

    @Test("A leading notch uses the last-to-first edge")
    func leadingNotch() {
        let corners = Corners {
            notch
            first
            second
            third
        }
        let expected = notch.between(start: third, end: first) + [first, second, third]

        #expect(corners == expected)
    }

    @Test("A trailing notch uses the last-to-first edge")
    func trailingNotch() {
        let corners = Corners {
            first
            second
            third
            notch
        }
        let expected = [first, second, third] + notch.between(start: third, end: first)

        #expect(corners == expected)
    }

    @Test("Consecutive notches share surrounding corners and retain source order")
    func consecutiveNotches() {
        let secondNotch = Notch(.rectangle, position: .relative(0.75), length: 10, depth: 5)
        let corners = Corners {
            first
            notch
            secondNotch
            second
        }
        let expected = [first]
            + notch.between(start: first, end: second)
            + secondNotch.between(start: first, end: second)
            + [second]

        #expect(corners == expected)
    }

    @Test("Existing corner and point expressions retain their order")
    func mixedCornerAndPointExpressions() {
        let point = CGPoint(x: 20, y: 30)
        let cornerArray = [Corner(x: 40, y: 50), Corner(x: 60, y: 70)]
        let pointArray = [CGPoint(x: 80, y: 90), CGPoint(x: 100, y: 110)]
        let corners = Corners {
            first
            point
            cornerArray
            pointArray
        }

        #expect(corners == [first, point.corner] + cornerArray + pointArray.corners)
    }

    @Test("Notches are omitted when fewer than two corners are available")
    func insufficientCorners() {
        let noCorners = Corners {
            notch
        }
        let oneCorner = Corners {
            notch
            first
            notch
        }

        #expect(noCorners == [])
        #expect(oneCorner == [first])
    }
}
