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

typealias Pet = (type: String, age: Int)

enum Gender {
    case female, male
}

struct User {
    let name: String
    let gender: Gender
    let pet: Pet
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
        XCTAssertEqual(try reflection.properties[1].get(from: person as Any) as? Int, 27)
        try reflection.properties[0].set("Frain2", to: &person)
        XCTAssertEqual(person.name, "Frain2")
    }
    
    func testRelfectionInstance() throws {
        let reflection = try StructReflection(reflecting: Person.self)
        guard let person1 = try reflection.instance() as? Person else {
            return XCTAssert(false)
        }
        XCTAssertEqual(person1.pet.name, "")
        let person2Any = try reflection.instance {
            if $0.name == "name", $0.owner == Cat.self {
                return "Momo"
            }
            if $0.name == "age", $0.owner == Cat.self {
                return 3
            }
            return nil
        }
        guard let person2 = person2Any as? Person else {
            return XCTAssert(false)
        }
        XCTAssertEqual(person2.pet.name, "Momo")
        XCTAssertEqual(person2.pet.age, 3)
    }
    
    func testReflectionUser() throws {
        let reflection = try StructReflection(reflecting: User.self)
        let userAny = try reflection.instance([
            "name": "Frain",
            "gender": 1,
            "pet": [
                "type": "Momo",
                "age": 3
            ]
        ])
        guard let user = userAny as? User else {
            return XCTAssert(false)
        }
        XCTAssertEqual(user.name, "Frain")
        XCTAssertEqual(user.gender, .male)
        XCTAssertEqual(user.pet.age, 3)
    }
}
