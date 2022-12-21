//
//  ContextMenuHandler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/10.
//

import Foundation
import UIKit

struct ContextMenuInfo {
    let item: AnyHashable
    let list: [AnyHashable]
    let viewController: UIViewController
}

protocol ContextMenuHandler {
    
    static func handle(_ info: ContextMenuInfo)
    
}
