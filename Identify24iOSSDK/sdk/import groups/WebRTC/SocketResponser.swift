//
//  SocketResponser.swift
//  identSDK
//
//  Created by Emir on 13.08.2020.
//  Copyright © 2020 Emir Beytekin. All rights reserved.
//

import UIKit

public class SocketResponser: NSObject {

}


public class FirstRoom: Codable {
    var id: String?
    var status: String?
    var form_uid: String?
    var created_at: String?
    var created_by: String?
    var customer_id: String?
    var customer_uid: String?
    
    init() {
        self.id = ""
        self.status = ""
        self.form_uid = ""
        self.created_at = ""
        self.created_by = ""
        self.customer_id = ""
        self.customer_uid = ""
    }

    init(id: String?, status: String?, form_uid: String?, created_at: String?, created_by: String?, customer_id: String?, customer_uid: String?) {
        self.id = id
        self.status = status
        self.form_uid = form_uid
        self.created_at = created_at
        self.created_by = created_by
        self.customer_id = customer_id
        self.customer_uid = customer_uid
    }
    
}

public class RoomResponse: Codable {
    var result: Bool?
    var response_status: Int?
    var messages: [String]?
    var data: FirstRoom?
    var allowed_content_types: String?

    init(result: Bool?, response_status: Int?, messages: [String]?, data: FirstRoom?, allowed_content_types: String?) {
        self.result = result
        self.response_status = response_status
        self.messages = messages
        self.data = data
        self.allowed_content_types = allowed_content_types
    }

    init() {
        self.result = false
        self.response_status = 0
        self.messages = [String]()
        self.data = FirstRoom()
        self.allowed_content_types = ""
    }
}

public class EmptyResponse: Codable {
    var result: Bool?
    var messages: [String]?
    var data: SMSData?

    init(result: Bool?, messages: [String]?, data: SMSData?) {
        self.result = result
        self.messages = messages
        self.data = data
    }
}

public class SMSData: Codable {
    var id: String?
    init(id: String?) {
        self.id = id
    }
}

public class SmsJson: Codable {
    var tid: String?
    var tan: String?

    init(tid: String?, tan: String?) {
        self.tid = tid
        self.tan = tan
    }
}

public class BoolResponse: Codable {
    var result: Bool?
    
    init(result: Bool?) {
        self.result = result
    }
}
