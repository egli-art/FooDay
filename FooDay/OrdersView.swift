import SwiftUI

// MARK: - Orders Tab

struct OrdersView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.orders.isEmpty {
                    VStack(spacing: 16) {
                        Text("🧾").font(.system(size: 70))
                        Text("No orders yet").font(.title2.bold())
                        Text("Your order history will appear here.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        let current = viewModel.currentOrders()
                        let past    = viewModel.pastOrders()

                        if !current.isEmpty {
                            Section("Active Orders") {
                                ForEach(current) { order in
                                    NavigationLink(destination: OrderTrackingView(order: order)) {
                                        OrderRow(order: order)
                                    }
                                }
                            }
                        }
                        if !past.isEmpty {
                            Section("Past Orders") {
                                ForEach(past) { order in
                                    NavigationLink(destination: OrderTrackingView(order: order)) {
                                        OrderRow(order: order)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Orders")
        }
    }
}

// MARK: - Order Row

struct OrderRow: View {
    let order: Order
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: order.status.systemIcon)
                .font(.title2)
                .foregroundColor(order.status.statusColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(order.restaurantName).font(.subheadline.bold())
                Text(order.items
                        .prefix(2)
                        .map { "\($0.quantity)× \($0.menuItem.name)" }
                        .joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack {
                    Text(order.status.displayText)
                        .font(.caption.bold())
                        .foregroundColor(order.status.statusColor)
                    Text("•").foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", order.total))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Order Tracking

struct OrderTrackingView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let order: Order

    private var liveOrder: Order {
        viewModel.orders.first(where: { $0.id == order.id }) ?? order
    }

    private let pipeline: [OrderStatus] = [.placed, .confirmed, .preparing, .outForDelivery, .delivered]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: Status hero card
                VStack(spacing: 12) {
                    Image(systemName: liveOrder.status.systemIcon)
                        .font(.system(size: 50))
                        .foregroundColor(liveOrder.status.statusColor)

                    Text(liveOrder.status.displayText)
                        .font(.title2.bold())

                    if liveOrder.status != .delivered && liveOrder.status != .cancelled {
                        Text("Estimated delivery: \(liveOrder.estimatedDelivery, style: .time)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(liveOrder.status.statusColor.opacity(0.10))
                .cornerRadius(20)
                .padding(.horizontal)

                // MARK: Progress
                if liveOrder.status != .cancelled {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Order Progress").font(.headline)

                        ProgressView(value: liveOrder.status.progress)
                            .tint(.orange)

                        HStack(spacing: 0) {
                            ForEach(pipeline, id: \.self) { step in
                                let reached = isReached(step)
                                VStack(spacing: 4) {
                                    Image(systemName: step.systemIcon)
                                        .font(.caption)
                                        .foregroundColor(reached ? .orange : Color(.systemGray3))
                                    Text(step.displayText)
                                        .font(.system(size: 9))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(reached ? .orange : Color(.systemGray3))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8)
                    .padding(.horizontal)
                }

                // MARK: Items & totals
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order Details").font(.headline)

                    ForEach(liveOrder.items) { item in
                        HStack {
                            Text(item.menuItem.imageName)
                            Text("\(item.quantity)× \(item.menuItem.name)")
                                .font(.subheadline)
                            Spacer()
                            Text("$\(String(format: "%.2f", item.subtotal))")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                    Divider()
                    HStack {
                        Text("Subtotal").foregroundColor(.secondary)
                        Spacer()
                        Text("$\(String(format: "%.2f", liveOrder.subtotal))")
                    }
                    .font(.subheadline)
                    HStack {
                        Text("Delivery").foregroundColor(.secondary)
                        Spacer()
                        Text(liveOrder.deliveryFee == 0
                             ? "FREE"
                             : "$\(String(format: "%.2f", liveOrder.deliveryFee))")
                            .foregroundColor(liveOrder.deliveryFee == 0 ? .green : .primary)
                    }
                    .font(.subheadline)
                    HStack {
                        Text("Total").bold()
                        Spacer()
                        Text("$\(String(format: "%.2f", liveOrder.total))")
                            .bold().foregroundColor(.orange)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8)
                .padding(.horizontal)

                // MARK: Delivery info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delivery Info").font(.headline)
                    Label(liveOrder.deliveryAddress, systemImage: "mappin.circle")
                        .font(.subheadline).foregroundColor(.secondary)
                    Label(liveOrder.paymentMethod, systemImage: "creditcard")
                        .font(.subheadline).foregroundColor(.secondary)
                    if !liveOrder.specialInstructions.isEmpty {
                        Label(liveOrder.specialInstructions, systemImage: "note.text")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8)
                .padding(.horizontal)

                Spacer(minLength: 30)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Order #\(String(liveOrder.id.prefix(6)).uppercased())")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func isReached(_ step: OrderStatus) -> Bool {
        guard let curIdx  = pipeline.firstIndex(of: liveOrder.status),
              let stepIdx = pipeline.firstIndex(of: step) else { return false }
        return stepIdx <= curIdx
    }
}
