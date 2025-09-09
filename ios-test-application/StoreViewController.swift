// StoreViewController.swift
// ios-test-application

import UIKit
import VSTT2

// Created by: CJ on 2025-09-02
// Copyright (c) 2025 

class StoreViewController: UIViewController{

  private let tag: String = "StoreViewController"

  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet weak var storeTableView: UITableView!
  @IBOutlet weak var itemsTableView: UITableView!

  // Populate with your test items
  let testItems: [TestItem] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    print("\(tag).viewDidLoad")

    // populate store table view

    storeTableView.dataSource = self
    storeTableView.delegate = self

    itemsTableView.dataSource = self
    itemsTableView.delegate = self

    storeTableView.isUserInteractionEnabled = true
    itemsTableView.isUserInteractionEnabled = false
    itemsTableView.alpha = 0.5
  }

  @IBAction func onExit(_ sender: UIButton) {
    dismiss(animated: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("\(tag).viewWillDisappear")
  }

  deinit {
    print("\(tag).deinit")
  }
}

extension StoreViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    var cell: UITableViewCell = UITableViewCell()

    if tableView == storeTableView {
      let storeCell = tableView.dequeueReusableCell(withIdentifier: "StoreTableCell") as! StoreTableCell

      storeCell.storeName.text = "\(AppState.shared.tt2.stores[indexPath.row].id):\(AppState.shared.tt2.stores[indexPath.row].name)"
      storeCell.store = AppState.shared.tt2.stores[indexPath.row]
      cell = storeCell

    } else if tableView == itemsTableView {
      let itemCell = tableView.dequeueReusableCell(withIdentifier: "ItemTableCell") as! ItemTableCell
      itemCell.itemName.text = "\(testItems[indexPath.row].title)"
      itemCell.item = testItems[indexPath.row]
      cell = itemCell
    }

    return cell
  }
  

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == storeTableView {
      return AppState.shared.tt2.stores.count
    } else if tableView == itemsTableView {
      return testItems.count
    } else {
      return 0
    }
  }
}

extension StoreViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == storeTableView {
      storeTableView.isUserInteractionEnabled = false
      itemsTableView.isUserInteractionEnabled = false
      print("\(tag).selectedStore: tap detected ")
      loadingIndicator.startAnimating()
      // do select operation of store
      let cell = tableView.cellForRow(at: indexPath) as! StoreTableCell
      print("\(tag).selectedStore: \((tableView.cellForRow(at: indexPath) as! StoreTableCell).store.id)")
      AppState.shared.tt2.initiate(store: cell.store) { [weak self] (error) in
        self?.storeTableView.isUserInteractionEnabled = true
        self?.loadingIndicator.stopAnimating()
        if let error = error {
          print("\(self?.tag).initStore Error: \(error)")
        } else {
          print("\(self?.tag).initStore Success")
          self?.itemsTableView.isUserInteractionEnabled = true
          self?.itemsTableView.alpha = 1.0
        }
      }
    } else if tableView == itemsTableView {
      // do select operation of item
      //
      let cell = tableView.cellForRow(at: indexPath) as! ItemTableCell
      AppState.shared.setSelectedItem(cell.item)

      present(storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController, animated: true)
    }
  }
}

class StoreTableCell: UITableViewCell {
  @IBOutlet weak var storeName: UILabel!
  var store: TT2Store!
}

class ItemTableCell: UITableViewCell {
  @IBOutlet weak var itemName: UILabel!
  var item: TestItem!
}
