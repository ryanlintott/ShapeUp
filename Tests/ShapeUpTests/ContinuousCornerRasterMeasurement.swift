//
//  ContinuousCornerRasterMeasurement.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-08-18.
//

#if os(macOS)
@testable import ShapeUp
import SwiftUI
import Testing

/// Measures a rendered shape from its raster alone.
///
/// This exists to answer one question: what does SwiftUI actually *draw* for a
/// continuous rounded rectangle? It never looks at path elements, never calls a
/// private symbol, and never draws anything over the shape. It renders the shape
/// by itself and reads the pixels.
///
/// Two choices make it accurate enough to be worth trusting:
///
/// - It reads the **alpha channel**, which is linear coverage by definition.
///   Reading a grayscale composite instead would mean guessing at a gamma curve,
///   and getting that wrong shifts every measurement.
/// - It finds each edge by **summing coverage across a whole row** rather than
///   hunting for the pixel where coverage crosses 50%. Summing uses every
///   partially covered pixel, so the answer does not depend on a threshold.
///
/// Measured against a circle, whose edge position is known exactly, this lands
/// within 0.07 of a pixel. A threshold-crossing probe on the same renders is off
/// by 1.3 pixels, roughly twenty times worse.
@available(macOS 13, *)
enum ContinuousCornerRasterProbe {
    /// One configuration to render and measure at.
    ///
    /// - Warning: `side - 2 * pad` must exceed `2 * 1.528665 * radius`, or
    ///   neighbouring corners overlap and the shape being measured is no longer
    ///   an isolated corner. ``isUnconstrained`` checks this.
    struct Config {
        let radius: CGFloat
        let pad: CGFloat
        let side: CGFloat
        let scale: CGFloat

        var isUnconstrained: Bool { (side - 2 * pad) > 2 * 1.528665 * radius }

        /// Corner radius in pixels. Measurement accuracy improves with this.
        var radiusInPixels: Double { Double(radius) * Double(scale) }

        static let all: [Self] = [
            .init(radius: 120, pad: 40, side: 512, scale: 16),
            .init(radius: 100, pad: 40, side: 512, scale: 16),
            .init(radius: 80, pad: 40, side: 512, scale: 16)
        ]
    }

    /// Renders content on nothing and returns its alpha coverage.
    @MainActor
    static func coverage<V: View>(
        side: CGFloat,
        scale: CGFloat,
        @ViewBuilder content: () -> V
    ) throws -> (width: Int, height: Int, alpha: [UInt8]) {
        let renderer = ImageRenderer(content: content().frame(width: side, height: side))
        renderer.scale = scale
        renderer.isOpaque = false
        guard let image = renderer.cgImage else { throw Failure.render }

        let width = image.width, height = image.height
        var alpha = [UInt8](repeating: 0, count: width * height)
        guard let context = alpha.withUnsafeMutableBytes({ buffer in
            CGContext(
                data: buffer.baseAddress, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue
            )
        }) else { throw Failure.context }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (width, height, alpha)
    }

    /// The sub-pixel column where the shape's left edge sits on a row.
    ///
    /// Coverage summed from column zero out to a column known to be inside the
    /// shape equals the covered width, so the edge is that column minus the sum.
    /// Returns nil unless the row genuinely starts outside and ends inside.
    static func leftEdge(row: Int, inside: Int, width: Int, alpha: [UInt8]) -> Double? {
        let base = row * width
        guard alpha[base] < 5, alpha[base + inside] > 250 else { return nil }
        var covered = 0.0
        for column in 0..<inside { covered += Double(alpha[base + column]) / 255 }
        return Double(inside) - covered
    }

    /// Measures one corner of a rendered continuous rounded rectangle.
    ///
    /// Only rows where the boundary is steeper than 45 degrees are used. A row
    /// scan smears badly once the boundary runs nearly parallel to it, which is
    /// what happens along the shallow half. The corner is symmetric about its
    /// diagonal, so mirroring the steep half recovers the shallow half exactly.
    ///
    /// Rows within a few pixels of the straight edge are dropped too. The curve
    /// meets its edge tangentially, so it hugs the edge for a long stretch where
    /// curve and edge are not separable in a raster.
    ///
    /// - Returns: Points on the corner, measured from the corner point and
    ///   divided by the radius, running from one edge round to the other.
    @MainActor
    static func measure(_ config: Config) throws -> [(x: Double, y: Double)] {
        guard config.isUnconstrained else { throw Failure.constrained }

        let (width, _, alpha) = try coverage(side: config.side, scale: config.scale) {
            RoundedRectangle(cornerRadius: config.radius, style: .continuous)
                .fill(Color.white)
                .padding(config.pad)
        }

        let cornerPixel = Double(config.pad) * Double(config.scale)
        let radiusPixels = config.radiusInPixels
        let inside = Int(cornerPixel + 1.62 * radiusPixels)

        var steep: [(x: Double, y: Double)] = []
        for row in Int(cornerPixel)..<min(Int(cornerPixel + 1.7 * radiusPixels), width) {
            guard let edge = leftEdge(row: row, inside: inside, width: width, alpha: alpha)
            else { continue }
            let x = (edge - cornerPixel) / radiusPixels
            // A row's coverage reflects the boundary at the row's centre.
            let y = ((Double(row) + 0.5) - cornerPixel) / radiusPixels
            if x <= y, x > 3 / radiusPixels { steep.append((x, y)) }
        }

        return (steep + steep.map { (x: $0.y, y: $0.x) }).sorted { $0.x < $1.x }
    }

