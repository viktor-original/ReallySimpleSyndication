//
//  XMLHelper.swift
//  ReallySimpleSyndicationApp
//
//  Created by Viktor Krasilnikov on 19.10.22.
//

import UIKit

struct RSSItem {
    var title: String
    var description: String
    var link: String
    var pubDate: String
}

class FeedParser: NSObject, XMLParserDelegate {
    
    private var rssItems: [RSSItem] = []
    private var rssImgs: [String] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentImgUrl = ""
    private var parserCompletionHandler: (([RSSItem], [String]) -> Void)?
    
    func parseFeed(url: String, completionHandler: (([RSSItem], [String]) -> Void)?) {
        self.parserCompletionHandler = completionHandler
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            let urlSession = URLSession.shared
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
            task.resume()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        switch elementName {
        case "item":
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
        case "enclosure":
            if let urlString = attributeDict["url"] {
                currentImgUrl += urlString
                rssImgs.append(urlString)
            }
        default: break
        }
        
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title": currentTitle += string
        case "description": currentDescription += string
        case "link": currentLink += string
        case "pubDate": currentPubDate += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(title: currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                  description: currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                  link: currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                  pubDate: currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            self.rssItems.append(rssItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItems, rssImgs)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
