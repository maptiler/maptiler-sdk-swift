//
//  EventProcessor.swift
//  MapTilerSDK
//

import Foundation

@MainActor
package protocol EventProcessorDelegate: AnyObject {
    func eventProcessor(_ processor: EventProcessor, didTriggerEvent event: MTEvent, with data: MTData?)
}

@MainActor
package class EventProcessor {
    enum Constants {
        static let circularEventBufferSize: Int = 20
        static let uknownEventMessage: String = "Unknown event occurred."
    }

    private var eventQueue: CircularEventBuffer = CircularEventBuffer(capacity: Constants.circularEventBufferSize)
    private var lastTouchTimestamp: TimeInterval = 0.0

    private var doubleTapSensitivity: Double = 0.4

    weak var delegate: EventProcessorDelegate?

    func registerEvent(_ event: MTEvent?, with data: MTData? = nil) {
        guard let event else {
            MTLogger.log(Constants.uknownEventMessage, type: .warning)

            return
        }

        processEventIfNeeded(event)
    }

    private func processEventIfNeeded(_ event: MTEvent, with data: MTData? = nil) {
        if event == .touchDidEnd {
            processTap()
        }

        if event == .isIdle {
            processIdleFollowingDoubleTap(with: data)
        }

        if event != .didDoubleTap {
            delegate?.eventProcessor(self, didTriggerEvent: event, with: data)
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

    private func processIdleFollowingDoubleTap(with data: MTData? = nil) {
        if eventQueue.contains(.didDoubleTap) {
            delegate?.eventProcessor(self, didTriggerEvent: .didDoubleTap, with: data)
            eventQueue.clear()
        }
    }

    package func setDoubleTapSensitivity(_ sensitivity: Double) {
        doubleTapSensitivity = sensitivity
    }
}
