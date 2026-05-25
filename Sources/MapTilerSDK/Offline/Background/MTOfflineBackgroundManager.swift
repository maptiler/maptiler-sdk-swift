//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

internal extension Notification.Name {
    static let mtOfflineBackgroundPackProgress = Notification.Name("mtOfflineBackgroundPackProgress")
    static let mtOfflineBackgroundPackCompleted = Notification.Name("mtOfflineBackgroundPackCompleted")
    static let mtOfflineBackgroundPackFailed = Notification.Name("mtOfflineBackgroundPackFailed")
}

internal class MTOfflineBackgroundManager: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {

    internal static let shared = MTOfflineBackgroundManager()

    private var session: URLSession!
    private let queue = DispatchQueue(label: "com.maptiler.sdk.offline.background", qos: .utility)

    // In-memory mapping: taskIdentifier -> MTBackgroundTaskData
    private var taskMappings: [Int: MTBackgroundTaskData] = [:]

    // Tracking completion handlers per pack
    private var appDelegateCompletionHandler: (() -> Void)?

    private override init() {
        super.init()
        loadMappings()

        let identifier = "com.maptiler.sdk.offline.backgroundSession"
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        config.httpAdditionalHeaders = ["User-Agent": MTConfig.customUserAgent]
        config.waitsForConnectivity = true
        config.isDiscretionary = false // Try to start immediately while foregrounded

        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    internal func setup(completionHandler: (() -> Void)?) {
        self.appDelegateCompletionHandler = completionHandler
    }

    internal func enqueue(tasks: [any MTDownloadTask], for packId: String) async throws {
        var newMappings = [Int: MTBackgroundTaskData]()

        for task in tasks {
            let relativePath: String
            let url: URL
            let isStyle: Bool

            if let resourceTask = task as? MTResourceDownloadTask {
                url = resourceTask.resource.url
                relativePath = resourceTask.resource.destinationPath
                isStyle = false
            } else if let styleTask = task as? MTStyleDownloadTask {
                url = styleTask.resource.url
                relativePath = styleTask.resource.destinationPath
                isStyle = true
            } else {
                continue
            }

            let destURL = MTOfflineStoragePaths.absoluteURL(for: packId, relativePath: relativePath)

            if MTOfflineStorage.isFileVerified(at: destURL) {
                continue
            }

            let normalizedURL = await MTURLNormalizer.normalize(url: url)
            var request = URLRequest(url: normalizedURL)
            request.httpMethod = "GET"

            let downloadTask = session.downloadTask(with: request)

            let data = MTBackgroundTaskData(
                taskIdentifier: downloadTask.taskIdentifier,
                packId: packId,
                relativePath: relativePath,
                isStyle: isStyle,
                resourceURL: url
            )

            newMappings[downloadTask.taskIdentifier] = data
            downloadTask.resume()
        }

        queue.sync {
            for (taskId, data) in newMappings {
                self.taskMappings[taskId] = data
            }
            self.saveMappings()
        }
    }

    private func loadMappings() {
        let url = MTOfflineStoragePaths.backgroundTaskMappingURL
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            let decoder = JSONDecoder()
            self.taskMappings = try decoder.decode([Int: MTBackgroundTaskData].self, from: data)
        } catch {
            print("MapTilerSDK: Failed to load background task mappings: \(error)")
        }
    }

    private func saveMappings() {
        let url = MTOfflineStoragePaths.backgroundTaskMappingURL
        let directory = url.deletingLastPathComponent()

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.taskMappings)
            try data.write(to: url, options: .atomic)
        } catch {
            print("MapTilerSDK: Failed to save background task mappings: \(error)")
        }
    }

    internal func cancelTasks(for packId: String) {
        queue.async {
            let tasksToCancel = self.taskMappings.values.filter { $0.packId == packId }
            self.session.getTasksWithCompletionHandler { _, _, downloadTasks in
                for task in downloadTasks
                where tasksToCancel.contains(where: { $0.taskIdentifier == task.taskIdentifier }) {
                    task.cancel()
                }
            }

            self.taskMappings = self.taskMappings.filter { $0.value.packId != packId }
            self.saveMappings()
        }
    }

    private func reportResourceComplete(for packId: String) {
        Task {
            session.getTasksWithCompletionHandler { _, _, downloadTasks in
                let remainingTasks = downloadTasks.filter { task in
                    if let mapping = self.queue.sync(execute: { self.taskMappings[task.taskIdentifier] }) {
                        return mapping.packId == packId
                    }
                    return false
                }.count

                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .mtOfflineBackgroundPackProgress,
                        object: nil,
                        userInfo: ["packId": packId]
                    )
                    if remainingTasks == 0 {
                        NotificationCenter.default.post(
                            name: .mtOfflineBackgroundPackCompleted,
                            object: nil,
                            userInfo: ["packId": packId]
                        )
                    }
                }
            }
        }
    }

    private func reportResourceFailed(for packId: String, error: Error) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .mtOfflineBackgroundPackFailed,
                object: nil,
                userInfo: ["packId": packId, "error": error]
            )
        }
    }

    // MARK: - Delegate Methods

    internal func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let taskId = downloadTask.taskIdentifier
        var mapping: MTBackgroundTaskData?

        queue.sync {
            mapping = self.taskMappings[taskId]
            self.taskMappings.removeValue(forKey: taskId)
            self.saveMappings()
        }

        guard let mapping = mapping else { return }

        let destURL = MTOfflineStoragePaths.absoluteURL(for: mapping.packId, relativePath: mapping.relativePath)

        do {
            let fileManager = FileManager.default
            let destDir = destURL.deletingLastPathComponent()

            if !fileManager.fileExists(atPath: destDir.path) {
                try fileManager.createDirectory(at: destDir, withIntermediateDirectories: true)
            }

            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.moveItem(at: location, to: destURL)

            self.reportResourceComplete(for: mapping.packId)
        } catch {
            self.reportResourceFailed(for: mapping.packId, error: error)
        }
    }

    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            let taskId = task.taskIdentifier
            var mapping: MTBackgroundTaskData?

            queue.sync {
                mapping = self.taskMappings[taskId]
                self.taskMappings.removeValue(forKey: taskId)
                self.saveMappings()
            }

            if let mapping = mapping {
                self.reportResourceFailed(for: mapping.packId, error: error)
            }
        }
    }

    internal func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.appDelegateCompletionHandler?()
            self.appDelegateCompletionHandler = nil
        }
    }
}
