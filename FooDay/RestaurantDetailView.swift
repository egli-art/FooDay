import SwiftUI

struct RestaurantDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let restaurant: Restaurant
    @State private var selectedCategory = "All"

    private var availableItems: [MenuItem] {
        restaurant.menuItems.filter { $0.isAvailable }
    }

    private var menuCategories: [String] {
        var cats = ["All"]
        let unique = Array(Set(availableItems.map { $0.category })).sorted()
        cats.append(contentsOf: unique)
        return cats
    }

    private var visibleItems: [MenuItem] {
        selectedCategory == "All"
            ? availableItems
            : availableItems.filter { $0.category == selectedCategory }
    }

    private var groupedItems: [String: [MenuItem]] {
        Dictionary(grouping: visibleItems, by: { $0.category })
    }

    private var sortedSectionKeys: [String] {
        selectedCategory == "All"
            ? Array(groupedItems.keys).sorted()
            : [selectedCategory]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Hero
                ZStack(alignment: .bottomLeading) {
                    Color.orange.opacity(0.12)
                    Text(restaurant.imageName)
                        .font(.system(size: 90))
                        .frame(maxWidth: .infinity)
                    LinearGradient(colors: [.clear, Color.black.opacity(0.5)],
                                   startPoint: .top, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name)
                            .font(.title.bold())
                            .foregroundColor(.white)
                        HStack {
                            Label(String(format: "%.1f", restaurant.rating),
                                  systemImage: "star.fill")
                                .font(.subheadline).foregroundColor(.yellow)
                            Text("•").foregroundColor(.white.opacity(0.7))
                            Text(restaurant.deliveryTime)
                                .font(.subheadline).foregroundColor(.white)
                            if restaurant.deliveryFee == 0 {
                                Text("• Free delivery")
                                    .font(.subheadline).foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                }
                .frame(height: 200)

                // MARK: Popular
                let popularItems = availableItems.filter { $0.isPopular }
                if selectedCategory == "All", !popularItems.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("⭐ Popular")
                            .font(.title3.bold())
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(popularItems) { item in
                                    PopularItemCard(item: item) {
                                        viewModel.addToCart(item, restaurant: restaurant)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                }

                // MARK: Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(menuCategories, id: \.self) { cat in
                            CategoryChip(title: cat, isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)

                // MARK: Menu sections
                ForEach(sortedSectionKeys, id: \.self) { category in
                    if let items = groupedItems[category] {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(category)
                                .font(.title3.bold())
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .padding(.bottom, 4)

                            ForEach(items) { item in
                                MenuItemRow(item: item) {
                                    viewModel.addToCart(item, restaurant: restaurant)
                                }
                                Divider().padding(.leading, 80)
                            }
                        }
                    }
                }

                Spacer(minLength: 100)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if viewModel.cartItemCount > 0,
               viewModel.cartRestaurantName == restaurant.name {
                CartStickyBar()
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Popular Item Card

struct PopularItemCard: View {
    let item: MenuItem
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Color.orange.opacity(0.10)
                Text(item.imageName).font(.system(size: 38))
            }
            .frame(width: 120, height: 80)
            .cornerRadius(10)

            Text(item.name)
                .font(.caption.bold())
                .lineLimit(1)

            HStack {
                Text("$\(String(format: "%.2f", item.price))")
                    .font(.caption)
                    .foregroundColor(.orange)
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(width: 120)
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.07), radius: 6)
    }
}

// MARK: - Menu Item Row

struct MenuItemRow: View {
    let item: MenuItem
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Color.orange.opacity(0.10)
                Text(item.imageName).font(.system(size: 28))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name).font(.subheadline.bold())
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text("$\(String(format: "%.2f", item.price))")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Cart sticky bar (bottom of restaurant detail)

struct CartStickyBar: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showCart = false

    var body: some View {
        Button {
            showCart = true
        } label: {
            HStack {
                Text("\(viewModel.cartItemCount) item\(viewModel.cartItemCount == 1 ? "" : "s")")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Spacer()
                Text("View Cart")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text("$\(String(format: "%.2f", viewModel.cartTotal))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.leading, 4)
            }
            .padding()
            .background(Color.orange)
            .cornerRadius(16)
            .shadow(color: Color.orange.opacity(0.4), radius: 10)
        }
        .sheet(isPresented: $showCart) {
            CartView()
        }
    }
}
