//
//  Purchase.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-11.
//

import Foundation
import FirebaseFirestoreSwift

struct Purchase: Hashable, Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var session: SessionList
    var sessionName: String
    var sessionDate: Date
    var sessionTime: String
    var sessionPrice: Double
    var numberOfTickets: Int
    var userEmail: String // Assuming you associate purchases with users
    
    init(session: SessionList, sessionName: String, sessionDate: Date, sessionTime: String, sessionPrice: Double, numberOfTickets: Int, userEmail: String) {
        self.session = session
        self.sessionName = sessionName
        self.sessionDate = sessionDate
        self.sessionTime = sessionTime
        self.sessionPrice = sessionPrice
        self.numberOfTickets = numberOfTickets
        self.userEmail = userEmail
    }
}
