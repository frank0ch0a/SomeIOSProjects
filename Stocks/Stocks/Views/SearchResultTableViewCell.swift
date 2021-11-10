//
//  SearchResultTableViewCell.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
static let identifier = "SearchResultTableViewCell:"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
