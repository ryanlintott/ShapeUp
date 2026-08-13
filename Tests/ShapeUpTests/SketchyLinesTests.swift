//
//  SketchyLinesTests.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-12.
//

import ShapeUp
import SwiftUI
import Testing

struct SketchyLinesTests {
    private let rect = CGRect(x: 0, y: 0, width: 100, height: 100)

    @Test
    func nilSharedDrawAmountPreservesLineDrawAmount() {
        let lines = SketchyLines(lines: [horizontalLine(drawAmount: 0.25)])

        #expect(lines.drawAmount == nil)
        #expect(lines.path(in: rect).boundingRect.width == 25)
    }

    @Test
    func sharedDrawAmountOverridesEveryLineWithoutMutatingLines() {
        let lines = SketchyLines(
            lines: [
                horizontalLine(drawAmount: 0.25),
                SketchyLine(edge: .leading, drawAmount: 0.5)
            ],
            drawAmount: 0.75
        )

        #expect(lines.path(in: rect).boundingRect == CGRect(x: 0, y: 0, width: 75, height: 75))
        #expect(lines.lines.map(\.drawAmount) == [0.25, 0.5])
    }

    @Test
    func animatableDataUpdatesSharedAndLineDrawAmounts() throws {
        var lines = SketchyLines(
            lines: [horizontalLine(drawAmount: 0.6)],
            drawAmount: 0.8
        )

        lines.animatableData.scale(by: 0.5)
        let line = try #require(lines.lines.first)

        #expect(lines.drawAmount == 0.4)
        #expect(line.drawAmount == 0.3)
    }

    @Test
    func nilSharedDrawAmountRemainsNilWhileLineDrawAmountsAnimate() throws {
        var lines = SketchyLines(lines: [horizontalLine(drawAmount: 0.6)])

        lines.animatableData.scale(by: 0.5)
        let line = try #require(lines.lines.first)

        #expect(lines.drawAmount == nil)
        #expect(line.drawAmount == 0.3)
    }

    @Test
    func changingDrawDirectionImmediatelyUsesTargetProperties() {
        let source = SketchyLine(
            edge: .top,
            startExtension: 2,
            endExtension: 4,
            offset: 6,
            drawAmount: 0.25,
            drawDirection: .toBottomTrailing
        )
        let target = SketchyLine(
            edge: .top,
            startExtension: 10,
            endExtension: 12,
            offset: 14,
            drawAmount: 0.75,
            drawDirection: .toTopLeading
        )

        var data = source.animatableData
        data.interpolate(towards: target.animatableData, amount: 0.5)
        var result = target
        result.animatableData = data

        #expect(result.startExtension == target.startExtension)
        #expect(result.endExtension == target.endExtension)
        #expect(result.offset == target.offset)
        #expect(result.drawAmount == target.drawAmount)
    }

    private func horizontalLine(drawAmount: CGFloat) -> SketchyLine {
        SketchyLine(edge: .top, drawAmount: drawAmount)
    }
}
