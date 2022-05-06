import XCTest
@testable import Reflection

enum EmptyEnum { }

enum Animal {
    case person(String), cat, dog
}

final class EnumTests: XCTestCase {
    func testReflectEmpty() throws {
        guard case let .enum(reflection) = try Reflection(reflecting: EmptyEnum.self) else {
            return XCTAssert(false)
        }
        XCTAssert(reflection.size == MemoryLayout<EmptyEnum>.size)
        XCTAssert(reflection.alignment == MemoryLayout<EmptyEnum>.alignment)
        XCTAssert(reflection.stride == MemoryLayout<EmptyEnum>.stride)
        XCTAssert(reflection.mangledName == "EmptyEnum")
        XCTAssert(reflection.genericTypes.isEmpty)
        XCTAssert(reflection.cases.isEmpty)
    }
    
    func testReflectAnimal() throws {
        guard case let .enum(reflection) = try Reflection(reflecting: Animal.self) else {
            return XCTAssert(false)
        }
        XCTAssert(reflection.size == MemoryLayout<Animal>.size)
        XCTAssert(reflection.alignment == MemoryLayout<Animal>.alignment)
        XCTAssert(reflection.stride == MemoryLayout<Animal>.stride)
        XCTAssert(reflection.mangledName == "Animal")
        XCTAssert(reflection.genericTypes.isEmpty)
        XCTAssert(reflection.cases.count == 3)
        XCTAssert(reflection.cases[0].name == "person")
        XCTAssert(reflection.cases[0].payloadType == String.self)
        XCTAssert(reflection.cases[1].payloadType == nil)
    }
}
