//
//  MasterViewController.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

/// The class represents a view controller displaying a list of quotes
class QuotesListViewController: UITableViewController {

    /// The quotes data source
    private let dataSource = QuotesDataSource()

    /// Indicates if data is currently being refreshed
    private var refreshing = false
    /// Timer that runs a data refresh
    weak private var refreshTimer: NSTimer?

    // Interval can be changed from outside
    var refreshInterval: NSTimeInterval = 8.42

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Star Wars Quotes"

        tableView.estimatedRowHeight = 89
        tableView.rowHeight = UITableViewAutomaticDimension

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        self.refreshControl = refreshControl
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.refreshData()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let quoteToPresent = dataSource.quotes[indexPath.row]
                if let detailViewController = segue.destinationViewController as? DetailViewController {
                    detailViewController.currentQuote = quoteToPresent
                }
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.quotes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! QuoteTableViewCell

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
        if !refreshing {
            refreshing = true
            if let refreshControl = self.refreshControl where refreshControl.refreshing == false {
                refreshControl.beginRefreshing()
            }
            dataSource.fetch({ [weak self] (removed, added) in
                guard let vc = self else {
                    return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    vc.refreshControl?.endRefreshing()
                    vc.navigationItem.prompt = nil

                    vc.tableView.beginUpdates()
                    vc.tableView.deleteRowsAtIndexPaths(convertToIndexPaths(removed), withRowAnimation: .Fade)
                    vc.tableView.insertRowsAtIndexPaths(convertToIndexPaths(added), withRowAnimation: .Fade)
                    vc.tableView.endUpdates()

                    vc.startRefreshTimer()
                    vc.refreshing = false
                }
            }, errorCallback: { [weak self] error in
                guard let vc = self else {
                    return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    NSLog("error: \(error)")
                    vc.navigationItem.prompt = "Data can not be loaded"
                    vc.refreshControl?.endRefreshing()
                    vc.startRefreshTimer()
                    vc.refreshing = false
                }
            })
            refreshTimer?.invalidate()
        }
    }

    /// Creates a new timer that updates data for the table view
    private func startRefreshTimer(shouldRepeat: Bool = false) {
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval, target: self, selector: "refreshData", userInfo: nil, repeats: shouldRepeat)
    }
}

/// Converts s NSIndexSet to an array of NSIndexPath with value from index set as a row index and 0 as a section index
func convertToIndexPaths(indexSet: NSIndexSet) -> [NSIndexPath] {
    var indexPaths = [NSIndexPath]()
    indexSet.enumerateIndexesUsingBlock { (index, stop) -> Void in
        indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
    }
    return indexPaths
}

/// The class represents a table view cell for a Quote
class QuoteTableViewCell: UITableViewCell {

    /// Quote title
    @IBOutlet var titleLabel: UILabel!
    /// Quote text
    @IBOutlet var descriptionLabel: UILabel!

}

