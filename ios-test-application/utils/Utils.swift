// Utils.swift
// ios-test-application

// Created by: CJ on 2025-09-02
// Copyright (c) 2025

import Foundation

protocol IdentifiableInstance: AnyObject {}
extension IdentifiableInstance {
  var instanceId: String { String(describing: ObjectIdentifier(self)) }
}

struct TestItem {
  let title: String
  let barcode: String
  let imageUrl: String
  let isActive: Bool

  init(title: String, barcode: String, imageUrl: String, isActive: Bool = true) {
    self.title = title
    self.barcode = barcode
    self.imageUrl = imageUrl
    self.isActive = isActive
  }

  init?(from dict: [String: Any]) {
    guard
      let title = dict["title"] as? String,
      let barcode = dict["barcode"] as? String
    else { return nil }
    self.title = title
    self.barcode = barcode
    self.imageUrl = dict["imageUrl"] as? String ?? ""
    self.isActive = dict["isActive"] as? Bool ?? true
  }
}

struct ServerConfig {
  let centralServerUrl: String
  let dataServerUrl: String
  let username: String
  let password: String
  let clientId: Int64

  init(centralServerUrl: String, dataServerUrl: String, username: String, password: String, clientId: Int64) {
    self.centralServerUrl = centralServerUrl
    self.dataServerUrl = dataServerUrl
    self.username = username
    self.password = password
    self.clientId = clientId
  }

  init?(from dict: [String: Any]) {
    guard
      let centralServerUrl = dict["CENTRAL_SERVER_URL"] as? String,
      let dataServerUrl = dict["DATA_SERVER_URL"] as? String,
      let username = dict["USERNAME"] as? String,
      let password = dict["PASSWORD"] as? String,
      let clientId = dict["CLIENT_ID"] as? Int64
    else { return nil }
    self.centralServerUrl = centralServerUrl
    self.dataServerUrl = dataServerUrl
    self.username = username
    self.password = password
    self.clientId = clientId
  }
}
