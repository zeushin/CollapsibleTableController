//
//  ViewController.swift
//  CollapsibleTableController
//
//  Created by Masher on 10/10/2018.
//  Copyright (c) 2018 Masher.dev. All rights reserved.
//

import UIKit
import CollapsibleTableController

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView! {
        didSet {
            collapsibleTableController.dataSource = self
            collapsibleTableController.delegate = self
        }
    }

    private var collapsibleTableController = CollapsibleTableController()

    var allCollapse = false

    @IBAction func barButtonAction(_ sender: Any) {
        if allCollapse {
            collapsibleTableController.expandAll()
        } else {
            collapsibleTableController.collapseAll()
        }
        allCollapse = !allCollapse
    }

}

// MARK: - CollapsibleTableDataSource
extension ViewController: CollapsibleTableDataSource {

    var collapsibleTableView: UITableView? {
        return tableView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfCollapsibleSectionsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int, collapsibleSection: Int) -> Int {
        switch collapsibleSection {
        case 0: return 5
        case 1: return 3
        case 2: return 2
        case 3: return 2
        case 4: return 2
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, headerForSection section: Int,
                   collapsibleSection: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Header")!
        cell.textLabel?.text = "Header \(collapsibleSection)"
        cell.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: CollapsibleIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath.indexPath)
        cell.textLabel?.text = "\(indexPath.collapsibleSection) - \(indexPath.row)"
        return cell
    }
}

// MARK: - CollapsibleTableDelegate
extension ViewController: CollapsibleTableDelegate {}
