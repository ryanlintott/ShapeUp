//
//  Vector2AlgebraicTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-04.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class Vector2AlgebraicTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    fileprivate struct V2ATest: Vector2Algebraic {
        static var zero = Self(vector: .zero)
        
        var vector: Vector2
    }
    
    func testVector2AlgebraicConformsToVector2Representable() throws {
        // given
        let testVectors: [Vector2] = [
            (0.0,0.0),
            (0,1),
            (1,0),
            (1,1),
            (-1,2),
            (2,-1),
            (1.2345,9.1234)
        ].map { Vector2(dx: $0.0, dy: $0.1) }
        
        testVectors.forEach { vector in
            // when
            let v2a = V2ATest(vector: vector)
            
            // then
            XCTAssertTrue((v2a as Any) is Vector2Representable)
        }
    }
    
    func testUnitVectorCoordinates() throws {
        // given
        let testUnitVectors: [(Angle, Vector2)] = [
            (0.0, 1.0, 0.0),
            (45, 0.70710678118, 0.70710678118),
            (90, 0, 1),
            (180, -1, 0),
            (270, 0, -1),
            (360, 1, 0),
            (450, 0, 1),
            (-45, 0.70710678118, -0.70710678118),
            (-90, 0, -1),
            (-180, -1, 0),
            (-270, 0, 1),
            (-360, 1, 0),
            (-450, 0, -1)
        ].map { (Angle.degrees($0), Vector2(dx: $1, dy: $2)) }
        
        testUnitVectors.forEach { angle, result in
            // when
            let unitVector = V2ATest.unitVector(direction: angle).vector
            
            // then
            XCTAssertEqual(unitVector.dx, result.dx, accuracy: 0.00001)
            XCTAssertEqual(unitVector.dy, result.dy, accuracy: 0.00001)
        }
    }
    
    func testUnitVectorMagnitudeIsOne() throws {
        // given
        let testAngles: [Angle] = [
            0.0,
            1,
            30,
            170,
            280,
            400,
            -1,
            -40,
            -170,
            -290,
            -400
        ].map { Angle.degrees($0) }
        
        testAngles.forEach { angle in
            // when
            let magnitude = V2ATest.unitVector(direction: angle).magnitude
            
            // then
            XCTAssertEqual(magnitude, 1.0, accuracy: 0.00001)
        }
    }

    func testVectorNegation() throws {
        // given
        let testVectors: [Vector2] = [
            (0.0,0.0),
            (0,1),
            (1,0),
            (1,1),
            (-1,2),
            (2,-1),
            (1.2345,9.1234)
        ].map { Vector2(dx: $0.0, dy: $0.1) }
        
        testVectors.forEach { vector in
            // when
            let v2a = V2ATest(vector: vector)
            let negatedVector = Vector2(dx: -vector.dx, dy: -vector.dy)
            let negatedV2A = V2ATest(vector: negatedVector)
            
            // then
            XCTAssertEqual(-v2a, negatedV2A)
        }
    }

    func testVectorDirectionMatchesAngle() throws {
        // given
        let testVectorDirections: [(Vector2, Angle)] = [
            (Vector2(dx: 2, dy: 0), .degrees(0)),
            (Vector2(dx: 2, dy: 2), .degrees(45)),
            (Vector2(dx: 0, dy: 2), .degrees(90)),
            (Vector2(dx: -2, dy: 0), .degrees(180)),
            (Vector2(dx: 0, dy: -2), .degrees(270)),
            (Vector2(dx: 2, dy: -2), .degrees(315))
        ]
        
        testVectorDirections.forEach { (vector, angle) in
            guard let direction = V2ATest(vector: vector).direction else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(direction.radians, angle.radians, accuracy: 0.000000001)
        }
    }
    
    func testNormalizeZeroVectorIsZeroVector() throws {
        // given
        let zeroVector = Vector2.zero
        
        // when
        let normalized = V2ATest(vector: zeroVector).normalized.vector
        
        // then
        XCTAssertEqual(normalized, zeroVector)
    }
    
    func testNormalizeVectorMagnitudeIsOne() throws {
        // given
        let testVectors: [Vector2] = [
            (0,1),
            (1,0),
            (24,36),
            (-2,4),
            (2,-6),
            (-1.2345,-9.1234)
        ].map { Vector2(dx: $0.0, dy: $0.1) }
        
        testVectors.forEach { vector in
            // when
            let magnitude = V2ATest(vector: vector).normalized.magnitude
            
            // then
            XCTAssertEqual(magnitude, 1.0, accuracy: 0.0000001)
        }
    }
}
