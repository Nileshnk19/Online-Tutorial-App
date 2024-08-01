//
//  Session.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import Foundation
import FirebaseFirestoreSwift

struct SessionList: Hashable, Decodable, Encodable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var description: String
    var rating: Double
    var guideName: String
    var photo: [String]
    var price: Double
    var isFavorite: Bool
    var guidePhoneNumber: Int
    var location: String
    
    init(name: String, description: String, rating: Double, guideName: String, photo: [String], price: Double, isFavorite: Bool, guidePhoneNumber: Int, location: String) {
        self.name = name
        self.description = description
        self.rating = rating
        self.guideName = guideName
        self.photo = photo
        self.price = price
        self.isFavorite = isFavorite
        self.guidePhoneNumber = guidePhoneNumber
        self.location = location
    }
}
