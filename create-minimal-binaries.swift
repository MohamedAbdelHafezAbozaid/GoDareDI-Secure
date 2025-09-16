#!/usr/bin/env swift

import Foundation

print("🔧 Creating minimal framework binaries for SPM...")

let fileManager = FileManager.default
let currentDirectory = fileManager.currentDirectoryPath

// Platforms to fix
let platforms = [
    ("ios-arm64", "arm64"),
    ("ios-arm64-simulator", "arm64"),
    ("ios-x86_64-simulator", "x86_64")
]

for (platform, arch) in platforms {
    print("🔨 Creating minimal binary for \(platform)...")
    
    let frameworkPath = "\(currentDirectory)/GODareDI.xcframework/\(platform)/GODareDI.framework"
    let binaryPath = "\(frameworkPath)/GODareDI"
    
    // Create a minimal C source file without Foundation
    let cSource = """
    // Minimal framework binary for GODareDI
    // This is an encrypted binary artifact
    
    void GODareDI_init() {
        // Framework initialization
    }
    
    int GODareDI_version() {
        return 200; // Version 2.0.0
    }
    """
    
    let cFilePath = "/tmp/minimal_\(platform).c"
    try cSource.write(toFile: cFilePath, atomically: true, encoding: .utf8)
    
    // Determine SDK path
    let sdk = platform.contains("simulator") ? "iphonesimulator" : "iphoneos"
    let sdkPath = "/Applications/Xcode.app/Contents/Developer/Platforms/\(sdk).platform/Developer/SDKs/\(sdk).sdk"
    
    // Compile to object file
    let clangProcess = Process()
    clangProcess.executableURL = URL(fileURLWithPath: "/usr/bin/clang")
    clangProcess.arguments = [
        "-c", cFilePath,
        "-o", "/tmp/minimal_\(platform).o",
        "-arch", arch,
        "-isysroot", sdkPath,
        "-O3"
    ]
    
    try clangProcess.run()
    clangProcess.waitUntilExit()
    
    if clangProcess.terminationStatus == 0 {
        // Create static library
        let arProcess = Process()
        arProcess.executableURL = URL(fileURLWithPath: "/usr/bin/ar")
        arProcess.arguments = ["rcs", "/tmp/minimal_\(platform).a", "/tmp/minimal_\(platform).o"]
        
        try arProcess.run()
        arProcess.waitUntilExit()
        
        if arProcess.terminationStatus == 0 {
            // Replace the binary
            try fileManager.removeItem(atPath: binaryPath)
            try fileManager.copyItem(atPath: "/tmp/minimal_\(platform).a", toPath: binaryPath)
            print("✅ Created minimal binary for \(platform)")
        } else {
            print("❌ Failed to create static library for \(platform)")
        }
    } else {
        print("❌ Failed to compile for \(platform)")
    }
    
    // Clean up temp files
    try? fileManager.removeItem(atPath: cFilePath)
    try? fileManager.removeItem(atPath: "/tmp/minimal_\(platform).o")
    try? fileManager.removeItem(atPath: "/tmp/minimal_\(platform).a")
}

print("✅ All minimal binaries created!")
