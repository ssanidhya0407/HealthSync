//
//  LabTest.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  LabTest.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct LabTest {
    let id: String
    let name: String
    let price: Double
    let description: String
    let preparationInstructions: String?
    
    init(id: String, name: String, price: Double, description: String, preparationInstructions: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.preparationInstructions = preparationInstructions
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let price = data["price"] as? Double,
              let description = data["description"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.price = price
        self.description = description
        self.preparationInstructions = data["preparationInstructions"] as? String
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "price": price,
            "description": description
        ]
        
        if let preparationInstructions = preparationInstructions {
            dict["preparationInstructions"] = preparationInstructions
        }
        
        return dict
    }
}