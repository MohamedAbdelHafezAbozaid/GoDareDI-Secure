//
//  UserViewModel.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - User View Model
@MainActor
public final class UserViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var users: [User] = []
    @Published public var selectedUser: User?
    @Published public var userProfile: UserProfile?
    @Published public var userStatistics: UserStatistics?
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var uploadProgress: Double = 0.0
    
    // MARK: - Private Properties
    private let getAllUsersUseCase: GetAllUsersUseCaseProtocol
    private let getUserUseCase: GetUserUseCaseProtocol
    private let getUserProfileUseCase: GetUserProfileUseCaseProtocol
    private let updateUserPreferencesUseCase: UpdateUserPreferencesUseCaseProtocol
    private let getUserStatisticsUseCase: GetUserStatisticsUseCaseProtocol
    private let uploadAvatarUseCase: UploadAvatarUseCaseProtocol
    
    // MARK: - Initialization
    public init(
        getAllUsersUseCase: GetAllUsersUseCaseProtocol,
        getUserUseCase: GetUserUseCaseProtocol,
        getUserProfileUseCase: GetUserProfileUseCaseProtocol,
        updateUserPreferencesUseCase: UpdateUserPreferencesUseCaseProtocol,
        getUserStatisticsUseCase: GetUserStatisticsUseCaseProtocol,
        uploadAvatarUseCase: UploadAvatarUseCaseProtocol
    ) {
        self.getAllUsersUseCase = getAllUsersUseCase
        self.getUserUseCase = getUserUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateUserPreferencesUseCase = updateUserPreferencesUseCase
        self.getUserStatisticsUseCase = getUserStatisticsUseCase
        self.uploadAvatarUseCase = uploadAvatarUseCase
    }
    
    // MARK: - Public Methods
    public func loadAllUsers() async {
        await performAsyncOperation {
            self.users = try await self.getAllUsersUseCase.execute()
        }
    }
    
    public func loadUser(id: String) async {
        await performAsyncOperation {
            self.selectedUser = try await self.getUserUseCase.execute(id: id)
        }
    }
    
    public func loadUserProfile(id: String) async {
        await performAsyncOperation {
            self.userProfile = try await self.getUserProfileUseCase.execute(id: id)
        }
    }
    
    public func updatePreferences(_ preferences: UserPreferences) async {
        await performAsyncOperation {
            let updatedPreferences = try await self.updateUserPreferencesUseCase.execute(preferences)
            // Update the current profile if it exists
            if var profile = self.userProfile {
                let updatedProfile = UserProfile(
                    user: profile.user,
                    preferences: updatedPreferences,
                    statistics: profile.statistics
                )
                self.userProfile = updatedProfile
            }
        }
    }
    
    public func loadUserStatistics(id: String) async {
        await performAsyncOperation {
            self.userStatistics = try await self.getUserStatisticsUseCase.execute(id: id)
        }
    }
    
    public func uploadAvatar(data: Data) async {
        await performAsyncOperation {
            let avatarURL = try await self.uploadAvatarUseCase.execute(data: data)
            // Update the selected user with the new avatar URL
            if let user = self.selectedUser {
                let updatedUser = User(
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    avatar: avatarURL,
                    createdAt: user.createdAt,
                    updatedAt: Date()
                )
                self.selectedUser = updatedUser
            }
        }
    }
    
    public func clearError() {
        errorMessage = nil
    }
    
    public func refreshData() async {
        if let userId = selectedUser?.id {
            await loadUser(id: userId)
            await loadUserProfile(id: userId)
            await loadUserStatistics(id: userId)
        } else {
            await loadAllUsers()
        }
    }
    
    // MARK: - Private Methods
    private func performAsyncOperation(_ operation: @escaping () async throws -> Void) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                try await operation()
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Error in UserViewModel: \(error)")
            }
            
            isLoading = false
        }
    }
}

// MARK: - Computed Properties
extension UserViewModel {
    public var hasUsers: Bool {
        return !users.isEmpty
    }
    
    public var hasSelectedUser: Bool {
        return selectedUser != nil
    }
    
    public var hasUserProfile: Bool {
        return userProfile != nil
    }
    
    public var hasUserStatistics: Bool {
        return userStatistics != nil
    }
    
    public var isUploading: Bool {
        return uploadProgress > 0.0 && uploadProgress < 1.0
    }
}
