//
//  ScopeManagement.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Scope Management Extensions
@available(iOS 13.0, macOS 10.15, *)
extension AdvancedDIContainerImpl {
    
    // MARK: - Scope Management
    public func createScope(_ scopeId: String) async {
        self.scopedInstances[scopeId] = [:]
        print("🔧 Created scope: \(scopeId)")
    }
    
    public func disposeScope(_ scopeId: String) async {
        self.scopedInstances.removeValue(forKey: scopeId)
        print("🗑️ Disposed scope: \(scopeId)")
    }
    
    public func setCurrentScope(_ scopeId: String) async {
        self.scopeId = scopeId
    }
    
    public func getCurrentScope() -> String {
        return scopeId
    }
}
