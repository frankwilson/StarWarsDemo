//
//  DetailViewController.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

/// Class shows full text of a quote
class DetailViewController: UIViewController {

    @IBOutlet weak var quoteTextLabel: UILabel?

    /// Current quote model
    var currentQuote: Quote? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let quote = currentQuote {
            title = quote.title
            quoteTextLabel?.text = quote.text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

}

