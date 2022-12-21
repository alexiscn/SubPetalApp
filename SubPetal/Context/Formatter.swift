//
//  Formatter.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/8.
//

import Foundation

struct Formatter {
    
    static var audioDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        //formatter.maximumUnitCount = 2
        return formatter
    }()
    
    static var playlistDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        //formatter.maximumUnitCount = 2
        return formatter
    }()
    
    static var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        return formatter
    }()
    
    static func format(_ interval: TimeInterval) -> String? {
        return audioDurationFormatter.string(from: interval)
    }
}


struct ISO3601DateFormatter {
    static let shared = ISO3601DateFormatter()

    private let secondsDateFormatter = DateFormatter()
    private let milisecondsDateFormatter = DateFormatter()

    init() {
        secondsDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        milisecondsDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZ"
    }
    
    func string(from date: Date) -> String {
        return secondsDateFormatter.string(from: date)
    }
    
    func date(from dateString: String) -> Date? {
        return (secondsDateFormatter.date(from: dateString)
                    ?? milisecondsDateFormatter.date(from: dateString))
    }
    
    func date(fromBytes bytes: ArraySlice<UInt8>) -> Date? {
        guard let dateString = String(bytes: Array(bytes), encoding: .ascii) else { return nil }
        return (secondsDateFormatter.date(from: dateString)
            ?? milisecondsDateFormatter.date(from: dateString))
    }
}
