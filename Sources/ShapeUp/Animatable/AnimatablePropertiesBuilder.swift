//
//  AnimatablePropertiesBuilder.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-04.
//

import SwiftUI

/// Builds direct animatable fields from writable key paths.
@resultBuilder
public enum AnimatablePropertiesBuilder<Root> { }

public extension AnimatablePropertiesBuilder {
    struct Empty: AnimatableProperty {
        public typealias AnimatableData = EmptyAnimatableData

        public init() { }

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
        
        public let keyPath: WritableKeyPath<Root, Value>
        
        public init(_ keyPath: WritableKeyPath<Root, Value>) {
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

        public init(_ first: First, _ second: Second) {
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
