//
//  DetailViewController.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel?

    var detailItem: Citation? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            self.title = detail.title
            self.detailDescriptionLabel?.text = detail.text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }

}

