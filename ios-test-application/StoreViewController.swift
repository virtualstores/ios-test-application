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
  var testItems: [TestItem] = []

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

  func loadItemsWithLocalFile() {
    guard
      let path = Bundle.main.path(forResource: "testItems", ofType: "plist"),
      let arr = NSArray(contentsOfFile: path) as? [[String:Any]]
    else { return }
    arr.forEach {
      guard let testItem = TestItem(from: $0), testItem.isActive else { return }
      AppState.shared.getPositionBy(identifier: testItem.barcode) { (result) in
        switch result {
        case .success(let item):
          if item.itemPosition != nil || item.zonePosition != nil {
            self.testItems.append(testItem)
            self.itemsTableView.reloadData()
          }
        case .failure(_):
          break
        }
      }
    }
  }
}

extension StoreViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell = UITableViewCell()
    switch tableView {
    case storeTableView:
      let storeCell = tableView.dequeueReusableCell(withIdentifier: "StoreTableCell") as! StoreTableCell
      storeCell.storeName.text = "\(AppState.shared.tt2.stores[indexPath.row].id):\(AppState.shared.tt2.stores[indexPath.row].name)"
      storeCell.store = AppState.shared.tt2.stores[indexPath.row]
      cell = storeCell
    case itemsTableView:
      let itemCell = tableView.dequeueReusableCell(withIdentifier: "ItemTableCell") as! ItemTableCell
      itemCell.itemName.text = "\(testItems[indexPath.row].title)"
      itemCell.item = testItems[indexPath.row]
      cell = itemCell
    default: break
    }

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch tableView {
    case storeTableView: return AppState.shared.tt2.stores.count
    case itemsTableView: return testItems.count
    default: return 0
    }
  }
}

extension StoreViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch tableView {
    case storeTableView:
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
          self?.loadItemsWithLocalFile()
        }
      }
    case itemsTableView:
      let cell = tableView.cellForRow(at: indexPath) as! ItemTableCell
      AppState.shared.setSelectedItem(cell.item)
      let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
      present(vc, animated: true)
    default: break
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
