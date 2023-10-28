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
    
    @Published var showDeleteAccountAlert = false
    var selectedAccForDeletion: Account?
        
    @Published var showingErrorAlert = false
    @Published var errorAlertMessage = ""
    
    @Published var isAccountInfoSheetOpen = false
    var selectedAccForInfoSheet: Account?
        
    private let accountService = MTAccountService()
    
    func openNewAddressSheet() {
        isNewAddressSheetOpen = true
    }
}
