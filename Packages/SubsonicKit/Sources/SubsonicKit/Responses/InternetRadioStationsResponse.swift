//
//  InternetRadioStationsResponse.swift
//  
//
//  Created by alexiscn on 2022/6/16.
//

import Foundation

public struct InternetRadioStationsResponse: Response {
    
    public var status: String
    
    public var version: String
    
    public var type: String?
    
    public var serverVersion: String?
    
    public var error: SubsonicError?
    
    
}
