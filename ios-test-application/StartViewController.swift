// ViewController.swift
// ios-test-application

// Created by: CJ on 2025-09-02
// Copyright (c) 2025 ___ORGANIZATIONNAME___

import UIKit
import VSTT2
import VSMap
import VSFoundation

class StartViewController: UIViewController {
  private let tag: String = "StartViewController"

  @IBOutlet weak var initAllOfTT2Button: UIButton!
  @IBOutlet weak var proceedButton: UIButton!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

  lazy var config: ServerConfig? = getConfig(for: 0)

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    print("\(tag).viewDidLoad")
    proceedButton.isEnabled = false
    loadingIndicator.isHidden = true
  }

  func getConfig(for client: Int) -> ServerConfig? {
    guard
      let path = Bundle.main.path(forResource: "config", ofType: "plist"),
      let dict = NSDictionary(contentsOfFile: path)?["CLIENT_\(client.description)"] as? [String: Any]
    else { return nil }
    return .init(from: dict)
  }

  @IBAction func handleInitTT2MapSDKButtonPressed(_ sender: UIButton) {
    print("\(tag).initTT2MapSDK")
    AppState.shared.initTT2Map(TT2Map())
    if AppState.shared.isTT2Initialised {
      AppState.shared.tt2.set(mapManager: AppState.shared.tt2Map.manager)
      proceedButton.isEnabled = true
    }
  }
  
  @IBAction func handleDisposeTT2MapSDKButtonPressed(_ sender: UIButton) {
    print("\(tag).disposeTT2MapSDK")
    AppState.shared.disposeTT2()
    proceedButton.isEnabled = false
  }

  @IBAction func handleInitTT2SDKButtonPressed(_ sender: UIButton) {
    print("\(tag).initTT2SDK")
    guard let config = config else { print("Could not get config"); return }
    let connectionSettings = EnvironmentConfig.Direct(authType: .tokenBased, tt2CentralServer: config.centralServerUrl, tt2DataServer: config.dataServerUrl)
    let authSettings = AuthSettings.tokenBased(.init(username: config.username, password: config.password))
    let settings = TT2Settings(isAutomaticFloorChangeEnabled: false, debugModeEnabled: true)

    AppState.shared.disposeTT2()
    AppState.shared.initTT2(TT2(connectionSettings: connectionSettings, authSettings: authSettings, settings: settings))
    if AppState.shared.isTT2MapInitialised {
      AppState.shared.tt2.set(mapManager: AppState.shared.tt2Map.manager)
    }
  }
  
  @IBAction func handleInitTT2ClientButtonPressed(_ sender: UIButton) {
    print("\(tag).initTT2Client")
    guard let config = config else { return }
    AppState.shared.tt2.initialize(clientId: config.clientId, positionKitParams: .retail) { [weak self] (error) in
      self?.loadingIndicator.stopAnimating()
      self?.loadingIndicator.isHidden = true
      sender.isEnabled = true

      if let error = error {
        print("\(self?.tag).onClient initialization failed: \(error)")
        return
      }
      print("\(self?.tag).onClient initialization completed")

      self?.proceedButton.isEnabled = AppState.shared.isTT2Initialised && AppState.shared.isTT2MapInitialised
    }
  }
  
  @IBAction func handleDisposeTT2SDKButtonPressed(_ sender: UIButton) {
    print("\(tag).disposeTT2SDK")
    AppState.shared.disposeTT2()
    proceedButton.isEnabled = false
  }
  

  @IBAction func handleInitAllOfTT2ButtonPressed(_ sender: UIButton) {
    print("\(tag).handleInit")
    guard let config = config else { print("Could not get config"); return }
    sender.isEnabled = false

    loadingIndicator.startAnimating()
    loadingIndicator.isHidden = false
    proceedButton.isEnabled = false

    let connectionSettings = EnvironmentConfig.Direct(authType: .tokenBased, tt2CentralServer: config.centralServerUrl, tt2DataServer: config.dataServerUrl)
    let authSettings = AuthSettings.tokenBased(.init(username: config.username, password: config.password))
    let settings = TT2Settings(isAutomaticFloorChangeEnabled: false, debugModeEnabled: true)

    AppState.shared.disposeTT2()
    AppState.shared.initTT2(TT2(connectionSettings: connectionSettings, authSettings: authSettings, settings: settings))
    AppState.shared.initTT2Map(TT2Map())
    AppState.shared.tt2.set(mapManager: AppState.shared.tt2Map.manager)

    AppState.shared.tt2.initialize(clientId: config.clientId, positionKitParams: .retail) { [weak self] (error) in
      self?.loadingIndicator.stopAnimating()
      self?.loadingIndicator.isHidden = true
      sender.isEnabled = true

      if let error = error {
        print("\(self?.tag).onClient initialization failed: \(error)")
        return
      }
      print("\(self?.tag).onClient initialization completed")
      self?.proceedButton.isEnabled = AppState.shared.isTT2Initialised && AppState.shared.isTT2MapInitialised
    }
  }

  @IBAction func handleDisposeAllOfTT2ButtonPressed(_ sender: UIButton) {
    print("\(tag).disposeAllOfTT2")
    AppState.shared.disposeTT2()
    proceedButton.isEnabled = false
  }

  @IBAction func handleProceedButtonPressed(_ sender: UIButton) {
    print("\(tag).OnProceed")
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("\(tag).viewWillDisappear")
  }

  deinit {
    print("\(tag).deinit")
  }
}
