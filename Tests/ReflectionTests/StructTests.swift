import XCTest
@testable import Reflection

fileprivate struct Cat {
    let name: String, age: Int
}

fileprivate struct Dog {
    let name: String, age: Int
}

fileprivate struct Person {
    let name: String, age: Int, pet: Cat
}

fileprivate struct GenericPerson<Pet, Pet2> {
    let name: String, age: Int
    let pet1: Pet, pet2: Pet2
}

final class StructTests: XCTestCase {
    
    func testReflectPerson() throws {
        guard case let .struct(reflection) = try Reflection(reflecting: Person.self) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.size, MemoryLayout<Person>.size)
        XCTAssertEqual(reflection.alignment, MemoryLayout<Person>.alignment)
        XCTAssertEqual(reflection.stride, MemoryLayout<Person>.stride)
        XCTAssertEqual(reflection.mangledName, "Person")
        XCTAssert(reflection.genericTypes.isEmpty)
        XCTAssertEqual(reflection.properties.count, 3)
        XCTAssert(reflection.properties[2].type == Cat.self)
        XCTAssertEqual(reflection.properties[2].name, "pet")
    }
    
    func testReflectGenericPerson() throws {
        typealias Person = GenericPerson<Cat, Dog>
        guard case let .struct(reflection) = try Reflection(reflecting: Person.self) else {
            return XCTAssert(false)
        }
        XCTAssertEqual(reflection.size, MemoryLayout<Person>.size)
        XCTAssertEqual(reflection.alignment, MemoryLayout<Person>.alignment)
        XCTAssertEqual(reflection.stride, MemoryLayout<Person>.stride)
        XCTAssertEqual(reflection.mangledName, "GenericPerson")
        XCTAssertEqual(reflection.properties.count, 4)
        XCTAssertEqual(reflection.properties[3].name, "pet2")
        XCTAssertEqual(reflection.genericTypes.count, 2)
        XCTAssert(reflection.genericTypes[1] == Dog.self)
    }
    
    func testReflectStructProperties() throws {
        let reflection = try StructReflection(reflecting: Person.self)
        var person = Person(name: "Frain", age: 27, pet: Cat(name: "Momo", age: 3))
        XCTAssertEqual(try reflection.properties[0].get(from: person) as? String, "Frain")
        XCTAssertEqual(try reflection.properties[1].get(from: person) as? Int, 27)
        try reflection.properties[0].set("Frain2", to: &person)
        XCTAssertEqual(person.name, "Frain2")
    }
    
    func testReflectAnyStructProperties() throws {
        let reflection = try StructReflection(reflecting: Person.self as Any.Type)
        var person = Person(name: "Frain", age: 27, pet: Cat(name: "Momo", age: 3)) as Any
        XCTAssertEqual(try reflection.properties[0].get(from: person) as? String, "Frain")
        XCTAssertEqual(try reflection.properties[1].get(from: person) as? Int, 27)
        try reflection.properties[0].set("Frain2", to: &person)
        XCTAssertEqual((person as! Person).name, "Frain2")
    }
    
    func testRelfectionInstance() throws {
        let reflection = try StructReflection(reflecting: Person.self)
        let person1 = try reflection.instance()
        XCTAssertEqual(person1.pet.name, "")
        let person2 = try reflection.instance {
            if $0.name == "name", $0.owner == Cat.self {
                return "Momo"
            }
            if $0.name == "age", $0.owner == Cat.self {
                return 3
            }
            return nil
        }
        XCTAssertEqual(person2.pet.name, "Momo")
        XCTAssertEqual(person2.pet.age, 3)
    }
}
