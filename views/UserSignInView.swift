//
//  UserSignInView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import SwiftUI

struct UserSignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp: Bool = false
    @State private var showSessionListView: Bool = false
    @State private var rememberMe = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject var firedbHelper: FirebaseDBHelper
    @EnvironmentObject var fireAuthHelper: FirebaseAuthHelper
    
    @Environment(\.dismiss) private var dissmiss
    
    var body: some View {
        VStack {
            // Profile Picture
            Image(systemName: "leaf.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .clipShape(Circle())
                .shadow(radius: 10)
                .padding(.top, 50)

            // Form
            Form {
                TextField("Enter Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)

                SecureField("Enter Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)

                Toggle("Remember me", isOn: $rememberMe)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.horizontal)
            }
            .padding(.top)

            // Sign In Button
            Button(action: signInAction) {
                Text("Sign In")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 20)
            }

            // Sign Up Button
            Button(action: {
                showSignUp = true
            }) {
                Text("Sign Up")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            email = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
            password = UserDefaults.standard.string(forKey: "KEY_PASSWORD") ?? ""
            self.rememberMe = UserDefaults.standard.bool(forKey: "KEY_REMEMBER_ME")
        }
        .navigationDestination(isPresented: $showSignUp) {
            UserSignUpView()
                .environmentObject(firedbHelper)
                .environmentObject(fireAuthHelper)
        }
        .navigationDestination(isPresented: $showSessionListView) {
            SessionListView()
                .environmentObject(firedbHelper)
                .environmentObject(fireAuthHelper)
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Sign In Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func signInAction() {
        if !email.isEmpty && !password.isEmpty {
            fireAuthHelper.signIn(email: email, password: password) { success, error in
                if success {
                    print("Signed in successfully")
                    
                    if self.rememberMe {
                        UserDefaults.standard.set(email, forKey: "KEY_EMAIL")
                        UserDefaults.standard.set(password, forKey: "KEY_PASSWORD")
                        UserDefaults.standard.set(self.rememberMe, forKey: "KEY_REMEMBER_ME")
                    }
                    
                    self.dissmiss()
                    showSessionListView = true
                } else {
                    alertMessage = error?.localizedDescription ?? "Unable to sign in"
                    showAlert = true
                }
            }
        } else {
            alertMessage = "Email and password cannot be empty"
            showAlert = true
        }
    }
}
#Preview {
    UserSignInView()
}
