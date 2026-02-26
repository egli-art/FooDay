import Foundation
import SwiftUI
import Combine

class AppViewModel: ObservableObject {

    // MARK: - Auth
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false

    // MARK: - Data
    @Published var restaurants: [Restaurant] = []
    @Published var orders: [Order] = []
    @Published var cart: [CartItem] = []
    @Published var cartRestaurantName: String = ""

    // MARK: - UI
    @Published var selectedTab: Int = 0
    @Published var showingCartConflictAlert: Bool = false
    @Published var pendingCartItem: CartItem?
    @Published var searchText: String = ""

    private let dataService = MockDataService.shared

    init() {
        restaurants = dataService.restaurants
        orders     = dataService.orders
    }

    // MARK: - Auth

    func login(email: String, password: String) -> Bool {
        guard let user = dataService.users.first(where: {
            $0.email.lowercased() == email.lowercased()
        }) else { return false }
        currentUser = user
        isLoggedIn  = true
        orders = dataService.orders.filter { $0.userId == user.id }
        return true
    }

    func register(name: String, email: String, phone: String, address: String) -> Bool {
        guard !dataService.users.contains(where: { $0.email == email }) else { return false }
        let newUser = User(name: name, email: email, phone: phone, address: address)
        dataService.users.append(newUser)
        currentUser = newUser
        isLoggedIn  = true
        orders = []
        return true
    }

    func logout() {
        currentUser = nil
        isLoggedIn  = false
        cart = []
        cartRestaurantName = ""
    }

    func updateProfile(name: String, phone: String, address: String) {
        guard let uid = currentUser?.id,
              let idx = dataService.users.firstIndex(where: { $0.id == uid })
        else { return }
        dataService.users[idx].name    = name
        dataService.users[idx].phone   = phone
        dataService.users[idx].address = address
        currentUser = dataService.users[idx]
    }

    // MARK: - Cart

    var cartTotal: Double    { cart.reduce(0) { $0 + $1.subtotal } }
    var cartItemCount: Int   { cart.reduce(0) { $0 + $1.quantity } }

    func addToCart(_ item: MenuItem, restaurant: Restaurant) {
        if !cart.isEmpty && cartRestaurantName != restaurant.name {
            pendingCartItem         = CartItem(menuItem: item, quantity: 1,
                                               restaurantId: restaurant.id,
                                               restaurantName: restaurant.name)
            showingCartConflictAlert = true
            return
        }
        cartRestaurantName = restaurant.name
        _addItem(item, restaurant: restaurant)
    }

    func clearCartAndAdd() {
        guard let pending = pendingCartItem else { return }
        cart               = []
        cartRestaurantName = pending.restaurantName
        if let r = restaurants.first(where: { $0.id == pending.restaurantId }) {
            _addItem(pending.menuItem, restaurant: r)
        }
        pendingCartItem = nil
    }

    private func _addItem(_ item: MenuItem, restaurant: Restaurant) {
        if let idx = cart.firstIndex(where: { $0.menuItem.id == item.id }) {
            cart[idx].quantity += 1
        } else {
            cart.append(CartItem(menuItem: item, quantity: 1,
                                  restaurantId: restaurant.id,
                                  restaurantName: restaurant.name))
        }
    }

    func removeFromCart(_ item: CartItem) {
        cart.removeAll { $0.id == item.id }
        if cart.isEmpty { cartRestaurantName = "" }
    }

    func updateQuantity(for item: CartItem, quantity: Int) {
        if quantity <= 0 {
            removeFromCart(item)
        } else if let idx = cart.firstIndex(where: { $0.id == item.id }) {
            cart[idx].quantity = quantity
        }
    }

    // MARK: - Orders

    func currentOrders() -> [Order] {
        orders.filter { $0.status != .delivered && $0.status != .cancelled }
    }

    func pastOrders() -> [Order] {
        orders.filter { $0.status == .delivered || $0.status == .cancelled }
    }

    func placeOrder(paymentMethod: String, instructions: String) -> Order? {
        guard let user = currentUser, !cart.isEmpty else { return nil }
        let fee = dataService.restaurants
            .first(where: { $0.name == cartRestaurantName })?.deliveryFee ?? 2.99
        let newOrder = Order(
            userId:              user.id,
            restaurantId:        cart.first?.restaurantId ?? "",
            restaurantName:      cartRestaurantName,
            items:               cart,
            status:              .placed,
            createdAt:           Date(),
            estimatedDelivery:   Calendar.current.date(byAdding: .minute, value: 35, to: Date()) ?? Date(),
            deliveryAddress:     user.address,
            subtotal:            cartTotal,
            deliveryFee:         fee,
            total:               cartTotal + fee,
            paymentMethod:       paymentMethod,
            specialInstructions: instructions
        )
        orders.insert(newOrder, at: 0)
        dataService.orders.insert(newOrder, at: 0)
        cart               = []
        cartRestaurantName = ""
        return newOrder
    }

    // MARK: - Admin

    var allOrders:      [Order]      { dataService.orders }
    var allRestaurants: [Restaurant] { dataService.restaurants }
    var allUsers:       [User]       { dataService.users }

    func toggleRestaurant(_ restaurant: Restaurant) {
        guard let idx = dataService.restaurants.firstIndex(where: { $0.id == restaurant.id })
        else { return }
        dataService.restaurants[idx].isActive.toggle()
        restaurants = dataService.restaurants
    }

    func advanceOrderStatus(_ order: Order) {
        let pipeline: [OrderStatus] = [.placed, .confirmed, .preparing, .outForDelivery, .delivered]
        guard let cur = pipeline.firstIndex(of: order.status),
              cur + 1 < pipeline.count
        else { return }
        updateOrderStatus(order, to: pipeline[cur + 1])
    }

    func updateOrderStatus(_ order: Order, to status: OrderStatus) {
        if let idx = dataService.orders.firstIndex(where: { $0.id == order.id }) {
            dataService.orders[idx].status = status
        }
        if let idx = orders.firstIndex(where: { $0.id == order.id }) {
            orders[idx].status = status
        }
    }

    // MARK: - Search

    var filteredRestaurants: [Restaurant] {
        let active = restaurants.filter { $0.isActive }
        guard !searchText.isEmpty else { return active }
        return active.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.cuisine.localizedCaseInsensitiveContains(searchText)
        }
    }
}
