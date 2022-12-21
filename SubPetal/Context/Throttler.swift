//
//  Throttler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

private extension Date {
    static func second(from referenceDate: Date) -> Float {
        return Float(Date().timeIntervalSince(referenceDate))
    }
}

class Throttler {
    
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    private var job: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private var maxInterval: Float
    
    init(seconds: Float) {
        self.maxInterval = seconds
    }
    
    func throttle(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem() { [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date.second(from: previousRun) > maxInterval ? 0 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
    }
}
