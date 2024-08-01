//
//  FirebaseDBHelper.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import Foundation
import FirebaseAuth

class FirebaseAuthHelper: ObservableObject{

    @Published var isLoggedIn = false
    @Published var user: FirebaseAuth.User? {
        didSet {
            objectWillChange.send()
        }
    }
    
    private static var shared: FirebaseAuthHelper?
    
    static func getInstance() -> FirebaseAuthHelper {
        if (shared == nil) {
            shared = FirebaseAuthHelper()
        }
        return shared!
    }
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user
            self.isLoggedIn = user != nil
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print(#function, "Error while creating account: \(error)")
                completion(false, error)
                return
            }
            
            guard let user = authResult?.user else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user data received"]))
                return
            }
            
            self?.user = user
            self?.isLoggedIn = true
            FirebaseDBHelper.getInstance().getUser()
            completion(true, nil)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print(#function, "Error while signing in: \(error)")
                completion(false, error)
                return
            }
            guard let user = authResult?.user else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"]))
                return
            }
            self?.user = user
            FirebaseDBHelper.getInstance().getUser()
            self?.isLoggedIn = true
            completion(true, nil)
        }
    }
    
    func signOut(){
        do {
            let remember = UserDefaults.standard.bool(forKey: "KEY_REMEMBER_ME")
            if  remember == false {
                //remove the userDedault values when the rememberMe if false
                
                UserDefaults.standard.removeObject(forKey: "KEY_EMAIL")
                UserDefaults.standard.removeObject(forKey: "KEY_PASSWORD")
                UserDefaults.standard.removeObject(forKey: "KEY_REMEMBER_ME")
                
            }
            
            FirebaseDBHelper.getInstance().userList = []
            try Auth.auth().signOut()
        } catch let error {
            print(#function, "Unable to sign out user: \(error)")
        }
    }
    
    func deleteUserAccount() {
        do {
            print(#function, "Current User: \(Auth.auth().currentUser)")
            let user = try Auth.auth().currentUser
            
            user?.delete { error in
                if let error = error {
                    // An error happened.
                    print(#function, "Error: \(error)")
                } else {
                    // Account deleted.
                    UserDefaults.standard.removeObject(forKey: "KEY_EMAIL")
                    UserDefaults.standard.removeObject(forKey: "KEY_PASSWORD")
                    UserDefaults.standard.removeObject(forKey: "KEY_REMEMBER_ME")
                    print(#function, "User deleted successfully: \(user)")
                }
            }
        } catch let error {
            print(#function, "Unable to sign out user: \(error)")
        }
    }
    
}
