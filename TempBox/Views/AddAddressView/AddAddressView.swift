//
//  AddAddressView.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.
//

import SwiftUI
import MailTMSwift

struct AddAddressView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var controller = AddAddressViewModel()
    @EnvironmentObject private var dataController: DataController
    private let accountService = MTAccountService()

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("Account name appears on the accounts list screen.")) {
                    TextField("Account name (Optional)", text: $controller.accountName)
                }
                
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
                        createAccount()
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
    
    func createAccount() {
        let auth = MTAuth(address: controller.getEmail(), password: controller.password)
        accountService.createAccount(using: auth) { [self] (accountResult: Result<MTAccount, MTError>) in
          switch accountResult {
            case .success(let account):
              login(account: account)
            case .failure(let error):
              controller.errorMessage = error.localizedDescription
              controller.showErrorAlert = true
          }
        }
    }
    
    func login(account: MTAccount) {
        let auth = MTAuth(address: controller.getEmail(), password: controller.password)
        accountService.login(using: auth) { [self] (result: Result<String, MTError>) in
          switch result {
            case .success(let token):
              dataController.addAccount(account: account, token: token, password: controller.password, accountName: controller.accountName)
              dismiss()
            case .failure(let error):
              controller.errorMessage = error.localizedDescription
              controller.showErrorAlert = true
          }
        }
    }
}

struct AddAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddAddressView()
    }
}
