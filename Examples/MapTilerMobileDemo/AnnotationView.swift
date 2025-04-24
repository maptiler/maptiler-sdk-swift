//
//  AnnotationView.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK
import CoreLocation

class AnnotationView: MTCustomAnnotationView {
    @IBOutlet weak var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    override init(frame: CGRect, coordinates: CLLocationCoordinate2D) {
        super.init(frame: frame, coordinates: coordinates)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self)
        addSubview(contentView)
    }
}
