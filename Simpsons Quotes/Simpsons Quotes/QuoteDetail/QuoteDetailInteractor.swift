//
//  QuoteDetailInteractor.swift
//  Simpsons Quotes
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import Foundation

class QuoteDetailInteractor: PresenterToInteractorQuoteDetailProtocol {
    
    // MARK: Properties
    var presenter: InteractorToPresenterQuoteDetailProtocol?
    var quote: Quote?
    
    func getImageDataFromURL() {
        print("Interactor receives the request from Presenter to get image data from the server.")
        KingfisherService.shared.loadImageFrom(urlString: quote!.image!, success: { (data) in
            self.presenter?.getImageFromURLSuccess(quote: self.quote!, data: data)
        }) { (error) in
            self.presenter?.getImageFromURLFailure(quote: self.quote!)
        }

    }
    

}
