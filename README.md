# Reflection

Reflection 提供 Swift 反射，能从 `Metatype` 中获取类型的属性等信息，也提供用从 `Metatype` 获取的信息中直接构造示例的能力

> 该项目尚在早期阶段，请勿用于正式项目

## 核心功能

- [x] 获取 `Metatype` 的 `size` / `alignment` / `stride` 信息
- [x] 获取 `Metatype` 中的属性信息，包括属性名，属性类型，是否可修改以及偏移值
- [x] 获取类 `Metatype` 中继承的信息，获取 `Metatype` 中的泛型信息
- [x] 获取枚举 `Metatype` 所有 case 的名称，关联值类型
- [x] 获取方法 `Metatype` 的入参类型和返回值类型
- [x] 可以通过属性信息修改属性值，无论是否为 var，无视访问修饰符
- [x] 可以通过获取的 `Metatype` 信息，通过传入 Dictionary 构造实例，也支持使用默认值

## 用例

建议下载本项目使用 [Playground](https://github.com/Alpensegler/Reflection/blob/main/Reflection.playground/Contents.swift) 查看用例

假如有一个元祖 Pet，枚举 Gender ，以及包含了两者的结构体 User，可以是来自其他模块，属性可以有任何访问修饰符

```swift
typealias Pet = (name: String, age: Int)

enum Gender {
    case female, male
}

struct User {
    private let name: String
    private let gender: Gender
    private let pet: Pet
}
```

可以通过 Reflection 获取到 User 的信息

```swift
let reflection = try Reflection(reflecting: User.self)

for property in reflection.properties {
    print(property.name, property.type)
}

// outputs: 
// name String
// gender Gender
// pet (name: String, age: Int)
```

也可以通过下标找需要的属性信息

``` swift
let property = reflection["pet"]
```

同时也可以通过 property 的 get / set 方法获取或修改实例中对应属性的值，可以有任意访问修饰符，var 也可以修改

```swift
try property?.get(from: user)
try property?.set(("Momo", 3) to: &user)
```

若不需要其他信息，也可以使用如下更便捷的修改方法（效果和上例相同）

```swift
try Reflection.get("pet", from: user)
try Reflection.set("pet", with: ("Momo", 3) to: &user)
```

如果一个类型需要频繁获取或修改属性值，还可以让该类继承自 `Reflectable` ，无需实现任何额外方法即可使用下例中的 API，效果同上例
```swift
extension User: Reflectable { }
user.rf.pet
user.rf.pet = ("Momo", 3)
```

Reflection 还提供传入 `[String: Any]` 构造实例的 API，嵌套结构也是支持的，这里支持结构体 / 元祖 / 类 / 枚举 （暂时只支持不包含关联值的枚举）

``` swift
let user = try reflection.instance([
    "name": "Frain",
    "gender": 1, // use Gender.male is also ok
    "pet": [
        "name": "Momo",
        "age": 3
    ]
])
```

也可以不传使用默认值

```swift
let user = try reflection.instance()
print(user)
// output: User(name: "", gener: .female, pet: (name: "", age: 0))
```

## 安装

### Carthage

将下面一行添加进 Cartfile 即可：

```text
github "Alpensegler/Reflection"
```

### Swift Package Manager
在 Xcode 中，点击 "Files -> Swift Package Manager -> Add Package Dependency..."，在搜索栏中输入 "https://github.com/Alpensegler/Reflection"