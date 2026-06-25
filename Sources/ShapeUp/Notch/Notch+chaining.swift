//
//  Notch+chaining.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-12.
//

extension Notch {
    /// Applies a style to this notch.
    /// - Parameter newStyle: Style used for notch.
    /// - Returns: A notch with a new style applied.
    func notchStyle(_ newStyle: NotchStyle) -> Notch {
        .init(newStyle, position: position, length: length, depth: depth)
    }
    
//    /// Applies a custom style to this notch.
//    /// - Parameters:
//    ///   - relativeCorners: Relative corners that define the notch shape.
//    /// - Returns: A notch with a custom style.
//    func notchShape(_ relativeCorners: [RelativeCorner]) -> Notch {
//        notchShape(.custom(relativeCorners: relativeCorners))
//    }
//    
//    /// Applies a custom style to this notch.
//    /// - Parameters:
//    ///   - relativeCorners: Relative corners that define the notch shape.
//    /// - Returns: A notch with a custom style.
//    func notchShape(@RelativeCornerArrayBuilder _ relativeCorners: () -> [RelativeCorner]) -> Notch {
//        notchShape(relativeCorners())
//    }
}
