# Changelog

## 0.6.0 - Unreleased

Changes since the previous versioned release, `0.5.3`.

This release includes several source-breaking changes and a large number of deprecations. All deprecated APIs are scheduled for removal in `1.0.0`. Upgrade to `0.6.0` and resolve all deprecation warnings before moving to `1.0.0`.

This release introduces a new way to construct corner arrays and shapes using result builders, new relative anchors and corners that allow for custom corner styles, better custom notches, and animation support for almost every corner shape. It also fixes several insetting issues that mostly affected concave corners.

### Breaking Changes

- `CornerStyle.rounded` now includes a `style` associated value. Existing construction continues to default to `.circular`, but pattern matching this case must account for the new value.
- Updated the package to Swift tools version 6.0 and raised the minimum supported versions to iOS 15, macOS 12, watchOS 8, and tvOS 15. The visionOS minimum remains version 1.
- Changed `CornerStyle.concave(radius:radiusOffset:)` to `CornerStyle.concave(radius:concaveInset:)` to correct drawing errors and allow animation.
- `CornerRectangle`, `CornerTriangle`, and `CornerPentagon` now use non-optional styles for each corner to support animation.
- `NotchStyle.cornerStyles` now returns resolved, non-optional styles; stored nil values are represented by `.automatic`.
- Replaced the closure-based `NotchStyle.custom(corners:)` enum case with `NotchStyle.custom(relativeCorners:)`. A deprecated factory converts closure-based custom notches when possible.
- Changed the concrete `AnimatableData` associated types of existing animatable types, including `Corner`, `CornerStyle`, `CornerRectangle`, `CornerTriangle`, `CornerPentagon`, and `SketchyLine`, as their animated properties expanded.
- Replaced `Corner.Dimensions.radiusOffset` with `concaveInset` and changed or removed several public calculation helpers. `Corner.Dimensions` is now deprecated in favor of the higher-level path and inset APIs.
- `RectAnchor` no longer conforms to `CaseIterable`.
- `AnchorType` removed.

### New Features

- Added `CornerStyle.RoundingStyle` with `.circular` and `.continuous` options. `CornerStyle.rounded(radius:style:)` defaults to `.circular`. Continuous corners preserve the requested nominal radius with zero-curvature edge joins at any supplied angle and use a profile fitted to SwiftUI's continuous rounded corner at 90 degrees.
- Added a new case `RectAnchor.relative(x:y:)` for storing relative positions.
- Added `RelativeCorner`, a type similar to `Corner` but with a `RectAnchor` position and an absolute offset along frame axes. It has convenience initializers similar to `RectAnchor` such as `.topLeft`, `.top`, `.right`, `.bottom`, `.center`, and `.relative(x:y:)`. Also, similar to `Corner` there are methods for moving, rotating, flipping, scaling, and changing corner styles for either single instances or arrays.
- Added `RelativeCornerCustom`, a version of `CornerCustom` that uses relative corners and can take animated State variables within its closure creating an animatable shape.
- Added `CornerStyle.automatic` which is the new default for all unstyled corners and will draw as a point by default. The new `defaultCornerStyle(_:)` method will update only corners with this automatic style.
- Added `CornerStyle.custom(radius:relativeCorners:)` for custom corner styles based on array of relative corners.
- Added a new `Notch` init with a trailing closure that builds a custom notch with relative corners.
- Added `CornerArrayBuilder`, `RelativeCornerArrayBuilder`, and `RectAnchorArrayBuilder` for building `Corner`, `RelativeCorner`, and `RectAnchor` arrays using result builders. `CornerArrayBuilder` also accepts `Notch` values and expands them between their nearest surrounding corners.
- Added `Corners` and `RelativeCorners` as typealiases for `[Corner]` and `[RelativeCorner]` with result builder inits to easily create arrays without comma-separated array literals.
- Added `Path.addClosedCornerShape` that takes an array of corners or a `CornerArrayBuilder` closure and draws it as a closed shape.
- Added a `Path.addOpenCornerShape` overload with a `CornerArrayBuilder` closure.
- Added the `CornerStylable` protocol so default corner styles can be applied consistently to corners, relative corners, arrays of corners or relative corners, notches, enumerated shapes, and custom shapes. Conforming types implement `transformCornerStyles(_:)`, which provides `defaultCornerStyle(_:)` automatically.
- Added the `CornerStyled` protocol to centralize the style property, `cornerStyle(_:)`, and `changingRadius(to:)` across `Corner` and `RelativeCorner`.
- Added animatable support for `CornerStyle`, `Corner`, `RelativeCorner`, `RectAnchor`, `NotchStyle`, `Notch`, `CornerRectangle`, `CornerTriangle`, `CornerPentagon`, and `RelativeCornerCustom`.
- Added `AnimatableProperties` that synthesizes `animatableData` from supplied writable key paths. It supports types that conform to `VectorArithmetic` or `Animatable` (including other `AnimatableProperties` types) and any `Optional` wrappers or `Array`/`Dictionary` collections of those types.
- Added public `AnimatablePropertyGroup` for grouping properties that should animate only while a `Hashable` identifier remains unchanged. When the identifier changes, the grouped properties keep their current values instead of receiving interpolated data.
- Added `AnimatableArray` and `AnimatableDictionary` helpers for animating arrays and dictionaries. Arrays expose public `animatableArray` and `animatableValueArray` properties, while dictionaries expose `animatableDictionary` and `animatableValueDictionary`.
- Added `CGFrame` for describing coordinate frames with an origin, an x-axis vector, and a y-axis vector. This is used internally to draw custom corners at any angle, not just 90 degrees.
- Added methods to easily convert `CGPoint` to `RectAnchor` and `Corner` to `RelativeCorner` given a `CGRect` or `CGFrame`.
- Added `CGSize.scaled(_:)` and `CGSize.scaled(x:y:)` helpers.
- Added `CGRect` move and scale helpers that use `RectAnchor` values as anchors.
- Added `Vector2Algebraic.crossProduct(with:)`, `dotProduct(with:)`, `scalarProjection`, `parallelComponent`, and `perpendicularComponent`.
- Added `AngleRepresentable.halfAngleSine`, `isApproximatelyZero(tolerance:)`, and `isApproximatelyStraight(tolerance:)` for half-angle geometry and angle checks that avoid floating-point equality.

