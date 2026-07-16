//
//  CornerStyleApplicationTests.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-07-16.
//

import ShapeUp
import SwiftUI
import Testing

struct CornerStyleApplicationTests {
    private let defaultStyle = CornerStyle.rounded(radius: 10)

    @Test("CornerStylable derives standard modifiers from its transformation requirement")
    func cornerStylableDerivesStandardModifiers() {
        let stylable = TestCornerStylable(styles: [.automatic, .point, .rounded(radius: 5)])

        #expect(stylable.cornerStyle(.concave(radius: 8)).styles == [
            .concave(radius: 8),
            .concave(radius: 8),
            .concave(radius: 8)
        ])
        #expect(stylable.defaultCornerStyle(defaultStyle).styles == [
            defaultStyle,
            .point,
            .rounded(radius: 5)
        ])
        #expect(stylable.changingRadius(to: 12).styles == [
            .automatic,
            .point,
            .rounded(radius: 12)
        ])
    }

    @Test("Arbitrary transformations apply to every direct style")
    func arbitraryTransformationsApplyToEveryDirectStyle() {
        let stylable = TestCornerStylable(styles: [.automatic, .point, .rounded(radius: 5)])
            .transformCornerStyles { style in
                style == .point ? .concave(radius: 3) : style
            }

        #expect(stylable.styles == [.automatic, .concave(radius: 3), .rounded(radius: 5)])
    }

    @Test("Corners are automatic by default")
    func cornersAreAutomaticByDefault() {
        #expect(Corner(x: 0, y: 0).style == .automatic)
        #expect(RelativeCorner(x: 0, y: 0).style == .automatic)
        #expect(CGPoint.zero.corner.style == .automatic)
    }

    @Test("Default corner style only replaces automatic styles")
    func defaultCornerStyleOnlyReplacesAutomaticStyles() {
        let corners = [
            Corner(x: 0, y: 0),
            Corner(.point, x: 1, y: 0),
            Corner(.concave(radius: 5), x: 1, y: 1)
        ]

        let styledCorners = corners.defaultCornerStyle(defaultStyle)

        #expect(styledCorners.map(\.style) == [defaultStyle, .point, .concave(radius: 5)])
    }

    @Test("Corner style continues to replace explicit styles")
    func cornerStyleReplacesExplicitStyles() {
        let corner = Corner(.point, x: 0, y: 0)

        #expect(corner.cornerStyle(defaultStyle).style == defaultStyle)
    }

    @Test("Indexed corner style only replaces the selected corner")
    func indexedCornerStyleOnlyReplacesSelectedCorner() {
        let corners = [
            Corner(x: 0, y: 0),
            Corner(x: 1, y: 0),
            Corner(x: 1, y: 1)
        ]

        let styledCorners = corners.cornerStyle(defaultStyle, corner: 1)

        #expect(styledCorners.map(\.style) == [.automatic, defaultStyle, .automatic])
    }

    @Test("Enumerated shapes preserve explicit styles when applying a default")
    func enumeratedShapesPreserveExplicitStyles() {
        let shape = CornerRectangle([.topRight: .point])
            .defaultCornerStyle(defaultStyle)

        #expect(shape.styles[.topLeft] == defaultStyle)
        #expect(shape.styles[.topRight] == .point)
        #expect(shape.styles[.bottomRight] == defaultStyle)
        #expect(shape.styles[.bottomLeft] == defaultStyle)
    }

    @Test("Enumerated transformations materialize automatic styles")
    func enumeratedTransformationsMaterializeAutomaticStyles() {
        let shape = CornerRectangle()
            .transformCornerStyles { $0 }

        #expect(shape.styles == [
            .topLeft: .automatic,
            .topRight: .automatic,
            .bottomRight: .automatic,
            .bottomLeft: .automatic
        ])
    }

    @Test("Notches apply defaults to missing styles and preserve explicit styles")
    func notchesApplyDefaultsToMissingStyles() {
        let notch = Notch(.triangle(cornerStyles: [nil, .point]), depth: 10)
            .defaultCornerStyle(defaultStyle)

        #expect(notch.style.cornerStyles == [defaultStyle, .point, defaultStyle])
    }

    @Test("Notch transformations resolve missing styles and normalize corner counts")
    func notchTransformationsResolveMissingStyles() {
        let style = NotchStyle.triangle(cornerStyles: [nil, .rounded(radius: 5), nil, .point])
            .changingRadius(to: 12)

        if case let .triangle(cornerStyles) = style {
            #expect(cornerStyles == [.automatic, .rounded(radius: 12), .automatic])
        } else {
            Issue.record("Expected a triangle notch style.")
        }
    }

    @Test("Setting corner styles resets unspecified corners to automatic")
    func settingCornerStylesResetsUnspecifiedCorners() {
        var corners = [
            Corner(.rounded(radius: 2), x: 0, y: 0),
            Corner(.concave(radius: 3), x: 1, y: 0),
            Corner(.point, x: 1, y: 1)
        ]

        corners.cornerStyles = [.rounded(radius: 10)]

        #expect(corners.map(\.style) == [
            .rounded(radius: 10),
            .automatic,
            .automatic
        ])
    }

    @Test("Custom shapes apply stored corner style transformations")
    func customShapesApplyStoredTransformations() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let cornerCustom = CornerCustom { rect in
            Corner(x: rect.minX, y: rect.minY)
            Corner(.point, x: rect.maxX, y: rect.maxY)
        }
        .defaultCornerStyle(defaultStyle)

        let relativeCornerCustom = RelativeCornerCustom(
            RelativeCorner.topLeft,
            RelativeCorner.topRight.cornerStyle(.point)
        )
        .defaultCornerStyle(defaultStyle)

        #expect(cornerCustom.corners(in: rect).map(\.style) == [defaultStyle, .point])
        #expect(relativeCornerCustom.relativeCorners.map(\.style) == [defaultStyle, .point])
    }

    @Test("Radius transformations do not recurse into nested styles")
    func radiusTransformationsDoNotRecurseIntoNestedStyles() {
        let nestedStyle = CornerStyle.straight(
            radius: 5,
            cornerStyles: [.rounded(radius: 2)]
        )
        let corner = Corner(nestedStyle, x: 0, y: 0)
            .changingRadius(to: 10)

        #expect(corner.style == .straight(
            radius: 10,
            cornerStyles: [.rounded(radius: 2)]
        ))
    }

    @Test("Automatic corners render the same path as point corners")
    func automaticCornersRenderAsPoints() {
        let points = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 100, y: 0),
            CGPoint(x: 100, y: 100),
            CGPoint(x: 0, y: 100)
        ]

        #expect(points.corners(.automatic).path() == points.corners(.point).path())
    }
}

private struct TestCornerStylable: CornerStylable {
    var styles: [CornerStyle]

    func transformCornerStyles(
        _ transform: @escaping @Sendable (CornerStyle) -> CornerStyle
    ) -> Self {
        var copy = self
        copy.styles = styles.map(transform)
        return copy
    }
}
