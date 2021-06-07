//
//  SignalingSDP.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/01/08.
//  Copyright © 2019 tkmngch. All rights reserved.
//

import Foundation

struct CallSocketResp : Codable {
    let action: String
    let room: String
}

struct ConnectSocketResp : Codable {
    let location: String
    let room: String
    let action: String
}

struct NFCConnectSocketResp : Codable {
    let room: String
    let action: String
    let status: String
}

struct sendSmsStr: Codable {
    let action: String
    let room: String
    let tid: String
    let tan: String
}

struct ToogleCamera: Codable {
    let action: String
    let result: Bool
    let room: String
}

struct ToogleTorch: Codable {
    let action: String
    let result: Bool
    let room: String
}

struct SDPSender: Codable {
    let action: String
    let room: String
    let sdp: SDP2?
}

struct SDP2: Codable {
    let type: String
    let sdp: String
}

struct SendCandidate: Codable {
    let action: String
    let candidate: Candidate?
    let room: String?
    let sessionDescription: SDP?
}

struct SMSCandidate: Codable {
    let action: String
    let room: String?
    let is_admin: Bool?
    let tid: Int?
}

struct GetCandidate: Codable {
    let action: String?
    let candidate: Candidate?
    let room: String?
}

struct SignalingMessage: Codable {
    let type: String
    let sessionDescription: SDP?
    let candidate: Candidate?
}

struct NewCandidate: Codable {
    let action: String
    let candidate: Candidate?
    let room: String
}

struct SDP: Codable {
    let sdp: String
}

struct Candidate: Codable {
    let candidate: String
    let sdpMLineIndex: Int32
    let sdpMid: String
}
