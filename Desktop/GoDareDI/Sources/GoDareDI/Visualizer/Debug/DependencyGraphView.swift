//
//  DependencyGraphView.swift
//  GoDareAdvanced
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

@MainActor
public struct DependencyGraphView: View {
    private let container: AdvancedDIContainer
    
    @State private var graph: DependencyGraph?
    @State private var analysis: GraphAnalysis?
    @State private var selectedNode: String?
    @State private var selectedVisualizationType: VisualizationType = .mermaid
    @State private var visualizationData: String = ""
    @State private var showInteractiveView = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var selectedTab = 0
    @State private var showCopyFeedback = false
    
    // Computed property to get token from container
    private var token: String? {
        if let containerImpl = container as? AdvancedDIContainerImpl {
            return containerImpl.token
        }
        return nil
    }
    
    // Computed property to check if container has valid token
    private var hasValidToken: Bool {
        if let containerImpl = container as? AdvancedDIContainerImpl {
            return containerImpl.hasValidToken
        }
        return false
    }
    
    // Computed property to check if container is in freemium mode
    private var isFreemiumMode: Bool {
        if let containerImpl = container as? AdvancedDIContainerImpl {
            return containerImpl.isFreemiumMode
        }
        return true // Default to freemium if not AdvancedDIContainerImpl
    }
    
