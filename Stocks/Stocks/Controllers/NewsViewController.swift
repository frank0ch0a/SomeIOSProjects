//
//  NewsViewController.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {

    let tableview: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewStoryTableViewCell.self, forCellReuseIdentifier: NewStoryTableViewCell.identifier)
        table.backgroundColor = .clear
        return table
    }()
    
    private var stories = [NewsStory]()
    private let type: Type
    enum `Type` {
        case topStories
        case company(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Initializers
    init(type: Type){
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
   
    // MARK: - Private
    private func  setUpTable() {
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    private func fetchNews() {
        ApiCaller.shared.news(for: type) {[weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableview.reloadData()
                }
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewStoryTableViewCell.identifier,
                                                        for: indexPath) as? NewStoryTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: .init(model: stories[indexPath.row]))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return nil}
        
        header.configure(with: .init(
            title: self.type.title,
            shouldShowAddButton: false))
        
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        //Open story
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentedFailedToOpenAlert()
            return
        }
        open(url: url)
    }
    
    private func  presentedFailedToOpenAlert() {
        HapticsManager.shared.vibrate(for: .error)
        
        let alert = UIAlertController(title: "Unable to open",
                                      message: "We were unable to open the article",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}
