//
//  FavoritesListView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import SwiftUI

struct FavoritesListScreen: View {
    
    @State private var userPressed = false
    @State private var isUserLoggedIn = false
    @State private var showSessionListView = false
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    
    var body: some View {
        VStack(spacing: 20) {
                    
                    List {
                        if self.firedbHelper.favouriteList.isEmpty {
                            Text("No sessions in your collection yet... Go ahead and add some.")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(self.firedbHelper.favouriteList.enumerated().map({$0}), id: \.element.self) { index, currentSession in
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
                                }
                            }
                            .onDelete(perform: { indexSet in
                                for index in indexSet {
                                    self.firedbHelper.allSessionList[index].isFavorite = false
                                    self.firedbHelper.updateFavourite(favouriteToUpdate: self.firedbHelper.allSessionList[index])
                                    self.firedbHelper.deleteFavourite(favouriteTodelete: self.firedbHelper.favouriteList[index])
                                }
                            })
                            
                            Spacer()
                            
                            Button(action: {
                                self.firedbHelper.deleteAllFavourite()
                                showSessionListView = true
                            }) {
                                Text("Remove All")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Favourite Sessions")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .accentColor(.green)
        .navigationTitle("Sessions List")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            //firedbHelper.inserrtSessionList()
            firedbHelper.getAllFavouriteList()
        }
        .navigationDestination(isPresented: $userPressed) {
            UserSignInView()
                .environmentObject(self.firedbHelper)
                .environmentObject(self.fireAuthHelper)
        }
        .navigationDestination(isPresented: $showSessionListView) {
            SessionListView()
                .environmentObject(self.firedbHelper)
                .environmentObject(self.fireAuthHelper)
        }
        .navigationBarBackButtonHidden()
    }//body
}//SessionsListScreen

#Preview {
    SessionListView()
}
