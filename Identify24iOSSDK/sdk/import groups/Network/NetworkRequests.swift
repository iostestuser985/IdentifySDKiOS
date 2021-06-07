//
//  NetworkRequests.swift
//  identSDK
//
//  Created by MacBookPro on 16.01.2021.
//  Copyright © 2021 Emir Beytekin. All rights reserved.
//

import Foundation
import Alamofire

public class SDKNetwork {
    
    public var BASE_URL = ""
    
    public func connectToRoom(identId: String, callback: @escaping((_ results: RoomResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/getIdentDetails/" + IdentifyManager.shared.userToken
        var jsonHeaders = [String : String]()
        jsonHeaders["Content-Type"] = "application/json"
        // debug// print(urlStr)
        
        Alamofire.request(urlStr, method: .get, parameters:nil, encoding: URLEncoding.default , headers:jsonHeaders).validate(contentType: ["application/json"]).responseJSON { response in
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(RoomResponse.self, from: data)
                if forceResp.messages?.count ?? 0 > 0 {
                    self.showAlert(msg: forceResp.messages?[0] ?? "Hata var!")
                } else {
                    DispatchQueue.main.async {
                        callback(forceResp)
                    }
                }
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func verifySms(tid: String, tan: String, callback: @escaping ((_ results: EmptyResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/verifyTan"
        var jsonHeaders = [String : String]()
        jsonHeaders["Content-Type"] = "application/json"
        let papara = SmsJson.init(tid: tid, tan: tan)
        
        Alamofire.request(urlStr, method: .post, parameters:papara.asDictionary(), encoding: JSONEncoding.default , headers:jsonHeaders).responseJSON { response in

            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(EmptyResponse.self, from: data)
                if forceResp.messages?.count ?? 0 > 0 {
                    self.showAlert(msg: forceResp.messages?[0] ?? "Hata var!")
                }
                DispatchQueue.main.async {
                    callback(forceResp)
                }
                
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func verifyNFC(model: IdentifyCard, callback: @escaping ((_ results: Bool) -> Void)) {
        let urlStr = BASE_URL + "mobile/nfc_verify"
        var jsonHeaders = [String : String]()
        jsonHeaders["Content-Type"] = "application/json"
        
        Alamofire.request(urlStr, method: .post, parameters:model.asDictionary(), encoding: JSONEncoding.default , headers:jsonHeaders).responseJSON { response in

//            if let  JSON = response.result.value,
//                let JSONData = try? JSONSerialization.data(withJSONObject: JSON, options: .pretty// printed),
//                let prettyString = NSString(data: JSONData, encoding: String.Encoding.utf8.rawValue) {
//            }
            
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(BoolResponse.self, from: data)
                
                DispatchQueue.main.async {
                    callback(forceResp.result ?? false)
                }
                
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func uploadSelfieImage(image: String, selfieType: SelfieTypes, callback: @escaping ((_ results: Bool) -> Void)) {
        let urlStr = BASE_URL + "mobile/upload"
        var params = [String : String]()
        params["type"] = selfieType.rawValue
        params["ident_id"] = IdentifyManager.shared.userToken
        params["image"] = image
        var jsonHeaders = [String : String]()
        jsonHeaders["Content-Type"] = "application/json"
        
        Alamofire.request(urlStr, method: .post, parameters:params, encoding: JSONEncoding.default , headers:jsonHeaders).responseJSON { response in
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(BoolResponse.self, from: data)
                DispatchQueue.main.async {
                    callback(forceResp.result ?? false)
                }
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func showAlert(msg: String) {
        AlertViewManager.defaultManager.showOkAlert("Hata", message: msg) { (action) in }
    }
    
}
public class IdentifyCardSDK: Codable {
    public var ident_id: String?
    public var name: String?
    public var surname: String?
    public var personalNumber: String?
    public var birthDate: String?
    public var expireDate: String?
    public var serialNumber: String?
    public var nationality: String?
    public var docType: String?
    public var authority: String?
    public var gender: String?
    public var image: String?

    public init() { }

    public init(ident_id: String?, name: String?, surname: String?, personalNumber: String?, birthdate: String?, expireDate: String?, serialNumber: String?, nationality: String?, docType: String?, authority: String?, gender: String?, image: String?) {
        self.ident_id = ident_id
        self.name = name
        self.surname = surname
        self.personalNumber = personalNumber
        self.birthDate = birthdate
        self.expireDate = expireDate
        self.serialNumber = serialNumber
        self.nationality = nationality
        self.docType = docType
        self.authority = authority
        self.gender = gender
        self.image = image
    }

}
