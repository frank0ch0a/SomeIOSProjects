//
//  ImageDataService.swift
//  Simpsons Quotes
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import UIKit

class ImageDataService {
    
    static let shared = { ImageDataService() }()
    
    func convertToUIImage(from data: Data) -> UIImage {
        return UIImage(data: data)!
    }
}
