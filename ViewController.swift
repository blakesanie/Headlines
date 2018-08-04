//
//  ViewController.swift
//  newsTest
//
//  Created by Blake Sanie on 11/22/17.
//  Copyright © 2017 fooBar. All rights reserved.
//

import UIKit

var currentlyParsing = true

var selectedIndex = -1

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    var myRefreshControl : UIRefreshControl?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        selectedSources = sources
        selectedCats = [String]()
        myRefreshControl = UIRefreshControl()
        myTableView.refreshControl = myRefreshControl
        print("didLoad")
        myRefreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        refreshTable()
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return max(articles.count,1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == section {
            return 3
        }
        return 1
    }
    
    @objc func loadList() {
        DispatchQueue.main.async {
            articles.shuffle()
            print("load")
            self.myTableView.reloadData()
            self.myRefreshControl?.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if articles.count == 0 {
            cell = myTableView.dequeueReusableCell(withIdentifier: "none")!
        } else {
            if indexPath.row == 1 {
                cell = myTableView.dequeueReusableCell(withIdentifier: "more")!
                let subView = cell.viewWithTag(1)
                subView?.layer.cornerRadius = 10
                subView?.clipsToBounds = true
                let label = cell.viewWithTag(2) as! UILabel
                if articles[selectedIndex].intro! == "" {
                    label.text = "     " + articles[selectedIndex].headline!
                } else {
                    label.text = "     " + articles[selectedIndex].intro!
                }
            } else if indexPath.row == 2 {
                cell = myTableView.dequeueReusableCell(withIdentifier: "buttons")!
                let imgView = cell.viewWithTag(1) as? UIImageView
                imgView?.layer.cornerRadius = 10
                let more = cell.viewWithTag(2)
                more?.layer.cornerRadius = 10
                let dismiss = cell.viewWithTag(3)
                dismiss?.layer.cornerRadius = 10
                
                imgView?.image = nil
                if articles[selectedIndex].img! != "" {
                    imgView?.downloadImageFrom(link: articles[selectedIndex].img!)
                } else {
                    imgView?.image = UIImage(named: "noImage")
                }
            } else {
                cell = myTableView.dequeueReusableCell(withIdentifier: "cell")!
                let contentView = cell.viewWithTag(1)
                contentView!.layer.cornerRadius = 10
                contentView!.clipsToBounds = true
                let head = cell.viewWithTag(2) as! UILabel
                let article = articles[min(indexPath.section,articles.count - 1)]
                head.text = article.headline //if error, too many rows created
                
                
                let imgView = cell.viewWithTag(3) as! UIImageView
                if let filename = article.source {
                    imgView.image = UIImage(named: filename)
                }
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("selected index is: \(selectedIndex), row pressed is \(indexPath.row)")
        if selectedIndex == -1 || (indexPath.row != 1 && indexPath.row != 2) {
            let nextIndex = indexPath.section
            myTableView.beginUpdates()
            if selectedIndex > -1 {
                myTableView.deleteRows(at: [IndexPath.init(row: 1, section: selectedIndex), IndexPath.init(row: 2, section: selectedIndex)], with: .fade)
            }
            if !(selectedIndex == indexPath.section && indexPath.row == 0) {
                selectedIndex = nextIndex
                myTableView.insertRows(at: [IndexPath.init(row: 1, section: selectedIndex), IndexPath.init(row: 2, section: selectedIndex)], with: .fade)
            } else {
                selectedIndex = -1
            }
            myTableView.endUpdates()
        }
    }
    
    
    func dismissDetails() {
        let index = selectedIndex
        selectedIndex =  -1
        myTableView.deleteRows(at: [IndexPath.init(row: 1, section: index),IndexPath.init(row: 2, section: index)], with: .fade)
    }
    
    @IBAction func refresh(_ sender: Any) {
        refreshTable()
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        performSegue(withIdentifier: "toSideMenu", sender: self)
    }
    
    @objc func refreshTable() {
        print("refresh")
        myRefreshControl?.beginRefreshing()
        JsonData.getJson()
    }
    
    @IBAction func readMorePressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: articles[selectedIndex].url!)!)
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismissDetails()
    }
    
    
    
    
    
    
}



extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension UIImageView {
    func downloadImageFrom(link:String) {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async() {
                self.contentMode = .scaleAspectFill
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}

