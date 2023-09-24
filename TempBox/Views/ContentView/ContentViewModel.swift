//
//  ContentViewModel.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.
//

import Foundation
import CoreData

class ContentViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var isNewAddressSheetOpen = false
    
    private let accountService = ""
    
    func openNewAddressSheet() {
        isNewAddressSheetOpen = true
    }
}
