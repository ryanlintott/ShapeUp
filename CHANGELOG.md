# Changelog

## Unreleased

Changes since the previous versioned release, `0.5.3`.

This has a few tiny breaks but a large number of deprecations that will likely be removed in the next big update. It introduces the concept of relative anchors and corners that allow for custom corner styles, better custom notches, and animation support for almost every corner shape. There is also finally a fix for some smaller annoying insetting issues that mostly affected concave corners.

### Breaking Changes

- Changed `CornerStyle.concave(radius:radiusOffset:)` to `CornerStyle.concave(radius:concaveInset:)` to correct drawing errors and allow animation.
- `CornerRectangle`, `CornerTriangle`, and `CornerPentagon` now use non-optional styles for each corner to support animation.
- `RectAnchor` no longer conforms to `CaseIterable`.
- `AnchorType` removed.

### New Features

- Added a new case `RectAnchor.relative(x:y:)` for storing relative positions.
- Added `RelativeCorner`, a type similar to `Corner` but with a `RectAnchor` position and an absolute offset along frame axes. It has convenience initializers similar to `RectAnchor` such as `.topLeft`, `.top`, `.right`, `.bottom`, `.center`, and `.relative(x:y:)`. Also, similar to `Corner` there are methods for moving, rotating, flipping, scaling, and changing corner styles for either single instances or arrays.
- Added `RelativeCornerCustom`, a version of `CornerCustom` that uses relative corners and can take animated State variables within its closure creating an animatable shape.
- Added `CornerStyle.custom(radius:relativeCorners:)` for custom corner styles based on array of relative corners.
- Added a new `Notch` init with a trailing closure that builds a custom notch with relative corners.
- Added `CornerArrayBuilder`, `RelativeCornerArrayBuilder`, and `RectAnchorArrayBuilder` for building `Corner`, `RelativeCorner`, and `RectAnchor` arrays using result builders.
- Added `Corners` and `RelativeCorners` as typealiases for `[Corner]` and `[RelativeCorner]` with result builder inits to easily create arrays without comma-separated array literals.
- Added `Path.addClosedCornerShape` that takes an array of corners or a `CornerArrayBuilder` closure and draws it as a closed shape.
- Added a `Path.addOpenCornerShape` overload with a `CornerArrayBuilder` closure.
- Added the `CornerStylable` protocol so corner styles can be applied consistently to corners, relative corners, arrays of corners or relative corners, notches, enumerated shapes, and custom shapes.
- Added the `CornerStyled` protocol to centralize corner style properties and methods across `Corner` and `RelativeCorner`
- Added animatable support for `CornerStyle`, `Corner`, `RelativeCorner`, `RectAnchor`, `NotchStyle`, `Notch`, `CornerRectangle`, `CornerTriangle`, `CornerPentagon`, and `RelativeCornerCustom`.
- Added `AnimatableArray`, `AnimatableDictionary`, and `NestedAnimatable` helpers for animating arrays, dictionaries, and nested animatable values.
- Added `CGFrame` for describing coordinate frames with an origin, an x-axis vector, and a y-axis vector. This is used internally to draw custom corners at any angle, not just 90 degrees.
- Added methods to easily convert `CGPoint` to `RectAnchor` and `Corner` to `RelativeCorner` given a `CGRect` or `CGFrame`.
- Added `CGSize.rect`, `CGSize.rect(at:anchor:)`, and `CGSize.scaled` helpers.
- Added `CGRect` move and scale helpers that use `RectAnchor` values as anchors.
- Added `Array<CGPoint>.path(closed:)` for building paths from point arrays.
- Added `Vector2Algebraic.crossProduct(with:)`, `dotProduct(with:)`, `scalarProjection`, `parallelComponent`, and `perpendicularComponent`.
- Added `Corner.Dimensions.isApproximatelyStraight(tolerance:)` for straight-angle checks that avoid floating-point equality.

### Changes

- Changed `NotchStyle.custom` from a stored closure into an array of relative corners so notches can participate in animation.
- Changed `Notch` properties from constants to variables to allow animation and gave `Notch.init` a default `.rectangle` style.
- Changed `CornerStyle.radius`, `concaveInset`, and related nested corner data to support animation updates.
- `RectAnchor` now conforms to `Equatable`, `Hashable`, and `Codable`.
- `RectAnchor` and added `vertices` to replace deprecated `vertexAnchors`
- Changed `CGRect` point method `rect.point(.topLeft)` to a subscript `rect[.topLeft]`.
- Changed `CGRect` point method `points(relativeLocation: (x, y))` to a subscript `rect[x, y]`.
- Changed `CGRect` point method `point(relativeLocations:)` and similar to `points {  }` that uses `RectAnchorArrayBuilder` that will take `.topLeft`, `.relative(x, y)` or even `(x, y)`.
- Changed `CornerShape` `corners(in:)` method to use `CornerArrayBuilder`
- Changed `CornerCustom` init to use `CornerArrayBuilder` and added a helper for `closed(_:)`.
- Changed enumerated corner shape `styles` dictionaries to store non-optional `CornerStyle` values.
- Added a shared `ShapeUp.xcworkspace` and shared `ShapeUp Development` scheme for working with the package tests and example app from one workspace.
- Updated the example app with new interactive shape examples that also show the code.


### Deprecations

- Deprecated `CGRect` properties `edgeAnchors` and `vertexAnchors`.
- Deprecated `CGRect` methods `point(_: RectAnchor)`, `points(relativeLocation:)`, and `point(relativeLocations:)`. Use subscript and builder-based APIs, such as `rect[anchor]`, `rect[x, y]`, and `rect.points { ... }`.
- Deprecated `NotchStyle.custom(corners:)`. Use relative-corner-based `NotchStyle.custom { ... }` instead.
- Deprecated notch factory methods like `Notch.rectangle(...)`, `Notch.triangle(...)` and `Notch.custom(...)`. Instead use `Notch(...)`, `Notch(.triangle, ...)` and `Notch(...) { }`
- Deprecated `applyingStyle` and `applyingStyles` in favor of `cornerStyle` and `cornerStyles` throughout.
- `RectAnchor.edgeAnchors` and `RectAnchor.vertexAnchors` are deprecated in favor of `RectAnchor.vertices` and explicit anchor builders.
- Deprecated `Array<Vector2Representable>` method `anchorPoint(_:)` and property `center`. Instead use `bounds.subscript (_:)` and `bounds[.center]`
- `Array<Vector2>` method `scaledPositions(scale:)` and `scaledPositions(width:height:)` were renamed to `scaledPositions(_:)` and `scaledPositions(x:y:)`
- `AngleType` is deprecated because equating angle classifications through floating-point values was error-prone.
- `Rectangle.applyingStyle` convenience methods are deprecated in favor of using `CornerRectangle` instead.

### Bug Fixes

- Fixed concave corner insetting, including reflex-angle cases and inset radius behavior.
- Fixed an issue where the last point in an inset point array could be inset incorrectly.
- Fixed visionOS example compilation where the glass effect API was unavailable.

### Tests

- Added tests for `CGPoint.relative(to:)`.
- Expanded tests for `RectAnchor`, `Vector2Algebraic`, `Vector2Representable`, and angle helpers.
- Removed `AngleTypeTests` after deprecating `AngleType`.
