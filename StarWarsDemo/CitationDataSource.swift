//
//  CitationDataSource.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

struct Quote: Equatable {
    let id: Int
    let title: String
    let text: String
}

func ==(lhs: Quote, rhs: Quote) -> Bool {
    return lhs.id == rhs.id
}

private let sourceUrlStr = "http://crazy-dev.wheely.com/"

func mapper(data: [String: AnyObject]) -> Quote? {
    let id = data["id"] as? NSNumber
    let title = data["title"] as? String
    let text = data["text"] as? String

    if (id == nil || title == nil || text == nil) {
        return nil
    }

    return Quote(id: id!.integerValue, title: title!, text: text!)
}

typealias DataChangedCallback = (removed: NSIndexSet, added: NSIndexSet) -> Void

class CitationDataSource {

    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    private(set) var quotes = [Quote]()

    var dataChangedCallback: DataChangedCallback?
    var errorCallback: ((NSError) -> Void)?

    // Does not compile without default initializer
    init() {
        // I could add network reachability check here, but I didn't
        // https://github.com/belkevich/reachability-ios
    }

    private func fetch() {
        let url = NSURL(string: sourceUrlStr)!;
        let task = self.session.dataTaskWithURL(url) { (result, response, error) -> Void in
            if response == nil {
                NSLog("Something's not right! Server did not return an array of data!")
                if let callback = self.errorCallback {
                    callback(error!)
                }
            } else {
                var error: NSError?
                var citations = NSJSONSerialization.JSONObjectWithData(result, options: nil, error: &error) as [[String: AnyObject]]?
                if let citationsRaw = citations {
                    self.processFetchedResult(citationsRaw)
                } else {
                    NSLog("Something's not right! Can't parse the data!")
                    if let callback = self.errorCallback {
                        callback(error!)
                    }
                }
            }

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        task.resume()
    }

    func refresh() {
        fetch()
    }

    private func processFetchedResult(result: [[String: AnyObject]]) {
        // Transform Dictionary to Quote
        // Then remove nil optionals
        // Then transform optionals to non-optionals
        let quotes = result.map(mapper).filter({ $0 != nil }).map({ $0! }).sorted({ $0.id < $1.id })

        let previousQuotes = self.quotes
        self.log("Old objects set", quotes: self.quotes)
        self.quotes = quotes
        self.log("New objects set", quotes: self.quotes)

        if let callback = self.dataChangedCallback {
            let intersecton = swd_intersect(previousQuotes, quotes)
            let toRemove = swd_substract(previousQuotes, intersecton)
            let toAdd = swd_substract(quotes, intersecton)
            self.log("Objects to remove", quotes: toRemove)
            self.log ("Objects to add", quotes: toAdd)

            callback(removed: self.indexSet(toRemove, inContainer: previousQuotes), added: self.indexSet(toAdd, inContainer:quotes))
        }
    }

    /// We know that both arrays are sorted!
    /// And we know that container contains all elements of target
    private func indexSet(target: [Quote], inContainer container: [Quote]) -> NSIndexSet {
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

    private func log(prefixMessage: String, quotes: [Quote]) {
        let objects = ", ".join(quotes.map({ "\($0.id)" }))
        NSLog("\(prefixMessage): \(objects)")
    }
}
