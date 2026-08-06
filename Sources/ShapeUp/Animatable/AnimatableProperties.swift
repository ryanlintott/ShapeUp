//
//  AnimatableProperties.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-04.
//

import SwiftUI

/// A type whose animation data is synthesized from writable key paths.
///
/// Every writable key path supplied by ``animatableProperties`` contributes to the synthesized
/// animation data.
///
/// ```swift
/// struct StyledRectangle: Shape, AnimatableProperties {
///     var insetAmount: CGFloat
///     var cornerStyle: CornerStyle
///
///     static var animatableProperties: some AnimatableProperty<Self> {
///         \.insetAmount
///         \.cornerStyle
///     }
///
///     func path(in rect: CGRect) -> Path {
///         rect
///             .insetBy(dx: insetAmount, dy: insetAmount)
///             .corners(cornerStyle)
///             .path()
///     }
/// }
/// ```
public protocol AnimatableProperties: Animatable {
    /// The descriptor containing this type's animatable properties.
    associatedtype PropertyDescriptor: AnimatableProperty<Self>

    /// The properties included in this type's animation data.
    @AnimatablePropertyBuilder<Self>
    static var animatableProperties: PropertyDescriptor { get }
}

extension AnimatableProperties {
    public var animatableData: PropertyDescriptor.AnimatableData {
        get {
            Self.animatableProperties.animatableData(for: self)
        }
        set {
            Self.animatableProperties.applyAnimatableData(newValue, to: &self)
        }
    }
}

/// A composable description of one or more animatable properties belonging to a root value.
public protocol AnimatableProperty<Root> {
    associatedtype Root
    associatedtype AnimatableData: VectorArithmetic

    func animatableData(for root: Root) -> AnimatableData
    func applyAnimatableData(_ animatableData: AnimatableData, to root: inout Root)
}

/// Builds an animatable property descriptor from writable key paths.
@resultBuilder
public enum AnimatablePropertyBuilder<Root> { }

public extension AnimatablePropertyBuilder {
    struct Empty: AnimatableProperty {
        public typealias AnimatableData = EmptyAnimatableData

        init() { }

        public func animatableData(for root: Root) -> EmptyAnimatableData {
            .zero
        }

        public func applyAnimatableData(
            _ animatableData: AnimatableData,
            to root: inout Root
        ) { }
    }
    
    struct AnimatableValue<Value: VectorArithmetic>: AnimatableProperty {
        public typealias AnimatableData = Value
        
        let keyPath: WritableKeyPath<Root, Value>
        
        init(_ keyPath: WritableKeyPath<Root, Value>) {
            self.keyPath = keyPath
        }
        
        public func animatableData(for root: Root) -> AnimatableData {
            root[keyPath: keyPath]
        }
        
        public func applyAnimatableData(_ animatableData: AnimatableData, to root: inout Root) {
            root[keyPath: keyPath] = animatableData
        }
    }
    
    struct Pair<
        First: AnimatableProperty,
        Second: AnimatableProperty
    >: AnimatableProperty where First.Root == Root, Second.Root == Root {
        public typealias AnimatableData = AnimatablePair<
            First.AnimatableData,
            Second.AnimatableData
        >

        private let first: First
        private let second: Second

        init(_ first: First, _ second: Second) {
            self.first = first
            self.second = second
        }

        public func animatableData(
            for root: Root
        ) -> AnimatableData {
            .init(
                first.animatableData(for: root),
                second.animatableData(for: root)
            )
        }

        public func applyAnimatableData(
            _ animatableData: AnimatableData,
            to root: inout Root
        ) {
            first.applyAnimatableData(animatableData.first, to: &root)
            second.applyAnimatableData(animatableData.second, to: &root)
        }
    }
    
    static func buildBlock() -> Empty {
        .init()
    }
    
    /// Non-Optional builders
    static func buildExpression<Value: VectorArithmetic>(
        _ expression: WritableKeyPath<Root, Value>
    ) -> AnimatableValue<Value> {
        .init(expression)
    }

