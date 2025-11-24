// MapViewController.swift
// ios-test-application

import UIKit
import VSMap
import Combine
import VSFoundation
import VSTT2
// Created by: CJ on 2025-09-02
// Copyright (c) 2025

class MapViewController: UIViewController, IdentifiableInstance {
  private var tag: String { "MapViewController:\(instanceId)" }
  private var cancellable = Set<AnyCancellable>()
  private var mapController: BaseMapController?

  @IBOutlet weak var mapView: TT2MapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    print("\(tag).viewDidLoad")

    // create MapController

    if let token = try? AppState.shared.tt2.activeFloor.mapBoxToken {
      mapController = BaseMapController(
        with: token,
        view: mapView,
        mapOptions: .init(),
        stateOptions: StateOptions.init(preset: .singleItemWayfinding)
      )
    }

    if let map = mapController {
      AppState.shared.tt2.set(map: map)
    }
    bindPublishers()
  }

  private func bindPublishers(){
    mapController?.mapStatePublisher.sink(receiveValue: { [weak self] state in
      print("\(self?.tag).onMapStateChanged: \(state)")
    }).store(in: &cancellable)

    mapController?.mapDataLoadedPublisher
      .sink { (result) in
        switch result {
        case .finished: break
        case .failure(_): break
        }
      } receiveValue: { [weak self] (loaded) in
        guard
          loaded,
          let self = self,
          let item = AppState.shared.selectedItem
        else { return }
        mapController?.zone.hideAllLayers()
        addMarkOnMap(for: item)
      }.store(in: &cancellable)
  }

  var item: Item?
  private func addMarkOnMap(for testItem: TestItem) {
    AppState.shared.getPositionBy(identifier: testItem.barcode) { [weak self] (result) in
      switch result {
      case .success(let item):
        var marker: MapMark?
        if let position = item.itemPosition {
          marker = self?.createMarker(with: position, imageUrl: testItem.imageUrl)
        }
        if let position = item.zonePosition {
          marker = self?.createMarker(with: position, imageUrl: testItem.imageUrl)
          self?.mapController?.zone.select(zoneId: position.id)
          self?.mapController?.zone.show(zoneId: position.id)
        }

        guard let marker = marker else { return }
        self?.item = item
        self?.mapController?.marker.add(marker: marker)
        self?.mapController?.path.set(goals: [marker.asGoal]) {}
      case .failure(let error):
        print("\(self?.tag).createMarker error: \(error)")
      }
    }
  }

  /// Creating a BaseMapMark with a ItemPosition
  func createMarker(with position: ItemPosition, imageUrl: String) -> MapMark {
    BaseMapMark(
      id: position.identifier,
      itemPosition: position,
      clusterable: false,
      defaultVisibility: true,
      focused: false,
      type: .imageUrl(imageUrl)
    )
  }

  /// Creating a BaseMapMark with a ZonePosition
  func createMarker(with position: ZonePosition, imageUrl: String) -> MapMark {
    BaseMapMark(
      id: position.id,
      zonePosition: position,
      clusterable: false,
      defaultVisibility: true,
      focused: false,
      type: .imageUrl(imageUrl)
    )
  }

  func syncPosition(identifier: String) {
    AppState.shared.tt2.navigation.syncPosition(identifier: identifier, type: .compass(forceSync: false), reportScanEvent: true) { [weak self] result in
      switch result {
      case .success(let success):
        print("\(self?.tag).syncPosition success: \(success)")
        AppState.shared.startVisit(with: self?.item)
      case .failure(let error):
        print("\(self?.tag).syncPosition error: \(error)")
      }
    }
  }

  @IBAction func scanQrCode(_ sender: UIButton) {
    let alert = UIAlertController(title: "Choose a start scan location", message: nil, preferredStyle: .actionSheet)
    try? AppState.shared.tt2.activeFloor.scanLocations?
      .filter { $0.type == .start }
      .forEach { (code) in
        alert.addAction(.init(title: code.code, style: .default, handler: { [weak self] (_) in
          self?.syncPosition(identifier: code.code)
        }))
      }
    alert.addAction(.init(title: "Cancel", style: .cancel))
    present(alert, animated: true)
  }

  @IBAction func scanEANCode(_ sender: UIButton) {
    syncPosition(identifier: "Enter random barcode here to test start navigation with EAN")
  }

  @IBAction func stopNavigation(_ sender: UIButton) {
    AppState.shared.tt2.navigation.stop()
    AppState.shared.tt2.analytics.stopCollectingHeatMapData()
    AppState.shared.tt2.analytics.stopVisit()
  }

  @IBAction func onExit(_ sender: UIButton) {
    print("\(tag).onExit")
    cancellable.removeAll()
    mapController?.dispose()
    AppState.shared.tt2.set(map: nil)
    mapController = nil
    if let item = item {
      AppState.shared.stopTrackingWayfinding(with: item)
      self.item = nil
    }

    dismiss(animated: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("\(tag).viewWillDisappear")
  }

  deinit {
    print("\(tag).deinit")
    //mapController?.path.set(goals: []){}
    // testa med och utan, spännande
    cancellable.removeAll()
  }
}
