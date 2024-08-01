//
//  PurchaseDetailView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-11.
//

import SwiftUI

struct PurchaseDetailView: View {
    
    let selectedPurchaseIndex : Int
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    @State private var price: Double = 0.0
    @State private var numberOfTickets: Int = 0
    @State private var session: SessionList = SessionList(name: "", description: "", rating: 0.0, guideName: "", photo: [], price: 0.0, isFavorite: false, guidePhoneNumber: 0, location: "")
    
    @State private var logoutPressed = false
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 20) {
            // Session details
            VStack(alignment: .leading, spacing: 10) {
                Text(self.name)
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                
                Text(self.session.description)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Star rating and guide info
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Star Rating:")
                        .font(.headline)
                    Text("\(self.session.rating, specifier: "%.1f")/5.0")
                        .foregroundColor(.blue)
                }
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Guide:")
                        .font(.headline)
                    Text(self.session.guideName)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Session photos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(self.session.photo, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
                .padding(.horizontal)
            }
            
            // Pricing
            VStack(spacing: 10) {
                // Show on Map
                Button(action: {
                    let address = self.session.location.replacingOccurrences(of: " ", with: "+")
                    let urlString = "https://maps.apple.com/?address=\(address)"
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "map")
                        Text(self.session.location)
                            .padding()
                    }
                }
                
                HStack {
                    Text("Number of Tickets:")
                        .font(.headline)
                    Spacer()
                    Text("\(self.numberOfTickets)")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Price:")
                        .font(.headline)
                    Spacer()
                    Text("$\(self.session.price * Double(self.numberOfTickets), specifier: "%.2f")")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Date: \(self.date, formatter: dateFormatter)")
                        .font(.subheadline)
                    Spacer()
                    Text("Time: \(self.time, formatter: timeFormatter)")
                        .font(.subheadline)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Session Detail")
        .onAppear() {
            self.name = self.firedbHelper.purchaseList[selectedPurchaseIndex].sessionName
            self.date = self.firedbHelper.purchaseList[selectedPurchaseIndex].sessionDate
            self.time = self.firedbHelper.purchaseList[selectedPurchaseIndex].sessionDate
            self.price = self.firedbHelper.purchaseList[selectedPurchaseIndex].sessionPrice
            self.numberOfTickets = self.firedbHelper.purchaseList[selectedPurchaseIndex].numberOfTickets
            self.session = self.firedbHelper.purchaseList[selectedPurchaseIndex].session
        }
        .toolbar {
            ToolbarItem(placement:.navigationBarTrailing) {
                NavigationLink(destination: ContentView(), isActive: self.$logoutPressed) {
                    Button {
                        UserDefaults.standard.removeObject(forKey: "UserEmail")
                        UserDefaults.standard.removeObject(forKey: "UserPassword")
                        UserDefaults.standard.removeObject(forKey: "UserRememberMe")
                        self.logoutPressed = true
                    } label: {
                        Text("LogOut")
                            .bold()
                    }//label
                }//NavigationLink
            }//ToolbarItem
        }//toolbar
    }
}

