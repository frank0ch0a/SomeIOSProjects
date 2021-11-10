//
//  WatchListViewController.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import UIKit
import FloatingPanel
class WatchListViewController: UIViewController {

    private var searchTimer: Timer?
    
   static var maxChangeWidth: CGFloat = 0
    
    private var panel: FloatingPanelController?
    
    ///Model
    private var watchListMap: [String: [CandleStick]] = [:]
    
    /// ViiewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self,
                       forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return table
        
    }()
    
    private var observer: NSObjectProtocol?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setUpTableView()
        fetchWatchlistData()
        setUpFloatingPanel()
        setupTitleView()
        setUPObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    // MARK: - Private
    
    private func  setUPObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList,
                                                          object: nil,
                                                          queue: .main
        ) { [weak self] _ in
            
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
        }
    }
    
    /// Fetch watch list models
    private func   fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchList
        
        createViewModelsPlaceHolders()
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchListMap[symbol] == nil{
            group.enter()
            //Fetch market data per symbol
           
            ApiCaller.shared.marketData(for: symbol) {[weak self] result in
                
                defer {
                    group.leave()
                }
                switch result {
                case .success(let data):
                    let candleSticks = data.candeleSticks
                    self?.watchListMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
                
            }
        }
        
        group.notify(queue: .main) {[weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    private func createViewModelsPlaceHolders() {
        
        let symbols = PersistenceManager.shared.watchList
        
        symbols.forEach {  item in
            viewModels.append(
                .init(symbol: item,
                      companyName: UserDefaults.standard.string(forKey: item) ?? "",
                      price: "0.0",
                      changeColor: .systemGreen,
                      changePercentage: "0.00",
                      chattViewModel: .init(data: [],
                                            showLegend: false,
                                            showAxis: false,
                                            fillColor: .clear))
            )
            
        }
        self.viewModels = viewModels.sorted(by: {$0.symbol < $1.symbol})
        tableView.reloadData()
    }
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = candleSticks.getPercentage()
            viewModels.append(.init(symbol: symbol,
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                                    price: getLatestClosingPrice(from: candleSticks),
                                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: .percentage(from: changePercentage),
                                    chattViewModel: .init(
                                        data: candleSticks.reversed().map {$0.close},
                                        showLegend: false,
                                        showAxis: false,
                                    fillColor: changePercentage < 0 ? .systemRed : .systemGreen)))
        }
        
       
        self.viewModels = viewModels.sorted(by: {$0.symbol < $1.symbol})
        
    }
    

    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        
        return .formatted(from: closingPrice)
        
        
    }
    private func   setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    private  func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.set(contentViewController: vc)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableview)
    }
    
    private func setupTitleView() {
        let titleView = UIView(
            frame: CGRect(
            x: 0,
             y: 0,
             width: view.width,
             height: navigationController?.navigationBar.height ?? 100))
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        titleView.addSubview(label)
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        navigationItem.titleView = titleView
        
    }
    private func setupSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }

}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                  return
              }
        
        //Reset timer
        searchTimer?.invalidate()
        
        //launch new timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            //Csll Api to search
        ApiCaller.shared.search(query: query) { result in
          
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    resultsVC.update(with: response.result)
                }
               
            case .failure(let error):
                DispatchQueue.main.async {
                    resultsVC.update(with: [])
                }
                print(error)
            }
            
        }
            
        })
    }
    
}

extension WatchListViewController: SearchResultViewControllerDelegate {
    func SearchResultViewControllerDidSelect(searchResult: SearchResult) {
        // Present stock details for given selection
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = StockDetailsViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
    
    
}

extension WatchListViewController: FloatingPanelControllerDelegate {
   
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier,
                                            for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferrdHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            //Update Persistence
            PersistenceManager.shared.removeToWatchList(symbol: viewModels[indexPath.row].symbol)
            
            //Update ViewModels
            viewModels.remove(at: indexPath.row)
         
            //Delete row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Open details for selection
        HapticsManager.shared.vibrateForSelection()
        
        // Present stock details for given selection
        let viewModel = viewModels[indexPath.row]
        
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = StockDetailsViewController(symbol: viewModel.symbol,
                                            companyName: viewModel.companyName,
                                            candleStickData:watchListMap[viewModel.symbol] ?? [] )
        let navVC = UINavigationController(rootViewController: vc)
       
        present(navVC, animated: true)
    }
}

extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        // Optimize : only refresh rows priot to the current row changes max width
        tableView.reloadData()
    }
    
    
}
