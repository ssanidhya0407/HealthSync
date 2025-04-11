//
//  Medicine.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  Medicine.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

struct Medicine {
    let id: String
    let name: String
    let price: Double
    let description: String
    let manufacturer: String?
    let category: String?
    let requiresPrescription: Bool
    let inStock: Bool
    
    init(id: String, name: String, price: Double, description: String, 
         manufacturer: String? = nil, category: String? = nil,
         requiresPrescription: Bool = false, inStock: Bool = true) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.manufacturer = manufacturer
        self.category = category
        self.requiresPrescription = requiresPrescription
        self.inStock = inStock
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
        self.manufacturer = data["manufacturer"] as? String
        self.category = data["category"] as? String
        self.requiresPrescription = data["requiresPrescription"] as? Bool ?? false
        self.inStock = data["inStock"] as? Bool ?? true
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "price": price,
            "description": description,
            "requiresPrescription": requiresPrescription,
            "inStock": inStock
        ]
        
        if let manufacturer = manufacturer {
            dict["manufacturer"] = manufacturer
        }
        
        if let category = category {
            dict["category"] = category
        }
        
        return dict
    }
}