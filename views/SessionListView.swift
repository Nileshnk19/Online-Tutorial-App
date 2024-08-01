//
//  SessionListView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import SwiftUI

struct SessionListView: View {
    
    @State private var userPressed = false
    @State private var isUserLoggedIn = false
    @State private var showprofile = false
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    
    var body: some View {
        TabView {
            SessionHome()
                .environmentObject(firedbHelper)
                .environmentObject(fireAuthHelper)
                .tabItem {
                    Image(systemName: "list.bullet.circle.fill")
                    Text("Session List")
                }//tabItem
            
            FavoritesListScreen()
                .environmentObject(firedbHelper)
                .environmentObject(fireAuthHelper)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites List")
                }//tabItem
            
            PurchaseListView()
                .environmentObject(firedbHelper)
                .environmentObject(fireAuthHelper)
                .tabItem {
                    Image(systemName: "ticket.fill")
                    Text("Purchase List")
                }//tabItem
        }//TabView
        .accentColor(.green)
        .navigationTitle("Sessions List")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            //firedbHelper.inserrtSessionList()
            firedbHelper.getAllSesstionList()
        }
        .toolbar() {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                //Login - Logout
                if (self.fireAuthHelper.isLoggedIn) {
                    
                    //User Profile
                    Button{
                        //open the profile screen
                        self.showprofile = true
                    } label: {
                        Text("Profile")
                    }
                    
                    Button {
                        self.fireAuthHelper.signOut()
                        self.userPressed = true
                    } label: {
                        Text("LogOut")
                            .bold()
                    }
                } else {
                    Button {
                        self.userPressed = true
                    } label: {
                        Text("LogIn")
                            .bold()
                    }
                }
            }
        }
        .navigationDestination(isPresented: $userPressed) {
            UserSignInView()
                .environmentObject(self.firedbHelper)
                .environmentObject(self.fireAuthHelper)
        }
        .navigationDestination(isPresented: self.$showprofile) {
            UserProfileView(selectedUserIndex: 0)
                .environmentObject(self.fireAuthHelper)
                .environmentObject(self.firedbHelper)
            
        }
        .navigationBarBackButtonHidden()
    }//body
}//SessionsListScreen

struct SessionHome: View {
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    
    var body: some View {
        VStack {
            
            List {
                if (self.firedbHelper.allSessionList.isEmpty){
                    Text("No sessions in the your collection yet... Go ahead and add some.")
                }else{
                    ForEach(self.firedbHelper.allSessionList.enumerated().map({$0}), id: \.element.self){index, currentSession in
                        
                        NavigationLink(destination: SessionDetailScreen(selectedSessionIndex: index)
                            .environmentObject(self.firedbHelper)
                            .environmentObject(self.fireAuthHelper)) {
                                HStack(spacing: 15) {
                                    Image("\(currentSession.photo[0])")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(currentSession.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Price/person: $\(currentSession.price, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                            }//ForEach
                    }//else
                }//List
            }
        }
    }
}

#Preview {
    SessionListView()
}
