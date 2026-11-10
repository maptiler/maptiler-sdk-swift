import Foundation

struct MyOptions: Codable {
    private var _maxCanvasSize: [Double]?

    public var maxCanvasSize: CGSize? {
        get {
            guard let size = _maxCanvasSize, size.count == 2 else { return nil }
            return CGSize(width: size[0], height: size[1])
        }
        set {
            if let newValue = newValue {
                _maxCanvasSize = [newValue.width, newValue.height]
            } else {
                _maxCanvasSize = nil
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case _maxCanvasSize = "maxCanvasSize"
    }
}

var opts = MyOptions()
opts.maxCanvasSize = CGSize(width: 800, height: 600)
let data = try! JSONEncoder().encode(opts)
print(String(data: data, encoding: .utf8)!)
