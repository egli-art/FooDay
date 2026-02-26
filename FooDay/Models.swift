import Foundation
import SwiftUI

// MARK: - User
struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var email: String
    var phone: String
    var address: String
    var isAdmin: Bool = false
    var orderHistory: [String] = []
}

// MARK: - Restaurant
struct Restaurant: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var cuisine: String
    var rating: Double
    var deliveryTime: String
    var deliveryFee: Double
    var imageName: String
    var isOpen: Bool = true
    var menuItems: [MenuItem]
    var address: String
    var isActive: Bool = true
}

// MARK: - MenuItem
struct MenuItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var description: String
    var price: Double
    var category: String
    var imageName: String
    var isAvailable: Bool = true
    var isPopular: Bool = false
}

// MARK: - CartItem
struct CartItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var menuItem: MenuItem
    var quantity: Int
    var restaurantId: String
    var restaurantName: String

    var subtotal: Double { menuItem.price * Double(quantity) }
}

// MARK: - Order
struct Order: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var restaurantId: String
    var restaurantName: String
    var items: [CartItem]
    var status: OrderStatus
    var createdAt: Date
    var estimatedDelivery: Date
    var deliveryAddress: String
    var subtotal: Double
    var deliveryFee: Double
    var total: Double
    var paymentMethod: String
    var specialInstructions: String = ""
}

// MARK: - OrderStatus
// NOTE: Color is NOT Codable, so we add a separate extension in Views
enum OrderStatus: String, Codable, CaseIterable {
    case placed = "placed"
    case confirmed = "confirmed"
    case preparing = "preparing"
    case outForDelivery = "out_for_delivery"
    case delivered = "delivered"
    case cancelled = "cancelled"

    var displayText: String {
        switch self {
        case .placed:          return "Order Placed"
        case .confirmed:       return "Confirmed"
        case .preparing:       return "Preparing"
        case .outForDelivery:  return "Out for Delivery"
        case .delivered:       return "Delivered"
        case .cancelled:       return "Cancelled"
        }
    }

    var systemIcon: String {
        switch self {
        case .placed:          return "checkmark.circle"
        case .confirmed:       return "clock"
        case .preparing:       return "flame"
        case .outForDelivery:  return "bicycle"
        case .delivered:       return "house.fill"
        case .cancelled:       return "xmark.circle"
        }
    }

    var progress: Double {
        switch self {
        case .placed:          return 0.10
        case .confirmed:       return 0.30
        case .preparing:       return 0.55
        case .outForDelivery:  return 0.80
        case .delivered:       return 1.00
        case .cancelled:       return 0.00
        }
    }

    // SwiftUI Color extension – NOT part of Codable conformance
    var statusColor: Color {
        switch self {
        case .placed:          return .blue
        case .confirmed:       return .orange
        case .preparing:       return .orange
        case .outForDelivery:  return .green
        case .delivered:       return .green
        case .cancelled:       return .red
        }
    }
}
