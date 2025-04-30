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

    override init(size: CGSize, coordinates: CLLocationCoordinate2D) {
        super.init(size: size, coordinates: coordinates)

        commonInit()
    }

    override init(size: CGSize, coordinates: CLLocationCoordinate2D, offset: MTPoint) {
        super.init(size: size, coordinates: coordinates, offset: offset)

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
