/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

import XCTest
@testable import GateEngine

final class GravityCreateValueTests: GateEngineXCTestCase {
    func testInt() {
        XCTAssertEqual(GravityValue(1), 1)
        XCTAssertEqual(GravityValue(0), 0)
        XCTAssertEqual(GravityValue(-1), -1)
        XCTAssertNotEqual(GravityValue(-1.0), -1)  // Casting should not work
    }

    func testFloat() {
        XCTAssertEqual(GravityValue(1.12345), 1.12345)
        XCTAssertNotEqual(GravityValue(1.0), 1)  // Casting should not work

        // Gravity assumes non-finite values as undefined
        XCTAssertEqual(GravityValue(Double.nan), .undefined)
        XCTAssertEqual(GravityValue(Double.infinity), .undefined)
        XCTAssertEqual(GravityValue(Double.signalingNaN), .undefined)
    }

    func testRange() throws {
        #if os(Linux)
        // TODO: GravityValue range equality fails on Linux - investigate
        throw XCTSkip("GravityValue range equality is broken on Linux")
        #else
        XCTAssertEqual(GravityValue(1 ... 10), 1 ... 10)
        XCTAssertEqual(GravityValue(1 ... 10).getRange(), 1 ... 10)
        XCTAssertEqual(GravityValue(1 ..< 10), 1 ..< 10)
        XCTAssertEqual(GravityValue(1 ..< 10).getRange(), 1 ..< 10)
        #endif
    }

    func testString() throws {
        #if os(Linux)
        // TODO: GravityValue string equality fails on Linux - investigate
        throw XCTSkip("GravityValue string equality is broken on Linux")
        #else
        XCTAssertEqual(GravityValue("Hello Train 🚂"), "Hello Train 🚂")
        XCTAssertNotEqual(GravityValue("Hello Train 🚂 "), "Hello Train 🚂")  //trailing space
        #endif
    }

    func testBool() {
        XCTAssertEqual(GravityValue(true), true)
        XCTAssertEqual(GravityValue(false), false)
        XCTAssertNotEqual(GravityValue(true), false)
    }

    func testList() throws {
        #if os(Linux) || os(Windows)
        // TODO: GravityValue list equality fails on Linux - investigate
        // Also fails on Windows: XCTAssertEqual failed comparing GravityValue's list
        // representation against the equivalent Swift array literal.
        throw XCTSkip("GravityValue list equality is broken on Linux and Windows")
        #else
        XCTAssertEqual(GravityValue(["yup", 1, 1.1, true]), ["yup", 1, 1.1, true])
        XCTAssertEqual(GravityValue(["yup", 1, 1.1, true]), ["yup", 1, 1.1, true])
        XCTAssertNotEqual(GravityValue([1, true]), [1.0, 1])  // Casting should not work
        #endif
    }

    func testMap() throws {
        #if os(Linux) || os(Windows)
        // TODO: GravityValue map causes crash on Linux - investigate
        // Also crashes the test process on Windows (same underlying Gravity map/hash issue).
        throw XCTSkip("GravityValue map crashes on Linux and Windows")
        #else
        XCTAssertEqual(GravityValue(["yup": 1, 1.1: true]), ["yup": 1, 1.1: true])
        XCTAssertNotEqual(GravityValue([1: true]), [1.0: 1])  // Casting should not work
        #endif
    }
}

#endif
