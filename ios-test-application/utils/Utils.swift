// Utils.swift
// ios-test-application

// Created by: CJ on 2025-09-02
// Copyright (c) 2025 

import Foundation

protocol IdentifiableInstance: AnyObject {}
extension IdentifiableInstance {
    var instanceId: String {
        String(describing: ObjectIdentifier(self))
    }
}
