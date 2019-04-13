//
//  TutorialDataDelegate.swift
//  SwiftSearcher
//
//  Created by Simon Italia on 4/13/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

protocol TutorialDataProtocol {
    
    func fetchedTutorials(jsonData: [[Tutorial]])
    
}

class TutorialDataDelegate {
    
    var delegate: TutorialDataProtocol?
    
    //Load local JSON file "CountryData.json"
    func getLocalJSONFile() {
        
        let jsonFilePath = Bundle.main.path(forResource: "TutorialData", ofType: "json")
        
        guard jsonFilePath != nil else {
            print("JSON file not found!")
            return
        }
        
        let jsonFileURL = URL(fileURLWithPath: jsonFilePath!)
        
        do {
            
            let jsonData = try Data(contentsOf: jsonFileURL)
            
            let jsonDecoder = JSONDecoder()
            let tutorials = try jsonDecoder.decode([[Tutorial]].self, from: jsonData)
            
            //Call to delegate method to pass JSON data to ViewController
            delegate?.fetchedTutorials(jsonData: tutorials)
            
            print("jsonDataObject created successfully from jsonFileURL")
            
        }
        catch {
            print("Failed to create jsonDataObjectfrom jsonFileURL")
        }
    }
}
