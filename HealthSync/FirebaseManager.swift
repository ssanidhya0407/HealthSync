//
//  FirebaseManager.swift
//  HealthSync
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  FirebaseManager.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  FirebaseManager.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {}
    
    func configure() {
        FirebaseApp.configure()
    }
    
    // MARK: - Authentication Methods
    
    func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func registerUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Utility Methods
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Database Operations
    
    func getDocument<T>(collection: String, documentId: String, completion: @escaping (Result<T?, Error>) -> Void) where T: Decodable {
        let db = Firestore.firestore()
        
        db.collection(collection).document(documentId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.success(nil))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: document.data() ?? [:])
                let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func saveDocument(collection: String, documentId: String? = nil, data: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()
        
        if let documentId = documentId {
            db.collection(collection).document(documentId).setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(documentId))
                }
            }
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection(collection).addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else if let documentId = ref?.documentID {
                    completion(.success(documentId))
                }
            }
        }
    }
    
    func updateDocument(collection: String, documentId: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection(collection).document(documentId).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteDocument(collection: String, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection(collection).document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
