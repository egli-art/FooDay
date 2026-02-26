import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showEditProfile  = false
    @State private var showLogoutAlert  = false

    var body: some View {
        NavigationView {
            List {

                // MARK: Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 70, height: 70)
                            Image(systemName: "person.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentUser?.name ?? "")
                                .font(.title3.bold())
                            Text(viewModel.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if viewModel.currentUser?.isAdmin == true {
                                Text("Admin")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }

                // MARK: Account
                Section("Account") {
                    Button {
                        showEditProfile = true
                    } label: {
                        ProfileRowLabel(icon: "person.text.rectangle", label: "Edit Profile", color: .blue)
                    }
                    .foregroundColor(.primary)

                    NavigationLink(destination: AddressView()) {
                        ProfileRowLabel(icon: "mappin.circle", label: "Delivery Address", color: .red)
                    }

                    NavigationLink(destination: OrdersView()) {
                        ProfileRowLabel(icon: "clock.arrow.circlepath", label: "Order History", color: .orange)
                    }
                }

                // MARK: Preferences
                Section("Preferences") {
                    ProfileRowLabel(icon: "bell",             label: "Notifications",   color: .purple)
                    ProfileRowLabel(icon: "creditcard",       label: "Payment Methods", color: .green)
                    ProfileRowLabel(icon: "questionmark.circle", label: "Help & Support", color: .teal)
                }

                // MARK: Logout
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                // MARK: Footer
                Section {
                    VStack(spacing: 2) {
                        Text("QuickBite v1.0")
                            .font(.caption).foregroundColor(.secondary)
                        Text("Made with ❤️ and SwiftUI")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .alert("Log Out?", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) { viewModel.logout() }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

// MARK: - Reusable row label

struct ProfileRowLabel: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .cornerRadius(8)
            Text(label).font(.subheadline)
        }
    }
}

// MARK: - Edit Profile

struct EditProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name    = ""
    @State private var phone   = ""
    @State private var address = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Group {
                        Text("Personal Info")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        QBTextField(icon: "person",  placeholder: "Full Name", text: $name)
                        QBTextField(icon: "phone",   placeholder: "Phone",     text: $phone)
                            .keyboardType(.phonePad)
                    }
                    Group {
                        Text("Delivery Address")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        QBTextField(icon: "mappin",  placeholder: "Address",   text: $address)
                    }

                    Button {
                        viewModel.updateProfile(name: name, phone: phone, address: address)
                        dismiss()
                    } label: {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(14)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                name    = viewModel.currentUser?.name    ?? ""
                phone   = viewModel.currentUser?.phone   ?? ""
                address = viewModel.currentUser?.address ?? ""
            }
        }
    }
}

// MARK: - Address View

struct AddressView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        Form {
            Section("Current Address") {
                Text(viewModel.currentUser?.address ?? "No address on file")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Delivery Address")
    }
}
