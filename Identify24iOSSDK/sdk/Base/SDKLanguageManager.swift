//
//  LanguageManager.swift
//  Kimlik
//
//  Created by MacBookPro on 13.02.2021.
//

import UIKit

public class SDKLanguageManager: NSObject {
    
    public override init() {}
    
    public static let shared = SDKLanguageManager()
    
    public func translate(key: Keywords) -> String {
        switch key {
        case .connect:
            return NSLocalizedString("Connect", comment: "")
        case .connectInfo:
            return NSLocalizedString("ConnectInfo", comment: "")
        case .scanAgain:
            return NSLocalizedString("ScanAgain", comment: "")
        case .scanInfo:
            return NSLocalizedString("ScanInfo", comment: "")
        case .humanSmile:
            return NSLocalizedString("HumanSmile", comment: "")
        case .humanSmileDescription:
            return NSLocalizedString("HumanSmileDescription", comment: "")
        case .callTitle:
            return NSLocalizedString("CallTitle", comment: "")
        case .callDescription:
            return NSLocalizedString("CallDescription", comment: "")
        case .enterSmsCode:
            return NSLocalizedString("EnterSmsCode", comment: "")
        case .waitingDesc1:
            return NSLocalizedString("WaitingDesc1", comment: "")
        case .waitingDesc2:
            return NSLocalizedString("WaitingDesc2", comment: "")
        case .thankU:
            return NSLocalizedString("ThankU", comment: "")
            
        case .board1:
            return NSLocalizedString("OnPage1", comment: "")
        case .board2:
            return NSLocalizedString("OnPage2", comment: "")
        case .board3:
            return NSLocalizedString("OnPage3", comment: "")
        case .board4:
            return NSLocalizedString("OnPage4", comment: "")
        case .board5:
            return NSLocalizedString("OnPage5", comment: "")
            
        case .nextPage:
            return NSLocalizedString("NextPage", comment: "")
        case .backPage:
            return NSLocalizedString("BackPage", comment: "")
        case .skipPage:
            return NSLocalizedString("SkipPage", comment: "")
        case .continuePage:
            return NSLocalizedString("Continue", comment: "")
            
        case .popSelfie:
            return NSLocalizedString("PopSelfie", comment: "")
        case .popSmiley:
            return NSLocalizedString("PopSmiley", comment: "")
        case .popVideo:
            return NSLocalizedString("PopVideo", comment: "")
        case .popMRZ:
            return NSLocalizedString("PopMRZ", comment: "")
        case .popNFC:
            return NSLocalizedString("PopNFC", comment: "")
        case .popIdBackPhoto:
            return NSLocalizedString("PopIdBackPhoto", comment: "")
        case .popIdFrontPhoto:
            return NSLocalizedString("PopIdFrontPhoto", comment: "")
        case .signatureInfo:
            return NSLocalizedString("SignatureInfo", comment: "")
        case .soundRecognitionInfo:
            return NSLocalizedString("SoundRecognitionInfo", comment: "")
        case .coreError:
            return NSLocalizedString("CoreError", comment: "")
        case .coreSuccess:
            return NSLocalizedString("CoreSuccess", comment: "")
        case .wrongSMSCode:
            return NSLocalizedString("WrongSMSCode", comment: "")
        case .coreOk:
            return NSLocalizedString("CoreOK", comment: "")
        }
    }

}

public enum Keywords {
    case connect
    case connectInfo
    case scanAgain
    case scanInfo
    case humanSmile
    case humanSmileDescription
    case callTitle
    case callDescription
    case enterSmsCode
    case waitingDesc1
    case waitingDesc2
    case thankU
    case board1
    case board2
    case board3
    case board4
    case board5
    case nextPage
    case backPage
    case skipPage
    case continuePage
    case popSelfie
    case popSmiley
    case popVideo
    case popMRZ
    case popNFC
    case popIdBackPhoto
    case popIdFrontPhoto
    case signatureInfo
    case soundRecognitionInfo
    case coreError
    case coreSuccess
    case wrongSMSCode
    case coreOk
}
