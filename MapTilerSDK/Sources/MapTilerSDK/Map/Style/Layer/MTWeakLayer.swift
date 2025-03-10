//
//  MTWeakLayer.swift
//  MapTilerSDK
//

package class MTWeakLayer {
    weak var layer: (any MTLayer)?

    init(layer: MTLayer? = nil) {
        self.layer = layer
    }
}
