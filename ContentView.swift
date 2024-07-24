//
//  ContentView.swift
//  downhillIdent
//
//  Created by Daniel Krupa on 23/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State var identityModels: [IdentityModel] = []
    var body: some View {
        NavigationView {
         
            VStack {
                HStack {
                    Spacer()
                    NavigationLink (destination: AddIdentityView(), label: {
                        Text("Add identity")
                    })
                }
                List (self.identityModels) { (model) in
                    HStack {
                        Text("\(model.currentDownHills)")
                        Spacer()
                        Text(model.creationTime)
                        Spacer()
                        Text("\(model.id)")
                        Spacer()
                 
                        // edit and delete button goes here
                    }
                }
         
            }.padding()
                .onAppear(perform: {
                    self.identityModels = DB_Manager().getIdentities()
                })
            .navigationBarTitle("List")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
