
//
//  FirebaseManager.swift
//  FooDay
//
//  Created by Your Name on 25/02/2024.
//

import Foundation
import Firebase

class FirebaseManager {

    static let shared = FirebaseManager()

    func configure() {
        FirebaseApp.configure()
    }
}
