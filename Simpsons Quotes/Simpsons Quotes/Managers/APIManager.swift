//
//  APIManager.swift
//  Simpsons Quotes
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import Foundation

class APIManager {
    
    static let shared = { APIManager() }()
    
    lazy var baseURL: String = {
        return "https://thesimpsonsquoteapi.glitch.me/"
    }()
}
