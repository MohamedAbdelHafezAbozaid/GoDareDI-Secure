//
//  SampleApp.swift
//  SampleApp
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI
import GoDareDI

// MARK: - Sample Services

protocol NetworkServiceProtocol {
    func fetchData() async throws -> String
}

protocol UserRepositoryProtocol {
    func getUser(id: String) async throws -> User
}

protocol GetUserUseCaseProtocol {
    func getUser(id: String) async throws -> User
}

// MARK: - Implementations

class NetworkService: NetworkServiceProtocol {
    func fetchData() async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        return "User data from network"
    }
}

class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getUser(id: String) async throws -> User {
        let data = try await networkService.fetchData()
        return User(id: id, name: "User \(id)", data: data)
    }
}

class GetUserUseCase: GetUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func getUser(id: String) async throws -> User {
        return try await repository.getUser(id: id)
    }
}

// MARK: - Models

struct User {
    let id: String
    let name: String
    let data: String
}

// MARK: - Dependency Registration

class DependencyRegistration {
    static func registerDependencies(in container: AdvancedDIContainer) async throws {
        print("🔧 Registering dependencies...")
        
        // Infrastructure layer (Singleton)
        await container.register(NetworkService.self, scope: .singleton) { container in
            print("📡 Creating NetworkService")
            return NetworkService()
        }
        
        // Repository layer (Transient)
        await container.register(UserRepository.self, scope: .transient) { container in
            print("🗄️ Creating UserRepository")
            let networkService = try await container.resolve(NetworkService.self)
            return UserRepository(networkService: networkService)
        }
        
        // Use case layer (Scoped)
        await container.register(GetUserUseCase.self, scope: .scoped, lifetime: .request) { container in
            print("🎯 Creating GetUserUseCase")
            let repository = try await container.resolve(UserRepository.self)
            return GetUserUseCase(repository: repository)
        }
        
        print("✅ All dependencies registered successfully")
    }
}

// MARK: - View Model

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let container: AdvancedDIContainer
    
    init(container: AdvancedDIContainer) {
        self.container = container
    }
    
    func loadUser(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let useCase = try await container.resolve(GetUserUseCase.self)
            let user = try await useCase.getUser(id: id)
            
            self.user = user
            print("✅ User loaded: \(user.name)")
            
        } catch {
            errorMessage = "Failed to load user: \(error.localizedDescription)"
            print("❌ Error loading user: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Sample App (Disabled - Remove @main to prevent interference)

// @main
struct SampleApp: App {
    @State private var container: AdvancedDIContainer?
    @State private var isInitialized = false
    
    var body: some Scene {
        WindowGroup {
            if isInitialized, let container = container {
                ContentView(container: container)
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
            // Create the container first
            container = AdvancedDIContainerImpl()
            
            // Then register dependencies
            try await DependencyRegistration.registerDependencies(in: container!)
            isInitialized = true
        } catch {
            print("❌ Failed to initialize app: \(error)")
        }
    }
}

// MARK: - Views

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Initializing dependencies...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ContentView: View {
    let container: AdvancedDIContainer
    @StateObject private var viewModel: UserViewModel
    @State private var showingDependencyGraph = false
    
    init(container: AdvancedDIContainer) {
        self.container = container
        self._viewModel = StateObject(wrappedValue: UserViewModel(container: container))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("GoDareDI Sample App")
                    .font(.title)
                    .fontWeight(.bold)
                
                if viewModel.isLoading {
                    ProgressView("Loading user...")
                } else if let user = viewModel.user {
                    UserCard(user: user)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorCard(message: errorMessage)
                } else {
                    Text("Tap the button to load a user")
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    Button("Load User") {
                        Task {
                            await viewModel.loadUser(id: "123")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                    
                    Button("Show Dependency Graph") {
                        showingDependencyGraph = true
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sample App")
        }
        .sheet(isPresented: $showingDependencyGraph) {
            SimpleDependencyGraphView(container: container)
        }
    }
}

struct UserCard: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User Information")
                .font(.headline)
            
            HStack {
                Text("ID:")
                Spacer()
                Text(user.id)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Name:")
                Spacer()
                Text(user.name)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Data:")
                Spacer()
                Text(user.data)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct ErrorCard: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}
