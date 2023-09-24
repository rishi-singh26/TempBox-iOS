//
//  ContentViewModel.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.
//

import Foundation
import CoreData
import MailTMSwift

class ContentViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var isNewAddressSheetOpen = false
    @Published var messages: [Account: MTMessage] = [Account: MTMessage]()
        
    private let accountService = MTAccountService()
    
    func openNewAddressSheet() {
        isNewAddressSheetOpen = true
    }
    
    func deleteAccount(account: Account, moc: NSManagedObjectContext) {
        guard let id = account.id, let token = account.token else { return } // handle user alert about error
        accountService.deleteAccount(id: id, token: token) { (result: Result<MTEmptyResult, MTError>) in
            if case let .failure(error) = result {
                print("Error Occurred while deleting account from mail.tm server: \(error)")
                return
            }
            moc.delete(account)
            do {
                try moc.save()
            } catch {
                print("Error while deleting account from core data \(error.localizedDescription)")
            }
        }
    }
}
