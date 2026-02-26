import SwiftUI

// MARK: - Admin Tab Root

struct AdminTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 0

    private var activeOrderCount: Int {
        viewModel.allOrders.filter {
            $0.status != .delivered && $0.status != .cancelled
        }.count
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            AdminDashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }
                .tag(0)

            AdminOrdersView()
                .tabItem { Label("Orders", systemImage: "list.bullet.rectangle") }
                .badge(activeOrderCount > 0 ? activeOrderCount : 0)
                .tag(1)

            AdminRestaurantsView()
                .tabItem { Label("Restaurants", systemImage: "fork.knife") }
                .tag(2)

            AdminUsersView()
                .tabItem { Label("Users", systemImage: "person.2.fill") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .accentColor(.orange)
    }
}

// MARK: - Dashboard

struct AdminDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel

    private var totalRevenue: Double {
        viewModel.allOrders
            .filter { $0.status == .delivered }
            .reduce(0) { $0 + $1.total }
    }
    private var activeOrders: Int {
        viewModel.allOrders.filter { $0.status != .delivered && $0.status != .cancelled }.count
    }
    private var activeRestaurants: Int {
        viewModel.allRestaurants.filter { $0.isActive }.count
    }
    private var regularUsers: Int {
        viewModel.allUsers.filter { !$0.isAdmin }.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                              spacing: 16) {
                        StatCard(title: "Revenue",      value: "$\(String(format: "%.0f", totalRevenue))",
                                 icon: "dollarsign.circle.fill", color: .green)
                        StatCard(title: "Active Orders", value: "\(activeOrders)",
                                 icon: "clock.fill",            color: .orange)
                        StatCard(title: "Restaurants",  value: "\(activeRestaurants)",
                                 icon: "building.2.fill",       color: .blue)
                        StatCard(title: "Users",        value: "\(regularUsers)",
                                 icon: "person.2.fill",         color: .purple)
                    }
                    .padding(.horizontal)

                    // Recent orders
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Orders")
                            .font(.title3.bold())
                            .padding(.horizontal)

                        ForEach(viewModel.allOrders.prefix(5)) { order in
                            AdminOrderCard(order: order)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Admin Dashboard")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundColor(color)
            Text(value).font(.title.bold())
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6)
    }
}

// MARK: - Admin Orders

struct AdminOrdersView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var filterStatus: OrderStatus? = nil

    private var displayedOrders: [Order] {
        guard let status = filterStatus else { return viewModel.allOrders }
        return viewModel.allOrders.filter { $0.status == status }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryChip(title: "All", isSelected: filterStatus == nil) {
                            filterStatus = nil
                        }
                        ForEach(OrderStatus.allCases.filter { $0 != .cancelled }, id: \.self) { s in
                            CategoryChip(title: s.displayText, isSelected: filterStatus == s) {
                                filterStatus = s
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                Divider()

                List(displayedOrders) { order in
                    AdminOrderCard(order: order)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if order.status != .delivered && order.status != .cancelled {
                                Button {
                                    viewModel.advanceOrderStatus(order)
                                } label: {
                                    Label("Advance", systemImage: "arrow.right.circle.fill")
                                }
                                .tint(.orange)
                            }
                        }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Manage Orders")
        }
    }
}

// MARK: - Admin Order Card

struct AdminOrderCard: View {
    @EnvironmentObject var viewModel: AppViewModel
    let order: Order

    // Always read from the live source so status updates reflect immediately
    private var liveOrder: Order {
        viewModel.allOrders.first(where: { $0.id == order.id }) ?? order
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("#\(String(liveOrder.id.prefix(6)).uppercased())")
                    .font(.caption.bold().monospaced())
                    .foregroundColor(.secondary)
                Spacer()
                StatusBadge(status: liveOrder.status)
            }
            Text(liveOrder.restaurantName).font(.subheadline.bold())
            Text(liveOrder.items.prefix(2)
                    .map { "\($0.quantity)× \($0.menuItem.name)" }
                    .joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            HStack {
                Text("$\(String(format: "%.2f", liveOrder.total))")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Spacer()
                Text(liveOrder.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct StatusBadge: View {
    let status: OrderStatus
    var body: some View {
        Text(status.displayText)
            .font(.caption.bold())
            .foregroundColor(status.statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status.statusColor.opacity(0.15))
            .cornerRadius(8)
    }
}

// MARK: - Admin Restaurants

struct AdminRestaurantsView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationView {
            List(viewModel.allRestaurants) { restaurant in
                HStack(spacing: 12) {
                    Text(restaurant.imageName).font(.title2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(restaurant.name).font(.subheadline.bold())
                        Text("\(restaurant.menuItems.count) items • \(restaurant.cuisine)")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { restaurant.isActive },
                        set: { _ in viewModel.toggleRestaurant(restaurant) }
                    ))
                    .tint(.orange)
                    .labelsHidden()
                }
            }
            .navigationTitle("Restaurants")
        }
    }
}

// MARK: - Admin Users

struct AdminUsersView: View {
    @EnvironmentObject var viewModel: AppViewModel

    private var regularUsers: [User] {
        viewModel.allUsers.filter { !$0.isAdmin }
    }

    var body: some View {
        NavigationView {
            List(regularUsers) { user in
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.name).font(.subheadline.bold())
                        Text(user.email).font(.caption).foregroundColor(.secondary)
                        Text(user.address)
                            .font(.caption).foregroundColor(.secondary).lineLimit(1)
                    }
                }
            }
            .navigationTitle("Users (\(regularUsers.count))")
        }
    }
}
