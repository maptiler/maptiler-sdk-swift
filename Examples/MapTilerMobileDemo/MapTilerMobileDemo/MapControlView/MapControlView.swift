//
//  MapControlView.swift
//  MapTilerMobileDemo
//

import UIKit

protocol MapControlViewDelegate: AnyObject {
    func mapControlViewDidTapZoomIn(_ mapControlView: MapControlView)
    func mapControlViewDidTapZoomOut(_ mapControlView: MapControlView)
    func mapControlView(_ mapControlView: MapControlView, didSelectBearing bearing: Double)
}

class MapControlView: BaseView {
    enum Constants {
        static let bearingPickerViewNumberOfComponents = 1
        static let bearingPickerViewNumberOfRows = 10
        static let defaultBorderWidth: CGFloat = 2.0
        static let defaultCornerRadius: CGFloat = 8.0
        static let accentColor = UIColor(red: 0, green: 161/255, blue: 194/255, alpha: 1)
    }

    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var zoomView: UIView!
    @IBOutlet weak var bearingPickerView: UIPickerView!

    weak var delegate: MapControlViewDelegate?

    private let bearings: [Int] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]

    override func commonInit() {
        super.commonInit()

        configZoomView()
    }

    private func configZoomView() {
        zoomView.layer.borderWidth = Constants.defaultBorderWidth
        zoomView.layer.borderColor = Constants.accentColor.cgColor
        zoomView.layer.cornerRadius = Constants.defaultCornerRadius
    }

    @IBAction func zoomInButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapControlViewDidTapZoomIn(self)
    }

    @IBAction func zoomOutButtonTouchUpInside(_ sender: UIButton) {
        delegate?.mapControlViewDidTapZoomOut(self)
    }
}

extension MapControlView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Constants.bearingPickerViewNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.bearingPickerViewNumberOfRows
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(bearings[row])°"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.mapControlView(self, didSelectBearing: Double(bearings[row]))
    }
}
