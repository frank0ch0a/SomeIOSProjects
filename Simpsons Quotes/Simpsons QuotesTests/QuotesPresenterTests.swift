//
//  Simpsons_QuotesTests.swift
//  Simpsons QuotesTests
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import XCTest
@testable import Simpsons_Quotes

class QuotesPresenterTests: XCTestCase {
    var presenter: QuotesPresenter!
    var interactor: TestQuotesInteractor!
    var router: QuotesRouter!
    
    override func setUp() {
      super.setUp()
        interactor = TestQuotesInteractor()
    }

    func load_quotes_tests() {
        
        
    }
}

extension QuotesPresenterTests {
    
    class TestQuotesInteractor: PresenterToInteractorQuotesProtocol {
        var presenter: InteractorToPresenterQuotesProtocol?
        var quotes: [Quote]?
        func loadQuotes() {
            
            QuoteService.shared.getQuotes(count: 6, success: { (code, quotes) in
                guard let jsonMock = TestConstants.jsonMock.data(using: .utf8) else {
                            return
                        }
                
              
                
            
                self.presenter?.fetchQuotesSuccess(quotes: quotes)
            }) { (code) in
                self.presenter?.fetchQuotesFailure(errorCode: code)
            }
            //QuoteService.shared.getQuotes(count: 4, success: { (code, quotes) in
                
//                guard let jsonMock = TestConstants.jsonMock else {
//
//                }
//
//                do {
//                    let result = try JSONDecoder().decode([Quote].self, from: jsonMock)
//                    self.quotes = result
//                } catch {
//
//                }
//            }
                                          
                                          
}
            
        func retrieveQuote(at index: Int) {
            <#code#>
        }
        
        
    }
}
