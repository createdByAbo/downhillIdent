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
    @ObservedObject var reloadViewHelper = ReloadViewHelper()

    class ReloadViewHelper: ObservableObject {
        func reloadView() {
            objectWillChange.send()
        }
    }

    
    var body: some View {
        NavigationView {
         
            VStack {
                List (self.identityModels) { (model) in
                    if searchText == "" || searchText == " " {
                        HStack {
                            Spacer()
                            Text("\(model.currentDownHills)")
                            Spacer()
                            Text(model.creationTime.components(separatedBy: .whitespaces)[1])
                            Spacer()
                            Text("\(model.id)")
                            Spacer()
                            Button("-1") {
                                DB_Manager().updateCurrentDownHillsById(idVal: model.id, count: -1)
                                model.currentDownHills += -1
                                reloadViewHelper.reloadView()
                            }.buttonStyle(.bordered).tint(.red)
                     
                            // edit and delete button goes here
                        }
                    } else if String(model.id).contains(searchText){
                        HStack {
                            Spacer()
                            Text("\(model.currentDownHills)")
                            Spacer()
                            Text(model.creationTime.components(separatedBy: .whitespaces)[1])
                            Spacer()
                            Text("\(model.id)")
                            Spacer()
                            Button("-1") {
                                DB_Manager().updateCurrentDownHillsById(idVal: model.id, count: -1)
                                model.currentDownHills += -1
                                reloadViewHelper.reloadView()
                            }.buttonStyle(.bordered).tint(.red)
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
