//
//  AddAddressViewModel.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.
//

import Foundation
import MailTMSwift
import Combine
import CoreData
import SwiftUI

class AddAddressViewModel: ObservableObject {
    // MARK: - Services
    private let accountService = MTAccountService()
    let domainService = MTDomainService()
    
    // MARK: - Account variables
    @Published var address: String = ""
    @Published var password: String = ""
    @Published var shouldUseRandomPassword: Bool = false {
        willSet {
            if newValue {
                generateRandomPass()
            } else {
                password = ""
            }
        }
    }
    
    var isPasswordValid: Bool {
        (password != "" && password.count >= 6) || shouldUseRandomPassword
    }
    
    // MARK: - Domain variables
    @Published var domains = [MTDomain]()
    @Published var selectedDomain: MTDomain = MTDomain(id: "", domain: "", isActive: false, isPrivate: false, createdAt: Date.now, updatedAt: Date.now)
    
    // MARK: - Error Alert variables
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    
    // MARK: Create Account properties
    @Published var isCreatingAccount = false
    var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Add account or Login
    let authOptions = ["New", "Login"]
    @Published var selectedAuthMode = "New"
    @Published var isCreatingNewAccount = true
    
    init() {
        loadDomains()
    }
    
    func loadDomains() {
        domainService.getAllDomains { (result: Result<[MTDomain], MTError>) in
            switch result {
              case .success(let domains):
                self.domains = domains
                if !domains.isEmpty {
                    self.selectedDomain = domains[0]
                }
              case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showErrorAlert = true
            }
        }
    }
    
    func generateRandomAddress() {
        address = String.generateRandomString(of: 10)
    }
    
    func generateRandomPass() {
        password = String.generateRandomString(of: 12, useUpperCase: true, useNumbers: true, useSpecialCharacters: true)
    }
    
    func getEmail() -> String {
        return isCreatingNewAccount ? "\(self.address)@\(self.selectedDomain.domain)" : self.address
    }
    
    func createAccount(moc: NSManagedObjectContext, dismiss: DismissAction) {
        let auth = MTAuth(address: getEmail(), password: password)
        accountService.createAccount(using: auth) { [self] (accountResult: Result<MTAccount, MTError>) in
          switch accountResult {
            case .success(let account):
              let localAccount = Account(context: moc)
              localAccount.id = account.id
              localAccount.address = account.address
              localAccount.createdAt = account.createdAt
              localAccount.isArchived = false
              localAccount.isDisabled = account.isDisabled
              localAccount.password = self.password
              localAccount.quotaLimit = Int32(account.quotaLimit)
              localAccount.quotaUsed = Int32(account.quotaUsed)
              localAccount.updatedAt = account.updatedAt
              
              login(moc: moc, account: localAccount, dismiss: dismiss)
            case .failure(let error):
              errorMessage = error.localizedDescription
              showErrorAlert = true
          }
        }
    }
    
    func login(moc: NSManagedObjectContext, account: Account, dismiss: DismissAction) {
        let auth = MTAuth(address: getEmail(), password: password)
        accountService.login(using: auth) { [self] (result: Result<String, MTError>) in
          switch result {
            case .success(let token):
              account.token = token
              try? moc.save()
              dismiss()
            case .failure(let error):
              errorMessage = error.localizedDescription
              showErrorAlert = true
          }
        }
    }
}
