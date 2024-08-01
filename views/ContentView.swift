//
//  ContentView.swift
//  Group6_NaturalWalk
//
//  Created by Nilesh Kurbet on 2024-07-10.
//

import SwiftUI

struct ContentView: View {
    
    var firedbHelper: FirebaseDBHelper = FirebaseDBHelper.getInstance()
    var fireAuthHelper: FirebaseAuthHelper = FirebaseAuthHelper.getInstance()
    
    var body: some View {
        NavigationStack {
            
            SessionListView()
                .environmentObject(firedbHelper)
                .environmentObject(fireAuthHelper)
            
        }//NavigationStack
    }//body
}

#Preview {
    ContentView()
}
