import SwiftUI

/// 订单评价视图
/// 用于用户对已完成的约见订单进行评分和评价，支持以下功能：
/// 1. 星级评分（1-5星）
/// 2. 文字评价
/// 3. 提交评价并更新订单状态
struct OrderRatingView: View {
    /// 要评价的订单ID
    let orderId: String
    /// 当前用户是否为订单创建者
    let isOrderCreator: Bool
    /// 用于关闭当前视图的环境变量
    @Environment(\.dismiss) private var dismiss
    
    /// 评分值（1-5星）
    @State private var rating: Int = 5
    /// 评价内容
    @State private var comment: String = ""
    /// 是否正在提交评价
    @State private var isSubmitting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 评分部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("约见评分")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .onTapGesture {
                                    rating = index
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // 评价内容
                VStack(alignment: .leading, spacing: 12) {
                    Text("评价内容")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $comment)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding()
                
                // 提交按钮
                Button(action: submitRating) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("提交评价")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isSubmitting)
                .padding(.horizontal)
                .padding(.top, 24)
            }
            .padding(.vertical)
        }
        .navigationTitle("评价约见")
    }
    
    /// 提交评价
    /// 将用户的评分和评价内容提交到服务器，并更新订单状态
    /// - 实现步骤：
    /// 1. 设置提交状态为true，显示加载指示器
    /// 2. 将评分和评价内容提交到服务器
    /// 3. 更新订单状态为已评价
    /// 4. 提交成功后关闭评价页面
    /// - Note: 当前使用延迟模拟网络请求，实际实现时需要替换为真实的API调用
    private func submitRating() {
        isSubmitting = true
        
        // TODO: 实现评价提交逻辑
        // 1. 将评分和评价内容提交到服务器
        // 2. 更新订单状态为已评价
        // 3. 关闭评价页面
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            dismiss()
        }
    }
}

#Preview {
    NavigationView {
        OrderRatingView(orderId: "1", isOrderCreator: true)
    }
}