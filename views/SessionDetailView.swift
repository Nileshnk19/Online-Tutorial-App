//
//  SessionDetailView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import SwiftUI

struct SessionDetailScreen: View {
    
    let selectedSessionIndex : Int
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var rating: Double = 0.0
    @State private var guideName: String = ""
    @State private var photo: [String] = []
    @State private var price: Double = 0.0
    @State private var isFavorite: Bool = false
    @State private var guidePhoneNumber: Int = 0
    @State private var showFavouriteListView: Bool = false
    @State private var showSessionListView: Bool = false
    @State private var showUserSignInView: Bool = false
    @State private var showingAlert: Bool = false
    @State private var messageAlert: String = "Alert Message"
    @State private var location: String = ""
    @State private var isShowingShareSheet: Bool = false
    
    //@State var session: SessionList
    
    @State private var logoutPressed = false
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    
    @State private var showPurchaseDialog = false
    @State private var numberOfTickets = 1
    
    var body: some View {
        VStack(spacing: 20) {
            // Session details
            VStack(alignment: .leading, spacing: 10) {
                Text(self.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                Text(self.description)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Star rating and guide info
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Star Rating:")
                        .font(.headline)
                    Text("\(self.rating, specifier: "%.1f")/5.0")
                        .foregroundColor(.blue)
                }
                Spacer()

                VStack(alignment: .leading, spacing: 5) {
                    Text("Guide:")
                        .font(.headline)
                    Text(self.guideName)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            // Session photos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(self.photo, id: \.self) { imageName in
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

            // Show on Map
            Button(action: {
                let address = self.location.replacingOccurrences(of: " ", with: "+")
                let urlString = "https://maps.apple.com/?address=\(address)"
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "map")
                    Text(self.location).padding()
                }
            }
            .padding(.horizontal)

            // Pricing
            HStack {
                Text("Price:")
                    .font(.headline)
                Spacer()
                Text("$\(self.price, specifier: "%.2f")")
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)

            // Buttons
            HStack(spacing: 20) {
                Button(action: {
                    self.isFavorite.toggle()
                    //self.userData.currentUser?.favorites.append(session)

                    if (self.fireAuthHelper.isLoggedIn) {
                        if self.isFavorite {
                            
                            //checking if the favouriteList already have the session
                            if self.firedbHelper.alreadyAddedToFavouriteList == false {
                                self.firedbHelper.insertFavourite(newFavourite: self.firedbHelper.allSessionList[self.selectedSessionIndex])
                                self.firedbHelper.allSessionList[self.selectedSessionIndex].isFavorite = true
                                self.firedbHelper.updateFavourite(favouriteToUpdate: self.firedbHelper.allSessionList[self.selectedSessionIndex])
                                print(#function, "Updated Data: \(self.firedbHelper.allSessionList)")

                            } else {
                                self.messageAlert = "This sesion is already added in the favourite list..."
                                self.showingAlert = true
                            }

                            //redirecting to the all sessionListView
                            self.showSessionListView = true

                        } else {
                            self.firedbHelper.deleteFavourite(favouriteTodelete: self.firedbHelper.favouriteList[self.selectedSessionIndex])
                            self.firedbHelper.allSessionList[self.selectedSessionIndex].isFavorite = false
                            self.firedbHelper.updateFavourite(favouriteToUpdate: self.firedbHelper.allSessionList[self.selectedSessionIndex])
                            self.showSessionListView = true
                        }//else

                    } else {

                        //redirect to login screen
                        showUserSignInView = true
                    }//else
                }) {
                    VStack {
                        Image(systemName: self.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(self.isFavorite ? .red : .gray)
                        Text(self.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                            .font(.caption)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())

                Button(action: {
                    self.isShowingShareSheet = true
                }) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .font(.caption)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())

                Button(action: {
                    callGuide()
                }) {
                    VStack {
                        Image(systemName: "phone")
                        Text("Call Guide")
                            .font(.caption)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())

                Button(action: {
                    if fireAuthHelper.isLoggedIn {
                        showPurchaseDialog = true
                    } else {
                        // Navigate to login screen
                        showUserSignInView = true
                    }
                }) {
                    VStack {
                        Image(systemName: "ticket.fill")
                        Text("Purchase")
                            .font(.caption)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Spacer()
        }

        .padding()
        .navigationTitle("Session Detail")
        .onAppear() {
            self.name = self.firedbHelper.allSessionList[selectedSessionIndex].name
            self.description = self.firedbHelper.allSessionList[selectedSessionIndex].description
            self.rating = self.firedbHelper.allSessionList[selectedSessionIndex].rating
            self.guideName = self.firedbHelper.allSessionList[selectedSessionIndex].guideName
            self.photo = self.firedbHelper.allSessionList[selectedSessionIndex].photo
            self.price = self.firedbHelper.allSessionList[selectedSessionIndex].price
            self.isFavorite = self.firedbHelper.allSessionList[selectedSessionIndex].isFavorite
            self.guidePhoneNumber = self.firedbHelper.allSessionList[selectedSessionIndex].guidePhoneNumber
            self.location = self.firedbHelper.allSessionList[selectedSessionIndex].location
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
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(activityItems: ["Check out this session: \(self.name) for $\(self.price) per person!"])
        }//sheet
        .sheet(isPresented: $showPurchaseDialog) {
            PurchaseView(session: self.firedbHelper.allSessionList[selectedSessionIndex], numberOfTickets: $numberOfTickets)
                .environmentObject(firedbHelper)
                .environmentObject(fireAuthHelper)
        }
        .navigationDestination(isPresented: self.$showSessionListView) {
            SessionListView()
                .environmentObject(self.firedbHelper)
                .environmentObject(self.fireAuthHelper)
            
        }
        .navigationDestination(isPresented: self.$showFavouriteListView) {
            FavoritesListScreen()
                .environmentObject(self.firedbHelper)
                .environmentObject(self.fireAuthHelper)
            
        }
        .navigationDestination(isPresented: self.$showUserSignInView) {
            UserSignInView()
                .environmentObject(self.firedbHelper)
                .environmentObject(self.fireAuthHelper)
            
        }
        .alert(self.messageAlert, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }//alert
    }
    
    func shareSession() {
        let activityViewController = UIActivityViewController(activityItems: ["Session: \(self.name), Price: \(self.price)"], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func callGuide() {
        let numberString = self.guidePhoneNumber
        
        guard let phoneURL = URL(string: "tel://\(numberString)") else {
            return
        }
        
        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
    }
}

struct PurchaseView: View {
    
    var session: SessionList
    @Binding var numberOfTickets: Int
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    @State private var showSessionListView: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Purchase Tickets for \(session.name)")
                .font(.title2)
                .padding()
            
            Stepper("Number of Tickets: \(numberOfTickets)", value: $numberOfTickets, in: 1...10)
                .padding()
            
            Button(action: {
                let purchase = Purchase(session: session, sessionName: session.name, sessionDate: Date(), sessionTime: "", sessionPrice: session.price, numberOfTickets: self.numberOfTickets, userEmail: self.firedbHelper.FIELD_EMAIL)
                self.firedbHelper.addPurchase(purchase: purchase)
                self.showSessionListView = true
                self.dismiss()
                
            }) {
                Text("Confirm Purchase")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .navigationDestination(isPresented: self.$showSessionListView) {
                SessionListView()
                    .environmentObject(self.firedbHelper)
                    .environmentObject(self.fireAuthHelper)
                
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
