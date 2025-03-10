//
//  MTWeakSource.swift
//  MapTilerSDK
//

public class MTWeakSource {
    weak var source: (any MTSource)?

    init(source: MTSource? = nil) {
        self.source = source
    }
}
