//
//  BeaconViewModel.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 13/02/24.
//

import Foundation

class BeaconViewModel: ObservableObject {
    
    @Published var text: String = "0"
    
    func updateText() {
        // Some logic to update the text property
        if let intValue = Int(self.text) {
            self.text = "\(intValue + 1)"
        } else {
            self.text = "-1"
        }
    }
}
