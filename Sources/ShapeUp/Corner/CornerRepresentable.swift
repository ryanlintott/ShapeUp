//
//  CornerRepresentable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-14.
//

import SwiftUI

public protocol CornerRepresentable {
    /// A corner representation of this object.
    var corner: Corner { get }
}

extension CornerRepresentable {
    /// Returns a corner at the same position with the applied style if not nil.
    ///
    /// If nil style is provided and the type is already a corner, the existing style will remain.
    /// - Note: As an alternative you can use method chaining to add a style `.corner.rounded(20)`
    /// - Parameter style: Corner style to use. Default is nil which renders as ``CornerStyle.point``.
    /// - Returns: Corner with the provided style and the same position as the point.
    func corner(_ style: CornerStyle? = nil) -> Corner {
        guard let style else { return corner }
        return corner.applyingStyle(style)
    }
}
