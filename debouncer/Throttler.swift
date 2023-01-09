//
//  Throttler.swift
//  debouncer
//
//  Created by sfilippov on 09.01.2023.
//

import Foundation

actor Throttler {

    private let timeIntervat: TimeInterval
    private var task: Task<Void, Error>?

    init(timeIntervat: TimeInterval) {
        self.timeIntervat = timeIntervat
    }

    func throttle(operation: @escaping () async -> Void) {
        guard task == nil else { return }
        task = Task {
            defer { task = nil }
            try await Task.sleep(seconds: timeIntervat)
        }

        Task {
            await operation()
        }
    }
}
