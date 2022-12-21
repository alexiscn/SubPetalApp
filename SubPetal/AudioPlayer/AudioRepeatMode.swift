//
//  AudioRepeatMode.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/7.
//

import Foundation
import UIKit
import Defaults

enum AudioRepeatMode: Int, Codable, Defaults.Serializable {
    case loop = 0
    case shuffle
    case one
    
    var next: AudioRepeatMode {
        switch self {
        case .loop: return .shuffle
        case .shuffle: return .one
        case .one: return .loop
        }
    }
    
    var displayIcon: UIImage? {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .ultraLight)
        switch self {
        case .loop: return UIImage(systemName: "repeat", withConfiguration: configuration)
        case .one: return UIImage(systemName: "repeat.1", withConfiguration: configuration)
        case .shuffle: return UIImage(systemName: "shuffle", withConfiguration: configuration)
        }
    }
}
