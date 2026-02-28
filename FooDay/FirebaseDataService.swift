//
//  FirebaseDataService.swift
//  FooDay
//
//  Created by Your Name on 25/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseDataService {

    static let shared = FirebaseDataService()
    private let db = Firestore.firestore()

    func fetchRestaurants(completion: @escaping ([Restaurant]) -> Void) {
        db.collection("restaurants").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }

            let restaurants = querySnapshot?.documents.compactMap { document -> Restaurant? in
                try? document.data(as: Restaurant.self)
            } ?? []
            
            completion(restaurants)
        }
    }
    
    func fetchOrderHistory(for userId: String, completion: @escaping ([Order]) -> Void) {
        db.collection("orders")
          .whereField("user_id", isEqualTo: userId)
          .getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }

            let orders = querySnapshot?.documents.compactMap { document -> Order? in
                try? document.data(as: Order.self)
            } ?? []
            
            completion(orders)
        }
    }
    
    // We can add more functions here later for things like:
    // - Placing an order
    // - Updating user profile
    // - Fetching a specific restaurant's menu
}
