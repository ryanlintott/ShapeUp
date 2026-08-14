//
//  CornerStyleCodableTests.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-08-13.
//

import Foundation
import ShapeUp
import Testing

struct CornerStyleCodableTests {
    static let styles: [CornerStyle] = [
        .automatic,
        .point,
        .rounded(radius: 20),
        .rounded(radius: .relative(0.5), style: .continuous),
        .concave(radius: 20, concaveInset: 3),
        .straight(radius: 20, cornerStyles: [.rounded(radius: 4)]),
        .cutout(radius: 20, cornerStyles: [.point]),
        .custom(radius: 20, relativeCorners: [.topLeft])
    ]

    @Test("Corner styles retain their values when encoded", arguments: styles)
    func roundTrip(style: CornerStyle) throws {
        let data = try JSONEncoder().encode(style)
        let decoded = try JSONDecoder().decode(CornerStyle.self, from: data)

        #expect(decoded == style)
    }
}
