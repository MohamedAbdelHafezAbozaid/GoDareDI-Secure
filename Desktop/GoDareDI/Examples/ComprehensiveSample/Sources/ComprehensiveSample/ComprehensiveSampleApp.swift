//
//  ComprehensiveSampleApp.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI
import GoDareDI

// MARK: - Sample App (Disabled - Remove @main to prevent interference)
// @main
struct ComprehensiveSampleApp: App {
    @State private var container: AdvancedDIContainer?
    @State private var isInitialized = false
    
    var body: some Scene {
        WindowGroup {
            if isInitialized, let container = container {
                MainTabView(container: container)
            } else {
                LoadingView()
                    .task {
                        await initializeApp()
                    }
            }
        }
    }
    
    private func initializeApp() async {
        do {
            print("🚀 Initializing Comprehensive Sample App...")
            
            // Create container with configuration
            let config = DIContainerConfig(
                maxCircularDependencyDepth: 3,
                enableCircularDependencyDetection: true,
                enableDependencyTracking: true,
                enablePerformanceMetrics: true,
                enableCaching: true
            )
            
            // Build container with modules
            container = try await ContainerFactory.createWithModules(
                config: config,
                modules: [
                    NetworkModule(),
                    CacheModule(),
                    RepositoryModule(),
                    UseCaseModule(),
                    ViewModelModule()
                ]
            )
            
            // Preload dependencies for better performance
            if let container = container {
                try await container.preloadViewModelsOnly()
                print("✅ Dependencies preloaded successfully")
            }
            
            isInitialized = true
            print("✅ App initialized successfully")
            
        } catch {
            print("❌ Failed to initialize app: \(error)")
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    let container: AdvancedDIContainer
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            UserListView(container: container)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Users")
                }
                .tag(0)
            
            DependencyGraphView(container: container)
                .tabItem {
                    Image(systemName: "network")
                    Text("Dependencies")
                }
                .tag(1)
            
            PerformanceView(container: container)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Performance")
                }
                .tag(2)
            
            SettingsView(container: container)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo/Icon
            Image(systemName: "network")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Title
            Text("GoDareDI")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Comprehensive Sample")
                .font(.title2)
                .foregroundColor(.secondary)
            
            // Loading indicator
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Initializing dependencies...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Dependency Graph View
struct DependencyGraphView: View {
    let container: AdvancedDIContainer
    @State private var graphData: String = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Generating dependency graph...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        Text(graphData)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    }
                }
            }
            .navigationTitle("Dependency Graph")
            .task {
                await generateGraph()
            }
        }
    }
    
    private func generateGraph() async {
        isLoading = true
        
        do {
            let visualizer = DependencyVisualizer(container: container)
            graphData = await visualizer.visualizeAsync(type: .mermaid)
        } catch {
            graphData = "Error generating graph: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Performance View
struct PerformanceView: View {
    let container: AdvancedDIContainer
    @State private var metrics: PerformanceMetrics?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading performance metrics...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let metrics = metrics {
                    List {
                        Section("Resolution Metrics") {
                            MetricRow(title: "Average Resolution Time", value: String(format: "%.3f ms", metrics.averageResolutionTime * 1000))
                            MetricRow(title: "Total Resolutions", value: "\(metrics.totalResolutions)")
                            MetricRow(title: "Cache Hit Rate", value: String(format: "%.1f%%", metrics.cacheHitRate))
                        }
                        
                        Section("Memory & Performance") {
                            MetricRow(title: "Memory Usage", value: String(format: "%.2f MB", metrics.memoryUsage))
                            MetricRow(title: "Circular Dependencies", value: "\(metrics.circularDependencyCount)")
                        }
                    }
                } else {
                    Text("No metrics available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Performance")
            .task {
                await loadMetrics()
            }
        }
    }
    
    private func loadMetrics() async {
        isLoading = true
        metrics = await container.getPerformanceMetrics()
        isLoading = false
    }
}

// MARK: - Metric Row
struct MetricRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    let container: AdvancedDIContainer
    @State private var showingClearCache = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Container Information") {
                    HStack {
                        Text("Registered Services")
                        Spacer()
                        Text("\(container.getRegisteredServicesCount())")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Current Scope")
                        Spacer()
                        Text(container.getCurrentScope())
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Actions") {
                    Button("Clear Cache") {
                        showingClearCache = true
                    }
                    .foregroundColor(.red)
                    
                    Button("Preload Dependencies") {
                        Task {
                            await container.preloadDependencies()
                        }
                    }
                    
                    Button("Validate Dependencies") {
                        Task {
                            do {
                                try await container.validateDependencies()
                            } catch {
                                print("Validation error: \(error)")
                            }
                        }
                    }
                }
                
                Section("Debug") {
                    Button("Print Metadata") {
                        container.debugPrintMetadata()
                    }
                    
                    Button("Print Factories") {
                        container.debugPrintFactories()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Clear Cache", isPresented: $showingClearCache) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    Task {
                        await container.cleanup()
                    }
                }
            } message: {
                Text("This will clear all cached instances and reset the container.")
            }
        }
    }
}
