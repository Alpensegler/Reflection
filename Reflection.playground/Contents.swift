import Reflection

typealias Pet = (type: String, age: Int)

enum Gender {
    case female, male
}

struct User {
    let name: String
    let gender: Gender
    let pet: Pet
}

guard case let .struct(reflection) = try Reflection(reflecting: User.self) else {
    fatalError()
}

for property in reflection.properties {
    print(property)
}

let user = try reflection.instance([
    "name": "Frain",
    "gender": 1, // use Gender.male is also ok
    "pet": [
        "type": "Momo",
        "age": 3
    ]
]) as! User

print(user)
