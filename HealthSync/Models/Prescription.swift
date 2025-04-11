//
//  Prescription.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  Prescription.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct Prescription {
    let id: String
    let patientId: String
    let doctorId: String
    let patientName: String
    let date: Date
    let instructions: String
    let medicines: [PrescriptionMedicine]
    
    struct PrescriptionMedicine {
        let name: String
        let dosage: String
        let frequency: String
        let duration: String
    }
    
    init(id: String, patientId: String, doctorId: String, patientName: String,
         date: Date, instructions: String, medicines: [PrescriptionMedicine]) {
        self.id = id
        self.patientId = patientId
        self.doctorId = doctorId
        self.patientName = patientName
        self.date = date
        self.instructions = instructions
        self.medicines = medicines
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let patientId = data["patientId"] as? String,
              let doctorId = data["doctorId"] as? String,
              let patientName = data["patientName"] as? String,
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let instructions = data["instructions"] as? String,
              let medicinesData = data["medicines"] as? [[String: Any]] else {
            return nil
        }
        
        let medicines = medicinesData.compactMap { medicineData -> PrescriptionMedicine? in
            guard let name = medicineData["name"] as? String,
                  let dosage = medicineData["dosage"] as? String,
                  let frequency = medicineData["frequency"] as? String,
                  let duration = medicineData["duration"] as? String else {
                return nil
            }
            
            return PrescriptionMedicine(name: name, dosage: dosage, frequency: frequency, duration: duration)
        }
        
        self.id = document.documentID
        self.patientId = patientId
        self.doctorId = doctorId
        self.patientName = patientName
        self.date = date
        self.instructions = instructions
        self.medicines = medicines
    }
    
    func toDict() -> [String: Any] {
        let medicinesData = medicines.map { medicine -> [String: Any] in
            return [
                "name": medicine.name,
                "dosage": medicine.dosage,
                "frequency": medicine.frequency,
                "duration": medicine.duration
            ]
        }
        
        return [
            "id": id,
            "patientId": patientId,
            "doctorId": doctorId,
            "patientName": patientName,
            "date": Timestamp(date: date),
            "instructions": instructions,
            "medicines": medicinesData
        ]
    }
}