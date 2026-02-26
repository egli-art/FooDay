import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedCategory = "All"

    private let categories = ["All", "🍔 Burgers", "🍕 Pizza", "🍣 Sushi", "🌮 Mexican", "🥗 Healthy"]

    private var filteredForCategory: [Restaurant] {
        guard selectedCategory != "All" else { return viewModel.filteredRestaurants }
        let keyword = selectedCategory.components(separatedBy: " ").last ?? ""
        return viewModel.filteredRestaurants.filter {
            $0.cuisine.localizedCaseInsensitiveContains(keyword)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good \(timeOfDay)! 👋")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(viewModel.currentUser?.name
                                    .components(separatedBy: " ").first ?? "Friend")
                                .font(.title.bold())
                        }
                        Spacer()
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)

                    // MARK: Active order banner
                    if let active = viewModel.currentOrders().first {
                        NavigationLink(destination: OrderTrackingView(order: active)) {
                            ActiveOrderBanner(order: active)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }

                    // MARK: Category chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { cat in
                                CategoryChip(title: cat,
                                             isSelected: selectedCategory == cat) {
                                    selectedCategory = cat
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: Featured row
                    if selectedCategory == "All" {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Featured")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(viewModel.filteredRestaurants.prefix(3)) { r in
                                        NavigationLink(destination: RestaurantDetailView(restaurant: r)) {
                                            FeaturedCard(restaurant: r)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // MARK: All restaurants
                    VStack(alignment: .leading, spacing: 10) {
                        Text(selectedCategory == "All" ? "All Restaurants" : "Results")
                            .font(.title2.bold())
                            .padding(.horizontal)

                        ForEach(filteredForCategory) { restaurant in
                            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                RestaurantCard(restaurant: restaurant)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(.top)
            }
            .navigationTitle("QuickBite 🍽️")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var timeOfDay: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "morning" }
        if h < 17 { return "afternoon" }
        return "evening"
    }
}

// MARK: - Shared subviews (also used in other files)

struct ActiveOrderBanner: View {
    let order: Order
    var body: some View {
        HStack {
            Image(systemName: order.status.systemIcon)
                .font(.title2)
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Active Order")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text("\(order.status.displayText) • \(order.restaurantName)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
        }
        .padding()
        .background(
            LinearGradient(colors: [.orange, Color.red.opacity(0.8)],
                           startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(16)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct FeaturedCard: View {
    let restaurant: Restaurant
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Color.orange.opacity(0.12)
                Text(restaurant.imageName).font(.system(size: 56))
            }
            .frame(width: 200, height: 120)
            .cornerRadius(14)

            VStack(alignment: .leading, spacing: 2) {
                Text(restaurant.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                HStack {
                    Image(systemName: "star.fill").font(.caption2).foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating)).font(.caption).foregroundColor(.secondary)
                    Text("•").foregroundColor(.secondary)
                    Text(restaurant.deliveryTime).font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 200)
    }
}

struct RestaurantCard: View {
    let restaurant: Restaurant
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Color.orange.opacity(0.10)
                Text(restaurant.imageName).font(.system(size: 34))
            }
            .frame(width: 78, height: 78)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(restaurant.cuisine)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 6) {
                    Label(String(format: "%.1f", restaurant.rating), systemImage: "star.fill")
                        .font(.caption).foregroundColor(.yellow)
                    Text("•").foregroundColor(.secondary)
                    Text(restaurant.deliveryTime).font(.caption).foregroundColor(.secondary)
                    Text("•").foregroundColor(.secondary)
                    Text(restaurant.deliveryFee == 0
                         ? "Free delivery"
                         : "$\(String(format: "%.2f", restaurant.deliveryFee)) fee")
                        .font(.caption)
                        .foregroundColor(restaurant.deliveryFee == 0 ? .green : .secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}
