//
//  DetailViewController.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var quoteTextLabel: UILabel?

    var currentQuote: Quote? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let quote = self.currentQuote {
            self.title = quote.title
            self.quoteTextLabel?.text = quote.text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }

}

