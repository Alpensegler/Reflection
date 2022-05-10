import XCTest
@testable import Reflection

enum EmptyEnum { }

enum Animal {
    case person(String), cat, dog
}

enum TestEnum {
    case a, b, c
}

final class EnumTests: XCTestCase {
    func testReflectEmpty() throws {
        guard case let .enum(reflection) = try Reflection(reflecting: EmptyEnum.self) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.size, MemoryLayout<EmptyEnum>.size)
        XCTAssertEqual(reflection.alignment, MemoryLayout<EmptyEnum>.alignment)
        XCTAssertEqual(reflection.stride, MemoryLayout<EmptyEnum>.stride)
        XCTAssertEqual(reflection.mangledName, "EmptyEnum")
        XCTAssert(reflection.genericTypes.isEmpty)
        XCTAssert(reflection.cases.isEmpty)
    }
    
    func testReflectAnimal() throws {
        guard case let .enum(reflection) = try Reflection(reflecting: Animal.self) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.size, MemoryLayout<Animal>.size)
        XCTAssertEqual(reflection.alignment, MemoryLayout<Animal>.alignment)
        XCTAssertEqual(reflection.stride, MemoryLayout<Animal>.stride)
        XCTAssertEqual(reflection.mangledName, "Animal")
        XCTAssert(reflection.genericTypes.isEmpty)
        XCTAssertEqual(reflection.cases.count, 3)
        XCTAssertEqual(reflection.cases[0].name, "person")
        XCTAssert(reflection.cases[0].payloadType == String.self)
        XCTAssertNil(reflection.cases[1].payloadType)
    }
    
    func testEnumInstance() throws {
        guard case let .enum(reflection) = try Reflection(reflecting: TestEnum.self) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.size, MemoryLayout<TestEnum>.size)
        XCTAssertEqual(reflection.alignment, MemoryLayout<TestEnum>.alignment)
        XCTAssertEqual(reflection.stride, MemoryLayout<TestEnum>.stride)
        guard let a = try reflection.instance() as? TestEnum else {
            return XCTAssert(false)
        }
        XCTAssertEqual(a, TestEnum.a)
    }
}
