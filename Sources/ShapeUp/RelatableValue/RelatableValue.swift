//
//  RelatableValue.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

/// An enumeration that represents either a relative or absolute value.
public enum RelatableValue: Codable, Sendable {
    case absolute(_ value: CGFloat)
    case relative(_ value: CGFloat)
    case mixed(absolute: CGFloat, relative: CGFloat)
}

public extension RelatableValue {
    /// The absolute value zero
    static let zero = RelatableValue.absolute(0)
    
    /// Returns the absolute value based on a provided total.
    /// - Parameter total: Total used to calculate absolute values of relative values.
    /// - Returns: The absolute value based on a provided total.
    func value(using total: CGFloat) -> CGFloat {
        switch self {
        case let .absolute(value):
            return value
        case let .relative(value):
            return value * total
        case let .mixed(absolute, relative):
            return absolute + (relative * total)
        }
    }
    
    /// Returns an absolute relatable value of this value based on a provided total.
    /// - Parameter total: Total used to create absolute values from relative values.
    /// - Returns: An absolute relatable value of this value based on a provided total.
    func absolute(using total: CGFloat) -> Self {
        .absolute(value(using: total))
    }
    
    /// Returns a relative relatable value of this value based on a provided total.
    /// - Parameter total: Total used to create relative values from absolute values.
    /// - Returns: A relative relatable value of this value based on a provided total.
    func relative(total: CGFloat) -> Self {
        .relative(value(using: total) / total)
    }
    
    /// Returns a mixed relatable value of this value based on a provided total.
    /// - Returns: A mixed relatable value of this value.
    var mixed: Self {
        .mixed(absolute: components.absolute, relative: components.relative)
    }
    
    /// The absolute and relative components of this value.
    var components: (absolute: CGFloat, relative: CGFloat) {
        switch self {
        case let .absolute(value):
            (absolute: value, relative: 0)
        case let .relative(value):
            (absolute: 0, relative: value)
        case let .mixed(absolute, relative):
            (absolute: absolute, relative: relative)
        }
    }
}

extension RelatableValue: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Values are compared by their ``components`` rather than by their case, so `.absolute(5)` and `.mixed(absolute: 5, relative: 0)` are equal.
    ///
    /// This is what makes the arithmetic below consistent. Adding two values of different cases produces a `.mixed` result, so without this `.relative(1) + .zero` would not equal `.relative(1)`, and `.relative(1) - .relative(1)` would not equal ``zero``.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.components == rhs.components
    }
}

extension RelatableValue: Hashable {
    /// Hash value is based on the ``components`` instead of the case so that equal values hash equally.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(components.absolute)
        hasher.combine(components.relative)
    }
}

extension RelatableValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public typealias IntegerLiteralType = Int
    
    /// Creates an absolute RelatableValue from the provided literal Double
    ///
    /// Useful when providing fixed values for RelatableValue properties.
    public init(floatLiteral value: Double) {
        self = .absolute(value)
    }
    
    /// Creates an absolute RelatableValue from the provided literal Int
    ///
    /// Useful when providing fixed values for RelatableValue properties.
    public init(integerLiteral value: Int) {
        self = .absolute(CGFloat(value))
    }
}
