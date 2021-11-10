//
//  Extensions.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import Foundation
import UIKit

// MARK: - Notification
extension Notification.Name {
    ///Notifcation for when symbol gets added to watchlist
    static let didAddToWatchList = Notification.Name("")
}

// MARK: - Number
extension NumberFormatter {
    /// Formatter for percent style
    static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    /// Formatter for decimal style
    static let numnberrmatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
}
// MARK: - ImageView


extension UIImageView {
    
    /// Set images from remote
    /// - Parameter url: URL to fetch from
    func setImage(with url: URL?) {
        guard let url = url else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
                
                guard let data = data, error == nil else {return }
                
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
    
    
    
}
// MARK: - String
extension String {
    /// Create String from time interval
    /// - Parameter timeInterval: Time interval since 1970
    /// - Returns: Formatted String
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    /// Percentage formatted String
    /// - Parameter double: Double to format
    /// - Returns: String en percent format
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentageFormatter
        
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    static func formatted(from number: Double) -> String {
        let formatter = NumberFormatter.numnberrmatter
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
// MARK: - DateFormatter

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
        
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
        
    }()
}
// MARK: - add subview

extension UIView {
    func addSubviews(_ views: UIView...){
        views.forEach {
            addSubview($0)
        }
    }
}

// MARK: - Framing

extension UIView {
    
    var width: CGFloat {
        frame.size.width
    }
    
    var height: CGFloat {
        frame.size.height
    }
    
    var left: CGFloat {
        frame.origin.x
    }
    
    var right: CGFloat {
        left + width
    }
    
    
    var top: CGFloat {
        frame.origin.y
    }
    
    var bottom: CGFloat {
        top + height
    }
    
    
}
// MARK: - CandleStic Sorting

extension Array where Element == CandleStick {
    func getPercentage() -> Double {
        let latestDate = self[0].date
        
      guard  let latestClose = self.first?.close,
          let priorClose = self.first(where: {
                !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
            })?.close  else {
            return 0
        }
        
        let diff = 1 - (priorClose/latestClose)
        
        
        return diff
    }
}
