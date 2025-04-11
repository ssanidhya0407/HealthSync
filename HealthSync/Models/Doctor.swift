//
//  Doctor.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  Doctor.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct Doctor {
    let id: String
    let name: String
    let email: String
    let specialization: String
    let license: String
    let availability: String
    let registrationDate: Date
    let isActive: Bool
    let avgRating: Double
    let totalPatients: Int
    
    init(id: String, name: String, email: String, specialization: String, license: String, 
         availability: String, registrationDate: Date = Date(), isActive: Bool = true, 
         avgRating: Double = 5.0, totalPatients: Int = 0) {
        self.id = id
        self.name = name
        self.email = email
        self.specialization = specialization
        self.license = license
        self.availability = availability
        self.registrationDate = registrationDate
        self.isActive = isActive
        self.avgRating = avgRating
        self.totalPatients = totalPatients
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let email = data["email"] as? String,
              let specialization = data["specialization"] as? String,
              let license = data["license"] as? String,
              let availability = data["availability"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.email = email
        self.specialization = specialization
        self.license = license
        self.availability = availability
        self.registrationDate = (data["registrationDate"] as? Timestamp)?.dateValue() ?? Date()
        self.isActive = data["isActive"] as? Bool ?? true
        self.avgRating = data["avgRating"] as? Double ?? 5.0
        self.totalPatients = data["totalPatients"] as? Int ?? 0
    }
    
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "specialization": specialization,
            "license": license,
            "availability": availability,
            "registrationDate": Timestamp(date: registrationDate),
            "isActive": isActive,
            "avgRating": avgRating,
            "totalPatients": totalPatients
        ]
    }
}