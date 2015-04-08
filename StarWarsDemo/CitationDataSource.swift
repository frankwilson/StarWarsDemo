//
//  CitationDataSource.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

struct Citation: Equatable {
    let id: Int
    let title: String
    let text: String
}

func ==(lhs: Citation, rhs: Citation) -> Bool {
    return lhs.id == rhs.id
}

private let sourceUrlStr = "http://crazy-dev.wheely.com"

func mapper(data: [String: AnyObject]) -> Citation {
    let id = (data["id"] as NSNumber).integerValue
    let title = data["title"] as String
    let text = data["text"] as String

    return Citation(id: id, title: title, text: text)
}

typealias DataChangedCallback = (removed: NSIndexSet, added: NSIndexSet) -> Void

class CitationDataSource {

    private let session: NSURLSession

    private(set) var citations = [Citation]()

    var dataChangedCallback: DataChangedCallback?

    init() {
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }

    private func fetch() {
        let url = NSURL(string: sourceUrlStr)!;
        let task = self.session.dataTaskWithURL(url) { (result, response, error) -> Void in
            var error: NSError?
            var citations = NSJSONSerialization.JSONObjectWithData(result, options: nil, error: &error) as [[String: AnyObject]]?

            if let citationsRaw = citations {
                let citations = citationsRaw.map(mapper).sorted({ $0.id < $1.id })

                let oldCitations = self.citations
                self.log("Old objects set", citations: self.citations)
                self.citations = citations
                self.log("New objects set", citations: self.citations)

                if let callback = self.dataChangedCallback {
                    let intersecton = swd_intersect(oldCitations, citations)
                    let toRemove = swd_substract(oldCitations, intersecton)
                    let toAdd = swd_substract(citations, intersecton)
                    self.log("Objects to remove", citations: toRemove)
                    self.log ("Objects to add", citations: toAdd)

                    callback(removed: self.indexSet(oldCitations, target: toRemove), added: self.indexSet(citations, target: toAdd))
                }
            } else {
                NSLog("Something's not right! Server did not return an array of data!")
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        task.resume()
    }

    func refresh() {
        fetch()
    }

    /// We know that both arrays are sorted!
    /// And we know that container contains all elements of target
    private func indexSet(container: [Citation], target: [Citation]) -> NSIndexSet {
        var checkedIndex = 0
        var result = NSMutableIndexSet()
        for (index, element) in enumerate(container) {
            if checkedIndex == target.count {
                break
            }
            if element.id < target[checkedIndex].id {
                continue
            } else {
                if element.id == target[checkedIndex].id {
                    result.addIndex(index)
                }
                checkedIndex++
            }
        }

        return NSIndexSet(indexSet: result)
    }

    private func log(prefixMessage: String, citations: [Citation]) {
        let objects = ", ".join(citations.map({ "\($0.id)" }))
        NSLog("\(prefixMessage): \(objects)")
    }
}