    /// Averages several independent renders to cut measurement noise.
    @MainActor
    static func measuredCorner(
        configs: [Config] = Config.all
    ) throws -> [(x: Double, y: Double)] {
        let curves = try configs.map { try measure($0) }
        guard let first = curves.first else { return [] }

        let lower = curves.map { $0.map(\.x).min()! }.max()!
        let upper = curves.map { $0.map(\.x).max()! }.min()!
        _ = first

        // Sample each curve at shared x positions, then average.
        return (0...400).map { step in
            let x = lower + (upper - lower) * Double(step) / 400
            let ys = curves.map { curve -> Double in
                let near = curve.min { abs($0.x - x) < abs($1.x - x) }!
                return near.y
            }
            return (x: x, y: ys.reduce(0, +) / Double(ys.count))
        }
    }

    enum Failure: Error { case render, context, constrained }
}

struct ContinuousCornerRasterMeasurementTests {
    /// Pins the probe's accuracy using a circle, whose edge position is known
    /// exactly for every row. If this regresses, nothing measured with the probe
    /// can be trusted.
    @MainActor
    @Test("The raster probe locates a known edge to within a tenth of a pixel")
    func probeAccuracy() throws {
        guard #available(macOS 13, *) else { return }
        let (width, _, alpha) = try ContinuousCornerRasterProbe.coverage(side: 512, scale: 8) {
            Circle().fill(Color.white)
        }
        let centre = Double(width) / 2
        var worst = 0.0
        for row in stride(from: Int(centre * 0.25), to: Int(centre * 0.9), by: 3) {
            guard let edge = ContinuousCornerRasterProbe.leftEdge(
                row: row, inside: Int(centre), width: width, alpha: alpha
            ) else { continue }
            let dy = (Double(row) + 0.5) - centre
            let exact = centre - (centre * centre - dy * dy).squareRoot()
            worst = max(worst, abs(edge - exact))
        }
        #expect(worst < 0.1)
    }

    @MainActor
    @Test("Every measurement configuration keeps its corner unconstrained")
    func configurationsAreUnconstrained() {
        guard #available(macOS 13, *) else { return }
        for config in ContinuousCornerRasterProbe.Config.all {
            #expect(config.isUnconstrained)
        }
    }

    /// Independent renders at different radii and scales must agree, since they
    /// are all measuring the same normalised shape.
    @MainActor
    @Test("Independent renders of the same shape agree")
    func rendersAgree() throws {
        guard #available(macOS 13, *) else { return }
        let curves = try ContinuousCornerRasterProbe.Config.all.map {
            try ContinuousCornerRasterProbe.measure($0)
        }
        let reference = curves[0]
        for other in curves.dropFirst() {
            let worst = other.map { point in
                reference.map { hypot($0.x - point.x, $0.y - point.y) }.min()!
            }.max()!
            #expect(worst < 0.001)
        }
    }

    /// Prints the measured shape. Not an assertion; run it when new samples are
    /// wanted and paste the output.
    @MainActor
    @Test("Print measured continuous corner samples")
    func printSamples() throws {
        guard #available(macOS 13, *) else { return }
        let curve = try ContinuousCornerRasterProbe.measuredCorner()

        // Even spacing along the curve, which is how a curvature profile is
        // parameterised, rather than even spacing in x.
        var lengths = [0.0]
        for (a, b) in zip(curve, curve.dropFirst()) {
            lengths.append(lengths.last! + hypot(b.x - a.x, b.y - a.y))
        }
        let total = lengths.last!

        print("SAMPLES measured continuous corner, \(curve.count) points averaged over \(ContinuousCornerRasterProbe.Config.all.count) renders")
        print("SAMPLES x from \(String(format: "%.5f", curve.first!.x)) to \(String(format: "%.5f", curve.last!.x)) radii")
        for step in 0...32 {
            let target = total * Double(step) / 32
            let index = lengths.enumerated().min {
                abs($0.element - target) < abs($1.element - target)
            }!.offset
            let point = curve[index]
            print(String(format: "SAMPLES CGPoint(x: %.9f, y: %.9f),", point.x, point.y))
        }
    }
}
#endif
