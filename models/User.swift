//
//  User.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import Foundation
import FirebaseFirestoreSwift

struct User : Hashable, Codable{
    
    @DocumentID var id : String? = UUID().uuidString
    var email : String = ""
    var name : String = ""
    var contactNumber : String = ""
    var cardDetail : String = ""
    
    init() {
        
    }
    
    init(email: String, name: String, contactNumber: String, cardDetail: String) {
        self.email = email
        self.name = name
        self.contactNumber = contactNumber
        self.cardDetail = cardDetail
    }
}
