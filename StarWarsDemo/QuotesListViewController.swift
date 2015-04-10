//
//  MasterViewController.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

class QuotesListViewController: UITableViewController {

    private let dataSource = CitationDataSource()

    private var refreshing = false
    weak private var refreshTimer: NSTimer?

    // Interval can be changed from outside
    var refreshInterval: NSTimeInterval = 8.42

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Star Wars Quotes"

        self.tableView.estimatedRowHeight = 89
        self.tableView.rowHeight = UITableViewAutomaticDimension

        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        self.refreshControl = refreshControl

        self.dataSource.dataChangedCallback = { [unowned self] (removed, added) in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl!.endRefreshing()
                self.navigationItem.prompt = nil

                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths(indexPaths(removed), withRowAnimation: .Fade)
                self.tableView.insertRowsAtIndexPaths(indexPaths(added), withRowAnimation: .Fade)
                self.tableView.endUpdates()

                self.startRefreshTimer()
                self.refreshing = false
            }
        }
        self.dataSource.errorCallback = { [unowned self] error in
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("error: \(error)")
                self.navigationItem.prompt = "Data can not be loaded"

                self.refreshControl!.endRefreshing()
                self.startRefreshTimer()
                self.refreshing = false
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.refreshData()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let quoteToPresent = dataSource.quotes[indexPath.row]
                (segue.destinationViewController as DetailViewController).currentQuote = quoteToPresent
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.quotes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as QuoteTableViewCell

        let object = dataSource.quotes[indexPath.row]

        cell.titleLabel.text = object.title
        cell.descriptionLabel.text = object.text

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    // MARK: - Other functions
    // Called by timer to refresh data
    func refreshData() {
        if !self.refreshing {
            self.refreshing = true
            if !self.refreshControl!.refreshing {
                self.refreshControl!.beginRefreshing()
            }
            self.dataSource.refresh()
            self.refreshTimer?.invalidate()
        }
    }

    private func startRefreshTimer(repeat: Bool = false) {
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval, target: self, selector: "refreshData", userInfo: nil, repeats: repeat)
    }
}

func indexPaths(indexSet: NSIndexSet) -> [NSIndexPath] {
    var indexPaths = [NSIndexPath]()
    indexSet.enumerateIndexesUsingBlock { (index, stop) -> Void in
        indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
    }
    return indexPaths
}


class QuoteTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

}

