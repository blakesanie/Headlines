//
//  SideMenu.swift
//  newsTest
//
//  Created by Blake Sanie on 11/23/17.
//  Copyright © 2017 fooBar. All rights reserved.
//

import UIKit

var selectedSources = [String]()
var selectedCats = [String]()

let sources = ["abc-news","australian-financial-review","axios","bbc-news","bild","bleacher-report","bloomberg","business-insider","buzzfeed","cbc-news","cbs-news","cnn","daily-mail","entertainment-weekly","espn","fortune","fox-news","ign","mashable","mtv-news","nbc-news","newsweek","nfl-news","nhl-news","techradar","the-huffington-post","the-new-york-times","the-wall-street-journal","the-washington-post","time","usa-today","wired"]

let cats = ["business","entertainment","general","health","music","science","sport","technology"]

class SideMenu: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var tempSources = [String]()
    var tempCats = [String]()
    
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var catTableView: UITableView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var fadeLayer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.transform = CGAffineTransform(translationX: -1.0 * mainView.frame.width, y: 0)
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        catTableView.delegate = self
        catTableView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        var offset = Int()
        if UIScreen.main.bounds.width < 321 {
            offset = 65
        } else {
            offset = 45
        }
        print(myCollectionView.frame.width, myCollectionView.frame.width / 2 - CGFloat(offset))
        let cellWidth = myCollectionView.frame.width / 2 - CGFloat(offset)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.minimumInteritemSpacing = 30
        layout.minimumLineSpacing = 30
        myCollectionView.collectionViewLayout = layout
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tempCats = selectedCats
        tempSources = selectedSources
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.mainView.transform = CGAffineTransform(translationX: 0, y: 0)
                        self.fadeLayer.alpha = 1.0
                        
        },
                       completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = catTableView.dequeueReusableCell(withIdentifier: "cell")
        let label = cell?.viewWithTag(1) as! UILabel
        label.text = formatCat(text: cats[indexPath.row])
        var indexes = [Int]()
        for cat in selectedCats {
            indexes.append(cats.index(of: cat)!)
        }
        if indexes.contains(indexPath.row) {
            cell?.accessoryType = .checkmark
            label.alpha = 1.0
        } else {
            cell?.accessoryType = .none
            label.alpha = 0.3
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cat = cats[indexPath.row]
        if selectedCats.contains(cat) {
            let index = selectedCats.index(of: cat)
            selectedCats.remove(at: index!)
        } else {
            selectedCats.append(cat)
        }
        print("\(selectedCats.count) cats")
        catTableView.reloadData()
    }
    
    @IBAction func selectAllCats(_ sender: Any) {
        selectedCats = cats
        catTableView.reloadData()
    }
    
    @IBAction func deselectAllCats(_ sender: Any) {
        selectedCats = [String]()
        catTableView.reloadData()
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(2) as! UIImageView
        imageView.image = UIImage(named: sources[indexPath.row])
        var indexes = [Int]()
        for source in selectedSources {
            indexes.append(sources.index(of: source)!)
        }
        if indexes.contains(indexPath.row) {
            cell.alpha = 1.0
        } else {
            cell.alpha = 0.2
        }
        return cell
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch?.location(in: self.view).x)! > self.view.frame.width * 0.7 {
            dismissView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let source = sources[indexPath.row]
        if selectedSources.contains(source) {
            let index = selectedSources.index(of: source)
            selectedSources.remove(at: index!)
        } else {
            selectedSources.append(source)
        }
        print("\(selectedSources.count) sources")
        myCollectionView.reloadData()
    }
    
    @IBAction func selectAllSources(_ sender: Any) {
        selectedSources = sources
        myCollectionView.reloadData()
    }
    
    @IBAction func deselectAllSources(_ sender: Any) {
        selectedSources = [String]()
        myCollectionView.reloadData()
    }
    
    func formatCat(text : String) -> String {
        var str = text
        str = str.replacingOccurrences(of: "-", with: " ")
        str = str.capitalized
        return str
    }
    
    func dismissView() {
        if selectedSources.count + selectedCats.count > 0 {
            if tempSources != selectedSources || tempCats != selectedCats {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
            }
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            self.mainView.transform = CGAffineTransform(translationX: -1.0 * self.mainView.frame.width, y: 0)
                            self.fadeLayer.alpha = 0.0
                            
            },
                           completion: { finished in
                            self.dismiss(animated: false)
            })
        } else {
            let alertController = UIAlertController(title: "Oops!", message:
                "Please choose at least one category or source", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Got It!", style: .default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func swipedLeft(_ sender: Any) {
        dismissView()
    }
    
}
