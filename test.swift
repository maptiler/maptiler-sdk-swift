import Foundation

let name = "---!@#"
let data = try! JSONEncoder().encode(name)
let string = String(data: data, encoding: .utf8)!
print(string)
