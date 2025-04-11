//
//  Order.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//

//
//  Order.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import Foundation
import FirebaseFirestore

enum OrderStatus: String {
    case processing = "processing"
    case shipped = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"
}

struct Order {
    let id: String
    let userId: String
    let orderDate: Date
    let items: [String]
    let status: OrderStatus
    let totalAmount: Double
    let deliveryAddress: String?
    
    init(id: String, userId: String, orderDate: Date = Date(),
         items: [String], status: OrderStatus = .processing,
         totalAmount: Double, deliveryAddress: String? = nil) {
        self.id = id
        self.userId = userId
        self.orderDate = orderDate
        self.items = items
        self.status = status
        self.totalAmount = totalAmount
        self.deliveryAddress = deliveryAddress
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let userId = data["userId"] as? String,
              let orderDate = (data["orderDate"] as? Timestamp)?.dateValue(),
              let items = data["items"] as? [String],
              let statusString = data["status"] as? String,
              let status = OrderStatus(rawValue: statusString),
              let totalAmount = data["totalAmount"] as? Double else {
            return nil
        }
        
        self.id = document.documentID
        self.userId = userId
        self.orderDate = orderDate
        self.items = items
        self.status = status
        self.totalAmount = totalAmount
        self.deliveryAddress = data["deliveryAddress"] as? String
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "orderDate": Timestamp(date: orderDate),
            "items": items,
            "status": status.rawValue,
            "totalAmount": totalAmount
        ]
        
        if let deliveryAddress = deliveryAddress {
            dict["deliveryAddress"] = deliveryAddress
        }
        
        return dict
    }
}
