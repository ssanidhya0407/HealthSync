//
//  Patient.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  Patient.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct Patient {
    let id: String
    let name: String
    let email: String
    let phoneNumber: String?
    let dateOfBirth: Date?
    let registrationDate: Date
    
    init(id: String, name: String, email: String, phoneNumber: String? = nil, dateOfBirth: Date? = nil, registrationDate: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.registrationDate = registrationDate
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.email = email
        self.phoneNumber = data["phoneNumber"] as? String
        self.dateOfBirth = (data["dateOfBirth"] as? Timestamp)?.dateValue()
        self.registrationDate = (data["registrationDate"] as? Timestamp)?.dateValue() ?? Date()
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "email": email,
            "userType": "patient",
            "registrationDate": Timestamp(date: registrationDate)
        ]
        
        if let phoneNumber = phoneNumber {
            dict["phoneNumber"] = phoneNumber
        }
        
        if let dateOfBirth = dateOfBirth {
            dict["dateOfBirth"] = Timestamp(date: dateOfBirth)
        }
        
        return dict
    }
}