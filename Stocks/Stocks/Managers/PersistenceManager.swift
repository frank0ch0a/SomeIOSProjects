//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import Foundation

final class PersistenceManager {
    static let shared  = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardingKey =  "hasOnboarded"
        static let watchListKey = "whathclist"
    }
    
    private init() {}
    
    // MARK: - Public
    
    public var watchList: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardingKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchListKey) ?? []
    }
  
    public func watchListContains(symbol: String) -> Bool {
        
        return watchList.contains(symbol)
    }
    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchList
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchListKey)
        userDefaults.set(companyName, forKey: symbol)
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    public func removeToWatchList(symbol: String) {
        var newList = [String]()
        print("Deleting: \(symbol)")
        userDefaults.set(nil, forKey: symbol)
        for item in watchList where item != symbol {
            print("\n\(item)")
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchListKey)
       
    }
    
    // MARK: - Private
    
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardingKey)
    }
    
    private func setUpDefaults() {
        
        let map: [String:String] = [
            "APPL" : "Apple inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com Inc.",
            "WORK": "Slack technologies",
            "FB": "Facbook Inc.",
            "NVDA": "Nvidia Inc.",
            "NKE": "Nike",
            "PINS": "Pinterest Inc."
        
        ]
        
        let symbols = map.keys.map {$0}
        userDefaults.set(symbols, forKey: Constants.watchListKey)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
        
        
    }
}
