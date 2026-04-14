//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineCoverageGenerator.swift
//  MapTilerSDK
//

import Foundation

// A sequence that lazily generates tile coordinates required to cover a bounding box
// based on the provided normalized inputs (zoom range, scheme).
internal struct MTOfflineCoverageGenerator: Sequence {
    internal let boundingBoxes: [MTBoundingBox]
    internal let inputs: MTOfflineCoverageInputs

    internal init(boundingBox: MTBoundingBox, inputs: MTOfflineCoverageInputs) {
        self.boundingBoxes = boundingBox.normalizedAndSplit()
        self.inputs = inputs
    }

    internal func makeIterator() -> MTOfflineCoverageIterator {
        return MTOfflineCoverageIterator(boundingBoxes: boundingBoxes, inputs: inputs)
    }
}

// An iterator that generates tiles within the specified bounding box and zoom range.
internal struct MTOfflineCoverageIterator: IteratorProtocol {
    private let boundingBoxes: [MTBoundingBox]
    private let inputs: MTOfflineCoverageInputs

    private var currentBoxIndex: Int = 0
    private var currentZoom: Int
    private var boundsX: ClosedRange<Int>
    private var boundsY: ClosedRange<Int>

    private var currentX: Int
    private var currentY: Int
    private var isCompleted: Bool = false

    internal init(boundingBoxes: [MTBoundingBox], inputs: MTOfflineCoverageInputs) {
        self.boundingBoxes = boundingBoxes
        self.inputs = inputs
        self.currentZoom = inputs.zoomRange.minZoom

        if boundingBoxes.isEmpty || inputs.zoomRange.minZoom > inputs.zoomRange.maxZoom {
            self.isCompleted = true
            self.boundsX = 0...0
            self.boundsY = 0...0
            self.currentX = 0
            self.currentY = 0
        } else {
            let bounds = MTTileMath.tileBounds(for: boundingBoxes[0], zoom: currentZoom)
            self.boundsX = bounds.minX...bounds.maxX
            self.boundsY = bounds.minY...bounds.maxY
            self.currentX = bounds.minX
            self.currentY = bounds.minY
        }
    }

    internal mutating func next() -> MTOfflineTile? {
        if isCompleted { return nil }

        // Transform the Y coordinate if the target scheme requires it.
        let effectiveY = inputs.scheme == .tms
            ? MTTileMath.flipYCoordinate(y: currentY, zoom: currentZoom)
            : currentY
        let tile = MTOfflineTile(x: currentX, y: effectiveY, z: currentZoom)

        // Advance to the next coordinate
        currentX += 1
        if currentX > boundsX.upperBound {
            currentX = boundsX.lowerBound
            currentY += 1

            if currentY > boundsY.upperBound {
                currentZoom += 1
                if currentZoom > inputs.zoomRange.maxZoom {
                    currentBoxIndex += 1
                    if currentBoxIndex < boundingBoxes.count {
                        currentZoom = inputs.zoomRange.minZoom
                        let bounds = MTTileMath.tileBounds(
                            for: boundingBoxes[currentBoxIndex],
                            zoom: currentZoom
                        )
                        self.boundsX = bounds.minX...bounds.maxX
                        self.boundsY = bounds.minY...bounds.maxY
                        self.currentX = bounds.minX
                        self.currentY = bounds.minY
                    } else {
                        isCompleted = true
                    }
                } else {
                    let bounds = MTTileMath.tileBounds(
                        for: boundingBoxes[currentBoxIndex],
                        zoom: currentZoom
                    )
                    self.boundsX = bounds.minX...bounds.maxX
                    self.boundsY = bounds.minY...bounds.maxY
                    self.currentX = bounds.minX
                    self.currentY = bounds.minY
                }
            }
        }

        return tile
    }
}
