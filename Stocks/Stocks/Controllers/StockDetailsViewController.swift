//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import UIKit
import SafariServices
class StockDetailsViewController: UIViewController {
    
    // Properties
    private let symbol:String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewStoryTableViewCell.self, forCellReuseIdentifier: NewStoryTableViewCell.identifier)
        table.backgroundColor = .secondarySystemBackground
        return table
        
    }()
    
    private var stories: [NewsStory] = []
    private var metrics: Metrics?
    // MARK: - Init
    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
    ){
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        setupCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    // MARK: - private
  
    
    private func setupCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapCLose))
    }
    
    @objc private func didTapCLose() {
        dismiss(animated: true, completion: nil)
    }
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height:( view.width * 0.7) + 100))
    }
    
    private func  fetchFinancialData() {
        let group = DispatchGroup()
        
        if candleStickData.isEmpty {
            group.enter()
            ApiCaller.shared.marketData(for: symbol) {[weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candeleSticks
                case .failure(let error):
                    print(error)
                }
                
            }
        }
        
        group.enter()
        ApiCaller.shared.financialMetrics(for: symbol) {[weak self] result in
           
            defer {
                group.leave()
            }
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
                print(metrics)
            case .failure(let error):
                print(error)
            }
            
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    
    }
    
    private func renderChart() {
        //Chart VM | FinancialMetrics ViewModel(s)
        
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: view.width,
                                                             height: (view.width * 0.7) + 100))
       
        //Configure
        var viewModels =  [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: String(metrics.AnnualWeekHigh)))
            viewModels.append(.init(name: "52L Low", value: String(metrics.AnnualWeekLow)))
            viewModels.append(.init(name: "52W Return", value: String(metrics.AnnualWeekPriceReturnDaily)))
            viewModels.append(.init(name: "Beta", value: String(metrics.beta)))
            viewModels.append(.init(name: "10D Vol.", value: String(metrics.TenDayAverageTradingVolume)))
            
        }
        let change = candleStickData.getPercentage()
        headerView.configure(chartViewModel: .init(data: candleStickData.reversed().map{$0.close},
                                                   showLegend: true,
                                                   showAxis: true,
                                                   fillColor: change < 0 ? .systemRed : .systemGreen),
                             metricViewModels: viewModels)
        
        tableView.tableHeaderView = headerView
        
        
    }
    
    
    
    private func fetchNews() {
        ApiCaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }

}

extension StockDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell  = tableView.dequeueReusableCell(withIdentifier: NewStoryTableViewCell.identifier, for: indexPath) as? NewStoryTableViewCell else { fatalError() }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier)
                as? NewsHeaderView else { return nil}
        header.delegate = self
        header.configure(with: .init(
            title: symbol.uppercased(),
            shouldShowAddButton: !PersistenceManager.shared.watchListContains(symbol: symbol)
        )
        )
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        guard let url = URL(string: stories[indexPath.row].url) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        
        HapticsManager.shared.vibrate(for: .success)
        //Add to watchlist
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)
        
        let alert = UIAlertController(title: "Added to Watchlist",
                                      message: "We've added \(companyName) to ypur watchlist",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
}
