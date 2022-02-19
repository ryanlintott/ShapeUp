//
//  AngleTypeTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-12.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class AngleTypeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAngleTypeIsComparableAndInOrder() throws {
        // given
        let angleTypes = AngleType.allCases
        
        // when
        let sorted = angleTypes.shuffled().sorted()
        
        // then
        XCTAssertEqual(angleTypes, sorted)
    }
    
    static let angleTypeTestValues: [(Angle, AngleType)] = [
        (0.0, AngleType.zero),
        (45, .acute),
        (-45, .acute),
        (90, .rightAngle),
        (-90, .rightAngle),
        (100, .obtuse),
        (-100, .obtuse),
        (180, .straight),
        (-180, .straight),
        (350, .reflex),
        (-350, .reflex),
        (360, .fullRotation),
        (-360, .fullRotation),
        (370, .over360),
        (-370, .over360)
    ].map { (.degrees($0.0), $0.1) }
    
    func testTypeOfAngle() throws {
        // given
        let testValues = Self.angleTypeTestValues
        
        testValues.forEach { (angle, resultType) in
            // when
            let type = AngleType.type(of: angle)
            
            // then
            XCTAssertEqual(type, resultType)
        }
    }
    
    func testInitFromDegrees() throws {
        // given
        let testValues = Self.angleTypeTestValues
        
        testValues.forEach { (angle, resultType) in
            // when
            let type = AngleType(degrees: angle.degrees)
            
            // then
            XCTAssertEqual(type, resultType)
        }
    }
    
    func testInitFromRadians() throws {
        // given
        let testValues = Self.angleTypeTestValues
        
        testValues.forEach { (angle, resultType) in
            // when
            let type = AngleType(radians: angle.radians)
            
            // then
            XCTAssertEqual(type, resultType)
        }
    }
}
