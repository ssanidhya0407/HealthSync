//
//  AppointmentStatus.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  Appointment.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

enum AppointmentStatus: String {
    case pending = "pending"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelled = "cancelled"
}

struct Appointment {
    let id: String
    let patientId: String
    let doctorId: String
    let patientName: String
    let date: Date
    let reason: String
    let status: AppointmentStatus
    let updatedAt: Date
    let notes: String?
    
    init(id: String, patientId: String, doctorId: String, patientName: String, 
         date: Date, reason: String, status: AppointmentStatus = .pending, 
         updatedAt: Date = Date(), notes: String? = nil) {
        self.id = id
        self.patientId = patientId
        self.doctorId = doctorId
        self.patientName = patientName
        self.date = date
        self.reason = reason
        self.status = status
        self.updatedAt = updatedAt
        self.notes = notes
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let patientId = data["patientId"] as? String,
              let doctorId = data["doctorId"] as? String,
              let patientName = data["patientName"] as? String,
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let reason = data["reason"] as? String,
              let statusString = data["status"] as? String,
              let status = AppointmentStatus(rawValue: statusString) else {
            return nil
        }
        
        self.id = document.documentID
        self.patientId = patientId
        self.doctorId = doctorId
        self.patientName = patientName
        self.date = date
        self.reason = reason
        self.status = status
        self.updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        self.notes = data["notes"] as? String
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "patientId": patientId,
            "doctorId": doctorId,
            "patientName": patientName,
            "date": Timestamp(date: date),
            "reason": reason,
            "status": status.rawValue,
            "updatedAt": Timestamp(date: updatedAt)
        ]
        
        if let notes = notes {
            dict["notes"] = notes
        }
        
        return dict
    }
}