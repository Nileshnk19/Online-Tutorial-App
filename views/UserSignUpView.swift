//
//  UserSignUpView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import SwiftUI

struct UserSignUpView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var name: String = ""
    @State private var contactNumber: String = ""
    @State private var cardDetail: String = ""
    @State private var showingAlert: Bool = false
    @State private var messageAlert: String = "Alert Message"
    @State private var showSessionListView: Bool = false
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    
    var body: some View {
        
        VStack {
            
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .clipShape(Circle())
                .shadow(radius: 10)
                .padding(.top, 50)
            
            Form{
                TextField("Enter Name", text: self.$name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Enter Email", text: self.$email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                
                SecureField("Enter Password", text: self.$password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Enter Password Again", text: self.$confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Enter Contact Number", text: self.$contactNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                TextField("Enter Card Detail", text: self.$cardDetail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
            }//Form ends
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)
            .padding()
            
            Section{
                Button(action: {
                    
                    if (self.email.isEmpty && self.password.isEmpty && self.confirmPassword.isEmpty && self.name.isEmpty && self.contactNumber.isEmpty && self.cardDetail.isEmpty) {
                        self.messageAlert = "Please, enter the values..."
                        self.showingAlert = true
                    } else if (self.password != self.confirmPassword) {
                        self.messageAlert = "Your password and confirm password dosen't match..."
                        self.showingAlert = true
                    } else {
                        
                        //if all the data is validated
                        //create account on firebase
                        
                        self.fireAuthHelper.signUp(email: self.email, password: self.password) { success, error in
                            if success {
                                print("Signed in successfully")
                                
                                self.firedbHelper.insertUser(newUser: User(email: self.email, name: self.name, contactNumber: self.contactNumber, cardDetail: self.contactNumber))
                                
                                self.showSessionListView = true
                            } else {
                                print(#function, "Unable to signUp: \(error)")
                            }
                        }
                        
                        //Navigating to the SignIn page
                        //self.showSessionListView = true
                        
                    }//else
                    
                }){
                    Text("Create Account")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }//Button ends
                .padding(.horizontal)
                .navigationDestination(isPresented: self.$showSessionListView) {
                    SessionListView()
                        .environmentObject(self.firedbHelper)
                        .environmentObject(self.fireAuthHelper)
                }
                .disabled( self.password != self.confirmPassword && self.email.isEmpty && self.password.isEmpty && self.confirmPassword.isEmpty)
                .alert(self.messageAlert, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }//alert
            }//Section ends
            Spacer()
        }//VStack
        .padding()
        
    }//body
}

#Preview {
    UserSignUpView()
}
