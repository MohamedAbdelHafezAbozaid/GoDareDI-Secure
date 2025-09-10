//
//  UserListView.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI
import GoDareDI

// MARK: - User List View
public struct UserListView: View {
    @StateObject private var viewModel: UserViewModel
    @State private var showingDependencyGraph = false
    
    public init(container: AdvancedDIContainer) {
        // This will be resolved when the view appears
        self._viewModel = StateObject(wrappedValue: UserViewModel(
            getAllUsersUseCase: GetAllUsersUseCase(repository: UserRepository(networkService: NetworkService(), cacheService: InMemoryCacheService())),
            getUserUseCase: GetUserUseCase(repository: UserRepository(networkService: NetworkService(), cacheService: InMemoryCacheService())),
            getUserProfileUseCase: GetUserProfileUseCase(repository: UserRepository(networkService: NetworkService(), cacheService: InMemoryCacheService())),
            updateUserPreferencesUseCase: UpdateUserPreferencesUseCase(repository: UserRepository(networkService: NetworkService(), cacheService: InMemoryCacheService())),
            getUserStatisticsUseCase: GetUserStatisticsUseCase(repository: UserRepository(networkService: NetworkService(), cacheService: InMemoryCacheService())),
            uploadAvatarUseCase: UploadAvatarUseCase(repository: UserRepository(networkService: NetworkService(), cacheService: InMemoryCacheService()))
        ))
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else if viewModel.hasUsers {
                    userListView
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Users")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dependency Graph") {
                        showingDependencyGraph = true
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Dependency Graph") {
                        showingDependencyGraph = true
                    }
                }
                #endif
            }
        }
        .sheet(isPresented: $showingDependencyGraph) {
            // DependencyGraphView(container: container)
            Text("Dependency Graph View")
                .padding()
        }
        .task {
            await viewModel.loadAllUsers()
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("User Management")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Comprehensive GoDareDI Sample")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading users...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await viewModel.loadAllUsers()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Users Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Pull to refresh or check your connection")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - User List View
    private var userListView: some View {
        List(viewModel.users) { user in
            UserRowView(user: user) {
                Task {
                    await viewModel.loadUser(id: user.id)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - User Row View
struct UserRowView: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                AsyncImage(url: URL(string: user.avatar ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("ID: \(user.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#if DEBUG
//struct UserListView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserListView(container: AdvancedDIContainerImpl())
//    }
//}
#endif
