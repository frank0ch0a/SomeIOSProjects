//
//  ApiCaller.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import Foundation

final class ApiCaller {
    
    static let shared = ApiCaller()
    
    private init() {}
    
    private struct Constants {
        static let apiKey = "c60sujqad3ifmvvnqdqg"
        static let sanboxApiKey = "sandbox_c60sujqad3ifmvvnqdr0"
        static let baseURL = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    public func news(
        for type: NewsViewController.`Type`,
        completion: @escaping (Result<[NewsStory], Error>) -> Void
    ) {
        switch type {
        case .topStories:
            request(
                url: url(for: .topStories,
                                queryParams: ["category": "general"]),
                expecting: [NewsStory].self,
                completion: completion
            )
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(
                url: url(for: .companyNews,
                                queryParams: [
                                    "symbol": symbol,
                                    "from":DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                    "to": DateFormatter.newsDateFormatter.string(from: today)
                                ]),
                expecting: [NewsStory].self,
                completion: completion
            )
        }
        
    }
    
    public func marketData(
        for symbol: String,
        numberOfDays:TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse, Error>)  -> Void
        ){
            let today = Date().addingTimeInterval(-(Constants.day))
            let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
          
            request(url: url(for: .marketData,
                                queryParams: [
                                   "symbol": symbol,
                                   "resolution": "1",
                                   "from": "\(Int(prior.timeIntervalSince1970))",
                                   "to": "\(Int(today.timeIntervalSince1970))"
                                ]
                            ),
                    expecting: MarketDataResponse.self,
                    completion: completion)
            
        
        }
    
    public func financialMetrics(
        for symbol: String,
        completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void
    ) {
        let url = url(for: .financials,
                         queryParams: ["symbol": symbol,
                                       "metric":"all"]
        )
        
        request(url: url,
                expecting: FinancialMetricsResponse.self,
                completion: completion)
    }
    
    // MARK: - Private
    private enum EndPoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidURL
    }
    
    // MARK: - Public
    public func search(
        query:String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void
    ) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        request(url: url(
            for: .search, queryParams: ["q":safeQuery]
        ),
                expecting: SearchResponse.self,
                completion: completion)
    }
    
    private func url(for endPoint: EndPoint,
                     queryParams: [String:String] = [:]) -> URL? {
        
        var urlString = Constants.baseURL + endPoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        //Add params
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        //Add token
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        //Convert query items to suffix string
        
        urlString += "?" + queryItems.map{ "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        
    
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T,Error>) -> Void) {
            
            guard let url = url else {
                completion(.failure(APIError.invalidURL))
                return
                
            }
            
            
            let task = URLSession.shared.dataTask(with: url){  data, _, error in
                
                guard let data = data, error == nil else {
                    if let error = error {
                        completion(.failure(error))
                    }else {
                        completion(.failure(APIError.noDataReturned))
                    }
                    
                    return
                    
                }
                
                do {
                    let result = try JSONDecoder().decode(expecting, from: data)
                    completion(.success(result))
                    
                } catch {
                    completion(.failure(error))
                    
                }
                
            }
            
            task.resume()
        }
    
}
