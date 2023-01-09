//
//  Debouncer.swift
//  debouncer
//
//  Created by sfilippov on 09.01.2023.
//

import Foundation

actor Debouncer {

    private let timeIntervat: TimeInterval
    private var task: Task<Void, Error>?

    init(timeIntervat: TimeInterval) {
        self.timeIntervat = timeIntervat        
    }

    func debounce(operation: @escaping () async -> Void) {
        task?.cancel()        
        task = Task {
            try await Task.sleep(seconds: timeIntervat)
            await operation()
            task = nil
        }
    }
}

extension Task where Success == Never, Failure == Never {
    public static func sleep(seconds duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(duration * .nanosecondsPerSecond))
    }
}

extension TimeInterval {
    static let nanosecondsPerSecond = TimeInterval(NSEC_PER_SEC)
}
