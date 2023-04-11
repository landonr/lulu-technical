//
//  lulutechnicalTests.swift
//  lulutechnicalTests
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import XCTest
@testable import lulutechnical

final class lulutechnicalTests: XCTestCase {

    let userDefaultsSuiteName = "TestDefaults"

    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: userDefaultsSuiteName)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShort() async throws {
        let viewModel = ViewModel()

        do {
            _ = try await viewModel.add("1")
        } catch {
            XCTAssertEqual(error as! ItemVerificationError, ItemVerificationError.tooShort)
        }
    }
    
    func testLong() async throws {
        let viewModel = ViewModel()

        do {
            _ = try await viewModel.add("123456789012345678900")
        } catch {
            XCTAssertEqual(error as! ItemVerificationError, ItemVerificationError.tooLong)
        }
    }
    
    func testDuplicate() async throws {
        let viewModel = ViewModel()
        
        do {
            let _ = try await viewModel.add("123")
            let _ = try await viewModel.add("123")
        } catch {
            XCTAssertEqual(error as! ItemVerificationError, ItemVerificationError.duplicate)
        }
    }
    
    func testSuccess() async throws {
        let viewModel = ViewModel()
        
        do {
            let result = try await viewModel.add("12345678901234567890")
            XCTAssertNotNil(result)
        } catch {
            XCTAssertNil(error)
        }
    }
}
