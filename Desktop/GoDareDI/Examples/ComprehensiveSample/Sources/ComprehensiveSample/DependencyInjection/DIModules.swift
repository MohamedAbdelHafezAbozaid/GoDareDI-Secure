//
//  DIModules.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation
import GoDareDI

// MARK: - Network Module
public struct NetworkModule: DIModule {
    public init() {}
    
    public func configure(container: AdvancedDIContainer) async throws {
        print("🔧 Configuring NetworkModule")
        
        // Register NetworkService as singleton
        await container.register(NetworkService.self, scope: .singleton) { container in
            print("📡 Creating NetworkService")
            return NetworkService()
        }
        
        print("✅ NetworkModule configured")
    }
}

// MARK: - Cache Module
public struct CacheModule: DIModule {
    public init() {}
    
    public func configure(container: AdvancedDIContainer) async throws {
        print("🔧 Configuring CacheModule")
        
        // Register CacheService as singleton
        await container.register(InMemoryCacheService.self, scope: .singleton) { container in
            print("💾 Creating InMemoryCacheService")
            return InMemoryCacheService()
        }
        
        print("✅ CacheModule configured")
    }
}

// MARK: - Repository Module
public struct RepositoryModule: DIModule {
    public init() {}
    
    public func configure(container: AdvancedDIContainer) async throws {
        print("🔧 Configuring RepositoryModule")
        
        // Register UserRepository as scoped
        await container.register(UserRepository.self, scope: .scoped) { container in
            print("🗄️ Creating UserRepository")
            let networkService = try await container.resolve(NetworkService.self)
            let cacheService = try await container.resolve(InMemoryCacheService.self)
            return UserRepository(networkService: networkService, cacheService: cacheService)
        }
        
        print("✅ RepositoryModule configured")
    }
}

// MARK: - Use Case Module
public struct UseCaseModule: DIModule {
    public init() {}
    
    public func configure(container: AdvancedDIContainer) async throws {
        print("🔧 Configuring UseCaseModule")
        
        // Register all use cases as transient
        await container.register(GetAllUsersUseCase.self, scope: .transient) { container in
            print("🎯 Creating GetAllUsersUseCase")
            let repository = try await container.resolve(UserRepository.self)
            return GetAllUsersUseCase(repository: repository)
        }
        
        await container.register(GetUserUseCase.self, scope: .transient) { container in
            print("🎯 Creating GetUserUseCase")
            let repository = try await container.resolve(UserRepository.self)
            return GetUserUseCase(repository: repository)
        }
        
        await container.register(GetUserProfileUseCase.self, scope: .transient) { container in
            print("🎯 Creating GetUserProfileUseCase")
            let repository = try await container.resolve(UserRepository.self)
            return GetUserProfileUseCase(repository: repository)
        }
        
        await container.register(UpdateUserPreferencesUseCase.self, scope: .transient) { container in
            print("🎯 Creating UpdateUserPreferencesUseCase")
            let repository = try await container.resolve(UserRepository.self)
            return UpdateUserPreferencesUseCase(repository: repository)
        }
        
        await container.register(GetUserStatisticsUseCase.self, scope: .transient) { container in
            print("🎯 Creating GetUserStatisticsUseCase")
            let repository = try await container.resolve(UserRepository.self)
            return GetUserStatisticsUseCase(repository: repository)
        }
        
        await container.register(UploadAvatarUseCase.self, scope: .transient) { container in
            print("🎯 Creating UploadAvatarUseCase")
            let repository = try await container.resolve(UserRepository.self)
            return UploadAvatarUseCase(repository: repository)
        }
        
        print("✅ UseCaseModule configured")
    }
}

// MARK: - View Model Module
public struct ViewModelModule: DIModule {
    public init() {}
    
    public func configure(container: AdvancedDIContainer) async throws {
        print("🔧 Configuring ViewModelModule")
        
        // Register UserViewModel as lazy (created when needed)
        await container.register(UserViewModel.self, scope: .lazy) { container in
            print("📱 Creating UserViewModel")
            let getAllUsersUseCase = try await container.resolve(GetAllUsersUseCase.self)
            let getUserUseCase = try await container.resolve(GetUserUseCase.self)
            let getUserProfileUseCase = try await container.resolve(GetUserProfileUseCase.self)
            let updateUserPreferencesUseCase = try await container.resolve(UpdateUserPreferencesUseCase.self)
            let getUserStatisticsUseCase = try await container.resolve(GetUserStatisticsUseCase.self)
            let uploadAvatarUseCase = try await container.resolve(UploadAvatarUseCase.self)
            
            return await UserViewModel(
                getAllUsersUseCase: getAllUsersUseCase,
                getUserUseCase: getUserUseCase,
                getUserProfileUseCase: getUserProfileUseCase,
                updateUserPreferencesUseCase: updateUserPreferencesUseCase,
                getUserStatisticsUseCase: getUserStatisticsUseCase,
                uploadAvatarUseCase: uploadAvatarUseCase
            )
        }
        
        print("✅ ViewModelModule configured")
    }
}

// MARK: - Application Module
public struct ApplicationModule: DIModule {
    public init() {}
    
    public func configure(container: AdvancedDIContainer) async throws {
        print("🔧 Configuring ApplicationModule")
        
        // Register all modules in dependency order
        let modules: [DIModule] = [
            NetworkModule(),
            CacheModule(),
            RepositoryModule(),
            UseCaseModule(),
            ViewModelModule()
        ]
        
        for module in modules {
            try await module.configure(container: container)
        }
        
        print("✅ ApplicationModule configured")
    }
}
