import XCTest
@testable import Reflection

fileprivate class Cat {
    let name: String, age: Int
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

fileprivate class Dog {
    let name: String, age: Int
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

fileprivate class Person {
    let name: String, age: Int, pet: Cat
    init(name: String, age: Int, pet: Cat) {
        self.name = name
        self.age = age
        self.pet = pet
    }
}

fileprivate class GenericPerson<Pet, Pet2> {
    let name: String, age: Int
    let pet1: Pet, pet2: Pet2
    init(name: String, age: Int, pet1: Pet, pet2: Pet2) {
        self.name = name
        self.age = age
        self.pet1 = pet1
        self.pet2 = pet2
    }
}

final class ClassTests: XCTestCase {
    func testReflectPerson() throws {
        guard case let .class(reflection) = try Reflection(reflecting: Person.self) else {
            return XCTAssert(false)
        }
        XCTAssert(reflection.size == MemoryLayout<Person>.size)
        XCTAssert(reflection.alignment == MemoryLayout<Person>.alignment)
        XCTAssert(reflection.stride == MemoryLayout<Person>.stride)
        XCTAssert(reflection.mangledName == "Person")
        XCTAssert(reflection.genericTypes.isEmpty)
        XCTAssert(reflection.properties.count == 3)
        XCTAssert(reflection.properties[2].type == Cat.self)
    }
    
    func testReflectGenericPerson() throws {
        typealias Person = GenericPerson<Cat, Dog>
        guard case let .class(reflection) = try Reflection(reflecting: Person.self) else {
            return XCTAssert(false)
        }
        XCTAssert(reflection.size == MemoryLayout<Person>.size)
        XCTAssert(reflection.alignment == MemoryLayout<Person>.alignment)
        XCTAssert(reflection.stride == MemoryLayout<Person>.stride)
        XCTAssert(reflection.mangledName == "GenericPerson")
        XCTAssert(reflection.properties.count == 4)
        XCTAssert(reflection.genericTypes.count == 2)
        XCTAssert(reflection.genericTypes[1] == Dog.self)
    }
    
    func testReflectClassProperties() throws {
        let reflection = try ClassReflection(reflecting: Person.self)
        var person = Person(name: "Frain", age: 27, pet: Cat(name: "Momo", age: 3))
        let name = try reflection.properties[0].get(from: person) as? String
        let age = try reflection.properties[1].get(from: person) as? Int
        XCTAssert(name == "Frain")
        XCTAssert(age == 27)
        let age2 = try reflection.properties[1].get(from: person as Any) as? Int
        XCTAssert(age2 == 27)
        try reflection.properties[0].set("Frain2", to: &person)
        XCTAssert(person.name == "Frain2")
    }
    
    func testRelfectionInstance() throws {
        let reflection = try ClassReflection(reflecting: Person.self)
        guard let person1 = try reflection.instance() as? Person else {
            return XCTAssert(false)
        }
        XCTAssert(person1.pet.name == "")
        let person2Any = try reflection.instance {
            guard $0.name == "name", $0.owner == Cat.self else { return nil }
            return "Momo"
        }
        guard let person2 = person2Any as? Person else {
            return XCTAssert(false)
        }
        XCTAssert(person2.pet.name == "Momo")
    }
}
