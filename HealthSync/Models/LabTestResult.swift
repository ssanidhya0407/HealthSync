//
//  LabTestResult.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

enum LabResultStatus: String {
    case pending = "pending"
    case completed = "completed"
}

struct LabTestResult {
    let id: String
    let patientId: String
    let doctorId: String
    let patientName: String
    let testDate: Date
    let results: String
    let status: LabResultStatus
    let labTest: LabTestInfo
    
    struct LabTestInfo {
        let id: String
        let name: String
        let price: Double
        let description: String
    }
    
    init(id: String, patientId: String, doctorId: String, patientName: String,
         testDate: Date, results: String, status: LabResultStatus = .pending,
         labTest: LabTestInfo) {
        self.id = id
        self.patientId = patientId
        self.doctorId = doctorId
        self.patientName = patientName
        self.testDate = testDate
        self.results = results
        self.status = status
        self.labTest = labTest
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let patientId = data["patientId"] as? String,
              let doctorId = data["doctorId"] as? String,
              let patientName = data["patientName"] as? String,
              let testDate = (data["testDate"] as? Timestamp)?.dateValue(),
              let results = data["results"] as? String,
              let statusString = data["status"] as? String,
              let status = LabResultStatus(rawValue: statusString),
              let labTestData = data["labTest"] as? [String: Any],
              let labTestId = labTestData["id"] as? String,
              let labTestName = labTestData["name"] as? String,
              let labTestPrice = labTestData["price"] as? Double,
              let labTestDescription = labTestData["description"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.patientId = patientId
        self.doctorId = doctorId
        self.patientName = patientName
        self.testDate = testDate
        self.results = results
        self.status = status
        self.labTest = LabTestInfo(id: labTestId, name: labTestName, price: labTestPrice, description: labTestDescription)
    }
    
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "patientId": patientId,
            "doctorId": doctorId,
            "patientName": patientName,
            "testDate": Timestamp(date: testDate),
            "results": results,
            "status": status.rawValue,
            "labTest": [
                "id": labTest.id,
                "name": labTest.name,
                "price": labTest.price,
                "description": labTest.description
            ]
        ]
    }
}
