//
//  CitationDataSource.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

/// The Quote model
struct Quote: Hashable, Equatable {
    let id: Int
    let title: String
    let text: String

    var hashValue: Int {
        return id
    }
}
extension Quote {
    /// Initialize the quote from a JSON dictionary
    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? NSNumber else {
            return nil
        }
        guard let title = data["title"] as? String else {
            return nil
        }
        guard let text = data["text"] as? String else {
            return nil
        }

        self.id = id.integerValue
        self.title = title
        self.text = text
    }
}
func ==(lhs: Quote, rhs: Quote) -> Bool {
    return lhs.id == rhs.id
}

enum QuotesDataSourceErrorType: ErrorType {
    /// When JSON parser returned something different from an Array
    case NotArray
}

private let sourceUrlStr = "https://crazy-dev.wheely.com/"
private let sourceUrl = NSURL(string: sourceUrlStr)!

typealias DataChangedCallback = (removedIndexes: NSIndexSet, addedIndexes: NSIndexSet) -> Void

// Also network reachability could be added
// https://github.com/belkevich/reachability-ios

/// Class fetches data from The Source
class QuotesDataSource {

    /// Network manager
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    /// Current quotes
    private(set) var quotes = [Quote]()

    /**
     * Fetches data from The Source
     *
     * - param callback: Callback that is called when data is updated
     * - param errorCallback: Callback that is called when there is error in fetching or parsing data
     */
    func fetch(callback: DataChangedCallback, errorCallback: (ErrorType -> Void)?) {

        let task = session.dataTaskWithURL(sourceUrl) { (result, response, error) -> Void in
            defer {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            guard let result = result else {
                NSLog("Something's not right! Server did not return an array of data!")
                if let theError = error {
                    errorCallback?(theError)
                }
                return
            }

            do {
                let citations = try NSJSONSerialization.JSONObjectWithData(result, options: [])
                if let quotes = citations as? [[String: AnyObject]] {
                    callback(self.processFetchedResult(quotes))
                } else {
                    errorCallback?(QuotesDataSourceErrorType.NotArray)
                }
            } catch let error {
                NSLog("Something's not right! Can't parse the data!")
                errorCallback?(error)
            }
        }

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        task.resume()
    }

    /// Prepares data for use – converts to an array of Quotes
    private func processFetchedResult(result: [[String: AnyObject]]) -> (removedIndexes: NSIndexSet, addedIndexes: NSIndexSet) {
        // Transform Dictionary to Quote
        let quotes = result.flatMap { Quote(data: $0) }

        let previousQuotes = Set<Quote>(self.quotes)
        log("Old objects set", quotes: self.quotes)
        self.quotes = quotes
        log("New objects set", quotes: self.quotes)
        let currentQuotes = Set<Quote>(self.quotes)

        let intersection = previousQuotes.intersect(currentQuotes)
        let quotesToRemove = previousQuotes.subtract(intersection)
        let quotesToAdd = currentQuotes.subtract(intersection)
        log("Objects to remove", quotes: Array(quotesToRemove))
        log("Objects to add", quotes: Array(quotesToAdd))

        return (removedIndexes: indexSet(quotesToRemove, inContainer: previousQuotes), addedIndexes: indexSet(quotesToAdd, inContainer: currentQuotes))
    }

    /// Makes index set by finding indexes of quotes from target set in a container set
    private func indexSet(targetSet: Set<Quote>, inContainer containerSet: Set<Quote>) -> NSIndexSet {
        let target = targetSet.sort { $0.id < $1.id }
        let container = containerSet.sort { $0.id < $1.id }
        var checkedIndex = 0
        let result = NSMutableIndexSet()
        for (index, element) in container.enumerate() {
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

    /// Logs array of quotes
    private func log(prefixMessage: String, quotes: [Quote]) {
        let objects = quotes.map({ "\($0.id)" }).joinWithSeparator(", ")
        NSLog("\(prefixMessage): \(objects)")
    }
}
