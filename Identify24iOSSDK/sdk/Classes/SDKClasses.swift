//
//  SDKClasses.swift
//  Kimlik
//
//  Created by Emir Beytekin on 20.04.2021.
//

import UIKit

public class Modules: Decodable {
    public var mName: String?
    public var mValue: SdkModules?
}

public class GlobalConstants {
    public static var appLogo: UIImage?
    public static var nfcErrorMaxCount: Int? = 3
}

public class IdentifyListener: Codable {
    var status: Bool?
    var message: String?
    
    init(status:Bool, message: String) {
        self.status = status
        self.message = message
    }
}
