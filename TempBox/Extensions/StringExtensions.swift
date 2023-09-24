//
//  StringExtensions.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.
//

import Foundation

extension String {
    static func generateRandomString(of length: Int, useUpperCase: Bool = false, useNumbers: Bool = false, useSpecialCharacters: Bool = false) -> String {
        var letters = "abcdefghijklmnopqrstuvwxyz"
        if useUpperCase {
            letters += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        if useNumbers {
            letters += "0123456789"
        }
        if useSpecialCharacters {
            letters += "@$%&*#()"
        }
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
