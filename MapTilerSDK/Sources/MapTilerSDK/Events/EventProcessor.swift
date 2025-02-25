//
//  EventProcessor.swift
//  MapTilerSDK
//

import Foundation

@MainActor
package protocol EventProcessorDelegate: AnyObject {
    func eventProcessor(_ processor: EventProcessor, didTriggerEvent event: MTEvent)
}

@MainActor
package class EventProcessor {
    enum Constants {
        static let circularEventBufferSize: Int = 20
    }

    private var eventQueue: CircularEventBuffer = CircularEventBuffer(capacity: Constants.circularEventBufferSize)
    private var lastTouchTimestamp: TimeInterval = 0.0

    private var doubleTapSensitivity: Double = 0.4

    weak var delegate: EventProcessorDelegate?

    func registerEvent(_ event: MTEvent?) {
        guard let event else {
            return
        }

        processEventIfNeeded(event)
    }

    private func processEventIfNeeded(_ event: MTEvent) {
        if event == .touchDidEnd {
            processTap()
        }

        if event == .isIdle {
            processIdleFollowingDoubleTap()
        }

        if event != .didDoubleTap {
            delegate?.eventProcessor(self, didTriggerEvent: event)
        }
    }

    private func processTap() {
        eventQueue.enqueue(.touchDidEnd)

        let currentTimestamp = Date.now.timeIntervalSince1970

        if currentTimestamp - lastTouchTimestamp < doubleTapSensitivity {
            eventQueue.enqueue(.didDoubleTap)
        }

        lastTouchTimestamp = currentTimestamp
    }

    private func processIdleFollowingDoubleTap() {
        if eventQueue.contains(.didDoubleTap) {
            delegate?.eventProcessor(self, didTriggerEvent: .didDoubleTap)
            eventQueue.clear()
        }
    }

    package func setDoubleTapSensitivity(_ sensitivity: Double) {
        doubleTapSensitivity = sensitivity
    }
}
