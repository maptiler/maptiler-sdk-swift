import Foundation

let path = "Tests/MapTilerSDKTests/MTTextPopupTests.swift"
var content = try! String(contentsOfFile: path)

let addAnchorTest = """

    @Test func addTextPopupCommand_includesAnchorWhenProvided() async throws {
        let popup = MTTextPopup(
            coordinates: coordinate,
            text: "Hello World",
            anchor: .top
        )

        let jsString = AddTextPopup(popup: popup).toJS()

        #expect(jsString.contains("\\"anchor\\":\\"top\\""))
    }
"""

content = content.replacingOccurrences(of: "    @Test func addTextPopupCommand_omitsMaxWidthWhenNil() async throws {", with: addAnchorTest + "\n    @Test func addTextPopupCommand_omitsMaxWidthWhenNil() async throws {")

let setterTest = """
        #expect(
            SetAnchorToTextPopup(popup: popup, anchor: .bottomLeft).toJS()
                == \"\"\"
                window.\\(popup.identifier).options.anchor = 'bottom-left';
                if (window.\\(popup.identifier).isOpen()) {
                    window.\\(popup.identifier)._update();
                }
                \"\"\"
        )
        #expect(
            SetAnchorToTextPopup(popup: popup, anchor: nil).toJS()
                == \"\"\"
                delete window.\\(popup.identifier).options.anchor;
                if (window.\\(popup.identifier).isOpen()) {
                    window.\\(popup.identifier)._update();
                }
                \"\"\"
        )
"""

content = content.replacingOccurrences(of: "        #expect(SetCoordinatesToTextPopup(popup: popup).toJS() == \"window.\\(popup.identifier).setLngLat([20.0, 10.0]);\")", with: "        #expect(SetCoordinatesToTextPopup(popup: popup).toJS() == \"window.\\(popup.identifier).setLngLat([20.0, 10.0]);\")\n" + setterTest)

let getterTest = """
        #expect(
            GetTextPopupAnchor(popup: popup).toJS() == \"\"\"
            (() => {
                const popup = window.\\(popup.identifier);
                if (!popup) return null;
                if (popup.options.anchor) return popup.options.anchor;
                const match = popup._container?.className.match(/maplibregl-popup-anchor-([a-z-]+)/);
                return match ? match[1] : null;
            })();
            \"\"\"
        )
"""

content = content.replacingOccurrences(of: "        #expect(IsTextPopupOpen(popup: popup).toJS() == \"window.\\(popup.identifier).isOpen();\")", with: getterTest + "\n        #expect(IsTextPopupOpen(popup: popup).toJS() == \"window.\\(popup.identifier).isOpen();\")")

try! content.write(toFile: path, atomically: true, encoding: .utf8)
