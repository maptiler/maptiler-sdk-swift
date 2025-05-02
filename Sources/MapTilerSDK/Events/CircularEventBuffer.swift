//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CircularEventBuffer.swift
//  MapTilerSDK
//

package class CircularEventBuffer {
    private var buffer: [MTEvent?]
    private var head: Int = 0
    private var tail: Int = 0
    private var capacity: Int
    private var isFull = false

    init(capacity: Int) {
        self.capacity = capacity
        self.buffer = Array(repeating: nil, count: capacity)
    }

    var isEmpty: Bool {
        return !isFull && head == tail
    }

    func enqueue(_ event: MTEvent) {
        buffer[tail] = event
        tail = (tail + 1) % capacity

        if isFull {
            head = (head + 1) % capacity
        }

        isFull = tail == head
    }

    func dequeue() -> MTEvent? {
        guard !isEmpty else {
            return nil
        }

        let event = buffer[head]
        buffer[head] = nil
        head = (head + 1) % capacity
        isFull = false

        return event
    }

    func contains(_ event: MTEvent) -> Bool {
        var index = head

        while index != tail {
            if buffer[index] == event {
                return true
            }

            index = (index + 1) % capacity
        }

        return false
    }

    func clear() {
        buffer = Array(repeating: nil, count: capacity)
        head = 0
        tail = 0
        isFull = false
    }
}
