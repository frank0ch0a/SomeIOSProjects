//
//  QuotesContract.swift
//  Simpsons Quotes
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import UIKit

// MARK: View Output (Presenter -> View)

protocol PresenterToViewQuotesProtocol {
    func onFetchQuotesSuccess()
    func onFetchQuotesFailure(error: String)
    
    func showHUD()
    func hideHUD()
    
    func deselectRowAt(row: Int)
}

// MARK: View Input (View -> Presenter)
protocol ViewToPresenterQuotesProtocol{
    
    var view: PresenterToViewQuotesProtocol? { get set }
    var interactor: PresenterToInteractorQuotesProtocol? { get set }
    var router: PresenterToRouterQuotesProtocol? { get set }
    
    var quotesStrings: [String]? { get set }
    
    func viewDidLoad()
    
    func refresh()
    
    func numberOfRowsInSection() -> Int
    func textLabelText(indexPath: IndexPath) -> String?
    
    func didSelectRowAt(index: Int)
    func deselectRowAt(index: Int)

}


// MARK: Interactor Input (Presenter -> Interactor)
protocol PresenterToInteractorQuotesProtocol{
    
    var presenter: InteractorToPresenterQuotesProtocol? { get set }
    
    func loadQuotes()
    func retrieveQuote(at index: Int)
}


// MARK: Interactor Output (Interactor -> Presenter)
protocol InteractorToPresenterQuotesProtocol {
    
    func fetchQuotesSuccess(quotes: [Quote])
    func fetchQuotesFailure(errorCode: Int)
    
    func getQuoteSuccess(_ quote: Quote)
    func getQuoteFailure()
    
}


// MARK: Router Input (Presenter -> Router)
protocol PresenterToRouterQuotesProtocol {
    
    static func createModule() -> UINavigationController
    
    func pushToQuoteDetail(on view: PresenterToViewQuotesProtocol, with quote: Quote)
}
