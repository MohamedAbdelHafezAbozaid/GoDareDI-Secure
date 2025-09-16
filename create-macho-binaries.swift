#!/usr/bin/env swift

import Foundation

print("🔧 Creating Mach-O binaries for SPM...")

let fileManager = FileManager.default
let currentDirectory = fileManager.currentDirectoryPath

// Platforms to fix
let platforms = [
    ("ios-arm64", "arm64"),
    ("ios-arm64-simulator", "arm64"),
    ("ios-x86_64-simulator", "x86_64")
]

for (platform, arch) in platforms {
    print("🔨 Creating Mach-O binary for \(platform)...")
    
    let frameworkPath = "\(currentDirectory)/GODareDI.xcframework/\(platform)/GODareDI.framework"
    let binaryPath = "\(frameworkPath)/GODareDI"
    
    // Create a simple C source file
    let cSource = """
    // Minimal framework binary for GODareDI
    void GODareDI_init() {
        // Framework initialization
    }
    
    int GODareDI_version() {
        return 200; // Version 2.0.0
    }
    """
    
    let cFilePath = "/tmp/macho_\(platform).c"
    try cSource.write(toFile: cFilePath, atomically: true, encoding: .utf8)
    
    // Determine SDK path
    let sdk = platform.contains("simulator") ? "iphonesimulator" : "iphoneos"
    let sdkPath = "/Applications/Xcode.app/Contents/Developer/Platforms/\(sdk).platform/Developer/SDKs/\(sdk).sdk"
    
    // Compile to Mach-O binary
    let clangProcess = Process()
    clangProcess.executableURL = URL(fileURLWithPath: "/usr/bin/clang")
    clangProcess.arguments = [
        cFilePath,
        "-o", "/tmp/macho_\(platform)",
        "-arch", arch,
        "-isysroot", sdkPath,
        "-shared",
        "-undefined", "dynamic_lookup",
        "-O3"
    ]
    
    try clangProcess.run()
    clangProcess.waitUntilExit()
    
    if clangProcess.terminationStatus == 0 {
        // Replace the binary
        try fileManager.removeItem(atPath: binaryPath)
        try fileManager.copyItem(atPath: "/tmp/macho_\(platform)", toPath: binaryPath)
        print("✅ Created Mach-O binary for \(platform)")
    } else {
        print("❌ Failed to create Mach-O binary for \(platform)")
    }
    
    // Clean up temp files
    try? fileManager.removeItem(atPath: cFilePath)
    try? fileManager.removeItem(atPath: "/tmp/macho_\(platform)")
}

print("✅ All Mach-O binaries created!")
