//
//  RelatableValue.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

/// An enumeration that represents either a relative or absolute value.
public enum RelatableValue: Equatable {
    case absolute(_ value: CGFloat)
    case relative(_ value: CGFloat)
}

public extension RelatableValue {
    /// The absolute value zero
    static let zero = RelatableValue.absolute(0)
    
    /// The absolute value
    /// - Parameter total: Total used when calculating relative values.
    /// - Returns: The absolute value based on a provided total
    func value(using total: CGFloat) -> CGFloat {
        switch self {
        case .absolute(let value):
            return value
        case .relative(let value):
            return value * total
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
