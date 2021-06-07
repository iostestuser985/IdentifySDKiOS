//
//  PassportModel.swift
//  IDCardPassportNFCReader
//
//  Created by AliOzdem on 10.06.2020.
//  Copyright © 2020 AliMert. All rights reserved.
//

import Foundation
import UIKit

public class PassportModel {

    public static var documentImage: UIImage = UIImage()
    public static var documentType: String = ""
    public static var countryCode: String = ""
    public static var surnames: String = ""
    public static var givenNames: String = ""
    public static var documentNumber: String = ""
    public static var nationality: String = ""
    public static var birthDate: Date? = Date()
    public static var sex: String = ""
    public static var expiryDate: Date? = Date()
    public static var personalNumber: String = ""

    public init() { }

    public init(documentNumber: String, birthDate: Date, expiryDate: Date) {
        PassportModel.documentNumber = documentNumber
        PassportModel.birthDate = birthDate
        PassportModel.expiryDate = expiryDate
    }

}

public class IdentifyCard: Codable {
    public static var ident_id: String?
    public static var name: String?
    public static var surname: String?
    public static var personalNumber: String?
    public static var birthDate: String?
    public static var expireDate: String?
    public static var serialNumber: String?
    public static var nationality: String?
    public static var docType: String?
    public static var authority: String?
    public static var gender: String?
    public static var image: String?

    public init() { }

    public init(ident_id: String?, name: String?, surname: String?, personalNumber: String?, birthdate: String?, expireDate: String?, serialNumber: String?, nationality: String?, docType: String?, authority: String?, gender: String?, image: String?) {
        IdentifyCard.ident_id = ident_id
        IdentifyCard.name = name
        IdentifyCard.surname = surname
        IdentifyCard.personalNumber = personalNumber
        IdentifyCard.birthDate = birthdate
        IdentifyCard.expireDate = expireDate
        IdentifyCard.serialNumber = serialNumber
        IdentifyCard.nationality = nationality
        IdentifyCard.docType = docType
        IdentifyCard.authority = authority
        IdentifyCard.gender = gender
        IdentifyCard.image = image
    }

}
