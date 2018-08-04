//
//  JsonData.swift
//  newsTest
//
//  Created by Blake Sanie on 11/22/17.
//  Copyright © 2017 fooBar. All rights reserved.
//

import Foundation

struct article {
    let headline : String?
    let intro : String?
    let url: String?
    let img: String?
    let source : String?
}

var articles = [article]()

class JsonData {
    static func getJson() {
        var sourcesParsed = 0
        currentlyParsing = true
        articles = [article]()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        while max(selectedSources.count,1) > sourcesParsed {
            // key is e8568dc9b5284deaa14e52d135ad9648
            
            //new key is 3b49377ff47f4e2baee0ceb3976a58b8
            
            //https://newsapi.org/v2/top-headlines?sources=the-new-york-times&apiKey=3b49377ff47f4e2baee0ceb3976a58b8
            
            var link = "https://newsapi.org/v2/top-headlines?"
            
            if selectedSources.count > 0 {
                link += "sources="
                for i in sourcesParsed..<min(sourcesParsed + 20,selectedSources.count) {
                    link += "\(selectedSources[i]),"
                }
                link = String(link.dropLast())
                link += "&"
            }
            
            let newLink = link
            
            if selectedCats.count > 0 {
                for i in 0..<selectedCats.count {
                    let cat = selectedCats[i]
                    link = newLink
                    link += "category=\(cat)&language=en&apiKey=3b49377ff47f4e2baee0ceb3976a58b8"
                    
                    let url = URL(string: link)
                    
                    let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        if error != nil {
                            print (error!)
                        }
                        else {
                            do {
                                if let data = data {
                                    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                    print(json)
                                    let results = json["articles"] as! [AnyObject]
                                    selectedIndex = -1
                                    for result in results {
                                        var desc = String()
                                        var title = String()
                                        var url = String()
                                        var img = String()
                                        var source = String()
                                        let src = result["source"] as AnyObject
                                        if let id = src["id"] as? String {
                                            source = id
                                        }
                                        if sources.contains(source) {
                                            if let ti = result["title"] as? String {
                                                title = ti.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                            }
                                            if let description = result["description"] as? String {
                                                desc = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                            }
                                            if let link = result["url"] as? String {
                                                url = link
                                            }
                                            if let image = result["urlToImage"] as? String {
                                                img = image
                                            }
                                            articles.append(article(headline: title, intro: desc, url: url, img: img, source: source))
                                        }
                                    }
                                    currentlyParsing = false
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                                }
                            } catch {
                                print("Error deserializing JSON: \(error)")
                            }
                        }
                    }
                    task.resume()
                }
            } else {
                link += "language=en&apiKey=3b49377ff47f4e2baee0ceb3976a58b8"
                
                //print(link + "\n")
                
                let url = URL(string: link)
                
                let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil {
                        print (error!)
                    }
                    else {
                        do {
                            if let data = data {
                                let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                let results = json["articles"] as! [AnyObject]
                                selectedIndex = -1
                                for result in results {
                                    var desc = String()
                                    var title = String()
                                    var url = String()
                                    var img = String()
                                    var source = String()
                                    let src = result["source"] as AnyObject
                                    if let id = src["id"] as? String {
                                        source = id
                                    }
                                    if sources.contains(source) {
                                        if let ti = result["title"] as? String {
                                            title = ti.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                        }
                                        if let description = result["description"] as? String {
                                            desc = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                        }
                                        if let link = result["url"] as? String {
                                            url = link
                                        }
                                        if let image = result["urlToImage"] as? String {
                                            img = image
                                        }
                                        articles.append(article(headline: title, intro: desc, url: url, img: img, source: source))
                                    }
                                }
                                currentlyParsing = false
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                            }
                        } catch {
                            print("Error deserializing JSON: \(error)")
                        }
                    }
                }
                task.resume()
            }
            sourcesParsed += 20
        }
        print("heyooooooo")
    }
}
