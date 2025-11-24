// AppState.swift
// ios-test-application

import Foundation
import UIKit
import VSFoundation
import VSTT2
import VSMap

// Created by: CJ on 2025-09-02
// Copyright (c) 2025

class AppState {
    static let shared = AppState()

    private var _tt2: TT2?
    var tt2: TT2 {
      guard let value = _tt2 else { fatalError("TT2 not initialised") }
      return value
    }

    var isTT2Initialised: Bool { _tt2 != nil }

    private var _tt2Map: TT2Map?
    var tt2Map: TT2Map {
      guard let value = _tt2Map else { fatalError("TT2 Map not initialised") }
      return value
    }
    var isTT2MapInitialised: Bool { _tt2Map != nil }

    private var _selectedItem: TestItem?
    var selectedItem: TestItem? { _selectedItem }

    private init() {}

    func initTT2(_ tt2: TT2) {
        self._tt2 = nil
        self._tt2 = tt2
    }

    func initTT2Map(_ tt2Map: TT2Map) {
        self._tt2Map = nil
        self._tt2Map = tt2Map
    }

    func disposeTT2() {
        self._tt2Map?.dispose()
        self._tt2Map = nil
        self._tt2?.dispose()
        self._tt2 = nil
    }

    func setSelectedItem(_ selectedItem: TestItem?) {
        self._selectedItem = selectedItem
    }

    func startVisit(with item: Item?) {
        guard (try? tt2.activeStore) != nil, !tt2.analytics.hasVisit else { return }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let info = DeviceInformation(
          id: UIDevice.current.name,
          operatingSystem: UIDevice.current.systemName,
          osVersion: UIDevice.current.systemVersion,
          appVersion: "\(appVersion ?? "Unknown") (\(buildNumber ?? ""))",
          deviceModel: UIDevice.current.modelName
        )
        tt2.analytics.startVisit(deviceInformation: info, tags: ["userId": "ios-test-app"]) { [weak self] (result) in
            switch result {
            case .success(_):
                try? self?.tt2.analytics.startCollectingHeatMapData()
            case .failure(let error):
                print("Error starting visit", error)
            }
            if let item = item {
                self?.startTrackingWayfinding(with: item)
            }
        }
    }

    func startTrackingWayfinding(with item: Item) {
        guard tt2.analytics.hasVisit else { return }
        if let position = item.itemPosition {
            tt2.analytics.startTrackingWayfinding(itemPosition: position)
        } else if let position = item.zonePosition {
            tt2.analytics.startTrackingWayfinding(zonePosition: position)
        }
    }

    func stopTrackingWayfinding(with item: Item) {
        guard tt2.analytics.hasVisit else { return }
        if let position = item.itemPosition {
            tt2.analytics.stopTrackingWayfinding(itemPosition: position)
        } else if let position = item.zonePosition {
            tt2.analytics.stopTrackingWayfinding(zonePosition: position)
        }
    }

    func getPositionBy(identifier: String, completion: @escaping (Result<Item, Error>) ->()) {
        tt2.position.getBy(barcode: identifier, completion: completion)
    }
}
