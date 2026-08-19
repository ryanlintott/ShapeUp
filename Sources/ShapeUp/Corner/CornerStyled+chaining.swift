//
//  CornerStyled+chaining.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-12.
//

import SwiftUI

public extension CornerStyled {
    /// Applies a rounded corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the rounded corner.
    ///   - style: Shape of the rounded corner. Defaults to `.circular`.
    /// - Returns: A corner with a rounded style applied.
    func rounded(radius: RelatableValue, style: CornerStyle.RoundingStyle = .circular) -> Self {
        self.cornerStyle(.rounded(radius: radius, style: style))
    }
    
    /// Applies a concave corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the concave corner.
    ///   - concaveInset: Inset for the concave radius. Default is 0. This value changes when insetting the corner.
    /// - Returns: A corner with a concave style applied.
    func concave(radius: RelatableValue, concaveInset: CGFloat = 0) -> Self {
        self.cornerStyle(.concave(radius: radius, concaveInset: concaveInset))
    }
    
    /// Applies a straight chamfer corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the straight corner.
    ///   - cornerStyles: Corner styles for the two resulting corners of the chamfer.
    /// - Returns: A corner with a straight style applied.
    func straight(radius: RelatableValue, cornerStyles: [CornerStyle] = []) -> Self {
        self.cornerStyle(.straight(radius: radius, cornerStyles: cornerStyles))
    }
    
    /// Applies a straight chamfer corner style to this corner with a single nested style.
    /// - Parameters:
    ///   - radius: Radius of the straight corner.
    ///   - cornerStyle: Corner style for the two resulting corners of the chamfer.
    /// - Returns: A corner with a straight style applied.
    func straight(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        self.cornerStyle(.straight(radius: radius, cornerStyle: cornerStyle))
    }
    
    /// Applies a cutout corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the cutout corner.
    ///   - cornerStyles: Corner styles for the three resulting corners of the cutout.
    /// - Returns: A corner with a cutout style applied.
    func cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = []) -> Self {
        self.cornerStyle(.cutout(radius: radius, cornerStyles: cornerStyles))
    }
    
    /// Applies a cutout corner style to this corner with a single nested style.
    /// - Parameters:
    ///   - radius: Radius of the cutout corner.
    ///   - cornerStyle: Corner style for the three resulting corners of the cutout.
    /// - Returns: A corner with a cutout style applied.
    func cutout(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        self.cornerStyle(.cutout(radius: radius, cornerStyle: cornerStyle))
    }
    
    /// Applies a custom corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the custom corner.
    ///   - relativeCorners: Relative corners that define the corner shape.
    /// - Returns: A corner with a custom style applied.
    func custom(radius: RelatableValue, relativeCorners: [RelativeCorner]) -> Self {
        self.cornerStyle(.custom(radius: radius, relativeCorners: relativeCorners))
    }
}
