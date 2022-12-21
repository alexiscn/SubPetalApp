//
//  Defaults.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import Foundation
import Defaults

// MARK: - Misc.
extension Defaults.Keys {
    
    static let rememberLastTab = Key<Bool>("rememberLastTab", default: true)
    
    static let lastSelectedTabIndex = Key<Int>("lastSelectedTabIndex", default: 0)
}

// MARK: - Audio
extension Defaults.Keys {
    
    static let repeatMode = Key<AudioRepeatMode>("AudioRepeatMode", default: .loop)
}
