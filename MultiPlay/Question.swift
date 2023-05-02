//
//  Question.swift
//  MultiPlay
//
//  Created by Uriel Ortega on 01/05/23.
//

import Foundation

struct Question: Hashable {
    let multiplication: String
    let result: String
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(multiplication)
            hasher.combine(result)
    }
}
