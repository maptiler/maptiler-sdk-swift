//
//  LayerView.swift
//  MapTilerMobileDemo
//

import UIKit

enum LayerType {
    case contours
    case aeroway
    case place
}

protocol LayerViewDelegate: AnyObject {
    func layerView(_ layerView: LayerView, didUpdateLayerState state: Bool, layer: LayerType)
}

class LayerView: BaseView {
    @IBOutlet weak var contoursSwitch: UISwitch!
    @IBOutlet weak var aerowaySwitch: UISwitch!
    @IBOutlet weak var placeSwitch: UISwitch!

    weak var delegate: LayerViewDelegate?

    override func commonInit() {
        super.commonInit()
    }

    @IBAction func contoursSwitchValueChanged(_ sender: UISwitch) {
        delegate?.layerView(self, didUpdateLayerState: contoursSwitch.isOn, layer: .contours)
    }

    @IBAction func aerowaySwitchValueChanged(_ sender: UISwitch) {
        delegate?.layerView(self, didUpdateLayerState: aerowaySwitch.isOn, layer: .aeroway)
    }

    @IBAction func placeSwitchValueChanged(_ sender: UISwitch) {
        delegate?.layerView(self, didUpdateLayerState: placeSwitch.isOn, layer: .place)
    }
}
