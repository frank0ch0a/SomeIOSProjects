//
//  HapticsManager.swift
//  Stocks
//
//  Created by Francisco Ochoa on 02/11/2021.
//

import Foundation
import UIKit


/// Object to manage haptics
final class HapticsManager {
    
    /// Sigleton
    static let shared = HapticsManager()
    
    
    /// Private constructor
    private init() {}
    
    // MARK: - Public
    
    /// Vibrate slighly for selection
    public func vibrateForSelection() {
        
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    
    
    
    }
    
    
    /// Play haptic for given interaction
    /// - Parameter type: Type to vibrate for
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
  
        
    }
}
