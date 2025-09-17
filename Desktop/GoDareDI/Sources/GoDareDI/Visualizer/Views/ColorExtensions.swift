//
//  ColorExtensions.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 18.0, macOS 10.15, *)
extension Color {
    // Dependency Graph Colors
    public static let dependencyBlue = Color.blue
    public static let serviceGreen = Color.green
    public static let errorRed = Color.red
    public static let warningOrange = Color.orange
    
    // Graph Node Colors
    public static let nodeBackground = Color.white
    public static let nodeBorder = Color.gray.opacity(0.3)
    public static let selectedNode = Color.blue.opacity(0.3)
    
    // Graph Edge Colors
    public static let edgeColor = Color.gray.opacity(0.5)
    public static let selectedEdge = Color.blue
    public static let circularDependency = Color.red
    
    // UI Colors
    public static let graphBackground = Color.gray.opacity(0.1)
    public static let panelBackground = Color.white
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary
}
