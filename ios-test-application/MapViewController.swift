// MapViewController.swift
// ios-test-application

import UIKit
import VSMap
import Combine
import VSFoundation
// Created by: CJ on 2025-09-02
// Copyright (c) 2025

class MapViewController: UIViewController, IdentifiableInstance {
  private var tag: String {
    "MapViewController:\(self.instanceId)"
  }
  private var cancellable = Set<AnyCancellable>()
  private var mapController: BaseMapController?

  @IBOutlet weak var mapView: TT2MapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    print("\(tag).viewDidLoad")

    // create MapController

    if let token = AppState.shared.tt2.activeFloor.mapBoxToken {
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

  var itemPosition: ItemPosition?
  private func addMarkOnMap(for testItem: TestItem) {
    AppState.shared.tt2.position.getBy(barcode: testItem.barcode) { [weak self] result in
      switch result {
      case .success(let item):
        guard let itemPosition = item.itemPosition else { return }
        self?.itemPosition = itemPosition
        let id = item.externalId
        let marker = BaseMapMark(
          id: id,
          itemPosition: itemPosition,
          clusterable: false,
          defaultVisibility: true,
          focused: false,
          type: .imageUrl(testItem.imageUrl)
        )

        self?.mapController?.marker.add(marker: marker)
        self?.mapController?.path.set(goals: [marker.asGoal]) {}
        if AppState.shared.tt2.analytics.hasVisit {
          AppState.shared.tt2.analytics.startTrackingWayfinding(itemPosition: itemPosition)
        }
      case .failure(let error): // Handle error
        print("\(self?.tag).createMarker error: \(error)")
      }
    }
  }

  @IBAction func scanQrCode(_ sender: UIButton) {
    AppState.shared.tt2.navigation.syncPosition(identifier: "start_test_3", type: .normal(syncRotation: false), reportScanEvent: true) { [weak self] result in
      switch result {
      case .success(let success):
        print("\(self?.tag).syncPosition success: \(success)")
        if !AppState.shared.tt2.analytics.hasVisit {
          AppState.shared.tt2.analytics.startVisit(deviceInformation: .init(id: "", operatingSystem: "", osVersion: "", appVersion: "", deviceModel: ""), tags: ["userId": "ios-test-app"]) { (result) in
            switch result {
            case .success(_):
              try? AppState.shared.tt2.analytics.startCollectingHeatMapData()
              if let itemPosition = self?.itemPosition {
                AppState.shared.tt2.analytics.startTrackingWayfinding(itemPosition: itemPosition)
              }
            case .failure(_):
              break
            }
          }
        }
      case .failure(let error):
        print("\(self?.tag).syncPosition error: \(error)")
      }
    }
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
    if let itemPosition = itemPosition {
      AppState.shared.tt2.analytics.stopTrackingWayfinding(itemPosition: itemPosition)
      self.itemPosition = nil
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
