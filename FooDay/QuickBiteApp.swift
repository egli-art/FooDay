import SwiftUI
import Firebase

@main
struct QuickBiteApp: App {
    @StateObject private var viewModel = AppViewModel()

    init() {
        FirebaseManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Root

struct RootView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        Group {
            if viewModel.isLoggedIn {
                if viewModel.currentUser?.isAdmin == true {
                    AdminTabView()
                } else {
                    MainTabView()
                }
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isLoggedIn)
    }
}

// MARK: - Main Tab Bar

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {

            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

//            SearchView()
//                .tabItem { Label("Search", systemImage: "magnifyingglass") }
//                .tag(1)

            CartView()
                .tabItem {
                    Label("Cart",
                          systemImage: viewModel.cartItemCount > 0 ? "cart.fill" : "cart")
                }
                .badge(viewModel.cartItemCount > 0 ? viewModel.cartItemCount : 0)
                .tag(2)

            OrdersView()
                .tabItem { Label("Orders", systemImage: "clock.arrow.circlepath") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .accentColor(.orange)
        // Cart-conflict alert lives here so it's always reachable
        .alert("Start New Cart?", isPresented: $viewModel.showingCartConflictAlert) {
            Button("Cancel", role: .cancel) { viewModel.pendingCartItem = nil }
            Button("Start New", role: .destructive) { viewModel.clearCartAndAdd() }
        } message: {
            Text("Your cart has items from \(viewModel.cartRestaurantName). Starting a new cart will remove them.")
        }
    }
}