### Changes

- Changed `NotchStyle.custom` from a stored closure into an array of relative corners so notches can participate in animation.
- Changed `Notch` properties from constants to variables to allow animation and gave `Notch.init` a default `.rectangle` style.
- Changed `CornerStyle.radius`, `concaveInset`, and related nested corner data to support animation updates.
- `RectAnchor` now conforms to `Equatable`, `Hashable`, and `Codable`.
- `RectAnchor` added `vertices` to replace deprecated `vertexAnchors`.
- Changed `CGRect` point method `rect.point(.topLeft)` to a subscript `rect[.topLeft]`.
- Changed `CGRect.point(relativeLocation:)` to a subscript `rect[x, y]`.
- Replaced the `CGRect.points(relativeLocations:)` overloads with `points { }`, which uses `RectAnchorArrayBuilder` and accepts anchors such as `.topLeft`, `.relative(x:y:)`, or `(x, y)` tuples.
- Changed the `CornerShape.corners(in:)` method to use `CornerArrayBuilder`.
- Changed `CornerCustom` init to use `CornerArrayBuilder` and added a helper for `closed(_:)`.
- Changed enumerated corner shape `styles` dictionaries to store non-optional `CornerStyle` values.
- Updated `SketchyLines` to animate its lines and optional shared draw amount. The shared draw amount now defaults to `nil`, preserving each `SketchyLine` draw amount unless an override is supplied.
- Added a shared `ShapeUp.xcworkspace` and shared `ShapeUp Development` scheme for working with the package tests and example app from one workspace.
- Updated the example app with new interactive shape examples that also show the code.

### Deprecations

- Deprecated `Corner.Dimensions`. This cached geometry type will become internal in a future release; use `[Corner].path(closed:)`, `[Corner].inset(by:previousPoint:nextPoint:)`, `Path.addOpenCornerShape`, or `Path.addClosedCornerShape` instead.
- Deprecated `CGRect` properties `edgeAnchors` and `vertexAnchors`.
- Deprecated `CGRect` methods `point(_:)`, `point(relativeLocation:)`, and `points(relativeLocations:)`. Use subscript and builder-based APIs, such as `rect[anchor]`, `rect[x, y]`, and `rect.points { ... }`.
- Deprecated `NotchStyle.custom(corners:)`. Use relative-corner-based `NotchStyle.custom { ... }` instead.
- Deprecated notch factory methods like `Notch.rectangle(...)`, `Notch.triangle(...)`, and `Notch.custom(...)`. Instead use `Notch(...)`, `Notch(.triangle, ...)`, and `Notch(...) { }`.
- Deprecated `applyingStyle` and `applyingStyles` in favor of `cornerStyle`, `defaultCornerStyle`, `transformCornerStyles`, and `cornerStyles` as appropriate. Array-wide style replacement remains available through deprecated compatibility methods but has no new `cornerStyle(_:)` equivalent.
- Deprecated the mutating `[Corner].addNotch` and `addNotches` methods in favor of assigning the result of `addingNotch` and `addingNotches` back to the array.
- `RectAnchor.edgeAnchors` and `RectAnchor.vertexAnchors` are deprecated in favor of `RectAnchor.vertices` and explicit anchor builders.
- Deprecated the `Array<Vector2Representable>` method `anchorPoint(_:)` and property `center`. Use `bounds[anchor]` and `bounds[.center]` instead.
- `Array<Vector2>` methods `scaledPositions(scale:)` and `scaledPositions(width:height:)` were renamed to `scaledPositions(_:)` and `scaledPositions(x:y:)`.
- `AngleType` is deprecated because equating angle classifications through floating-point values was error-prone.
- `Rectangle.applyingStyle` convenience methods are deprecated in favor of using `CornerRectangle` instead.
- Deprecated `SketchyLine.path(in:drawAmount:)`; set `drawAmount` on the line and call `path(in:)` instead.
- Deprecated `Shape.scaleToFit(_:aspectRatio:)`. This was a very old method I haven't used in a long time. If you need this functionality use SwiftUI Shape's scale modifier and check the code for this method. This will be removed in the next major version.

### Bug Fixes

- Fixed concave corner insetting, including reflex-angle cases and inset radius behavior.
- Fixed corner path drawing and insetting at zero and 180 degree angles for all corner styles.
- Fixed an issue where the last point in an inset point array could be inset incorrectly.
- Fixed `Shape.scaleToFit(_:aspectRatio:)` producing an incorrect horizontal scale when fitting a narrower aspect ratio into a wider frame.
- Fixed visionOS example compilation where the glass effect API was unavailable.
- Fixed transitions between different `CornerStyle` cases interpolating unrelated animation data, which could make custom subcorners slide in from the corner's start point. Different styles now switch immediately, while properties within the same style continue to animate.

### Tests

- Expanded test coverage for corner construction, styling, paths, and insetting; relative coordinates and anchors; animation helpers; vector and angle math; and shape scaling.
