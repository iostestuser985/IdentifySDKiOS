//
//  SDKProtocols.swift
//  Kimlik
//
//  Created by Emir Beytekin on 20.04.2021.
//

import Foundation

public protocol IdentifyListenerDelegate:class {
    func incomingCall()
    func endCall()
    func comingSms()
    func openNFC()
    func skipNFC()
    func approvedSms(stats: Bool)
    func openWarningCircle()
    func closeWarningCircle()
    func openCardCircle()
    func closeCardCircle()
    func terminateCall()
    func imOffline() // paneldeki browser kapanırsa
}

public protocol PopUpProtocol {
    func handlePopUpAction(action: Bool)
}

public protocol LoadingViewDelegate {
    func hideAllLoaders()
}

public protocol IdentifyManagerListener: class {
    func sdkResponse(stats: IdentifyListener)
//    func endCall()
//    func comingSms()
//    func openNFC()
//    func skipNFC()
//    func approvedSms(stats: Bool)
//    func openWarningCircle()
//    func closeWarningCircle()
//    func openCardCircle()
//    func closeCardCircle()
//    func terminateCall()
//    func imOffline() // paneldeki browser kapanırsa
}
