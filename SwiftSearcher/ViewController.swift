//
//  ViewController.swift
//  SwiftSearcher
//
//  Created by Simon Italia on 4/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController {
    
    //Property to store tutorial project titles and subtitles
    var tutorials = [[String]]()
    
    //Property to track tutorials favorited by user
    var favorites = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tutorials.append(["Project 1: Storm Viewer, Constants and Variables", "UITableView, UIImageView, FileManager, storyboards"])
        
        tutorials.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        
        tutorials.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL"])
        
        tutorials.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"])
        
        tutorials.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange"])
        
        tutorials.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        
        tutorials.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController"])
        
        tutorials.append(["Project 8: 7 Swifty Words", "addTarget(), enumerated(), count, index(of:), property observers, range operators."])
        
        print(tutorials)
        
        //Load previouslysaved favorites from disk (if any)
        let defaults = UserDefaults.standard
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            
            favorites = savedFavorites
        }
        
        //Set table cell / row to allow edit so user can save tutorial as a favorite, denoted by checkmark
        tableView.isEditing = true
        
        //Also set table cell / row to allow selection during editing
        tableView.allowsSelectionDuringEditing = true
 
    }
    
    //Set number of table rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tutorials.count
    }
    
    //Create and return the cell object to display in the table rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Pull out each project tutorial object from the array
        let tutorial = tutorials[indexPath.row]
        
        //Assign each project tutorial object's name (at index 0) and subtitle (at index 1) to the cell / row text.
//        cell.textLabel?.text = "\(tutorial[0]): \(tutorial[1])"
        
        //Set attributed settings to cell text by calling our makeAttributedString method and passing in the text strings
        cell.textLabel?.attributedText = makeAttributedString(title: tutorial[0], subtitle: tutorial[1])
        
        //If user has favorited a tutorial, show a checkmark
        if favorites.contains(indexPath.row) {
            cell.editingAccessoryType = .checkmark
                
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    //Apply string formatting using NSAttributedString
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
    
    //Set title font (using NSAttributedString.Key.font dictionary key) to preferredFont. Also set text color with .foregroundColor:
    let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.purple]
    
    //Set subtitle font to preferredFont
    let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
    
    //Apply title attributes. Declared as mutable since subtitle is appended to it
    let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
    
    let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    func showTutorial(_ which: Int) {
        if let url = URL(string: "https://hackingwithswift.com/read/\(which + 1)") {
            
            let config = SFSafariViewController.Configuration()
            
            //Set reader mode flag
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true )
        }
    }
    
    //Display tutorial when user taps a table row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if favorites.contains(indexPath.row) {
            return .delete
        
        } else {
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //If user is adding tutorial / row itemto favorites
        if editingStyle == .insert {
            
            //Add to favorites array
            favorites.append(indexPath.row)
            
            //Capture the index of the row item / tutorial
            indexOf(tutorial: indexPath.row)
        
        //If user is removing tutotial / row item from favorites
        } else {
            if let index = favorites.firstIndex(of: indexPath.row) {
                favorites.remove(at: index)
                deindexOf(tutorial: indexPath.row)
            }
        }
        
        //Save changes (add or remove favorited tutorial) to disk
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        //Update tableView with changes
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
    func indexOf(tutorial item: Int) {
        
        let tutorial = tutorials[item]
        
        //Configure CSSearchableItemAttributeSet to store Spotlight searchable information
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                //kUTTypeText informs iOS that the indexed record we're storing is text
        
        //Store favorited tutorial title and subtitle (content)
        attributeSet.title = tutorial[0]
        attributeSet.contentDescription = tutorial[1]
        
        //Wrap attributeSet inside CSSearchableItem object
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        
        //Override default 1 month expiry period, after item is indexed
        item.expirationDate = Date.distantFuture
        
        //Index item object
        CSSearchableIndex.default().indexSearchableItems([item], completionHandler: { error in
            
            if let error = error {
                    print("indexing error: \(error.localizedDescription)")
                
            } else {
                    print("Search item successfuly indexed!")
            }
        })
    }
    
    func deindexOf(tutorial item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
                
            } else {
                print("Seacrh item succesfully removed from index")
            }
        }
    }
}
