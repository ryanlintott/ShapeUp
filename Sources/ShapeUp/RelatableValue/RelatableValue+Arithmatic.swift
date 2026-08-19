//
//  RelatableValue+Arithmatic.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-24.
//

import SwiftUI

extension RelatableValue: AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
        case let (.absolute(lhsValue), .absolute(rhsValue)):
            return .absolute(lhsValue + rhsValue)
            
        case let (.relative(lhsValue), .relative(rhsValue)):
            return .relative(lhsValue + rhsValue)
            
        case let (.mixed(lhsAbsolute, lhsRelative), .mixed(rhsAbsolute, rhsRelative)):
            return .mixed(absolute: lhsAbsolute + rhsAbsolute, relative: lhsRelative + rhsRelative)
            
        case (.absolute, .relative), (.relative, .absolute), (.absolute, .mixed), (.mixed, .absolute), (.relative, .mixed), (.mixed, .relative):
            return lhs.mixed + rhs.mixed
        }
    }
    
    public static prefix func - (x: Self) -> Self {
        switch x {
        case let .absolute(value):
            return .absolute(-value)
        case let .relative(value):
            return .relative(-value)
        case let .mixed(absolute, relative):
            return .mixed(absolute: -absolute, relative: -relative)
        }
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        lhs + -rhs
    }

}

public extension RelatableValue {
    /// RelatableValue multiplication
    ///
    /// - Note: Disfavoured so a bare numeric literal on the left is never read as a `RelatableValue`. Without it, `1 * someCGFloat` has two equally good readings, and Swift 6.0 calls that ambiguous.
    @_disfavoredOverload
    static func * (lhs: RelatableValue, rhs: CGFloat) -> RelatableValue {
        switch lhs {
        case let .absolute(lhsValue):
            return .absolute(lhsValue * rhs)

        case let .relative(lhsValue):
            return .relative(lhsValue * rhs)

        case let .mixed(lhsAbsolute, lhsRelative):
            return .mixed(absolute: lhsAbsolute * rhs, relative: lhsRelative * rhs)
        }
    }
    
    /// RelatableValue division
    ///
    /// - Note: Disfavoured for the same reason as ``*(_:_:)``.
    @_disfavoredOverload
    static func / (lhs: RelatableValue, rhs: CGFloat) -> RelatableValue {
        lhs * (1 / rhs)
    }
    
    /// RelatableValue multiplication assignment
    static func *= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
    /// RelatableValue division assignment
    static func /= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs / rhs
    }
}
