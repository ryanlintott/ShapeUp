//
//  Notch+chaining.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-12.
//

public extension Notch {
    /// Applies a style to this notch.
    /// - Parameter newStyle: Style used for notch.
    /// - Returns: A notch with a new style applied.
    func applyingStyle(_ newStyle: NotchStyle) -> Notch {
        .init(newStyle, position: position, length: length, depth: depth)
    }
    
    /// Applies a triangular style to this notch.
    var triangle: Self { triangle() }
    
    /// Applies a triangular style to this notch.
    /// - Parameters:
    ///   - cornerStyle: Corner style used for all corners in the notch. Default is a .point style.
    /// - Returns: A notch with a triangular style.
    func triangle(cornerStyle: CornerStyle? = nil) -> Notch {
        applyingStyle(.triangle(cornerStyle: cornerStyle))
    }
    
    /// Applies a triangular style to this notch.
    /// - Parameters:
    ///   - cornerStyles: Corner styles used for each corner in the notch. Nil values use a .point style.
    /// - Returns: A notch with a triangular style.
    func triangle(cornerStyles: [CornerStyle?]) -> Notch {
        applyingStyle(.triangle(cornerStyles: cornerStyles))
    }
    
    /// Applies a rectangular style to this notch.
    var rectangle: Self { rectangle() }
    
    /// Applies a rectangular style to this notch.
    /// - Parameters:
    ///   - cornerStyle: Corner style used for all corners in the notch. Default is a .point style.
    /// - Returns: A notch with a rectangular style.
    func rectangle(cornerStyle: CornerStyle? = nil) -> Notch {
        applyingStyle(.rectangle(cornerStyle: cornerStyle))
    }
    
    /// Applies a rectangular style to this notch.
    /// - Parameters:
    ///   - cornerStyles: Corner styles used for each corner in the notch. Nil values use a .point style.
    /// - Returns: A notch with a rectangular style.
    func rectangle(cornerStyles: [CornerStyle?]) -> Notch {
        applyingStyle(.rectangle(cornerStyles: cornerStyles))
    }
    
    /// Applies a custom style to this notch.
    /// - Parameters:
    ///   - relativeCorners: Relative corners that define the notch shape.
    /// - Returns: A notch with a custom style.
    func custom(relativeCorners: [RelativeCorner]) -> Notch {
        applyingStyle(.custom(relativeCorners: relativeCorners))
    }
    
    /// Applies a custom style to this notch.
    /// - Parameters:
    ///   - relativeCorners: Relative corners that define the notch shape.
    /// - Returns: A notch with a custom style.
    func custom(@RelativeCornerArrayBuilder relativeCorners: () -> [RelativeCorner]) -> Notch {
        custom(relativeCorners: relativeCorners())
    }
}
