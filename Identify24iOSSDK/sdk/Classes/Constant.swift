//
//  Constant.swift
//  Kimlik
//
//  Created by MacBookPro on 1.02.2021.
//

import UIKit

public struct URLConstants {
    static var baseAPIUrl = "https://api.identifytr.com/"
    static var stunServers = ["stun:stun.l.google.com:19302", "turn:3.64.99.127:3478"]
    static var stunUsername = "test"
    static var stunPassword = "test"
    static var webSocketUrl = "wss://ws.identifytr.com:8888/"
}

public struct KBURLConstants {
    static let baseAPIUrl = "https://api.kimlikbasit.com/"
    static var stunServers = ["stun:stun.l.google.com:19302", "turn:18.156.205.32:3478"]
    static var stunUsername = "test"
    static var stunPassword = "test"
    static var webSocketUrl = "wss://ws.identifytr.com:8888/"
}
