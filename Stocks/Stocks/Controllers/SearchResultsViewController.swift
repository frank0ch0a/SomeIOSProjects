//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import UIKit
protocol SearchResultViewControllerDelegate: AnyObject {
    func SearchResultViewControllerDidSelect(searchResult: SearchResult)
}

class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultViewControllerDelegate?
    var results: [SearchResult] = []
    private var tableView: UITableView = {
        let table = UITableView()
        // Register Cell
        table.register(SearchResultTableViewCell.self,
                       forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTable()

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    private func  setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    public func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }

}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        
        let model = results[indexPath.row]
        cell.textLabel?.text = model.symbol
        cell.detailTextLabel?.text = model.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = results[indexPath.row]
        delegate?.SearchResultViewControllerDidSelect(searchResult: model)
    }
}
