//
//  ColorExtensions.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif
#if os(iOS)
import UIKit
#endif

// MARK: - Color Extensions
extension Color {
    static var controlBackground: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #elseif os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
    
    static var separator: Color {
        #if os(macOS)
        return Color(NSColor.separatorColor)
        #elseif os(iOS)
        return Color(UIColor.separator)
        #else
        return Color.gray.opacity(0.3)
        #endif
    }
}
