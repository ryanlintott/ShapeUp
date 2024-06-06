//
//  AngleType.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-04.
//

import SwiftUI

/// An enumeration representing the type of an angle.
public enum AngleType: Int, Comparable, CaseIterable, Sendable {
    /// An angle of zero degrees with initial and terminal sides in the same location.
    case zero
    /// An angle with a magnitude greater than 0 but less than 90 degrees.
    case acute
    /// An angle with a magnitude of 90 degrees.
    case rightAngle
    /// An angle with a magnitude greater than 90 but less than 180 degrees.
    case obtuse
    /// An angle with a magnitude of 180 degrees.
    case straight
    /// An angle with a magnitude greater than 180 but less than 360 degrees.
    case reflex
    /// An angle with a magnitude of 360 degrees.
    case fullRotation
    /// An angle with a magnitude greater than 360 degrees.
    case over360
    
    public static func < (lhs: AngleType, rhs: AngleType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension AngleType {
    /// Creates an angle type based on a supplied radians.
    /// - Parameter radians: The magnitude of this value is used to determine the type.
    init(radians: Double) {
        self = Self.type(of: .radians(radians))
    }
    
    /// Creates an angle type based on a supplied degrees.
    /// - Parameter degrees: The magnitude of this value is used to determine the type.
    init(degrees: Double) {
        self = Self.type(of: .degrees(degrees))
    }
    
    /// Creates an angle type based on the supplied angle.
    /// - Parameter angle: The positive value of this angle is used to determine the type.
    /// - Returns: The type of the supplied angle.
    static func type(of angle: Angle) -> Self {
        switch angle.positive.radians {
        case 0:
            return .zero
        case (.pi * 0.5):
            return .rightAngle
        case (.pi):
            return .straight
        case (.pi * 2):
            return .fullRotation
        case 0...(.pi * 0.5):
            return .acute
        case (.pi * 0.5)...(.pi):
            return obtuse
        case (.pi)...(.pi * 2):
            return .reflex
        default:
            return .over360
        }
    }
}
