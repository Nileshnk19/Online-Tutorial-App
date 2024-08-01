//
//  UserProfileView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-11.
//

import SwiftUI

struct UserProfileView: View {
    
    let selectedUserIndex: Int
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var contactNumber: String = ""
    @State private var cardDetail: String = ""
    @State private var showingAlert: Bool = false
    @State private var messageAlert: String = "Alert Message"
    @State private var showSignIn: Bool = false
    @State private var showAllParking: Bool = false
    
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .clipShape(Circle())
                .shadow(radius: 10)
                .padding(.top, 50)
                    
                    Form {
                        TextField("Enter Name", text: self.$name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Enter Email", text: self.$email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                        
                        TextField("Enter Contact Number", text: self.$contactNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Enter Car Number Plate", text: self.$cardDetail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .disableAutocorrection(true)
                    
                    Section {
                        Button(action: {
                            // Task: validate the data
                            if self.name.isEmpty || self.email.isEmpty || self.contactNumber.isEmpty || self.cardDetail.isEmpty {
                                self.messageAlert = "Please, enter all the values..."
                                self.showingAlert = true
                            } else {
                                // Update user information
                                self.firedbHelper.userList[selectedUserIndex].name = self.name
                                self.firedbHelper.userList[selectedUserIndex].email = self.email
                                self.firedbHelper.userList[selectedUserIndex].contactNumber = self.contactNumber
                                self.firedbHelper.userList[selectedUserIndex].cardDetail = self.cardDetail
                                
                                self.firedbHelper.updateUser(updatedUser: self.firedbHelper.userList[selectedUserIndex])
                                
                                self.showAllParking = true
                            }
                        }) {
                            Text("Update User")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert(self.messageAlert, isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        .onAppear {
                            self.name = self.firedbHelper.userList[selectedUserIndex].name
                            self.email = self.firedbHelper.userList[selectedUserIndex].email
                            self.contactNumber = self.firedbHelper.userList[selectedUserIndex].contactNumber
                            self.cardDetail = self.firedbHelper.userList[selectedUserIndex].cardDetail
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            firedbHelper.deleteUser(userToDelete: self.firedbHelper.userList[selectedUserIndex])
                            fireAuthHelper.deleteUserAccount()
                            self.showSignIn = true
                        } label: {
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationDestination(isPresented: self.$showSignIn) {
                    UserSignInView()
                        .environmentObject(self.firedbHelper)
                        .environmentObject(self.fireAuthHelper)
                }
                .navigationDestination(isPresented: self.$showAllParking) {
                    SessionListView()
                        .environmentObject(self.firedbHelper)
                        .environmentObject(self.fireAuthHelper)
                }
            }//VStack
    }//body

//#Preview {
//    UserProfileView()
//}
