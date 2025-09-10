//
//  SimpleDependencyGraphView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

/// Cross-platform compatible dependency graph view
@MainActor
public struct SimpleDependencyGraphView: View {
    private let container: AdvancedDIContainer
    
    @State private var graph: DependencyGraph?
    @State private var analysis: GraphAnalysis?
    @State private var visualizationData: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showCopyFeedback = false
    @State private var isUpdatingDashboard = false
    @State private var dashboardUpdateMessage: String?
    
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
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Show subscription prompt if in freemium mode or no valid token
                if isFreemiumMode || !hasValidToken {
                    subscriptionPromptView
                } else {
                    // Action Buttons (only show if has valid token)
                    actionButtonsView
                    
                    // Dashboard Update Section (only show if container has valid token)
                    dashboardUpdateView
                    
                    // Status
                    statusView
                    
                    // Analysis Summary
                    if let analysis = analysis {
                        analysisSummaryView(analysis)
                    }
                    
                    // Visualization
                    if !visualizationData.isEmpty {
                        visualizationView
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Dependency Graph")
        }
        .task {
            // Only load graph data if user has valid token and is not in freemium mode
            if !isFreemiumMode && hasValidToken {
                await loadGraphData()
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Dependency Graph")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Visualize your application's dependency relationships")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Action Buttons View
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            // Refresh Button
            Button(action: {
                Task {
                    await loadGraphData()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
            
            // Generate Visualization Button
            Button(action: {
                Task {
                    await generateVisualization()
                }
            }) {
                HStack {
                    Image(systemName: "chart.dots.scatter")
                    Text("Generate Mermaid")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
        }
    }
    
    // MARK: - Status View
    
    private var statusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isLoading ? "hourglass" : "checkmark.circle")
                    .foregroundColor(isLoading ? .orange : .green)
                
                Text(isLoading ? "Loading..." : "Ready")
                    .fontWeight(.medium)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - Analysis Summary View
    
    private func analysisSummaryView(_ analysis: GraphAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analysis Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Total Services:")
                    Spacer()
                    Text("\(analysis.totalNodes)")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Total Dependencies:")
                    Spacer()
                    Text("\(analysis.totalDependencies)")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Circular Dependencies:")
                    Spacer()
                    Text("\(analysis.circularDependencyChains.count)")
                        .fontWeight(.medium)
                        .foregroundColor(analysis.circularDependencyChains.isEmpty ? .green : .red)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - Visualization View
    
    private var visualizationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Mermaid Diagram")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(showCopyFeedback ? "Copied!" : "Copy") {
                    copyToClipboard()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(5)
            }
            
            ScrollView {
                Text(visualizationData)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - Dashboard Update View
    private var dashboardUpdateView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📊 Dashboard Sync")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Button(action: {
                Task {
                    await updateDashboard()
                }
            }) {
                HStack {
                    if isUpdatingDashboard {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                    Text(isUpdatingDashboard ? "Updating..." : "Update Dashboard")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isUpdatingDashboard ? Color.gray : Color.blue)
                .cornerRadius(8)
            }
            .disabled(isUpdatingDashboard || graph == nil)
            
            if let message = dashboardUpdateMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(message.hasPrefix("✅") ? .green : .red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func loadGraphData() async {
        isLoading = true
        errorMessage = nil
        
        // Force refresh the container's dependency map first
        await container.preloadDependencies()
        
        // Then get the updated dependency graph
        async let graphTask = container.getDependencyGraph()
        async let analysisTask = container.analyzeDependencyGraph()
        
        let (dependencyGraph, graphAnalysis) = await (graphTask, analysisTask)
        graph = dependencyGraph
        analysis = graphAnalysis
        
        print("✅ Loaded dependency graph with \(dependencyGraph.nodes.count) nodes and \(dependencyGraph.edges.count) edges")
        
        isLoading = false
    }
    
    private func generateVisualization() async {
        isLoading = true
        errorMessage = nil
        
        // Force refresh the container's dependency map first
        await container.preloadDependencies()
        
        let config = VisualizationConfig(
            type: .mermaid,
            format: .mermaid,
            showScopes: true,
            showLifetimes: true,
            showDependencies: true,
            groupByLayer: true,
            colorizeByScope: true,
            interactive: false,
            maxDepth: 10,
            includeCircular: true,
            enableAsyncRendering: true,
            enableProgressTracking: true
        )
        
        do {
            let visualizer: DependencyVisualizer
            if hasValidToken, let token = token {
                visualizer = DependencyVisualizer(container: container, token: token, config: config)
            } else {
                visualizer = DependencyVisualizer(container: container, config: config)
            }
            visualizationData = try await visualizer.visualizeAsync(type: .mermaid)
            print("✅ Generated visualization with \(visualizationData.count) characters")
        } catch VisualizationError.tokenRequired {
            errorMessage = "A valid token is required for dependency visualization. Please initialize the container with a token."
        } catch VisualizationError.invalidToken {
            errorMessage = "Invalid token. Please check your token and try again."
        } catch VisualizationError.tokenExpired {
            errorMessage = "Token has expired. Please generate a new token from your dashboard."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func copyToClipboard() {
        // Check if we have data to copy
        guard !visualizationData.isEmpty else {
            print("⚠️ No visualization data to copy")
            return
        }
        
        // Copy to clipboard
        #if os(iOS)
        UIPasteboard.general.string = visualizationData
        print("✅ Copied \(visualizationData.count) characters to clipboard")
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(visualizationData, forType: .string)
        print("✅ Copied \(visualizationData.count) characters to clipboard")
        #endif
        
        // Show feedback
        showCopyFeedback = true
        
        // Reset feedback after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCopyFeedback = false
        }
    }
    
    private func updateDashboard() async {
        guard hasValidToken,
              let token = token,
              let graph = graph,
              let analysis = analysis else {
            dashboardUpdateMessage = "❌ Missing data for dashboard update"
            return
        }
        
        isUpdatingDashboard = true
        dashboardUpdateMessage = nil
        
        do {
            // Get performance metrics
            let metrics = await container.getPerformanceMetrics()
            
            // Create dependency info
            let dependencyInfo = DependencyInfo(
                version: "1.0.0",
                dependencies: createDependencyNodes(from: graph),
                nodes: convertToGraphNodes(graph.nodes),
                edges: convertToGraphEdges(graph.edges),
                analysis: analysis,
                performanceMetrics: metrics
            )
            
            // Update dashboard
            let syncProvider = DefaultDashboardSyncProvider(token: token)
            try await syncProvider.updateDashboard(with: dependencyInfo)
            
            dashboardUpdateMessage = "✅ Dashboard updated successfully!"
            
        } catch {
            dashboardUpdateMessage = "❌ Failed to update dashboard: \(error.localizedDescription)"
        }
        
        isUpdatingDashboard = false
        
        // Clear message after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            dashboardUpdateMessage = nil
        }
    }
    
    private func createDependencyNodes(from graph: DependencyGraph) -> [DashboardDependencyNode] {
        return graph.nodes.map { node in
            let dependencies = graph.edges
                .filter { $0.from == node.id }
                .map { $0.to }
            
            return DashboardDependencyNode(
                id: node.id,
                type: node.type.rawValue,
                scope: node.scope.rawValue,
                lifetime: "application", // Default lifetime since DependencyNode doesn't have lifetime
                dependencies: dependencies,
                isRegistered: true,
                resolutionTime: nil
            )
        }
    }
    
    private func convertToGraphNodes(_ dependencyNodes: [DependencyNode]) -> [GraphNode] {
        return dependencyNodes.map { node in
            GraphNode(
                id: node.id,
                type: node.type.rawValue,
                scope: node.scope,
                lifetime: .application // Default lifetime
            )
        }
    }
    
    private func convertToGraphEdges(_ dependencyEdges: [DependencyEdge]) -> [GraphEdge] {
        return dependencyEdges.map { edge in
            GraphEdge(
                from: edge.from,
                to: edge.to,
                type: .dependency
            )
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
        
        print("🔄 Attempting to upgrade to Premium...")
        
        do {
            try await containerImpl.upgradeToPremium(token: token)
            print("🎉 Premium upgrade successful!")
            print("🔄 Refreshing view to show premium features...")
            
            // Refresh the view to show premium features
            await MainActor.run {
                // The view will automatically refresh due to the computed properties
            }
        } catch DITokenValidationError.invalidTokenFormat {
            print("❌ Upgrade failed: Invalid token format")
            print("   Token must be 64 characters long and contain only hexadecimal characters")
            showUpgradeError(message: "Invalid token format. Token must be 64 characters long and contain only hexadecimal characters.")
        } catch DITokenValidationError.invalidToken {
            print("❌ Upgrade failed: Token is invalid or expired")
            print("   Please check your token and try again")
            showUpgradeError(message: "Token is invalid or expired. Please check your token and try again.")
        } catch DITokenValidationError.validationFailed(let error) {
            print("❌ Upgrade failed: Validation error - \(error.localizedDescription)")
            showUpgradeError(message: "Token validation failed: \(error.localizedDescription)")
        } catch {
            print("❌ Upgrade failed: Unexpected error - \(error)")
            showUpgradeError(message: "Upgrade failed: \(error.localizedDescription)")
        }
    }
    
    private func showUpgradeError(message: String) {
        #if canImport(UIKit)
        let alert = UIAlertController(title: "Upgrade Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
        #elseif canImport(AppKit)
        let alert = NSAlert()
        alert.messageText = "Upgrade Failed"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        #endif
    }
}
