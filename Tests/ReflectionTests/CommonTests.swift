import XCTest
@testable import Reflection

fileprivate typealias Pet = (type: String, age: Int)

fileprivate enum Gender {
    case female, male
}

fileprivate struct User: Reflectable {
    let name: String
    let gender: Gender
    let pet: Pet
}

final class CommonTests: XCTestCase {
    
    func testReflectionUser() throws {
        let reflection = try StructReflection(reflecting: User.self)
        var user = try reflection.instance([
            "name": "Frain",
            "gender": 1,
            "pet": [
                "type": "Cat",
                "age": 3
            ]
        ])
        XCTAssertEqual(user.name, "Frain")
        XCTAssertEqual(user.gender, .male)
        XCTAssertEqual(user.pet.age, 3)
        XCTAssertEqual(user.rf.name as? String, "Frain")
        user.rf.pet = ("Dog", 1)
        XCTAssert(user.rf.pet as! Pet == ("Dog", 1))
    }
}
