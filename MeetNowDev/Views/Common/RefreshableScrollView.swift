import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () async -> Void
    let content: () -> Content
    
    init(
        isRefreshing: Binding<Bool>,
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isRefreshing = isRefreshing
        self.onRefresh = onRefresh
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            content()
        }
        .refreshable {
            isRefreshing = true
            await onRefresh()
            isRefreshing = false
        }
    }
}