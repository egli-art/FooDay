import SwiftUI

// MARK: - Cart Tab Root

struct CartView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showCheckout = false
    // Allow CartView to be dismissed when pushed as a sheet from CartStickyBar
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Group {
                if viewModel.cart.isEmpty {
                    EmptyCartView()
                } else {
                    CartContentView(showCheckout: $showCheckout)
                }
            }
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCheckout) {
            CheckoutView()
        }
    }
}

// MARK: - Empty

struct EmptyCartView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack(spacing: 20) {
            Text("🛒").font(.system(size: 80))
            Text("Your cart is empty")
                .font(.title2.bold())
            Text("Add items from a restaurant to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Browse Restaurants") {
                viewModel.selectedTab = 0
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding(32)
    }
}

// MARK: - Cart Content

struct CartContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var showCheckout: Bool

    private var deliveryFee: Double {
        viewModel.restaurants
            .first(where: { $0.name == viewModel.cartRestaurantName })?
            .deliveryFee ?? 2.99
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header:
                    Text(viewModel.cartRestaurantName)
                        .font(.headline)
                        .textCase(nil)
                ) {
                    ForEach(viewModel.cart) { item in
                        CartItemRow(item: item)
                    }
                    .onDelete { offsets in
                        offsets.forEach { viewModel.removeFromCart(viewModel.cart[$0]) }
                    }
                }

                Section("Order Summary") {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("$\(String(format: "%.2f", viewModel.cartTotal))")
                    }
                    HStack {
                        Text("Delivery Fee")
                        Spacer()
                        Text(deliveryFee == 0
                             ? "FREE"
                             : "$\(String(format: "%.2f", deliveryFee))")
                            .foregroundColor(deliveryFee == 0 ? .green : .primary)
                    }
                    HStack {
                        Text("Total").bold()
                        Spacer()
                        Text("$\(String(format: "%.2f", viewModel.cartTotal + deliveryFee))")
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
            }
            .listStyle(.insetGrouped)

            // Checkout CTA
            Button {
                showCheckout = true
            } label: {
                Text("Proceed to Checkout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(14)
            }
            .padding()
        }
    }
}

// MARK: - Cart Item Row

struct CartItemRow: View {
    @EnvironmentObject var viewModel: AppViewModel
    let item: CartItem

    var body: some View {
        HStack(spacing: 12) {
            Text(item.menuItem.imageName).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.menuItem.name).font(.subheadline.bold())
                Text("$\(String(format: "%.2f", item.menuItem.price)) each")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            QuantityStepper(quantity: item.quantity) { newQty in
                viewModel.updateQuantity(for: item, quantity: newQty)
            }
        }
    }
}

// MARK: - Quantity Stepper

struct QuantityStepper: View {
    let quantity: Int
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button {
                onChange(quantity - 1)
            } label: {
                Image(systemName: quantity == 1 ? "trash" : "minus")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                    .frame(width: 28, height: 28)
            }

            Text("\(quantity)")
                .font(.subheadline.bold())
                .frame(minWidth: 18)

            Button {
                onChange(quantity + 1)
            } label: {
                Image(systemName: "plus")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Checkout

struct CheckoutView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPayment = "Credit Card"
    @State private var instructions    = ""
    @State private var placedOrder: Order?
    @State private var showConfirmation = false

    private let paymentMethods = ["Credit Card", "Apple Pay", "PayPal", "Cash"]

    private var deliveryFee: Double {
        viewModel.restaurants
            .first(where: { $0.name == viewModel.cartRestaurantName })?
            .deliveryFee ?? 2.99
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Delivering to") {
                    HStack {
                        Image(systemName: "mappin.circle.fill").foregroundColor(.orange)
                        Text(viewModel.currentUser?.address ?? "No address")
                            .font(.subheadline)
                    }
                }

                Section("Payment Method") {
                    ForEach(paymentMethods, id: \.self) { method in
                        HStack {
                            Text(paymentEmoji(method))
                            Text(method)
                            Spacer()
                            if selectedPayment == method {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { selectedPayment = method }
                    }
                }

                Section("Special Instructions") {
                    TextField("e.g. no onions, ring doorbell…",
                              text: $instructions, axis: .vertical)
                        .lineLimit(3)
                }

                Section("Order Summary") {
                    ForEach(viewModel.cart) { item in
                        HStack {
                            Text(item.menuItem.name)
                            Spacer()
                            Text("×\(item.quantity)").foregroundColor(.secondary)
                            Text("$\(String(format: "%.2f", item.subtotal))")
                                .foregroundColor(.orange)
                                .padding(.leading, 4)
                        }
                    }
                    HStack {
                        Text("Delivery").foregroundColor(.secondary)
                        Spacer()
                        Text(deliveryFee == 0
                             ? "FREE"
                             : "$\(String(format: "%.2f", deliveryFee))")
                            .foregroundColor(deliveryFee == 0 ? .green : .primary)
                    }
                    HStack {
                        Text("Total").bold()
                        Spacer()
                        Text("$\(String(format: "%.2f", viewModel.cartTotal + deliveryFee))")
                            .bold().foregroundColor(.orange)
                    }
                }

                Section {
                    Button {
                        if let order = viewModel.placeOrder(
                            paymentMethod: selectedPayment,
                            instructions: instructions
                        ) {
                            placedOrder = order
                            showConfirmation = true
                        }
                    } label: {
                        Text("Place Order")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.orange)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showConfirmation) {
                if let order = placedOrder {
                    OrderConfirmationView(order: order, onDismiss: { dismiss() })
                }
            }
        }
    }

    private func paymentEmoji(_ method: String) -> String {
        switch method {
        case "Apple Pay": return "🍎"
        case "PayPal":    return "💙"
        case "Cash":      return "💵"
        default:          return "💳"
        }
    }
}

// MARK: - Order Confirmation

struct OrderConfirmationView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    let order: Order
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.green)
            }
            VStack(spacing: 8) {
                Text("Order Placed! 🎉")
                    .font(.title.bold())
                Text("Your order from **\(order.restaurantName)** has been received.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Text("Estimated delivery: ~35 min")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button {
                    dismiss()
                    onDismiss()
                    viewModel.selectedTab = 3
                } label: {
                    Text("Track Order")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.orange).cornerRadius(14)
                }
                Button {
                    dismiss()
                    onDismiss()
                    viewModel.selectedTab = 0
                } label: {
                    Text("Back to Home")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }
}
