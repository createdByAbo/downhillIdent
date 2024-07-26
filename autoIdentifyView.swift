import SwiftUI
import AVFoundation
import Vision

struct AutoIdentityView: View {
    @State var identityModels: [IdentityModel] = []
    @StateObject private var viewModel = CameraViewModel()
    @ObservedObject var reloadViewHelper = ReloadViewHelper()

    class ReloadViewHelper: ObservableObject {
        func reloadView() {
            objectWillChange.send()
        }
    }
    
    var body: some View {
        VStack {
            CameraView(viewModel: viewModel)
                .frame(height: 400)
                .cornerRadius(10)
                .shadow(radius: 10)
            
            if viewModel.recognizedList.count > 0{
                ScrollView {
                    Text(viewModel.recognizedList[0])
                        .font(.body)
                }
                .onAppear(perform: {
                    identityModels = DB_Manager().getIdentitiesById(idVal: Int64(viewModel.recognizedList[0])!)
                })
                if identityModels.count == 0 {
                    NavigationLink (destination: AddIdentityView(), label: {
                        Text("Add identity with this id")
                    }).buttonStyle(.bordered).tint(.green)
                }
            } else {
                ScrollView {
                    Text(viewModel.recognizedText)
                        .font(.body)
                }
            }
            if identityModels.count > 0{
                HStack {
                    
                    if !identityModels[0].isDailyTicketPurchased {
                        CircularProgressView(progress: CGFloat(identityModels[0].currentDownHills)/CGFloat(identityModels[0].purchasedDownHills))
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                    if identityModels[0].isDailyTicketPurchased {
                        Text("inf")
                    } else {
                        Text("\(identityModels[0].currentDownHills)")
                    }
                    Spacer()
                    Text(identityModels[0].creationTime.components(separatedBy: .whitespaces)[1])
                    Spacer()
                    Text("\(identityModels[0].id)")
                    Spacer()
                    if !identityModels[0].isDailyTicketPurchased {
                        Button("-1") {
                            DB_Manager().updateCurrentDownHillsById(idVal: identityModels[0].id, count: -1)
                            identityModels[0].currentDownHills += -1
                            reloadViewHelper.reloadView()
                        }.buttonStyle(.bordered).tint(.orange)
                    }
                    Button("delete") {
                        DB_Manager().dropRowById(idVal: identityModels[0].id)
                        reloadViewHelper.reloadView()
                    }.buttonStyle(.bordered).tint(.red)
                }
            }
        }
        .padding()
        .navigationBarTitle("Auto Identity", displayMode: .inline)
    }
}

#Preview {
    AutoIdentityView()
}
