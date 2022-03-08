//
//  AngleRepresentable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-08.
//

import SwiftUI

/// An object that can be represented as an angle
///
/// This protocol is used to add additional functionality to SwiftUI Angle
///
/// Use this line to add this functionality to your project:
///
///     extension Angle: AngleRepresentable { }
///
public protocol AngleRepresentable {
    var radians: Double { get }
}

extension AngleRepresentable {
    /// The angle represented as a SwiftUI Angle (used in functions below).
    fileprivate var angle: Angle {
        .radians(radians)
    }
}

public extension AngleRepresentable {
    /// Type of an angle based on its magnitude
    var type: AngleType {
        AngleType.type(of: angle)
    }
    
    /// Positive magnitude of an angle.
    ///
    /// Negative angles are made positive, positive angles are untouched. Full rotations are included.
    var positive: Angle {
        angle > .zero ? angle : -angle
    }
    
    /// An angle half the size keeping it's sign.
    var halved: Angle {
        angle / 2
    }

    /// An angle equal to 90 degrees minus the angle.
    ///
    /// Complementary angles are a pair of angles that add up to 90 degrees. For angles greater than 90 degrees, complementary angles will be negative. For angles less than zero, complementary angles will be greater than 90 degrees.
    var complementary: Angle {
        .radians(.pi / 2) - angle
    }
    
    /// An angle equal to 180 degrees minus the angle.
    ///
    /// Supplementary angles are a pair of angles that add up to 180 degrees. For angles greater than 180 degrees, supplementary angles will be negative. For angles less than zero, supplementary angles will be greater than 180 degrees.
    var supplementary: Angle {
        .radians(.pi) - angle
    }
    
    /// An angle equal to 360 degrees minus the angle.
    ///
    /// Exmplementary angles are a pair of angles that add up to 360 degrees. For angles greater than 360 degrees, exmplementary angles will be negative. For angles less than zero, explementary angles will be greater than 360 degrees.
    var explementary: Angle {
        .radians(.pi * 2) - angle
    }
    
    /// The smallest positive coterminal angle.
    ///
    /// Coterminal angles are angles that share the same initial and terminal sides. For example: 10°, 370°, and -350° are all coterminal.
    var minPositiveCoterminal: Angle {
        guard angle != .zero else { return .zero }
        // Smallest coterminal angle
        let minCoterminal = angle.radians.remainder(dividingBy: .pi * 2)
        // If it's less than zero, add 360 degrees
        let minPositiveCoterminal = minCoterminal < 0 ? .pi * 2 + minCoterminal : minCoterminal
        return .radians(minPositiveCoterminal)
    }
    

    /// Minimum rotation required to turn from a specified angle position to this one if both are in the standard position with initial side on the positive X axis.
    ///
    /// Values between -180 and +180 degrees
    /// - Parameter angle: Angle
    func minRotation(from angle: Angle) -> Angle {
        // Possible values between 0 and 360
        let rotation = (self.angle - angle).minPositiveCoterminal
        // If it's reflex, return the negative expementary version.
        return rotation.type == .reflex ? -rotation.explementary : rotation
    }

    func maxRotation(from angle: Angle) -> Angle {
        let minRotation = minRotation(from: angle)
        let maxRotationSign: Double = minRotation.radians >= 0 ? -1 : 1
        return minRotation.positive.explementary * maxRotationSign
    }
    
    /// A coterminal angle that is a reflex angle.
    ///
    /// Values between +180 and +360 degrees and between -180 and -360 degrees.
    var reflexCoterminal: Angle {
        maxRotation(from: .zero)
    }
    
    /// A coterminal angle that is a not a reflex angle.
    ///
    /// Values between -180 and +180 degrees.
    var nonReflexCoterminal: Angle {
        minRotation(from: .zero)
    }

    /// The positive angle that's the shortest distance back to zero
    @available(*, deprecated, message: "Use nonReflexCoterminal.positive instead or look for another solution.")
    var interior: Angle {
        nonReflexCoterminal.positive
    }
    
    /// Returns the positive angle formed by connecting 3 points.
    ///
    /// Working in screen space where +X = right and -Y = up this is the clockwise angle.
    /// Values between 0 and 360 degrees
    /// - Parameters:
    ///   - initialPoint: Point on the intial side of the angle.
    ///   - anchor: Corner point of the angle.
    ///   - terminalPoint: Point on the terminal side of the angle.
    /// - Returns: The positive angle of rotation from the initial point to the terminal point around an anchor point.
    static func threePoint<T: Vector2Representable, U: Vector2Representable, V: Vector2Representable>(_ initialPoint: T, _ anchor: U, _ terminalPoint: V) -> Angle {
        // Get both angles and ensure they are not undefined.
        guard
            let initialAngle = (initialPoint.vector - anchor.vector).direction,
            let terminalAngle = (terminalPoint.vector - anchor.vector).direction
        else {
            // If either the initial and terminal side has no direction (has a length of zero) then the angle between these two sides will also be zero.
            return .zero
        }
        
        return (terminalAngle - initialAngle).minPositiveCoterminal
    }
}
