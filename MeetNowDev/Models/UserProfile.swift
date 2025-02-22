import Foundation

import SwiftUI

class UserProfile: ObservableObject {
    @Published var nickname: String
    @Published var phoneNumber: String
    @Published var gender: Gender
    @Published var age: Int
    @Published var avatarUrl: String?
    @Published var role: RoleSelectionView.UserRole
    
    init(nickname: String = "", phoneNumber: String = "", gender: Gender = .male, age: Int = 18, avatarUrl: String? = nil, role: RoleSelectionView.UserRole = .poster) {
        self.nickname = nickname
        self.phoneNumber = phoneNumber
        self.gender = gender
        self.age = age
        self.avatarUrl = avatarUrl
        self.role = role
    }
    
    static var mock: UserProfile {
        let profile =
        UserProfile()
        profile.nickname = "测试用户"
        profile.phoneNumber = "17712341234"
        profile.gender = .male
        profile.age = 25
        profile.avatarUrl = nil
        profile.role = .poster
        return profile
    }
}