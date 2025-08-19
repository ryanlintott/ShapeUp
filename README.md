<img width="456" alt="ShapeUp Logo" src="https://user-images.githubusercontent.com/2143656/157464613-38fd35cc-7802-4cb7-914b-4da480a0411e.png">

[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FShapeUp%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanlintott/ShapeUp)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FShapeUp%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanlintott/ShapeUp)
![License - MIT](https://img.shields.io/github/license/ryanlintott/ShapeUp)
![Version](https://img.shields.io/github/v/tag/ryanlintott/ShapeUp?label=version)
![GitHub last commit](https://img.shields.io/github/last-commit/ryanlintott/ShapeUp)
[![Mastodon](https://img.shields.io/badge/mastodon-@ryanlintott-5c4ee4.svg?style=flat)](http://mastodon.social/@ryanlintott)
[![Twitter](https://img.shields.io/badge/twitter-@ryanlintott-blue.svg?style=flat)](http://twitter.com/ryanlintott)

# Overview
A Swift Package that makes SwiftUI shapes easier to build. (The logo above was created in 100 lines + SwiftUI Text)

Features:
- [`RectAnchor`](#rectanchor), an enum for all major anchor points on a rectangle. Used for transform functions.
- Extensions to [`CGPoint`](#cgpoint), [`CGRect`](#cgrect), and [`CGSize`](#cgsize)
- [`Corner`](#corner), a `CGPoint` with `style`.
- [`CornerStyle`](#cornerstyle) options: `.point`, `.rounded`, `.straight`, `.cutout`, and `.concave`
- Basic shapes like [`CornerRectangle`](#basic-shapes), [`CornerTriangle`](#basic-shapes), and [`CornerPentagon`](#basic-shapes) with stylable corners.
- [`CornerShape`](#cornershape), a protocol for making your own open or closed shapes out of an array of Corners.
- [`CornerCustom`](#cornercustom), for building corner shapes inline without making a new type.
- Add a [`Notch`](#notch) of any `NotchStyle` inbetween two corners.
- [`.addOpenCornerShape()`](#add-cornershape) or [`.addClosedCornerShape()`](#add-cornershape) for adding a few corners to a SwiftUI `Path`
- [`Vector2`](#vector2), a new type similar to `CGPoint` but used to do vector math.
- [`Vector2Representable`](#vector2representable) protocol that adds a `.vector` property needed to conform to other Vector2-related protocols.
- [`Vector2Algebraic`](#vector2algebraic) protocol used to add vector algebra capabilities to `Vector2`
- [`Vector2Transformable`](#vector2transformable) protocol with methods for transforming arrays of points.
- [`RelatableValue`](#relatablevalue), an enum used to store `.relative` or `.absolute` values.
- [`CGFrame`](#cgframe), a coordinate space or rhombus defined by an origin and vectors for each axis
- [`SketchyLine`](#sketchyline), an animatable line `Shape` that aligns to frame edges and can extend beyond the frame.
- [`.emboss()` or `.deboss()`](#emboss-or-deboss) any SwiftUI `Shape` or `View`.
- [`AnimatablePack`](#animatablepack) as an alternative to `AnimatablePair` that takes any number of properties.

# Demo App
The `Example` folder has an app that demonstrates the features of this package.

# Installation and Usage
This package is compatible with iOS 14+, macOS 11+, watchOS 7+, tvOS 14+, and visionOS.

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
## RectAnchor and CGRect
Inside a SwiftUI `Shape` path method, points often have positions relative to the `rect` property.

New subscripts on `CGRect` make it easy to create points at on of 9 anchor locations plus any `.relative` location using the new `RectAnchor` type.

```swift
func path(in rect: CGRect) -> Path {
    // Current method
    let point1 = CGPoint(x: rect.minX, y: rect.minY)
    let point2 = CGPoint(x: rect.minX + (rect.width * 0.4), y: rect.minY + (rect.width * 0.7))
    
    // ShapeUp method
    let point1 = rect[.topLeft]
    let point2 = rect[.relative(0.4, 0.7)]
    
    // or an even shorter version for relative locations
    let point2 = rect[0.4, 0.7]
    ...
}
```

The new `points(_:)` method can transform an array of `RectAnchor` or `(x: CGFloat, y: CGFloat)` into an array of `CGPoint`

```swift
// Current method
let points = [
    CGPoint(x: rect.minX, y: rect.midY),
    CGPoint(x: rect.midX, y: rect.midY),
    CGPoint(x: rect.minX + (rect.width * 0.4), y: rect.minY + (rect.width * 0.7))
]

// ShapeUp method
let points = rect.points(
    .left,
    .center,
    .relative(0.4, 0.7)
)

// Or if you want all relative points
let points = rect.points(
    (0.0, 0.5),
    (0.5, 0.5),
    (0.4, 0.7)
)
```

## CGPoint
`CGPoint` conforms to a new [`Vector2Transformable`](#vector2transformable) protocol so single points or arrays can be moved, rotated, flipped, scaled, or inset.

```swift
points
    .moved(dx: 100, dy: 50)
    .rotated(.degrees(45), anchor: .center)
    .flipped(mirrorLineStart: .topLeft, mirrorLineEnd: .bottomLeft)
    .scaledPositions(2.5, anchor: .bottomRight)
    .insetPoints(5)
```

They can also be converted to [`RectAnchor`](#rectanchor) with positions relative to a `CGRect` or  [`CGFrame`](#cgframe).

```swift
let relativeToRect: [RectAnchor] = points.relative(to: CGRect(...))
let relativeToFrame: [RectAnchor] = points.relative(to: CGFrame(...))
```

## CGRect
`CGRect` can also be moved and scaled.

```swift
rect
    .moved(dx: 40, dy: 2.5)
    .scaled(x: 2, y: 1.5, anchor: .center)
```

## CGSize
`CGSize` can also be scaled or it can be used to quickly create a `CGRect`

```swift
let scaledSize: CGSize = size.scaled(3)
let rect = size.rect(at: point, anchor: .center)
```


## Corner
What if a shape were defined simply by an array of corners with a specified style? This means you can generate a `Path` from this array. By default this path is assumed to be closed with the last point connecting back to the first.

```swift
[
    Corner(x: 0, y: 0).rounded(radius: 10),
    Corner(x: 10, y: 0).cutout(radius: 5),
    Corner(x: 5, y: 10).straight(radius: 5)
].path()
```

## CornerStyle
An enum storing style information for a `Corner`. In all cases, the radius is a [`RelatableValue`](#relatablevalue) that can either be an absolute value or relative to the length of the shortest line from that corner.

<img width="50" alt="Pink triangle with a point corner" src="https://user-images.githubusercontent.com/2143656/157761591-2341d07c-5f0e-4434-ad19-22873f7357d9.svg"> `.point`
A simple point corner with no properties.

<img width="50" alt="Pink triangle with a rounded corner" src="https://user-images.githubusercontent.com/2143656/157762280-630dddf9-4cd4-4779-84e6-43f2f834e6b0.svg"> `.rounded(radius: RelatableValue)`
A rounded corner with a radius.

<img width="50" alt="Pink triangle with a concave cut corner" src="https://user-images.githubusercontent.com/2143656/157762293-ac45ea61-6427-4def-b560-060944ac2c1a.svg"> `.concave(radius: RelatableValue, concaveInset: CGFloat)`
A concave corner where the radius determines the start and end points of the cut. The concave inset value is used to store the corner inset value as this is needed to properly draw inset variations.

<img width="50" alt="Pink triangle with a straight cut corner" src="https://user-images.githubusercontent.com/2143656/157762299-437bcec4-2fc8-475b-bbbb-ed810d86ca7f.svg"> `.straight(radius: RelatableValue, cornerStyles: [CornerStyle] = [])`
A straight chamfer corner where the radius determines the start and end points of the cut. Additional corner styles can be used on the two resulting corners of the chamfer. (You can continue nesting recursively.)

<img width="50" alt="Pink triangle with a cutout corner" src="https://user-images.githubusercontent.com/2143656/157762313-c4015f99-7c53-4571-93b5-a8b476c9f5da.svg"> `.cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = [])`
A cutout corner where the radius determines the start and end points of the cut. Additional corner styles can be used on the three resulting corners of the cut. (Again, you can continue nesting recursively.)

A custom corner uses the radius to determine the top left and bottom right corners of a rhombus in which you can add any number of relative corners to draw your shape.


## Basic Shapes
`CornerRectangle`, `CornerTriangle`, and `CornerPentagon` are pre-built shapes where you can customize the style of any corner.

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

## CornerShape
A protocol for creating shapes built from an array of `Corner`s. The path and inset functions needed to conform to SwiftUI `InsettableShape` are already implemented.

### How to build a CornerShape
- Set `insetAmount` to zero (this property will is used to automatically inset the CornerShape).
- Set the `closed` property to define if your shape should be closed or left open.
- Write a function that returns an array of corners.

```swift
struct MyCornerShape: CornerShape {
    var insetAmount: CGFloat = .zero
    var closed = true
   
    func corners(in rect: CGRect) -> [Corner] {
        [
            rect[.bottomLeft].rounded(radius: 5),
            rect[.topLeft].rounded(radius: 5)
            rect[.topRight].corner(.rounded(radius: 5),
            rect[.bottomRight].corner(.rounded(radius: 5)
        ]
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


## RelativeCornerShape
The easiest way to create your own shape out of Corners is to use RelativeCornerShape. This shape takes an array of `RelativeCorner`. This type is very similar to `Corner` except it's position information is always relative to the bound of the shape.

```swift
RelativeCornerShape(
    RelativeCorner(anchor: .bottomLeft),
    RelativeCorner(anchor: .top, .rounded(radius: 20)),
    RelativeCorner(anchor: .bottomRight),
    RelativeCorner(anchor: .relative(0.5, 0.7), .straight(radius: 10))
)
.fill()

/// Shorter method
RelativeCornerShape(
    .bottomLeft,
    .top.rounded(radius: 20),
    .bottomRight,
    .relative(0.5, 0.7).straight(radius: 10)
)
.fill()
```




## CornerCustom
Sometimes you might want to make a shape inline without defining a new struct. `CornerCustom` is a `CornerShape` that takes a closure that returns an array of `Corner`s. The closure itself needs to be `Sendable` so that it can be used to generate a path for a SwiftUI `Shape`.

```swift
CornerCustom { rect in
    [
        Corner(x: rect.midX, y: rect.minY),
        Corner(.rounded(radius: 10), x: rect.maxX, y: rect.maxY),
        Corner(.rounded(radius: 10), x: rect.minX, y: rect.maxY)
    ]
}
.strokeBorder(lineWidth: 5)
```

## Notch
Sometimes you want to cut a notch in the side of a shape. This can be tricky to do when the line is at an odd angle but `Notch` makes it easy. A `Notch` has a `NotchStyle`, position, length and depth.

The following code adds a rectangular notch between the second and third corner. The `addingNotch()` function makes all the necessary calculations to add the corners representing that notch into the `Corner` array.

```swift
let notch = Notch(.rectangle, position: .relative(0.5), length: .relative(0.2), depth: .relative(0.1))

let corners = corners.addingNotch(notch, afterCornerIndex: 1)
```

### NotchStyle
Notches styles are essentially arrays of `RelativeCorner` so you can create any shape you like.

```swift
let notchStyle = NotchStyle(relativeCorners: [
    RelativeCorner(anchorPoint: .topLeft),
    RelativeCorner(anchorPoint: .left),
    RelativeCorner(.rounded(radius: 15), anchorPoint: .bottom),
    RelativeCorner(anchorPoint: .right),
    RelativeCorner(anchorPoint: .topRight)
])
```

Or you can quickly create triangular or rectangular notches with custom corner styles.
```swift
/// Specify styles for each corner
let triangleStyle: NotchStyle = .triangle(cornerStyles: [.rounded(radius: 10), .point, .straight(radius: 5)])
/// Or specify one style for all
let rectangleStyle: NotchStyle = .rectangle(cornerStyle: .rounded(radius: .relative(0.2))
```

## Add CornerShape
Shapes made completely with corners have their limitations. Only straight lines and arcs are possible. If you want to use corners to draw only a portion of your shape you can do that too with `.addOpenCornerShape()` and `.addClosedCornerShape()` functions added to `Path`

## Vector2
A vector type used as an alternative to CGPoint that conforms to all the Vector2 protocols.

## Vector2Representable
A protocol that adds the `vector: Vector2` property. `Vector2`, `CGPoint`, and `Corner` all conform to this and it's required for any other Vector2 protocols.

Other properties and methods:
```swift
point: CGPoint
corner(_ style:) -> Corner
```

Array extensions:
```swift
points: [CGPoint]
vectors: [Vector2]
corners(_ style: CornerStyle?) -> [Corner]
corners(_ styles: [CornerStyle?]) -> [Corner]
bounds: CGRect
center: CGPoint
anchorPoint(_ anchor: RectAnchor) -> CGPoint
angles: [Angle]
```

## Vector2Algebraic
A protocol that adds vector math. Only applied to `Vector2` by default but can be added to any other `Vector2Representable` if need be.

Functions include: magnitude, direction, normalized, addition, subtraction, and multiplication or division with scalars.

## Vector2Transformable
A protocol that adds transformation functions (move, rotate, flip, inset) to any `Vector2Representable` or array of that type. Applied to `Vector2`, `CGPoint`, and `Corner`.

## RelatableValue
A handy enum that represents either a relative or absolute value. This is used in lots of situations throughout ShapeUp to give flexibility when defining parameters.

When setting a corner radius you might want a fixed value like 20 or you might want a value that's 20% of the maximum so that it will scale proportionally. `RelatableValue` gives you both of those options.
```swift
let absolute = RelatableValue.absolute(20)
let relative = RelatableValue.relative(0.2)
```

Later, the value is determined by running the `value(using total:)` function. Absolute values will always be the same but any relative values will be calculated. In the case of a corner radius, the total would be the maximum radius that would fit that corner given the length of the two lines and the angle of the corner.
```swift
let radius = relatableRadius.value(using: maxRadius)
```

For ease of use, `RelatableValue` conforms to `ExpressibleByIntegerLiteral` and `ExpressibleByFloatLiteral`. This means in many cases you can omit `.absolute()` when writing absolute values.
```swift
// Both are the same
let cornerStyle = .rounded(radius: .absolute(5))
let cornerStyle = .rounded(radius: 5)
```

## CGFrame
For more complex transformations a coordinate space or rhombus defined only by an origin and a vector for each axis can be helpful. This allows for flexible relative positioning and transformations of points to non-rectilinear coordinate systems. Specifically this is used to draw custom cornerStyles

Similar to `CGRect` you can easily create points, anchor points or arrays of either.

```swift
let frame = CGFrame(origin: .zero, xAxis: Vector2(dx: 10, dy: 0), yAxis: Vector2(dx: 10, dy: 8))
let center: CGPoint = frame[.center]
let edgeMidpoints: [CGPoint] = frame[.top, .right, .bottom, .left]
let relativePoint: [CGPoint] = frame[1.0, 0.666]
let relativePoints: [CGPoint] = frame[(0.0, 0.7), (0.3, 1.0), (1.0, 0.0))
let anchorPoint: RectAnchor = frame[CGPoint(x: 15, y: 4)]
let anchorPoints: [RectAnchor] = rect[relativePoints]
```

```swift
CGFrame(origin: .zero, size: CGSize(width: 10, height: 20), anchor: .center, rotation: .degrees(45))
```

## SketchyLine
A animatable line Shape with ends that can extend and a position that can offset perpendicular to its direction.

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
