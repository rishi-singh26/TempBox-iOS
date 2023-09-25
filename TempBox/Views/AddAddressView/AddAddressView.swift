//
//  AddAddressView.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.
//

import SwiftUI

struct AddAddressView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @StateObject var controller = AddAddressViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    if controller.isCreatingNewAccount {
                        Picker(selection: $controller.selectedDomain) {
                            ForEach(controller.domains, id: \.self) { domain in
                                Text(domain.domain)
                            }
                        } label: {
                            TextField("Address", text: $controller.address)
                                .autocapitalization(.none)
                        }
                        Button("Random address") {
                            controller.generateRandomAddress()
                        }
                    }
                    if !controller.isCreatingNewAccount {
                        TextField("Address", text: $controller.address)
                            .keyboardType(.emailAddress)
                    }
                }
                
                Section {
                    if !controller.shouldUseRandomPassword || !controller.isCreatingNewAccount {
                        SecureField("Password", text: $controller.password)
                            .keyboardType(.asciiCapable) // This avoids suggestions bar on the keyboard.
                            .autocorrectionDisabled(true)
                    }
                    if controller.isCreatingNewAccount {
                        Toggle("Use random password", isOn: $controller.shouldUseRandomPassword.animation())
                    }
                }
                
                HStack {
                    Image(systemName: "info.square.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.white))
                    Text("The password once set can not be reset or changed.")
                }
                .listRowBackground(Color.yellow.opacity(0.2))
            }
            .navigationTitle("Add Address")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }

                }
                
//                ToolbarItem(placement: .principal) {
//                    Picker("Select auth mode", selection: $controller.selectedAuthMode) {
//                        ForEach(controller.authOptions, id: \.self) {
//                            Text($0)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                    .frame(width: 170)
//                    .onChange(of: controller.selectedAuthMode) { newValue in
//                        if newValue == "New" {
//                            withAnimation {
//                                controller.isCreatingNewAccount = true
//                                controller.shouldUseRandomPassword ? controller.generateRandomPass() : nil
//                            }
//                        } else {
//                            withAnimation {
//                                controller.isCreatingNewAccount = false
//                                controller.password = ""
//                            }
//                        }
//                    }
//                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        controller.createAccount(moc: moc, dismiss: dismiss)
                    } label: {
                        Text("Done")
                            .font(.headline)
                    }

                }
            }
            .alert(isPresented: $controller.showErrorAlert) {
                Alert(title: Text("Alert!"), message: Text(controller.errorMessage))
            }
        }
    }
}

struct AddAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddAddressView()
    }
}