    static func buildExpression<Value: VectorArithmetic & Animatable>(
        _ expression: WritableKeyPath<Root, Value>
    ) -> AnimatableValue<Value> {
        .init(expression)
    }
    
    static func buildExpression<Value: Animatable>(
        _ expression: WritableKeyPath<Root, Value>
    ) -> AnimatableValue<Value.AnimatableData> {
        .init(expression.appending(path: \.animatableData))
    }
    
    /// Optional builders
    static func buildExpression<Value: VectorArithmetic>(
        _ expression: WritableKeyPath<Root, Value?>
    ) -> AnimatableValue<Value> {
        .init(expression.appending(path: \.unwrappedAnimatableData))
    }
    
    static func buildExpression<Value: VectorArithmetic & Animatable>(
        _ expression: WritableKeyPath<Root, Value?>
    ) -> AnimatableValue<Value> {
        .init(expression.appending(path: \.unwrappedAnimatableData))
    }
    
    static func buildExpression<Value: Animatable>(
        _ expression: WritableKeyPath<Root, Value?>
    ) -> AnimatableValue<Value.AnimatableData> {
        .init(expression.appending(path: \.unwrappedAnimatableValueData))
    }
    
    /// Array builders
    static func buildExpression<Value: VectorArithmetic>(
        _ expression: WritableKeyPath<Root, Array<Value>>
    ) -> AnimatableValue<AnimatableArray<Value>> {
        .init(expression.appending(path: \.animatableArray))
    }
    
    static func buildExpression<Value: VectorArithmetic & Animatable>(
        _ expression: WritableKeyPath<Root, Array<Value>>
    ) -> AnimatableValue<AnimatableArray<Value>> {
        .init(expression.appending(path: \.animatableArray))
    }
    
    static func buildExpression<Value: Animatable>(
        _ expression: WritableKeyPath<Root, Array<Value>>
    ) -> AnimatableValue<AnimatableArray<Value.AnimatableData>> {
        .init(expression.appending(path: \.animatableValueArray))
    }
    
    /// Dictionary builders
    static func buildExpression<Key, Value: VectorArithmetic>(
        _ expression: WritableKeyPath<Root, Dictionary<Key, Value>>
    ) -> AnimatableValue<AnimatableDictionary<Key, Value>> {
        .init(expression.appending(path: \.animatableDictionary))
    }
    
    static func buildExpression<Key, Value: VectorArithmetic & Animatable>(
        _ expression: WritableKeyPath<Root, Dictionary<Key, Value>>
    ) -> AnimatableValue<AnimatableDictionary<Key, Value>> {
        .init(expression.appending(path: \.animatableDictionary))
    }
    
    static func buildExpression<Key, Value: Animatable>(
        _ expression: WritableKeyPath<Root, Dictionary<Key, Value>>
    ) -> AnimatableValue<AnimatableDictionary<Key, Value.AnimatableData>> {
        .init(expression.appending(path: \.animatableValueDictionary))
    }

    static func buildPartialBlock<First: AnimatableProperty<Root>>(
        first: First
    ) -> First {
        first
    }

    static func buildPartialBlock<
        Accumulated: AnimatableProperty<Root>,
        Next: AnimatableProperty<Root>
    >(
        accumulated: Accumulated,
        next: Next
    ) -> Pair<Accumulated, Next> {
        .init(accumulated, next)
    }
}

fileprivate extension Optional where Wrapped: VectorArithmetic {
    var unwrappedAnimatableData: Wrapped {
        get {
            switch self {
            case .none: .zero
            case let .some(value): value
            }
        }
        set {
            self? = newValue
        }
    }
}

fileprivate extension Optional where Wrapped: Animatable {
    var unwrappedAnimatableValueData: Wrapped.AnimatableData {
        get {
            switch self {
            case .none: .zero
            case let .some(value): value.animatableData
            }
        }
        set {
            self?.animatableData = newValue
        }
    }
}
