import Reflection

typealias Pet = (name: String, age: Int)

enum Gender {
    case female, male
}

struct User {
    private let name: String
    private let gender: Gender
    private let pet: Pet
}

let reflection = try Reflection(reflecting: User.self)

for property in reflection.properties {
    print(property.name, property.type)
}

var user = try reflection.instance([
    "name": "Frain",
    "gender": 1, // use Gender.male is also ok
    "pet": [
        "name": "Momo",
        "age": 3
    ]
])  

try Reflection.get("name", from: user)
try Reflection.set("name", with: "Frain2", to: &user)

extension User: Reflectable { }
user.rf.name
user.rf.pet = ("Miemie", 1)
print(user)
