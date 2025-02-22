import Foundation

enum Gender: String, CaseIterable {
    case all = "不限"
    case male = "男"
    case female = "女"
    
    static func fromUserGender(_ userGender: Gender?) -> Gender {
        return userGender ?? .all
    }
}