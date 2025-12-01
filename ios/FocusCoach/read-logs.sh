#!/bin/bash
# Script to read Focus Coach debug logs
# Run: ./read-logs.sh

echo "🔍 Searching for Focus Coach debug logs..."
echo ""

# Try to find log file in Simulator
SIMULATOR_LOGS=$(find ~/Library/Developer/CoreSimulator/Devices -name "focus-coach-debug.log" 2>/dev/null | head -1)

if [ -n "$SIMULATOR_LOGS" ]; then
    echo "✅ Found log file: $SIMULATOR_LOGS"
    echo ""
    echo "📝 Last 50 lines:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ContentView.swift
        .onAppear {
            AppLogger.shared.info("👁️ ContentView appeared, isLoading=\(isLoading), isAuthenticated=\(firebaseService.isAuthenticated)")
            // Wait a moment for Firebase to initialize
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
                AppLogger.shared.info("⏱️ Loading finished, isLoading=false, isAuthenticated=\(firebaseService.isAuthenticated)")
            }
        }
    }
}

// MARK: - Auth View

struct AuthView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: PremiumTheme.Spacing.xl) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: PremiumTheme.Spacing.md) {
                Text("Focus Coach")
                    .font(PremiumTheme.Typography.headlineLG)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                
                Text("Get your shit done")
                    .font(PremiumTheme.Typography.bodyMD)
                    .foregroundColor(PremiumTheme.Colors.textSecondary)
            }
            .padding(.bottom, PremiumTheme.Spacing.xxl)
            
            // Form
            VStack(spacing: PremiumTheme.Spacing.lg) {
                // Email
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                    Text("Email")
                        .font(PremiumTheme.Typography.label)
                        .foregroundColor(PremiumTheme.Colist.textSecondary)
                    
                    TextField("", text: $email)
                        .textFieldStyle(.plain)
                        .padding()
                        .glassmorphism()
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                
                // Password
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                    Text("Password")
                        .font(PremiumTheme.Typography.label)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                    
                    SecureField("", text: $password)
                        .textFieldStyle(.plain)
                        .padding()
                        .glassmorphism()
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(PremiumTheme.Typography.bodySM)
                        .foregroundColor(PremiumTheme.Colors.error)
                        .padding(.top, PremiumTheme.Spacing.sm)
                }
                
                // Submit Button
                Button(action: handleSubmit) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isRegistering ? "Register" : "Login")
                                .font(PremiumTheme.Typography.bodyMD)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassmorphism(opacity: 0.1)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                .disabled(isLoading)
                
                // Toggle Register/Login
                Button(action: { isRegistering.toggle(); errorMessage = nil }) {
                    Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Register")
                        .font(PremiumTheme.Typography.bodySM)
                        .foregroundColor(PremiumTheme.Colors.primary)
                }
            }
            .padding(.horizontal, PremiumTheme.Spacing.xl)
            
            Spacer()
        }
    }
    
    // TEST-CURSOR: Diese Datei wurde von Cursor bearbeitet - ContentView.swift im FocusCoach/FocusCoach Ordner!
    
    private func handleSubmit() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        _Concurrency.Task {
            do {
                if isRegistering {
                    try await firebaseService.register(email: email, password: password)
                } else {
                    try await firebaseService.login(email: email, password: password)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Dashboard View (Placeholder)

struct DashboardView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    
    var body: some View {
        VStack(spacing: PremiumTheme.Spacing.lg) {
            Text("Welcome to Focus Coach!")
                .font(PremiumTheme.Typography.headlineMD)
                .foregroundColor(PremiumTheme.Colors.textPrimary)
                .padding()
            
            Text("iOS App is ready!")
                .font(PremiumTheme.Typography.bodyMD)
                .foregroundColor(PremiumTheme.Colors.textSecondary)
            
            // TEST-CURSOR: Logout Button wurde von Cursor bearbeitet!
            Button("Logout") {
                _Concurrency.Task {
                    try? await firebaseService.logout()
                }
            }
            .padding()
            .glassmorphism()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PremiumTheme.Colors.backgroundMain)
    }
}

#Preview {
    ContentView()
        .environmentObject(FirebaseService.shared)
}
