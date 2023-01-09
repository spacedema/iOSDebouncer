//
//  debouncerTests.swift
//  debouncerTests
//
//  Created by sfilippov on 09.01.2023.
//

import XCTest
@testable import debouncer

final class debouncerTests: XCTestCase {

    func testDebouncer() async throws {
        let expectation = expectation(description: "Ensure last task fired")
        let debouncer = Debouncer(timeIntervat: 1)
        var value = ""

        var fulfillmentCount = 0
        expectation.expectedFulfillmentCount = 2

        func accumulateAndSendToServer(_ input: String) async {
            value += input
            await debouncer.debounce { [value] in
                switch fulfillmentCount {
                case 0:
                    XCTAssertEqual(value, "hello")
                case 1:
                    XCTAssertEqual(value, "hello, world")
                default:
                    XCTFail()
                }

                expectation.fulfill()
                fulfillmentCount += 1
            }
        }

        // When
        await accumulateAndSendToServer("h")
        await accumulateAndSendToServer("e")
        await accumulateAndSendToServer("l")
        await accumulateAndSendToServer("l")
        await accumulateAndSendToServer("o")

        try await Task.sleep(seconds: 2)

        await accumulateAndSendToServer(",")
        await accumulateAndSendToServer(" ")
        await accumulateAndSendToServer("w")
        await accumulateAndSendToServer("o")
        await accumulateAndSendToServer("r")
        await accumulateAndSendToServer("l")
        await accumulateAndSendToServer("d")

        try await Task.sleep(seconds: 2)

        wait(for: [expectation], timeout: 10)
    }

    func testThrottler() async throws {
        let expectation = expectation(description: "Ensure first task fired")
        let throttler = Throttler(timeIntervat: 1)

        var fulfillmentCount = 0
        expectation.expectedFulfillmentCount = 2
        var value = ""

        func accumulateAndSendToServer(_ input: String) async {
            value += input

            await throttler.throttle { [value] in
                // Then
                switch fulfillmentCount {
                case 0:
                    XCTAssertEqual(value, "h")
                case 1:
                    XCTAssertEqual(value, "hello,")
                default:
                    XCTFail()
                }

                expectation.fulfill()
                fulfillmentCount += 1
            }
        }

        // When
        await accumulateAndSendToServer("h")
        await accumulateAndSendToServer("e")
        await accumulateAndSendToServer("l")
        await accumulateAndSendToServer("l")
        await accumulateAndSendToServer("o")

        try await Task.sleep(seconds: 2)

        await accumulateAndSendToServer(",")
        await accumulateAndSendToServer(" ")
        await accumulateAndSendToServer("w")
        await accumulateAndSendToServer("o")
        await accumulateAndSendToServer("r")
        await accumulateAndSendToServer("l")
        await accumulateAndSendToServer("d")

        try await Task.sleep(seconds: 2)

        wait(for: [expectation], timeout: 10)
    }
}
