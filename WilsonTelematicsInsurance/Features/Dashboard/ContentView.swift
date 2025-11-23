import SwiftUI

struct ContentView: View {

    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("🔥 Logged in")
                .font(.title)

            if let user = authVM.user {
                Text("Email: \(user.email ?? "unknown")")
            }

            if let token = authVM.telematicsDeviceToken {
                Text("Telematics Device Token:")
                    .font(.headline)
                Text(token)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("No telematics token yet.")
                    .foregroundColor(.secondary)
            }

            Button("Sign Out") {
                authVM.signOut()
            }
            .padding(.top, 20)
        }
        .padding()
    }
}


#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
