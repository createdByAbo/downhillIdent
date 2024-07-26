//
//  AddIdentityView.swift
//  downhillIdent
//
//  Created by Daniel Krupa on 24/07/2024.
//

import SwiftUI

struct AddIdentityView: View {
    
    @State var id: Int64 = 0
    @State var purchasedDownHills: Int64 = 0
    @State var isDailyTicketPurchased: Bool = false
    @State var total: Double = 0.0
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            TextField("Id", value: $id, format: .number)
                .padding(10)
                .background(Color(.systemGray6))
                .keyboardType(.numberPad)
                .cornerRadius(5)
                .disableAutocorrection(true)
            
            TextField("Count of downhills", value: $purchasedDownHills, format: .number)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(5)
                .keyboardType(.numberPad)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Toggle("Is daily ticket purchased", isOn: $isDailyTicketPurchased)
                    
            Button(action: {
                DB_Manager().addIdentity(idVal: self.id, purchasedDownHillsVal: self.purchasedDownHills, isDailyTicketPurchasedVal: self.isDailyTicketPurchased)
                
                self.mode.wrappedValue.dismiss()
            }, label: {
                Text("Add Identity")
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }.padding()
        Text("total : \(DB_Manager().calculateTotal(isDailyTicketPurchased: isDailyTicketPurchased, purchasedDownHills: purchasedDownHills), specifier: "%.2f") PLN")
    }
}

#Preview {
    AddIdentityView()
}
