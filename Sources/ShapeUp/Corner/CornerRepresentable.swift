//
//  CornerRepresentable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-11.
//

import SwiftUI

/// A protocol for types that can be represented as a `RelativeCorner`.
///
/// This protocol allows arrays of `RectAnchor` and `RelativeCorner` to be used interchangeably,
/// with `RectAnchor` values defaulting to `.point` corner style.
public protocol RelativeCornerRepresentable {
    /// Converts the conforming type to a `RelativeCorner`.
    /// - Returns: A `RelativeCorner` representation of this type.
    var relativeCorner: RelativeCorner { get }
}

// MARK: - RelativeCorner Conformance

extension RelativeCorner: RelativeCornerRepresentable {
    public var relativeCorner: RelativeCorner { self }
}

// MARK: - RectAnchor Conformance

extension RectAnchor: RelativeCornerRepresentable {
    public var relativeCorner: RelativeCorner { .init(self) }
}

// MARK: - Array Extensions

extension Array where Element: RelativeCornerRepresentable {
    /// Converts an array of `RelativeCornerRepresentable` elements to an array of `RelativeCorner`.
    /// - Returns: An array of `RelativeCorner` with the specified style applied.
    public var relativeCorners: [RelativeCorner] { map (\.relativeCorner) }
}
