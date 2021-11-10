//
//  QuoteService.swift
//  Simpsons Quotes
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import ObjectMapper

class QuoteService {
    
    static let shared = { QuoteService() }()
    
    func getQuotes(count: Int, success: @escaping (Int, [Quote]) -> (), failure: @escaping (Int) -> ()) {
        
        let urlString = self.configureApiCall(Endpoints.QUOTES, "count", "\(count)")
        
        APIClient.shared.getArray(urlString: urlString, success: { (code, arrayOfQuotes) in
            success(code, arrayOfQuotes)
            
        }) { (code) in
            failure(code)
        }
    }
    
    func configureApiCall(_ baseURL: String, _ parameter: String, _ value: String) -> String {
        return baseURL + "?" + parameter + "=" + value
    }
}