    public init(container: AdvancedDIContainer) {
        self.container = container
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Show subscription prompt if in freemium mode or no valid token
                if isFreemiumMode || !hasValidToken {
                    subscriptionPromptView
                } else {
                    // Tab Selection
                    tabSection
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        // Overview Tab
                        overviewTab
                            .tag(0)
                        
                        // Visualization Tab
                        visualizationTab
                            .tag(1)
                        
                        // Interactive Tab
                        interactiveTab
                            .tag(2)
                    }
                    #if os(iOS)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    #endif
                }
            }
        }
        .onAppear {
            // Only load graph data if user has valid token and is not in freemium mode
            if !isFreemiumMode && hasValidToken {
                loadGraphData()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dependency Graph")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Analyze your dependency injection structure")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    loadGraphData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.controlBackground)
    }
    
    // MARK: - Tab Section
    private var tabSection: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Overview",
                icon: "chart.bar.fill",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabButton(
                title: "Visualization",
                icon: "eye.fill",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabButton(
                title: "Interactive",
                icon: "hand.tap.fill",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color.controlBackground)
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Error Display
                if let errorMessage = errorMessage {
                    ErrorCard(message: errorMessage)
                }
                
                // Loading Indicator
                if isLoading {
                    LoadingCard()
                }
                
                // Statistics Section
                if let analysis = analysis {
                    statisticsSection(analysis: analysis)
                }
                
                // Graph Information
                if graph != nil {
                    graphInfoSection(graph: graph!)
                }
                
                // Dashboard Update Section
                DashboardUpdateView(container: container, graph: graph, analysis: analysis)
            }
            .padding()
        }
    }
    
    // MARK: - Visualization Tab
    private var visualizationTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Visualization Type Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Visualization Type")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(VisualizationType.allCases, id: \.self) { type in
                            VisualizationTypeCard(
                                type: type,
                                isSelected: selectedVisualizationType == type
                            ) {
                                selectedVisualizationType = type
                                generateVisualization()
                            }
                        }
                    }
                }
                
                // Generate Button
                Button(action: {
                    generateVisualization()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Generate Visualization")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .disabled(graph == nil)
                
                // Visualization Output
                if !visualizationData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Generated Visualization")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Button(action: {
                                copyToClipboard(visualizationData)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: showCopyFeedback ? "checkmark" : "doc.on.doc")
                                    Text(showCopyFeedback ? "Copied!" : "Copy")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ScrollView {
                            Text(visualizationData)
                                .font(Font.system(.body, design: .monospaced))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.controlBackground)
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 300)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Interactive Tab
    private var interactiveTab: some View {
        VStack {
            if showInteractiveView {
                if let graph = graph {
                    #if os(macOS)
                    if #available(macOS 13.0, *) {
                        InteractiveDependencyGraphView(graph: graph)
                    } else {
                        Text("Interactive view requires macOS 13.0 or later")
                            .foregroundColor(.secondary)
                    }
                    #else
                    InteractiveDependencyGraphView(graph: graph)
                    #endif
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Interactive View")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tap to explore your dependency graph interactively")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showInteractiveView = true
                    }) {
                        Text("Launch Interactive View")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(graph == nil)
                }
                .padding()
            }
        }
    }
    
    // MARK: - Statistics Section
    private func statisticsSection(analysis: GraphAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatisticsCard(
                    title: "Total Dependencies",
                    value: "\(analysis.totalDependencies)",
                    icon: "link",
                    color: .blue
                )
                
                StatisticsCard(
                    title: "Circular Dependencies",
                    value: "\(analysis.circularDependencyChains.count)",
                    icon: "arrow.triangle.2.circlepath",
                    color: .red
                )
                
                StatisticsCard(
                    title: "Max Depth",
                    value: "\(analysis.maxDepth)",
                    icon: "arrow.down",
                    color: .orange
                )
                
                StatisticsCard(
                    title: "Complexity Score",
                    value: String(format: "%.1f", analysis.complexityMetrics.couplingScore),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Graph Info Section
    private func graphInfoSection(graph: DependencyGraph) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Graph Information")
                .font(.headline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Nodes:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(graph.nodes.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Edges:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(graph.edges.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Dependency Types:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Set(graph.nodes.map { $0.type }).count)")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.controlBackground)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Functions
    private func loadGraphData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            let dependencyGraph = await container.getDependencyGraph()
            let graphAnalysis = await container.analyzeDependencyGraph()
            
            await MainActor.run {
                self.graph = dependencyGraph
                self.analysis = graphAnalysis
                self.isLoading = false
                print("✅ Loaded dependency graph with \(dependencyGraph.nodes.count) nodes and \(dependencyGraph.edges.count) edges")
            }
        }
    }
    
    private func generateVisualization() {
        guard graph != nil else { return }
        
        Task {
            do {
                let visualizer = DependencyVisualizer(container: container)
                let result = try await visualizer.visualizeAsync(type: selectedVisualizationType)
                
                await MainActor.run {
                    self.visualizationData = result
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate visualization: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = text
        #endif
        
        // Show feedback
        showCopyFeedback = true
        
        // Reset feedback after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCopyFeedback = false
        }
    }
    
    // MARK: - Subscription Prompt View
    
    private var subscriptionPromptView: some View {
        VStack(spacing: 24) {
            // Premium Icon
            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                Text("Premium Feature")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Feature Description
            VStack(spacing: 12) {
                Text("Unlock Advanced Dependency Visualization")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("Get detailed insights into your app's dependency architecture with interactive graphs, analysis, and dashboard sync.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Features List
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Interactive Dependency Graphs", description: "Visualize your app's architecture")
                FeatureRow(icon: "arrow.triangle.2.circlepath", title: "Circular Dependency Detection", description: "Identify and fix dependency cycles")
                FeatureRow(icon: "chart.bar.fill", title: "Performance Analytics", description: "Track complexity and coupling metrics")
                FeatureRow(icon: "icloud.and.arrow.up", title: "Dashboard Sync", description: "Sync data to web dashboard")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // Subscription Buttons
            VStack(spacing: 12) {
                Button(action: {
                    openSubscriptionPage()
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Subscribe to Premium")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                Button(action: {
                    openDashboard()
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Get Token from Dashboard")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    showTokenInputDialog()
                }) {
                    HStack {
                        Image(systemName: "key.fill")
                        Text("Enter Premium Token")
                    }
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Free Trial Info
            VStack(spacing: 8) {
                Text("✨ 7-day free trial available")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
                
                Text("Cancel anytime • No commitment")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    // MARK: - Feature Row Component
    
    private struct FeatureRow: View {
        let icon: String
        let title: String
        let description: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Subscription Actions
    
    private func openSubscriptionPage() {
        // Open the web dashboard subscription page
        if let url = URL(string: "https://godaredi-60569.web.app") {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #elseif canImport(AppKit)
            NSWorkspace.shared.open(url)
            #endif
        }
    }
    
    private func openDashboard() {
        // Open the web dashboard to get a token
        if let url = URL(string: "https://godaredi-60569.web.app") {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #elseif canImport(AppKit)
            NSWorkspace.shared.open(url)
            #endif
        }
    }
    
    private func showTokenInputDialog() {
        // Show an alert to input the premium token
        #if canImport(UIKit)
        let alert = UIAlertController(title: "Enter Premium Token", message: "Please enter your premium token to unlock advanced features.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your 64-character token"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        let upgradeAction = UIAlertAction(title: "Upgrade", style: .default) { _ in
            if let token = alert.textFields?.first?.text, !token.isEmpty {
                Task {
                    await upgradeToPremium(token: token)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(upgradeAction)
        alert.addAction(cancelAction)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
        #elseif canImport(AppKit)
        // macOS implementation
        let alert = NSAlert()
        alert.messageText = "Enter Premium Token"
        alert.informativeText = "Please enter your premium token to unlock advanced features."
        alert.alertStyle = .informational
        
        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        inputField.placeholderString = "Enter your 64-character token"
        alert.accessoryView = inputField
        
        alert.addButton(withTitle: "Upgrade")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let token = inputField.stringValue
            if !token.isEmpty {
                Task {
                    await upgradeToPremium(token: token)
                }
            }
        }
        #endif
    }
    
    private func upgradeToPremium(token: String) async {
        guard let containerImpl = container as? AdvancedDIContainerImpl else {
            print("❌ Cannot upgrade: Container is not AdvancedDIContainerImpl")
            return
        }
        
        do {
            try await containerImpl.upgradeToPremium(token: token)
            print("🎉 Successfully upgraded to Premium!")
            
            // Refresh the view to show premium features
            await MainActor.run {
                // The view will automatically refresh due to the computed properties
                loadGraphData()
            }
        } catch {
            print("❌ Failed to upgrade to Premium: \(error)")
            
            // Show error message
            #if canImport(UIKit)
            let alert = UIAlertController(title: "Upgrade Failed", message: "Invalid token. Please check your token and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
            #elseif canImport(AppKit)
            let alert = NSAlert()
            alert.messageText = "Upgrade Failed"
            alert.informativeText = "Invalid token. Please check your token and try again."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            #endif
        }
    }
}
