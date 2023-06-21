//
//  RelatableValue.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

/// An enumeration that represents either a relative or absolute value.
public enum RelatableValue: Equatable, Hashable, AdditiveArithmetic, Sendable {
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
        switch self {
        case let .absolute(value):
            return .mixed(absolute: value, relative: 0)
        case let .relative(value):
            return .mixed(absolute: 0, relative: value)
        case .mixed:
            return self
        }
    }
}

extension RelatableValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public typealias IntegerLiteralType = Int
    
    /// Creates an absolute RelatableValue from the provided literal Double
    ///
    /// Usefull when providing fixed values for RelatableValue properties.
    public init(floatLiteral value: Double) {
        self = .absolute(value)
    }
    
    /// Creates an absolute RelatableValue from the provided literal Int
    ///
    /// Usefull when providing fixed values for RelatableValue properties.
    public init(integerLiteral value: Int) {
        self = .absolute(CGFloat(value))
    }
}
