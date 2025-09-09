// AppState.swift
// ios-test-application

import Foundation
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
}
