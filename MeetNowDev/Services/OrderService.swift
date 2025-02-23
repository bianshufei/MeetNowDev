import Foundation

/// 订单服务类
/// 负责处理订单相关的业务逻辑，包括：
/// 1. 订单状态管理
/// 2. 订单数据同步
/// 3. 订单操作验证
class OrderService: ObservableObject {
    /// 单例实例
    static let shared = OrderService()
    
    /// 订单列表
    @Published private(set) var orders: [Order] = []
    
    /// 订单状态变更通知
    let orderStatusDidChange = NotificationCenter.default.publisher(for: .orderStatusDidChange)
    
    private init() {
        // 初始化时加载模拟数据
        orders = Order.mockOrders
        
        // 监听订单状态变更通知
        setupNotifications()
    }
    
    /// 设置通知监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrderStatusChange(_:)),
            name: .orderStatusDidChange,
            object: nil
        )
    }
    
    /// 处理订单状态变更通知
    @objc private func handleOrderStatusChange(_ notification: Notification) {
        guard let orderInfo = notification.userInfo?["orderInfo"] as? [String: Any],
              let orderId = orderInfo["orderId"] as? String,
              let newStatus = orderInfo["newStatus"] as? OrderStatus else {
            return
        }
        
        updateOrderStatus(orderId: orderId, newStatus: newStatus)
    }
    
    /// 更新订单状态
    /// - Parameters:
    ///   - orderId: 订单ID
    ///   - newStatus: 新状态
    ///   - completion: 完成回调
    func updateOrderStatus(
        orderId: String,
        newStatus: OrderStatus,
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {
        // TODO: 实现与服务器的状态同步
        // 这里先使用本地更新模拟
        
        if let index = orders.firstIndex(where: { $0.id == orderId }) {
            // 验证状态转换是否合法
            guard isValidStatusTransition(from: orders[index].status, to: newStatus) else {
                completion?(.failure(OrderError.invalidStatusTransition))
                return
            }
            
            // 更新状态
            orders[index].status = newStatus
            
            // 发送状态更新通知
            NotificationCenter.default.post(
                name: .orderStatusDidChange,
                object: self,
                userInfo: [
                    "orderId": orderId,
                    "newStatus": newStatus
                ]
            )
            
            completion?(.success(()))
        } else {
            completion?(.failure(OrderError.orderNotFound))
        }
    }
    
    /// 更新订单列表
    /// - Parameter newOrders: 新的订单列表
    func updateOrders(_ newOrders: [Order]) {
        orders = newOrders
    }
    
    /// 接单
    /// - Parameters:
    ///   - orderId: 订单ID
    ///   - takerName: 接单人姓名
    ///   - completion: 完成回调
    func takeOrder(
        orderId: String,
        takerName: String,
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else {
            completion?(.failure(OrderError.orderNotFound))
            return
        }
        
        // 验证订单是否可接单
        guard orders[index].status == .pending else {
            completion?(.failure(OrderError.invalidStatusTransition))
            return
        }
        
        // 更新接单人信息和状态
        orders[index].takerName = takerName
        updateOrderStatus(orderId: orderId, newStatus: .inProgress, completion: completion)
    }
    
    /// 验证状态转换是否合法
    /// - Parameters:
    ///   - from: 当前状态
    ///   - to: 目标状态
    /// - Returns: 是否为合法的状态转换
    private func isValidStatusTransition(from: OrderStatus, to: OrderStatus) -> Bool {
        switch (from, to) {
        case (.pending, .inProgress),             // 待接单 -> 进行中
             (.pending, .cancelled),              // 待接单 -> 已取消
             (.inProgress, .completed),           // 进行中 -> 已完成
             (.inProgress, .cancelled):           // 进行中 -> 已取消
            return true
        default:
            return false
        }
    }
    
    /// 获取指定ID的订单
    /// - Parameter id: 订单ID
    /// - Returns: 订单对象（如果存在）
    func getOrder(by id: String) -> Order? {
        return orders.first { $0.id == id }
    }
    
    /// 获取用户相关的订单列表
    /// - Parameters:
    ///   - isOrderCreator: 是否为订单创建者
    ///   - status: 订单状态过滤（可选）
    /// - Returns: 过滤后的订单列表
    func getOrders(isOrderCreator: Bool, status: OrderStatus? = nil) -> [Order] {
        var filteredOrders = orders
        
        // 根据用户身份筛选订单
        filteredOrders = filteredOrders.filter { order in
            if isOrderCreator {
                return order.creatorName == UserProfile.mock.nickname
            } else {
                return order.takerName == UserProfile.mock.nickname || order.status == .pending
            }
        }
        
        if let status = status, status != .all {
            filteredOrders = filteredOrders.filter { $0.status == status }
        }
        
        return filteredOrders
    }
}

/// 订单相关错误
enum OrderError: LocalizedError {
    case orderNotFound
    case invalidStatusTransition
    
    var errorDescription: String? {
        switch self {
        case .orderNotFound:
            return "订单不存在"
        case .invalidStatusTransition:
            return "非法的状态转换"
        }
    }
}

/// 通知名称扩展
extension Notification.Name {
    /// 订单状态变更通知
    static let orderStatusDidChange = Notification.Name("orderStatusDidChange")
}