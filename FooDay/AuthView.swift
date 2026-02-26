import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isLogin = true
    @State private var email    = ""
    @State private var password = ""
    @State private var name     = ""
    @State private var phone    = ""
    @State private var address  = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Logo
                VStack(spacing: 10) {
                    Text("🍽️")
                        .font(.system(size: 72))
                    Text("QuickBite")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Delicious food, delivered fast")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)

                // MARK: Segment
                Picker("", selection: $isLogin) {
                    Text("Log In").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                // MARK: Fields
                VStack(spacing: 14) {
                    if !isLogin {
                        QBTextField(icon: "person", placeholder: "Full Name", text: $name)
                    }
                    QBTextField(icon: "envelope", placeholder: "Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    QBTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                    if !isLogin {
                        QBTextField(icon: "phone", placeholder: "Phone", text: $phone)
                            .keyboardType(.phonePad)
                        QBTextField(icon: "mappin", placeholder: "Delivery Address", text: $address)
                    }
                }
                .padding(.horizontal, 24)

                // Error
                if let err = errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                        .padding(.horizontal, 24)
                }

                // MARK: CTA
                Button(action: handleAuth) {
                    Text(isLogin ? "Log In" : "Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                // MARK: Quick-login hints
                if isLogin {
                    VStack(spacing: 6) {
                        Text("Demo accounts:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("User – alex@example.com") {
                            email = "alex@example.com"; password = "password"
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        Button("Admin – admin@foodapp.com") {
                            email = "admin@foodapp.com"; password = "password"
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    .padding(.top, 18)
                }

                Spacer(minLength: 40)
            }
        }
        .onChange(of: isLogin) { _ in errorMessage = nil }
    }

    // MARK: - Logic

    private func handleAuth() {
        errorMessage = nil
        if isLogin {
            if !viewModel.login(email: email, password: password) {
                errorMessage = "Invalid email or password."
            }
        } else {
            guard !name.isEmpty, !email.isEmpty, !address.isEmpty else {
                errorMessage = "Please fill in all required fields."
                return
            }
            if !viewModel.register(name: name, email: email, phone: phone, address: address) {
                errorMessage = "An account with this email already exists."
            }
        }
    }
}

// MARK: - Reusable text field

struct QBTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 22)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
