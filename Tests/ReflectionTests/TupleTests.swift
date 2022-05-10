import XCTest
@testable import Reflection

fileprivate typealias Cat = (name: String, age: Int)
fileprivate typealias Person = (name: String, age: Int, pet: Cat)

final class TupleTests: XCTestCase {
    
    func testReflectPerson() throws {
        guard case let .tuple(reflection) = try Reflection(reflecting: Person.self) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.size, MemoryLayout<Person>.size)
        XCTAssertEqual(reflection.alignment, MemoryLayout<Person>.alignment)
        XCTAssertEqual(reflection.stride, MemoryLayout<Person>.stride)
        XCTAssertEqual(reflection.properties.count, 3)
        XCTAssert(reflection.properties[2].type == Cat.self)
        XCTAssertEqual(reflection.properties[2].name, "pet")
    }
    
    func testReflectTupleProperties() throws {
        let reflection = try TupleReflection(reflecting: Person.self)
        var person = (name: "Frain", age: 27, pet: (name: "Momo", age: 3))
        XCTAssertEqual(try reflection.properties[0].get(from: person) as? String, "Frain")
        XCTAssertEqual(try reflection.properties[1].get(from: person) as? Int, 27)
        XCTAssertEqual(try reflection.properties[1].get(from: person as Any) as? Int, 27)
        try reflection.properties[0].set("Frain2", to: &person)
        XCTAssertEqual(person.name, "Frain2")
    }
    
    func testRelfectionInstance() throws {
        let reflection = try TupleReflection(reflecting: Person.self)
        guard let person1 = try reflection.instance() as? Person else {
            return XCTAssert(false)
        }
        XCTAssertEqual(person1.pet.name, "")
        let person2Any = try reflection.instance {
            guard $0.name == "name", $0.owner == Cat.self else { return nil }
            return "Momo"
        }
        guard let person2 = person2Any as? Person else {
            return XCTAssert(false)
        }
        XCTAssertEqual(person2.pet.name, "Momo")
    }
}
