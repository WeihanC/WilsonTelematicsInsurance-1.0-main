//
//  AuthView.swift
//  WilsonTelematicsInsurance
//
//  Created by WIlson's macbook on 11/22/25.
//


import SwiftUI

struct AuthView: View {

    @EnvironmentObject var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpMode = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                Text("Telematics Insurance")
                    .font(.title)
                    .fontWeight(.bold)

                Picker("", selection: $isSignUpMode) {
                    Text("Log In").tag(false)
                    Text("Sign Up").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("Password (min 6)", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                Button(action: handleSubmit) {
                    if authVM.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(isSignUpMode ? "Create Account" : "Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(authVM.isLoading || email.isEmpty || password.count < 6)

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    private func handleSubmit() {
        if isSignUpMode {
            authVM.signUp(email: email, password: password)
        } else {
            authVM.signIn(email: email, password: password)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
