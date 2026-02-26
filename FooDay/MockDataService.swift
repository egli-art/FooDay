import Foundation

// MARK: - Free functions used to build sample data
// (Defined at file scope so they can be called from property initializers)

private func makeBurgerItems() -> [MenuItem] {
    [
        MenuItem(name: "Classic Burger",    description: "Beef patty, lettuce, tomato, onion, pickles",       price: 12.99, category: "Burgers", imageName: "🍔", isPopular: true),
        MenuItem(name: "Cheese Burger",     description: "Double cheddar, special sauce, caramelized onions", price: 14.99, category: "Burgers", imageName: "🍔"),
        MenuItem(name: "BBQ Bacon Burger",  description: "Smoked bacon, BBQ sauce, crispy onions",            price: 16.99, category: "Burgers", imageName: "🍔", isPopular: true),
        MenuItem(name: "Veggie Burger",     description: "Plant-based patty, avocado, sprouts",               price: 13.99, category: "Burgers", imageName: "🥦"),
        MenuItem(name: "French Fries",      description: "Crispy golden fries with sea salt",                 price:  4.99, category: "Sides",   imageName: "🍟", isPopular: true),
        MenuItem(name: "Onion Rings",       description: "Beer-battered, crispy onion rings",                 price:  5.99, category: "Sides",   imageName: "🧅"),
        MenuItem(name: "Chocolate Shake",   description: "Thick creamy chocolate milkshake",                  price:  6.99, category: "Drinks",  imageName: "🥤"),
        MenuItem(name: "Lemonade",          description: "Fresh squeezed with mint",                          price:  3.99, category: "Drinks",  imageName: "🍋"),
    ]
}

private func makePizzaItems() -> [MenuItem] {
    [
        MenuItem(name: "Margherita",      description: "San Marzano tomato, fresh mozzarella, basil",     price: 15.99, category: "Pizzas",   imageName: "🍕", isPopular: true),
        MenuItem(name: "Pepperoni",       description: "Classic pepperoni with mozzarella",               price: 17.99, category: "Pizzas",   imageName: "🍕", isPopular: true),
        MenuItem(name: "BBQ Chicken",     description: "Grilled chicken, BBQ sauce, red onion, cilantro", price: 18.99, category: "Pizzas",   imageName: "🍕"),
        MenuItem(name: "Veggie Supreme",  description: "Bell peppers, mushrooms, olives, artichokes",     price: 16.99, category: "Pizzas",   imageName: "🍕"),
        MenuItem(name: "Garlic Bread",    description: "Toasted sourdough with garlic butter and herbs",  price:  6.99, category: "Sides",    imageName: "🥖"),
        MenuItem(name: "Caesar Salad",    description: "Romaine, parmesan, croutons, caesar dressing",    price:  9.99, category: "Salads",   imageName: "🥗"),
        MenuItem(name: "Tiramisu",        description: "Classic Italian dessert with espresso",           price:  7.99, category: "Desserts", imageName: "🍰"),
        MenuItem(name: "Sparkling Water", description: "Italian sparkling mineral water",                 price:  2.99, category: "Drinks",   imageName: "💧"),
    ]
}

private func makeSushiItems() -> [MenuItem] {
    [
        MenuItem(name: "Salmon Roll",          description: "Fresh salmon, avocado, cucumber",                     price: 14.99, category: "Rolls",       imageName: "🍣", isPopular: true),
        MenuItem(name: "Tuna Nigiri (2pc)",    description: "Premium bluefin tuna over seasoned rice",             price: 12.99, category: "Nigiri",      imageName: "🍣"),
        MenuItem(name: "Dragon Roll",          description: "Shrimp tempura, avocado on top, eel sauce",           price: 18.99, category: "Rolls",       imageName: "🍣", isPopular: true),
        MenuItem(name: "Spicy Tuna Roll",      description: "Tuna, sriracha mayo, cucumber",                       price: 13.99, category: "Rolls",       imageName: "🍣"),
        MenuItem(name: "Miso Soup",            description: "Traditional dashi broth with tofu and seaweed",       price:  3.99, category: "Soups",       imageName: "🍜"),
        MenuItem(name: "Edamame",              description: "Steamed and lightly salted soybeans",                 price:  4.99, category: "Appetizers",  imageName: "🌿", isPopular: true),
        MenuItem(name: "Green Tea Ice Cream",  description: "Matcha soft serve",                                   price:  5.99, category: "Desserts",    imageName: "🍦"),
        MenuItem(name: "Sake (carafe)",        description: "Premium warm sake",                                   price: 12.99, category: "Drinks",      imageName: "🍶"),
    ]
}

