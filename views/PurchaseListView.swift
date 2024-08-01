//
//  PurchaseListView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-11.
//

import SwiftUI

struct PurchaseListView: View {
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    @State private var logoutPressed = false
    
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
        VStack(alignment: .leading, spacing: 20) {
            List {
                ForEach(self.firedbHelper.purchaseList.enumerated().map({$0}), id: \.element.self) { index, currentPurchase in
                    NavigationLink(destination: PurchaseDetailView(selectedPurchaseIndex: index)
                        .environmentObject(self.firedbHelper)
                        .environmentObject(self.fireAuthHelper)) {
                            VStack(alignment: .leading, spacing: 5){
                                Text(currentPurchase.sessionName)
                                    .font(.headline)
                                Text("Date: \(currentPurchase.sessionDate, formatter: dateFormatter )")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Time: \(currentPurchase.sessionDate, formatter: timeFormatter )")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                            }
                            .padding(.vertical, 10)
                        }
                }
            }
            .navigationTitle("Sessions List")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: self.$logoutPressed) {
                ContentView()
            }
        }
        .padding()
        .onAppear {
            self.firedbHelper.getPurchases()
        }
    }
}


#Preview {
    PurchaseListView()
}
