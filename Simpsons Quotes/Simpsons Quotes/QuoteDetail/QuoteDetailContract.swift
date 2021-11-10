//
//  QuoteDetailContract.swift
//  Simpsons Quotes
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import UIKit

// MARK: View Output (Presenter -> View)
protocol PresenterToViewQuoteDetailProtocol {
    
    func onGetImageFromURLSuccess(_ quote: String, character: String, image: UIImage)
    func onGetImageFromURLFailure(_ quote: String, character: String)
}


// MARK: View Input (View -> Presenter)
protocol ViewToPresenterQuoteDetailProtocol{
    
    var view: PresenterToViewQuoteDetailProtocol? { get set }
    var interactor: PresenterToInteractorQuoteDetailProtocol? { get set }
    var router: PresenterToRouterQuoteDetailProtocol? { get set }

    func viewDidLoad()
    
}


// MARK: Interactor Input (Presenter -> Interactor)
protocol PresenterToInteractorQuoteDetailProtocol{
    
    var presenter: InteractorToPresenterQuoteDetailProtocol? { get set }
    
    var quote: Quote? { get set }
    
    func getImageDataFromURL()
    
}


// MARK: Interactor Output (Interactor -> Presenter)
protocol InteractorToPresenterQuoteDetailProtocol {
    
    func getImageFromURLSuccess(quote: Quote, data: Data?)
    func getImageFromURLFailure(quote: Quote)
    
}


// MARK: Router Input (Presenter -> Router)
protocol PresenterToRouterQuoteDetailProtocol{
    
    static func createModule(with quote: Quote) -> UIViewController
}

