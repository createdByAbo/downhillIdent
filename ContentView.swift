import SwiftUI

struct CircularProgressView: View {
  let progress: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 2)
        .opacity(0.1)
        .foregroundColor(.blue)

      Circle()
        .trim(from: 0.0, to: min(progress, 1.0))
        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .foregroundColor(.blue)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: progress)
    }
  }
}

struct ContentView: View {
    @State var identityModels: [IdentityModel] = []
    @State private var searchText = ""
    @ObservedObject var reloadViewHelper = ReloadViewHelper()
    @State private var isPresentingDelConfirm: Bool = false
    @State private var isPresentingDelAllConfirm: Bool = false
    @State private var isInEditMode: Bool = false
    
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
                            
                            if !model.isDailyTicketPurchased {
                                CircularProgressView(progress: CGFloat(model.currentDownHills)/CGFloat(model.purchasedDownHills))
                                    .frame(width: 20, height: 20)
                            }
                            Spacer()
                            if model.isDailyTicketPurchased {
                                Text("inf")
                            } else {
                                Text("\(model.currentDownHills)")
                            }
                            Spacer()
                            Text(model.creationTime.components(separatedBy: .whitespaces)[1])
                            Spacer()
                            Text("\(model.id)")
                            Spacer()
                            if !model.isDailyTicketPurchased {
                                Button("-1") {
                                    DB_Manager().updateCurrentDownHillsById(idVal: model.id, count: -1)
                                    model.currentDownHills += -1
                                    reloadViewHelper.reloadView()
                                }.buttonStyle(.bordered).tint(.orange)
                            }
                            Button("del", role: .destructive) {
                                isPresentingDelConfirm = true
                            }.buttonStyle(.bordered).tint(.red)
                            .confirmationDialog("Are you sure?",
                                isPresented: $isPresentingDelConfirm) {
                                Button("Delete item with id: \(model.id)", role: .destructive) {
                                    DB_Manager().dropRowById(idVal: model.id)
                                    reloadViewHelper.reloadView()
                                }
                            }
                        }
                    } else if String(model.id).contains(searchText){
                        HStack {
                            if !model.isDailyTicketPurchased {
                                CircularProgressView(progress: CGFloat(model.currentDownHills)/CGFloat(model.purchasedDownHills))
                                    .frame(width: 20, height: 20)
                            }
                            Spacer()
                            if model.isDailyTicketPurchased {
                                Text("inf")
                            } else {
                                Text("\(model.currentDownHills)")
                            }
                            Spacer()
                            Text(model.creationTime.components(separatedBy: .whitespaces)[1])
                            Spacer()
                            Text("\(model.id)")
                            Spacer()
                            if !model.isDailyTicketPurchased {
                                Button("-1") {
                                    DB_Manager().updateCurrentDownHillsById(idVal: model.id, count: -1)
                                    model.currentDownHills += -1
                                    reloadViewHelper.reloadView()
                                }.buttonStyle(.bordered).tint(.orange)
                            }
                            Button("del", role: .destructive) {
                                isPresentingDelConfirm = true
                            }.buttonStyle(.bordered).tint(.red)
                            .confirmationDialog("Are you sure?",
                                isPresented: $isPresentingDelConfirm) {
                                Button("Delete item with id: \(model.id)", role: .destructive) {
                                    DB_Manager().dropRowById(idVal: model.id)
                                    reloadViewHelper.reloadView()
                                }
                            }
                        }
                    }
                }
                HStack {
                    NavigationLink (destination: AddIdentityView(), label: {
                        Text("Add")
                    }).buttonStyle(.bordered).tint(.green)
                    
                    NavigationLink (destination: AutoIdentityView(), label: {
                        Text("Identify")
                    }).buttonStyle(.bordered).tint(.blue)
                    
                    if !isInEditMode {
                        Button("Edit") {
                            isInEditMode.toggle()
                        }
                        .buttonStyle(.bordered).tint(.orange)
                    } else {
                        Button("Save") {
                            isInEditMode.toggle()
                        }
                        .buttonStyle(.bordered).tint(.pink)
                    }
                    
                    Button("delete all", role: .destructive) {
                        isPresentingDelAllConfirm = true
                    }.buttonStyle(.bordered).tint(.red)
                    .confirmationDialog("Are you sure?",
                        isPresented: $isPresentingDelAllConfirm) {
                        Button("Delete all items?", role: .destructive) {
                            DB_Manager().dropTableData()
                            reloadViewHelper.reloadView()
                        }
                    }
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
