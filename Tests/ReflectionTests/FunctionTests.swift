import XCTest
@testable import Reflection

fileprivate typealias SomeFunction = (String, Int) -> Void

fileprivate func someFunction(arg1: Int, arg2: String) -> Int {
    arg1
}

final class FunctionTests: XCTestCase {
    func testFunction1() throws {
        guard case let .function(reflection) = try Reflection(reflecting: SomeFunction.self) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.size, MemoryLayout<SomeFunction>.size)
        XCTAssertEqual(reflection.alignment, MemoryLayout<SomeFunction>.alignment)
        XCTAssertEqual(reflection.stride, MemoryLayout<SomeFunction>.stride)
        XCTAssertEqual(reflection.argumentTypes.count, 2)
        XCTAssert(reflection.argumentTypes[1] == Int.self)
        XCTAssert(reflection.returnType == Void.self)
    }
    
    func testFunction2() throws {
        guard case let .function(reflection) = try Reflection(reflecting: type(of: someFunction)) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.argumentTypes.count, 2)
        XCTAssert(reflection.argumentTypes[1] == String.self)
        XCTAssert(reflection.returnType == Int.self)
    }
}
