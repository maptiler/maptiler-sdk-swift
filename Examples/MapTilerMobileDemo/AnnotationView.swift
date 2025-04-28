//
//  AnnotationView.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK
import CoreLocation

protocol AnnotationViewDelegate: AnyObject {
    func didTapClose()
}

class AnnotationView: MTCustomAnnotationView {
    @IBOutlet weak var contentView: UIView!

    weak var delegate: AnnotationViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    override init(frame: CGRect, coordinates: CLLocationCoordinate2D) {
        super.init(frame: frame, coordinates: coordinates)

        commonInit()
    }

    override init(frame: CGRect, coordinates: CLLocationCoordinate2D, offset: MTPoint) {
        super.init(frame: frame, coordinates: coordinates, offset: offset)

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

    @IBAction func closeButtonTouchUpInside(_ sender: UIButton) {
        delegate?.didTapClose()
    }
}
