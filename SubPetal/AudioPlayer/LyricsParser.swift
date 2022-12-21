//
//  LyricsParser.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

struct LyricsParser {
    
    static func parse(content: String) -> Lyrics? {
        let regex = try? NSRegularExpression(pattern: #"\[(.*?):(.*?)\]"#, options: [])
        let range = NSRange(location: 0, length: content.count)
        guard let matches = regex?.matches(in: content, options: .withoutAnchoringBounds, range: range) else {
            return nil
        }
     
        var lyric = Lyrics()
        for (index, match) in matches.enumerated() {
            let time = content.subString(range: match.range)
            let timestamp = parseTimestamp(time: time)
            let line: String
            if index < matches.count - 1 {
                let next = matches[index + 1]
                let lineRange = NSMakeRange(match.range.upperBound, next.range.lowerBound - match.range.upperBound)
                line = content.subString(range: lineRange)
            } else {
                let lineRange = NSMakeRange(match.range.upperBound, content.count - match.range.upperBound)
                line = content.subString(range: lineRange)
            }
            let sentence = Lyrics.Sentence(start: timestamp, content: line)
            lyric.sentences.append(sentence)
        }
        return lyric
    }
    
    static func parseTimestamp(time: String) -> Int {
        let text = time.trimSquareBrackets()
        let components = text.split(separator: ":")
        if components.count == 2 {
            let minute = Float(String(components[0])) ?? 0
            let second = Float(String(components[1])) ?? 0
            let timestamp = minute * 60 + second
            return Int(timestamp * 100)
        }
        return -1
    }
}

fileprivate extension String {
    
    func subString(range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.location)
        let end = self.index(self.startIndex, offsetBy: range.location + range.length)
        return String(self[start ..< end])
    }
    
    func trimSquareBrackets() -> String {
        return self.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
    }
    
    func trimCircleBrackets() -> String {
        return self.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    }
}
