import SwiftUI

struct OrderDiscoveryView: View {
    @State private var selectedGender: Gender = .all
    @State private var selectedAgeRange: AgeRange = .young
    
    enum AgeRange: String, CaseIterable {
        case young = "18-25岁"
        case mature = "26-35岁"
        
        var range: ClosedRange<Int> {
            switch self {
            case .young: return 18...25
            case .mature: return 26...35
            }
        }
        
        static func fromAge(_ age: Int) -> AgeRange {
            if age >= 18 && age <= 25 {
                return .young
            } else {
                return .mature
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 筛选条件栏
                HStack(spacing: 16) {
                    // 性别筛选
                    Menu {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Button(action: { selectedGender = gender }) {
                                HStack {
                                    Text(gender.rawValue)
                                    if selectedGender == gender {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } label: {
                        FilterButton(title: "性别", value: selectedGender.rawValue)
                    }
                    
                    // 年龄筛选
                    Menu {
                        ForEach(AgeRange.allCases, id: \.self) { range in
                            Button(action: { selectedAgeRange = range }) {
                                HStack {
                                    Text(range.rawValue)
                                    if selectedAgeRange == range {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } label: {
                        FilterButton(title: "年龄", value: selectedAgeRange.rawValue)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 5)
                
                // 订单列表
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<10) { _ in
                            OrderCard(description: "")
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("发现可参与的约见")
        }
    }
}

// 筛选按钮组件
struct FilterButton: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundColor(.gray)
            Text(value)
                .foregroundColor(.primary)
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// 订单卡片组件
struct OrderCard: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 订单头部信息
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("用户昵称")
                            .font(.headline)
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("男")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                    Text("朝阳区1km内")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("剩余名额：1人")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // 订单内容
            VStack(alignment: .leading, spacing: 12) {
                // 活动类型标签
                HStack {
                    Label("吃饭", systemImage: "fork.knife")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("15分钟前发布")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // 补充说明
                if !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                
                // 时间信息
                Label(
                    "今天 12:30",
                    systemImage: "clock"
                )
                .font(.subheadline)
                .foregroundColor(.primary)
            }
            
            // 接单按钮
            Button(action: {
                // TODO: 实现接单逻辑
            }) {
                Text("立即接单")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

#Preview {
    OrderDiscoveryView()
}