//
//  LayerView.swift
//  MapTilerMobileDemo
//

import UIKit

enum LayerType {
    case contours
    case aeroway
    case place
    case satellite
}

protocol LayerViewDelegate: AnyObject {
    func layerView(_ layerView: LayerView, didUpdateLayerState state: Bool, layer: LayerType)
}

class LayerView: BaseView {
    @IBOutlet private weak var contoursSwitch: UISwitch!
    @IBOutlet private weak var aerowaySwitch: UISwitch!
    @IBOutlet private weak var placeSwitch: UISwitch!
    @IBOutlet private weak var satelliteSwitch: UISwitch!

    weak var delegate: LayerViewDelegate?

    @IBAction func contoursSwitchValueChanged(_ sender: UISwitch) {
        delegate?.layerView(self, didUpdateLayerState: contoursSwitch.isOn, layer: .contours)
    }

    @IBAction func aerowaySwitchValueChanged(_ sender: UISwitch) {
        delegate?.layerView(self, didUpdateLayerState: aerowaySwitch.isOn, layer: .aeroway)
    }

    @IBAction func placeSwitchValueChanged(_ sender: UISwitch) {
        delegate?.layerView(self, didUpdateLayerState: placeSwitch.isOn, layer: .place)
    }

    @IBAction func satelliteSwitchValueChanged(_ sender: UISwitch) {
        delegate?.layerView(self, didUpdateLayerState: satelliteSwitch.isOn, layer: .satellite)
    }
}
