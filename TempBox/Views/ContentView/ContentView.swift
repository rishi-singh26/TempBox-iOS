//
//  ContentView.swift
//  TempBox
//
//  Created by Rishi Singh on 20/09/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest<Account>(sortDescriptors: [
        SortDescriptor(\.createdAt)
    ]) var accounts: FetchedResults<Account>
    
    @StateObject var controller = ContentViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    Text(account.address ?? "No Address")
                }
            }
            .navigationTitle("TempBox")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: controller.openNewAddressSheet) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("New Address")
                            }
                            .fontWeight(.bold)
                        }
                        Spacer()
                        Text("Accounts: \(accounts.count)")
                    }
                }
            }
            .searchable(text: $controller.searchText)
            .listStyle(.sidebar)
            .sheet(isPresented: $controller.isNewAddressSheetOpen) {
                AddAddressView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