private func makeTacoItems() -> [MenuItem] {
    [
        MenuItem(name: "Carne Asada Tacos (3)",        description: "Grilled beef, salsa verde, cilantro, onion",         price: 13.99, category: "Tacos",    imageName: "🌮", isPopular: true),
        MenuItem(name: "Fish Tacos (3)",               description: "Baja-style with slaw and chipotle crema",            price: 14.99, category: "Tacos",    imageName: "🌮"),
        MenuItem(name: "Veggie Tacos (3)",             description: "Roasted peppers, black beans, pico, guac",           price: 11.99, category: "Tacos",    imageName: "🌮"),
        MenuItem(name: "Chicken Burrito",              description: "Grilled chicken, rice, beans, cheese, sour cream",   price: 12.99, category: "Burritos", imageName: "🌯", isPopular: true),
        MenuItem(name: "Guacamole & Chips",            description: "Fresh avocado with house-made tortilla chips",        price:  7.99, category: "Sides",    imageName: "🥑", isPopular: true),
        MenuItem(name: "Elote",                        description: "Grilled corn, cotija cheese, chili, lime",           price:  6.99, category: "Sides",    imageName: "🌽"),
        MenuItem(name: "Horchata",                     description: "Rice milk with cinnamon and vanilla",                price:  3.99, category: "Drinks",   imageName: "🥛"),
        MenuItem(name: "Churros",                      description: "Crispy with cinnamon sugar and chocolate dip",       price:  5.99, category: "Desserts", imageName: "🍫"),
    ]
}

private func makeHealthyItems() -> [MenuItem] {
    [
        MenuItem(name: "Kale Caesar",       description: "Kale, parmesan, croutons, anchovy dressing",    price: 13.99, category: "Salads",  imageName: "🥗", isPopular: true),
        MenuItem(name: "Quinoa Power Bowl", description: "Quinoa, roasted veggies, tahini, feta",         price: 14.99, category: "Bowls",   imageName: "🥣", isPopular: true),
        MenuItem(name: "Acai Bowl",         description: "Acai base, granola, fresh berries, honey",      price: 12.99, category: "Bowls",   imageName: "🍓"),
        MenuItem(name: "Avocado Toast",     description: "Sourdough, smashed avocado, poached egg",       price: 11.99, category: "Toast",   imageName: "🥑"),
        MenuItem(name: "Green Smoothie",    description: "Spinach, banana, mango, almond milk",           price:  7.99, category: "Drinks",  imageName: "🥤", isPopular: true),
        MenuItem(name: "Coconut Water",     description: "Fresh young coconut water",                     price:  4.99, category: "Drinks",  imageName: "🥥"),
    ]
}

// MARK: - MockDataService

class MockDataService {

    static let shared = MockDataService()

    // Use lazy so the free functions above can be called at first access
    lazy var restaurants: [Restaurant] = [
        Restaurant(name: "Burger Republic", cuisine: "American • Burgers",  rating: 4.7, deliveryTime: "20-30 min", deliveryFee: 2.99, imageName: "🍔", menuItems: makeBurgerItems(),  address: "123 Main St"),
        Restaurant(name: "Pizza Napoli",    cuisine: "Italian • Pizza",     rating: 4.8, deliveryTime: "25-40 min", deliveryFee: 0.00, imageName: "🍕", menuItems: makePizzaItems(),   address: "456 Oak Ave"),
        Restaurant(name: "Sakura Sushi",    cuisine: "Japanese • Sushi",    rating: 4.9, deliveryTime: "30-45 min", deliveryFee: 3.99, imageName: "🍣", menuItems: makeSushiItems(),   address: "789 Cherry Blvd"),
        Restaurant(name: "Taco Loco",       cuisine: "Mexican • Tacos",     rating: 4.5, deliveryTime: "15-25 min", deliveryFee: 1.99, imageName: "🌮", menuItems: makeTacoItems(),    address: "321 Pepper Lane"),
        Restaurant(name: "The Green Bowl",  cuisine: "Healthy • Salads",    rating: 4.6, deliveryTime: "20-30 min", deliveryFee: 2.49, imageName: "🥗", menuItems: makeHealthyItems(), address: "555 Wellness Way", isActive: false),
    ]

    lazy var users: [User] = [
        User(name: "Alex Johnson", email: "alex@example.com",    phone: "+1 555-0101", address: "42 Maple Street, New York, NY 10001"),
        User(name: "Admin User",   email: "admin@foodapp.com",   phone: "+1 555-0000", address: "HQ", isAdmin: true),
    ]

    lazy var orders: [Order] = {
        var result: [Order] = []
        let r0 = self.restaurants[0]
        let r1 = self.restaurants[1]
        let u0 = self.users[0]

        let items0: [CartItem] = [
            CartItem(menuItem: r0.menuItems[0], quantity: 2, restaurantId: r0.id, restaurantName: r0.name),
            CartItem(menuItem: r0.menuItems[4], quantity: 1, restaurantId: r0.id, restaurantName: r0.name),
        ]
        let subtotal0 = items0.reduce(0.0) { $0 + $1.subtotal }

        result.append(Order(
            userId: u0.id,
            restaurantId: r0.id,
            restaurantName: r0.name,
            items: items0,
            status: .delivered,
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            deliveryAddress: u0.address,
            subtotal: subtotal0,
            deliveryFee: r0.deliveryFee,
            total: subtotal0 + r0.deliveryFee,
            paymentMethod: "Credit Card"
        ))

        let items1: [CartItem] = [
            CartItem(menuItem: r1.menuItems[0], quantity: 1, restaurantId: r1.id, restaurantName: r1.name),
        ]
        result.append(Order(
            userId: u0.id,
            restaurantId: r1.id,
            restaurantName: r1.name,
            items: items1,
            status: .preparing,
            createdAt: Date(),
            estimatedDelivery: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date(),
            deliveryAddress: u0.address,
            subtotal: 15.99,
            deliveryFee: 0.0,
            total: 15.99,
            paymentMethod: "Apple Pay"
        ))
        return result
    }()
}
