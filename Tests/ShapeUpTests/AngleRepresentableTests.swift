//
//  AngleRepresentableTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-02.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class AngleRepresentableTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAngleType() throws {
        let angleTests: [Angle] = [0,45,90,100,180,200,360,370].map { .degrees($0) }
        angleTests.forEach { angle in
            XCTAssertEqual(angle.type, AngleType.type(of: angle))
        }
    }
    
    func testPositive() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (0.0, 0.0),
            (45, 45),
            (-45, 45),
            (90, 90),
            (-90, 90),
            (180, 180),
            (-180, 180),
            (350, 350),
            (-350, 350),
            (360, 360),
            (-360, 360)
        ].map { (.degrees($0.0),.degrees($0.1)) }
        
        // then
        testValues.forEach { (angle, resultAngle) in
            XCTAssertEqual(angle.positive.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testHalved() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (0.0, 0.0),
            (45, 22.5),
            (-45, -22.5),
            (90, 45),
            (-90, -45),
            (180, 90),
            (-180, -90),
            (350, 175),
            (-350, -175),
            (360, 180),
            (-360, -180)
        ].map { (.degrees($0.0),.degrees($0.1)) }
        
        // then
        testValues.forEach { (angle, resultAngle) in
            XCTAssertEqual(angle.halved.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testComplementary() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (0.0, 90.0),
            (45, 45),
            (-45, 135),
            (90, 0),
            (100, -10)
        ].map { (Angle.degrees($0.0),Angle.degrees($0.1)) }
        
        testValues.forEach { (angle, resultAngle) in
            // when
            let testAngle = angle.complementary
            
            //then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testSupplementary() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (0.0, 180.0),
            (90, 90),
            (-45, 225),
            (180, 0),
            (190, -10)
        ].map { (.degrees($0.0),.degrees($0.1)) }
        
        testValues.forEach { (angle, resultAngle) in
            // when
            let testAngle = angle.supplementary
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testExplementary() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (0.0, 360.0),
            (90, 270),
            (-45, 405),
            (360, 0),
            (370, -10)
        ].map { (.degrees($0.0),.degrees($0.1)) }
        
        testValues.forEach { (angle, resultAngle) in
            // when
            let testAngle = angle.explementary
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testMinPositiveCoterminal() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (0.0, 0.0),
            (0.0001, 0.0001),
            (20, 20),
            (359.99999, 359.99999),
            (0.0 + 360, 0),
            (10.0 + 360, 10),
            (350.0 - 360, 350),
            (45.0 - 360 - 360, 45)
        ].map { (.degrees($0.0), .degrees($0.1)) }
        
        testValues.forEach { (angle, resultAngle) in
            // when
            let testAngle = angle.minPositiveCoterminal
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testMinRotation() throws {
        // given
        let testValues: [(Angle, Angle, Angle)] = [
            (10.0, 0.0, 10.0),
            (0.0001, 0.0, 0.0001),
            (-10, 0, -10),
            (179, 0, 179),
            (0, -10, 10),
            (0, -179, 179),
            (271, 90, -179),
            (181, 179, 2),
            (179, 181, -2),
            (361, 0, 1),
            (0, 361, -1),
            (-361, 0, -1),
            (0, -361, 1)
        ].map { (.degrees($0.0), .degrees($0.1), .degrees($0.2)) }
        
        testValues.forEach { (angle, fromAngle, resultAngle) in
            // when
            let testAngle = angle.minRotation(from: fromAngle)
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testMaxRotation() throws {
        // given
        let testValues: [(Angle, Angle, Angle)] = [
            (10.0, 0.0, -350.0),
            (0.0001, 0.0, -359.9999),
            (-10, 0, 350),
            (179, 0, -181),
            (0, -350, 350),
            (0, -179, -181),
            (271, 90, 181),
            (181, 179, -358),
            (179, 181, 358),
            (361, 0, -359),
            (0, 361, 359),
            (-361, 0, 359),
            (0, -361, -359)
        ].map { (.degrees($0.0), .degrees($0.1), .degrees($0.2)) }
        
        testValues.forEach { (angle, fromAngle, resultAngle) in
            // when
            let testAngle = angle.maxRotation(from: fromAngle)
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testReflexCoterminal() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (10.0, -350.0),
            (0.0001, -359.9999),
            (-10, 350),
            (181, 181),
            (-270, -270),
            (179, -181),
            (361, -359),
            (-361, 359),
            (719, 359)
        ].map { (.degrees($0.0), .degrees($0.1)) }
        
        testValues.forEach { (angle, resultAngle) in
            // when
            let testAngle = angle.reflexCoterminal
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testNonReflexCoterminal() throws {
        // given
        let testValues: [(Angle, Angle)] = [
            (10.0, 10.0),
            (0.0001, 0.0001),
            (-10, -10),
            (181, -179),
            (-270, 90),
            (179, 179),
            (361, 1),
            (-361, -1),
            (719, -1)
        ].map { (.degrees($0.0), .degrees($0.1)) }
        
        testValues.forEach { (angle, resultAngle) in
            // when
            let testAngle = angle.nonReflexCoterminal
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
    
    func testThreePointClockwiseAngleIsMatchingTests() throws {
        // Remember: Screen space coordinates are...
        // -X = Left
        // +X = Right
        // -Y = Up
        // +Y = Down
        let testValues: [(Angle, Vector2, Vector2, Vector2)] = [
            (0.0, (0.0,0.0), (0.0,0.0), (0.0,0.0)),
            (0, (1,0), (0,0), (2,0)),
            (0, (2,2), (1,1), (3,3)),
            (45, (1,0), (0,0), (1,1)),
            (45, (2,2), (1,1), (1,2)),
            (90, (1,0), (0,0), (0,1)),
            (90, (1,1), (0,0), (-1,1)),
            (180, (1,0), (0,0), (-1,0)),
            (180, (1,1), (1,0), (1,-1)),
            (270, (0,1), (0,0), (1,0)),
            (270, (-1,0), (0,0), (0,1)),
            (315, (1,1), (0,0), (1,0))
        ].map { (degrees, start, corner, end) in
            (Angle.degrees(degrees), Vector2(dx: start.0, dy: start.1), Vector2(dx: corner.0, dy: corner.1), Vector2(dx: end.0, dy: end.1))
        }
        
        testValues.forEach { (resultAngle, start, corner, end) in
            // when
            let testAngle = Angle.threePoint(start, corner, end)
            
            // then
            XCTAssertEqual(testAngle.radians, resultAngle.radians, accuracy: 0.000001)
        }
    }
}
