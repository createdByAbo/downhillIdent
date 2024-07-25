//
//  ContentView.swift
//  downhillIdent
//
//  Created by Daniel Krupa on 23/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State var identityModels: [IdentityModel] = []
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
         
            VStack {
                List (self.identityModels) { (model) in
                    if searchText == "" {
                        HStack {
                            Spacer()
                            Text("\(model.currentDownHills)")
                            Spacer()
                            Text(model.creationTime)
                            Spacer()
                            Text("\(model.id)")
                            Spacer()
                     
                            // edit and delete button goes here
                        }
                    } else if String(model.id).contains(searchText){
                        HStack {
                            Spacer()
                            Text("\(model.currentDownHills)")
                            Spacer()
                            Text(model.creationTime)
                            Spacer()
                            Text("\(model.id)")
                            Spacer()
                     
                            // edit and delete button goes here
                        }
                    }
                }
                HStack {
                    NavigationLink (destination: AddIdentityView(), label: {
                        Text("Add identity")
                    })
                }
         
            }.padding()
                .onAppear(perform: {
                    self.identityModels = DB_Manager().getIdentities()
                })
            .navigationBarTitle("List")
            .searchable(text: $searchText)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
