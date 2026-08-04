<img width="456" alt="ShapeUp Logo" src="https://user-images.githubusercontent.com/2143656/157464613-38fd35cc-7802-4cb7-914b-4da480a0411e.png">

[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FShapeUp%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanlintott/ShapeUp)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FShapeUp%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanlintott/ShapeUp)
![License - MIT](https://img.shields.io/github/license/ryanlintott/ShapeUp)
![Version](https://img.shields.io/github/v/tag/ryanlintott/ShapeUp?label=version)
![GitHub last commit](https://img.shields.io/github/last-commit/ryanlintott/ShapeUp)
[![Mastodon](https://img.shields.io/badge/mastodon-@ryanlintott-5c4ee4.svg?style=flat)](https://mastodon.social/@ryanlintott)
[![Bluesky](https://img.shields.io/badge/bluesky-@ryanlintott-0285FF.svg?style=flat)](https://bsky.app/profile/ryanlintott.bsky.social)

# Overview
A Swift Package that makes SwiftUI shapes easier to build. (The logo above was created in 100 lines + SwiftUI Text)

Features:
- [`RectAnchor`](#rectanchor), an enum for major anchor points in a rectangle or coordinate frame. Used for transform functions.
- Extensions to [`CGPoint`](#cgpoint), [`CGRect`](#cgrect), and [`CGSize`](#cgsize)
- [`Corner`](#corner), a `CGPoint` with `style`.
- [`CornerStyle`](#cornerstyle) options: `.automatic`, `.point`, `.rounded`, `.straight`, `.cutout`, `.concave`, and `.custom`
- Basic shapes like [`CornerRectangle`](#basic-shapes), [`CornerTriangle`](#basic-shapes), and [`CornerPentagon`](#basic-shapes) with stylable corners.
- [`CornerShape`](#cornershape), a protocol for making your own open or closed shapes out of an array of Corners.
- [`CornerCustom`](#cornercustom), for building corner shapes inline without making a new type.
- [`RelativeCornerCustom`](#relativecornercustom), for building animatable corner shapes from relative positions.
- Add a [`Notch`](#notch) of any `NotchStyle` between two corners.
- [`.addOpenCornerShape()`](#add-cornershape) or [`.addClosedCornerShape()`](#add-cornershape) for adding a few corners to a SwiftUI `Path`
- [`Vector2`](#vector2), a type similar to `CGPoint` but used to do vector math.
- [`Vector2Representable`](#vector2representable) protocol that adds a `.vector` property needed to conform to other Vector2-related protocols.
- [`Vector2Algebraic`](#vector2algebraic) protocol used to add vector algebra capabilities to `Vector2`
- [`Vector2Transformable`](#vector2transformable) protocol with methods for transforming arrays of points.
- [`RelatableValue`](#relatablevalue), an enum used to store `.relative` or `.absolute` values.
- [`CGFrame`](#cgframe), a coordinate space or rhombus defined by an origin and vectors for each axis
- [`SketchyLine`](#sketchyline), an animatable line `Shape` that aligns to frame edges and can extend beyond the frame.
- [`.emboss()` or `.deboss()`](#emboss-or-deboss) any SwiftUI `Shape` or `View`.
- [`AnimatablePack`](#animatablepack) as an alternative to `AnimatablePair` that takes any number of properties.
- [`AnimatableArray`](#animatablearray) for animating arrays element by element.
- [`AnimatableDictionary`](#animatabledictionary) for animating dictionary values by key.

# Demo App
The `Example` folder has an app that demonstrates the features of this package.

# Installation and Usage
This package is compatible with iOS 15+, macOS 12+, watchOS 8+, tvOS 15+, and visionOS 1+.

1. In Xcode go to `File -> Add Packages`
2. Paste in the repo's url: `https://github.com/ryanlintott/ShapeUp` and select by version.
3. Import the package using `import ShapeUp`

# Is this Production-Ready?
Really it's up to you. I currently use this package in my own [Old English Wordhord app](https://oldenglishwordhord.com/app).

Additionally, if you find a bug or want a new feature add an issue and I will get back to you about it.

# Support This Project
ShapeUp is open source and free but if you like using it, please consider supporting my work.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/X7X04PU6T)

Or you can buy a t-shirt with the ShapeUp logo

<a href="https://cottonbureau.com/p/JBYGB7/shirt/shapeup#/20149802"><img width="256" alt="ShapeUp T-Shirt" src="https://cottonbureau.com/mockup?vid=20149802&hash=6UJM&w=512"></a>
- - -
# Features
## RectAnchor
`RectAnchor` references a relative location in a `CGRect` like `.topLeft`, `.bottomRight`, and `.relative(x: 0.2, y: 0.8)`. It's similar to `UnitPoint` but it uses left and right instead of leading and trailing as it cannot respond to locale changes.

Inside the `path(in:)` method of a SwiftUI `Shape`, points often use positions relative to the `rect` parameter. `ShapeUp` adds a subscript on `CGRect` that uses `RectAnchor` to clarify this code.

```swift
func path(in rect: CGRect) -> Path {
    // Current method
    let point1 = CGPoint(x: rect.minX, y: rect.minY)
    let point2 = CGPoint(x: rect.minX + (rect.width * 0.4), y: rect.minY + (rect.height * 0.7))
    
    // ShapeUp method
    let point1 = rect[.topLeft]
    let point2 = rect[.relative(0.4, 0.7)]
    
    // or an even shorter version using relative locations
    let point1 = rect[0, 0]
    let point2 = rect[0.4, 0.7]
    ...
}
```

When you need several points, `points(_:)` accepts a `RectAnchorArrayBuilder` closure containing anchors or relative coordinate tuples.

```swift
let points = rect.points {
    .topLeft
    (0.4, 0.7)
    .bottomRight
}
```

## CGPoint
`CGPoint` conforms to [`Vector2Transformable`](#vector2transformable), so single points or arrays can be moved, rotated, flipped, scaled, or inset. Convert the transformed points to corners to create a `Path` that draws lines between them.

```swift
func path(in rect: CGRect) -> Path {
    [
        rect[.topLeft].moved(dx: 10),
        rect[.right],
        rect[0.7, 1.0]    
    ]
    .moved(dx: 100, dy: 50)
    .rotated(.degrees(45), anchor: .center)
    .flipped(mirrorLineStart: .topLeft, mirrorLineEnd: .bottomLeft)
    .scaledPositions(2.5, anchor: .bottomRight)
    .insetPoints(5)
    .corners
    .path()
}
```

## Corner
What if you wanted to turn those points into rounded corners? Just add a `.rounded` style!

```swift
func path(in rect: CGRect) -> Path {
    [
        rect[.topLeft].moved(dx: 10),
        rect[.right],
        rect[0.7, 1.0]     
    ]
    .corners(.rounded(radius: 20))
    .path()
}
```

Adding a `CornerStyle` to an array of `CGPoint` changes it into an array of `Corner`. You can also apply different styles to individual corners.

```swift
func path(in rect: CGRect) -> Path {
    [
        rect[.topLeft]
            .moved(dx: 10)
            .rounded(radius: 20),
            
        rect[.right],
        
        rect[0.7, 1.0]
            .cutout(radius: .relative(0.4))
    ]
    .path()
}
```

Arrays of corners with styles can be awkward to format. `Corners` can build an array of corners using `CornerArrayBuilder` (similar to `ViewBuilder`) so you can omit all those commas. You can also include a `Notch`, which is added between the nearest corners before and after it. Corner lookup is cyclic, so a leading or trailing notch is added between the last and first corners.

```swift
func path(in rect: CGRect) -> Path {
    Corners {
        rect[.topLeft]
            .moved(dx: 10)
            .rounded(radius: 20)
            
        rect[.right]
        
        rect[0.7, 1.0] 
            .cutout(radius: .relative(0.4))
    }
    .path()
}
```

```swift
let corners = Corners {
    rect[.topLeft]
    rect[.topRight]
    Notch(.triangle, length: 30, depth: 15)
    rect[.bottomRight]
    rect[.bottomLeft]
}
```


## CornerStyle
Many different styles can be used on a `Corner` to define its shape.

`.automatic`
The initial style for corners created without an explicit style. It renders as a point unless resolved by `defaultCornerStyle(_:)`.

<img width="50" alt="Pink triangle with a point corner" src="https://user-images.githubusercontent.com/2143656/157761591-2341d07c-5f0e-4434-ad19-22873f7357d9.svg"> `.point`
An explicit point corner with no properties. Unlike `.automatic`, it is preserved when applying a default style.

<img width="50" alt="Pink triangle with a rounded corner" src="https://user-images.githubusercontent.com/2143656/157762280-630dddf9-4cd4-4779-84e6-43f2f834e6b0.svg"> `.rounded(radius: RelatableValue)`
A rounded corner with a radius.

<img width="50" alt="Pink triangle with a concave cut corner" src="https://user-images.githubusercontent.com/2143656/157762293-ac45ea61-6427-4def-b560-060944ac2c1a.svg"> `.concave(radius: RelatableValue, concaveInset: CGFloat = 0)`
A concave corner is like an inverted rounded corner where the radius determines the start and end points of the cut. The concave inset value is the inset of the concave radius and is automatically adjusted when insetting this corner.

<img width="50" alt="Pink triangle with a straight cut corner" src="https://user-images.githubusercontent.com/2143656/157762299-437bcec4-2fc8-475b-bbbb-ed810d86ca7f.svg"> `.straight(radius: RelatableValue, cornerStyles: [CornerStyle] = [])`
A straight chamfer corner where the radius determines the start and end points of the cut. Additional corner styles can be used on the two resulting corners of the chamfer. (You can continue nesting recursively.)

<img width="50" alt="Pink triangle with a cutout corner" src="https://user-images.githubusercontent.com/2143656/157762313-c4015f99-7c53-4571-93b5-a8b476c9f5da.svg"> `.cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = [])`
A cutout corner where the radius determines the start and end points of the cut. Additional corner styles can be used on the three resulting corners of the cut. (Again, you can continue nesting recursively.)

Lastly, a custom corner uses the radius to determine the top left and bottom right corners of a rhombus in which you can add any number of relative corners to draw your shape.

```swift
.custom(radius: 20) {
    RelativeCorner.topLeft
    RelativeCorner.bottom.rounded(radius: .relative(0.4))
    RelativeCorner.topRight
}
```

Use `cornerStyle(_:)` to replace the style on an individual corner or selected shape corners. Use `defaultCornerStyle(_:)` on a value containing multiple corners to style automatic corners while preserving explicit styles.

```swift
CornerRectangle()
    .cornerStyle(.point, shapeCorner: .topRight)
    .defaultCornerStyle(.rounded(radius: 20))
```

Types conforming to `CornerStylable` implement `transformCornerStyles(_:)` once, which supplies `defaultCornerStyle(_:)`. The narrower `CornerStyled` protocol supplies `cornerStyle(_:)` and `changingRadius(to:)` to `Corner` and `RelativeCorner` that contain a single style. Arrays of these values provide indexed style replacement, `cornerStyles(_:)`, and the `cornerStyles` property. Transformations apply to each direct style contained by the value without separately visiting nested styles.


## RelatableValue
The corner radius for any corner style uses a `RelatableValue`. This is a value that stores either an absolute or a relative value. This type is used in several other ShapeUp types and you can use it in your types to add a relative option to your parameters.

When setting a corner radius you might want a fixed value like 20 or you might want a value that's 20% of the maximum radius so that it will scale proportionally.

```swift
let cornerStyle1: CornerStyle = .rounded(radius: .absolute(20))
let cornerStyle2: CornerStyle = .rounded(radius: .relative(0.2))
```

`RelatableValue` conforms to `ExpressibleByIntegerLiteral` and `ExpressibleByFloatLiteral`. This means you can omit `.absolute()` when writing absolute values.
```swift
let cornerStyle1: CornerStyle = .rounded(radius: 20)
let cornerStyle2: CornerStyle = .rounded(radius: .relative(0.2))
```

Internally, the final value is determined by running the `value(using total:)` function. Absolute values are unchanged and relative values are calculated using the maximum radius that would fit the corner given the length of the two sides and the angle.


## CornerShape
An alternative to SwiftUI `Shape` where shapes are built from an array of `Corner`s. The resulting shape automatically conforms to `InsettableShape` with no additional work.

`CornerShape` only draws straight lines between its styled corners, so if you want Bezier curves between corners you will need to use `Shape` and `addOpenCornerShape` instead.

### How to build a CornerShape
- Set `insetAmount` to zero (this property is used to automatically inset the CornerShape).
- The `closed` property determines if your path will close or be left open.
- Write a method that returns an array of corners.

```swift
struct MyCornerShape: CornerShape {
    var insetAmount: CGFloat = .zero
    var closed = true
   
    func corners(in rect: CGRect) -> [Corner] {
        rect[.topLeft]
            .moved(dx: 10)
            .rounded(radius: 20)
            
        rect[.right]
        
        rect[0.7, 1.0] 
            .cutout(radius: .relative(0.4))
    }
}
```

### Using A CornerShape
A `CornerShape` can be used in SwiftUI Views the same way as `RoundedRectangle` or similar.
```swift
MyCornerShape()
    .fill()
```

The corners can also be accessed directly for use in a regular SwiftUI `Shape`
```swift
func path(in rect: CGRect) -> Path {
    var path = Path()
    
    // ...Draw some quad curves or similar complex shapes
    
    let corners: [Corner] = MyCornerShape()
        .corners(in: rect)
        .inset(by: 10)
        .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
        
    path.addOpenCornerShape(
        corners,
        previousPoint: path.currentPoint,
        nextPoint: rect[.center],
        moveToStart: false
    )
    
    // ...Draw some more
    
    return path
}
```

## CornerCustom
Sometimes you might want to make a shape inline without defining a new struct. `CornerCustom` is a `CornerShape` that takes a closure that returns an array of `Corner`s.

The closure is `@Sendable`, so captured view state will not drive animation the way it can with `RelativeCornerCustom`.

```swift
CornerCustom { rect in
    rect[.topLeft]
        .moved(dx: 10)
        .rounded(radius: 20)
        
    rect[.right]
    
    rect[0.7, 1.0] 
        .cutout(radius: .relative(0.4))
}
.fill()
```

## RelativeCornerCustom
An alternative to `CornerCustom` that can use `@State` values and can therefore be animated. This shape takes an array of `RelativeCorner`, a type similar to `Corner` except its position is a relative anchor point with an absolute offset.

```swift
RelativeCornerCustom {
    RelativeCorner.topLeft
        .moved(dx: 10)  // absolute offsets are still possible
        .rounded(radius: 20)
        
    RelativeCorner.right
    
    RelativeCorner(x: 0.7, y: 1.0)
        .cutout(radius: .relative(0.4))
}
.fill()
```

## Basic Shapes
`CornerRectangle`, `CornerTriangle`, and `CornerPentagon` are pre-built corner shapes where you can customize the style of any corner. Some parameters in these shapes also use `RelatableValue` to define point locations by relative values.

Examples:
```swift
CornerRectangle([
    .topLeft: .straight(radius: 60),
    .topRight: .cutout(radius: .relative(0.2)),
    .bottomRight: .rounded(radius: .relative(0.8)),
    .bottomLeft: .concave(radius: .relative(0.2))
])
.fill()

CornerTriangle(
    topPoint: .relative(0.6),
    styles: [
        .top: .straight(radius: 10),
        .bottomRight: .rounded(radius: .relative(0.3)),
        .bottomLeft: .concave(radius: .relative(0.2))
    ]
)
.stroke()
    
CornerPentagon(
    pointHeight: .relative(0.3),
    topTaper: .relative(0.1),
    bottomTaper: .relative(0.3),
    styles: [
        .topRight: .concave(radius: 30),
        .bottomLeft: .straight(radius: .relative(0.3))
    ]
)
.fill()
```


## Notch
Sometimes you want to cut a notch in the side of a shape. This can be tricky to do when the line is at an odd angle but `Notch` makes it easy. A `Notch` has a `NotchStyle`, position, length and depth.

The following code adds a rectangular notch between the second and third corner. The `addingNotch()` function makes all the necessary calculations to add the corners representing that notch into the `Corner` array.

```swift
let notch = Notch(position: .relative(0.5), length: .relative(0.2), depth: .relative(0.1))

let corners = corners.addingNotch(notch, afterCornerIndex: 1)
```

### NotchStyle
Rectangular is the default style but triangular notches are just as easy to make. Both styles can have custom corner styles applied to each corner.

```swift
/// Specify styles for each corner
Notch(.triangle, depth: 20)
    .cornerStyles([.rounded(radius: 10), .point, .straight(radius: 5)])

/// Or specify one style for all
Notch(length: .relative(0.2), depth: 50)
    .defaultCornerStyle(.rounded(radius: .relative(0.2)))
```

### Custom NotchStyle
Notch styles are essentially arrays of `RelativeCorner` so you can create any shape you like.
```swift
Notch(depth: .relative(0.1)) {
    RelativeCorner.topLeft
    RelativeCorner.left
    RelativeCorner.bottom.rounded(radius: 15)
    RelativeCorner.right
    RelativeCorner.topRight
}
```


## Add CornerShape
If you have a more complex shape with curves but still want to add corners you can use the `.addOpenCornerShape()` and `.addClosedCornerShape()` functions added to `Path`.

Both functions accept an array or a trailing `CornerArrayBuilder` closure:

```swift
var path = Path()

path.addOpenCornerShape(
    previousPoint: path.currentPoint,
    nextPoint: rect[.bottomRight]
) {
    rect[.topLeft]
    rect[.top].rounded(radius: 12)
    rect[.right]
}

path.addClosedCornerShape {
    rect[.topLeft]
    rect[.topRight]
    rect[.bottom].rounded(radius: 20)
}
```

## Vector2
A vector type used as an alternative to CGPoint that conforms to all the Vector2 protocols.

## Vector2Representable
A protocol that adds the `vector: Vector2` property. `Vector2`, `CGPoint`, and `Corner` all conform to this and it's required for any other Vector2 protocols.

Properties and methods:
```swift
point: CGPoint
corner(_ style:) -> Corner
corner: Corner
```

Array extensions:
```swift
vectors: [Vector2]
points: [CGPoint]
corners(_ style: CornerStyle?) -> [Corner]
corners(_ styles: [CornerStyle?]) -> [Corner]
corners: [Corner]
bounds: CGRect
angles: [Angle]
```

## Vector2Algebraic
A protocol that adds vector math and adds conformance to `AdditiveArithmetic`. Only applied to `Vector2` by default but can be added to any other `Vector2Representable` type if need be.

Functions include: magnitude, magnitudeSquared, direction, normalized, addition, subtraction, multiplication or division with scalars, cross product, dot product, scalar projection, parallel component and perpendicular component.

## Vector2Transformable
A protocol that adds transformation functions (move, rotate, flip, inset, scale) to any `Vector2Representable` or array of that type. Applied to `Vector2`, `CGPoint`, and `Corner`.


## CGRect
Create a `CGPoint` or `Corner` from a relative anchor position `RectAnchor` of a `CGRect`.
```swift
/// Default will return a CGPoint
let point = rect[.topRight]

/// When a Corner type is required there is an overload that will return a Corner instead
let corners = Corners {
    rect[.topRight]
    rect[1.0, 0.2]
    rect[.bottom].rounded(radius: 20)
}
```

Scale and move `CGRect`
```swift
let transformedRect = rect
    .moved(dx: 40, dy: 2.5)
    .scaled(x: 2, y: 1.5, anchor: .center)
```

## CGSize
Scale
```swift
let scaledSize: CGSize = size.scaled(3)
```

## CGFrame
A coordinate frame defined by an origin and a vector for each axis. Similar to `CGRect` you can use it to convert `RectAnchor` positions within the frame to absolute points and is used internally to draw custom corner styles.

```swift
let frame = CGFrame(origin: .zero, xAxis: Vector2(dx: 10, dy: 0), yAxis: Vector2(dx: 10, dy: 8))
let center: CGPoint = frame[.center]
let edgeMidpoints = [RectAnchor.top, .right, .bottom, .left].points(in: frame)
let relativePoint: CGPoint = frame[1.0, 0.666]
let relativePoints = [
    RectAnchor.relative(x: 0.0, y: 0.7),
    .relative(x: 0.3, y: 1.0),
    .relative(x: 1.0, y: 0.0)
].points(in: frame)
```

```swift
CGFrame(origin: .zero, size: CGSize(width: 10, height: 20), rotation: .degrees(45))
```

## SketchyLine
An animatable line `Shape` with ends that can extend and a position that can offset perpendicular to its direction.

<img width="195" alt="image" src="https://user-images.githubusercontent.com/2143656/157765981-3f48e2bb-50c8-46ba-b2b3-80d7491f1473.png">

```swift
Text("Hello World")
    .alignmentGuide(.bottom) { d in
        // moves bottom alignment to text baseline
        return d[.firstTextBaseline]
    }
    .background(
        SketchyLines(lines: [
            .leading(startExtension: -2, endExtension: 10),
            .bottom(startExtension: 5, endExtension: 5, offset: .relative(0.05))
        ], drawAmount: 1)
            .stroke(Color.red)
        , alignment: .bottom
    )
```

## Emboss or Deboss
Extensions for `InsettableShape` and `View` that create an embossed or debossed effect.

<img width="205" alt="image" src="https://user-images.githubusercontent.com/2143656/157765787-a8bcdee3-fec3-40f8-8414-1c66ca073db6.png">

## AnimatablePack
*\*Xcode 16+, iOS 17+, macOS 14+, watchOS 10+, tvOS 17+*

Animate lots of properties in a `Shape` using `AnimatablePack` instead of nesting `AnimatablePair` types

Here is an example of animatableData using AnimatablePair:
 ```swift
 struct MyShape: Animatable {
     var animatableData: AnimatablePair<CGFloat, AnimatablePair<RelatableValue, Double>> {
         get { AnimatablePair(insetAmount, AnimatablePair(cornerRadius, rotation)) }
         set {
             insetAmount = newValue.first
             cornerRadius = newValue.second.first
             rotation = newValue.second.second
         }
     }
 }
 ```
 You can see how it would get quite large once you start adding more than a few properties.
 Here's how to use AnimatablePack instead:
 ```swift
 struct MyShape: Animatable {
     var animatableData: AnimatablePack<CGFloat, RelatableValue, Double> {
         get { AnimatablePack(insetAmount, cornerRadius, rotation) }
         set { (insetAmount, cornerRadius, rotation) = newValue() }
     }
 }
 ```

## AnimatableArray
Animate an array element by element using `AnimatableArray`. Arrays of `VectorArithmetic` values expose `animatableData`, while arrays of `Animatable` values expose `elementAnimatableData`.

> **Note:** Only changes to existing elements can be animated. Adding or removing elements will not animate.

```swift
struct MyShape: Animatable {
    var corners: [Corner]

    var animatableData: AnimatableArray<Corner.AnimatableData> {
        get { corners.elementAnimatableData }
        set { corners.elementAnimatableData = newValue }
    }
}
```

## AnimatableDictionary
Animate dictionary values by key using `AnimatableDictionary`. Dictionaries of `VectorArithmetic` values expose `animatableData`, while dictionaries of `Animatable` values expose `valueAnimatableData`.

> **Note:** `animatableData` updates existing values, adds incoming keys, and preserves keys omitted from the new data. `valueAnimatableData` only updates matching existing keys, so it does not add or remove keys.

```swift
struct MyShape: Animatable {
    var styles: [CornerRectangle.ShapeCorner: CornerStyle]

    var animatableData: AnimatableDictionary<CornerRectangle.ShapeCorner, CornerStyle.AnimatableData> {
        get { styles.valueAnimatableData }
        set { styles.valueAnimatableData = newValue }
    }
}
```
