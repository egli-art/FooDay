# QuickBite – Xcode Setup Guide

## Requirements
- Xcode 14.0 or later
- iOS 15.0+ deployment target
- No third-party dependencies (pure SwiftUI + Foundation)

---

## Step-by-Step Setup

### 1. Create a new Xcode project

1. Open Xcode → **File → New → Project…**
2. Choose **iOS → App**
3. Fill in:
   - **Product Name:** `QuickBite`
   - **Team:** (your team or Personal Team)
   - **Organization Identifier:** e.g. `com.yourname`
   - **Interface:** `SwiftUI`
   - **Language:** `Swift`
   - Uncheck *Use Core Data* and *Include Tests*
4. Click **Next** and choose a save location

---

### 2. Delete the default files

In the Xcode Project Navigator, delete these auto-generated files:
- `ContentView.swift`

Keep `Assets.xcassets` and `Info.plist`.

---

### 3. Add the source files

In the Project Navigator, right-click the **QuickBite** folder (yellow) and choose  
**Add Files to "QuickBite"…**

Add all files from this folder, preserving structure. The recommended way:

1. Create **Groups** (yellow folders) in Xcode matching the folder names:
   - `Models`
   - `ViewModels`
   - `Services`
   - `Views`

2. Drag each `.swift` file into the correct group.

**File list:**
```
QuickBiteApp.swift          ← Root (top-level, no group)
Models/
  Models.swift
ViewModels/
  AppViewModel.swift
Services/
  MockDataService.swift
Views/
  AuthView.swift
  HomeView.swift
  SearchView.swift
  RestaurantDetailView.swift
  CartView.swift
  OrdersView.swift
  ProfileView.swift
  AdminViews.swift
```

Make sure every file is checked for the **QuickBite** target when prompted.

---

### 4. Set deployment target

1. Click the **QuickBite** project in the Navigator (blue icon)
2. Select the **QuickBite** target
3. Under **General → Deployment Info**, set minimum iOS to **15.0**

---

### 5. Build & Run

1. Select any iPhone simulator (iPhone 15 or 14 recommended)
2. Press **⌘R** or click the ▶ button

---

## Demo Credentials

| Role  | Email                 | Password    |
|-------|-----------------------|-------------|
| User  | alex@example.com      | anything    |
| Admin | admin@foodapp.com     | anything    |

> Tap the quick-login buttons on the login screen for one-tap access.

---

## Known Limitations (mock app)

- All data is in-memory — resets on relaunch
- Auth accepts any password for demo accounts
- Order status advances only via Admin panel swipe actions
- No real payment processing
- No map or GPS integration

---

## Connecting a Real Backend

All models conform to `Codable`. To connect a real API:
1. Replace `MockDataService` with a `NetworkService` using `URLSession`
2. Add `@Published var isLoading: Bool` and error states to `AppViewModel`
3. Swap mock auth with JWT/OAuth token flow
4. Use WebSockets or polling for live order status updates
