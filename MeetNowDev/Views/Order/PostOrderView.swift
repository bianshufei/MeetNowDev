import SwiftUI

struct PostOrderView: View {
    @State private var selectedOrderType: OrderType = .instant
    @State private var selectedActivityType: ActivityType = .dining
    @State private var selectedDateTime = Date()
    @State private var location = ""
    @State private var description = ""
    
    enum OrderType {
        case instant   // 即时约见
        case scheduled // 预约约见
    }
    
    enum ActivityType: String, CaseIterable {
        case dining = "吃饭"
        case sports = "运动"
        case exhibition = "看展"
        case drinking = "喝酒"
        case study = "学习"
        case companion = "陪伴"
        
        var icon: String {
            switch self {
            case .dining: return "fork.knife"
            case .sports: return "figure.run"
            case .exhibition: return "photo.artframe"
            case .drinking: return "wineglass"
            case .study: return "book"
            case .companion: return "person.2"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    OrderTypeSection(
                        selectedOrderType: $selectedOrderType
                    )
                    
                    ActivityTypeSection(
                        selectedActivityType: $selectedActivityType
                    )
                    
                    DescriptionSection(
                        description: $description
                    )
                    
                    TimeSection(
                        selectedDateTime: $selectedDateTime,
                        orderType: selectedOrderType
                    )
                    
                    LocationSection(
                        location: $location
                    )
                    
                    PublishButton()
                }
                .padding(.vertical)
            }
            .navigationTitle("发布约见")
        }
    }
}

// 订单类型选择区域
struct OrderTypeSection: View {
    @Binding var selectedOrderType: PostOrderView.OrderType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("约见类型")
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                OrderTypeButton(
                    title: "即时约见",
                    icon: "clock.fill",
                    isSelected: selectedOrderType == .instant,
                    action: { selectedOrderType = .instant }
                )
                
                OrderTypeButton(
                    title: "预约约见",
                    icon: "calendar",
                    isSelected: selectedOrderType == .scheduled,
                    action: { selectedOrderType = .scheduled }
                )
            }
        }
        .padding(.horizontal)
    }
}

// 活动类型选择区域
struct ActivityTypeSection: View {
    @Binding var selectedActivityType: PostOrderView.ActivityType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("活动类型")
                .font(.headline)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(PostOrderView.ActivityType.allCases, id: \.self) { type in
                    ActivityTypeButton(
                        type: type,
                        isSelected: selectedActivityType == type,
                        action: { selectedActivityType = type }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

// 补充说明区域
struct DescriptionSection: View {
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("补充说明")
                .font(.headline)
                .foregroundColor(.gray)
            
            TextEditor(text: $description)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
}

// 时间选择区域
struct TimeSection: View {
    @Binding var selectedDateTime: Date
    let orderType: PostOrderView.OrderType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("约见时间")
                .font(.headline)
                .foregroundColor(.gray)
            
            Group {
                if orderType == .instant {
                    DatePicker(
                        "",
                        selection: $selectedDateTime,
                        in: Date()...,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                } else {
                    DatePicker(
                        "",
                        selection: $selectedDateTime,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .environment(\.locale, .init(identifier: "zh_CN"))
                }
            }
        }
        .padding(.horizontal)
    }
}

// 地点输入区域
struct LocationSection: View {
    @Binding var location: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("约见地点")
                .font(.headline)
                .foregroundColor(.gray)
            
            TextField("请输入约见地点", text: $location)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.orange)
                            .padding(.trailing, 8)
                    }
                )
        }
        .padding(.horizontal)
    }
}

// 发布按钮
struct PublishButton: View {
    var body: some View {
        Button(action: {
            // TODO: 实现发布逻辑
        }) {
            Text("发布约见")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .orange.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }
}

// 订单类型按钮组件
struct OrderTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(isSelected ? .orange : .gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1)
            )
        }
    }
}

// 活动类型按钮组件
struct ActivityTypeButton: View {
    let type: PostOrderView.ActivityType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                Text(type.rawValue)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(isSelected ? .orange : .gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1)
            )
        }
    }
}

#Preview {
    PostOrderView()
}