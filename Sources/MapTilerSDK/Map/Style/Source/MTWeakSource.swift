//
//  MTWeakSource.swift
//  MapTilerSDK
//

package class MTWeakSource {
    weak var source: (any MTSource)?

    init(source: MTSource? = nil) {
        self.source = source
    }
}
