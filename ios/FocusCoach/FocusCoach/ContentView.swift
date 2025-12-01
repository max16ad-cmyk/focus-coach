//
//  ContentView.swift
//  FocusCoach
//
//  Root View - EQUINOX+ Style
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                // Loading Screen - EQUINOX+ style
                ZStack {
                    PremiumTheme.Colors.backgroundMain
                        .ignoresSafeArea()
                    
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        ProgressView()
                            .tint(PremiumTheme.Colors.ralphLaurenBlue)
                            .scaleEffect(1.5)
                        
                        Text("Focus Coach")
                            .font(PremiumTheme.Typography.headlineLG)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                    }
                }
            } else if firebaseService.isAuthenticated {
                // Authenticated - Show Main Tab View
                MainTabView()
                    .environmentObject(firebaseService)
            } else {
                // Not Authenticated - Show Auth Screen
                AuthView()
            }
        }
        .onAppear {
            print("🔥🔥🔥 ContentView.onAppear - isLoading=\(isLoading), isAuthenticated=\(firebaseService.isAuthenticated)")
            fflush(stdout)
            
            // Set loading to false immediately - Firebase should already be initialized
            isLoading = false
            print("🔥🔥🔥 ContentView: Setting isLoading=false immediately")
            fflush(stdout)
            
            // Fallback: Also set it after a delay to ensure it happens
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isLoading = false
                print("🔥🔥🔥 ContentView: Setting isLoading=false from delayed fallback")
                fflush(stdout)
            }
            
            // Prüfe wiederkehrende Tasks beim App-Start
            if firebaseService.isAuthenticated {
                _Concurrency.Task {
                    await TaskRepeater.shared.checkAndCreateRepeatingTasks()
                }
            }
        }
        .onChange(of: firebaseService.isAuthenticated) { newValue in
            print("🔥🔥🔥 ContentView: Auth state changed to \(newValue)")
            fflush(stdout)
            // Ensure loading is false when auth state changes
            isLoading = false
            print("🔥🔥🔥 ContentView: Setting isLoading=false from onChange")
            fflush(stdout)
        }
    }
}

// MARK: - Auth View (EQUINOX+ Style)

struct AuthView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer()
                        .frame(height: PremiumTheme.Spacing.xxl)
                    
                    // Welcome section - EQUINOX+ style
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Welcome!")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                        
                        Text("Realize Your Potential")
                            .font(PremiumTheme.Typography.headlineXL)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .lineLimit(2)
                        
                        Text("Sign in to continue your productivity journey and access your personalized plans.")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, PremiumTheme.Spacing.sm)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.xxl)
                    
                    // Form
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        // Email
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                            Text("Email")
                                .font(PremiumTheme.Typography.label)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                .tracking(PremiumTheme.Typography.labelTracking)
                            
                            TextField("", text: $email)
                                .textFieldStyle(.plain)
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                )
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                            Text("Password")
                                .font(PremiumTheme.Typography.label)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                .tracking(PremiumTheme.Typography.labelTracking)
                            
                            SecureField("", text: $password)
                                .textFieldStyle(.plain)
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                )
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                        }
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(PremiumTheme.Typography.bodySM)
                                .foregroundColor(PremiumTheme.Colors.error)
                                .padding(.top, PremiumTheme.Spacing.xs)
                        }
                        
                        // Submit Button - EQUINOX+ style
                        EquinoxButton(
                            title: isRegistering ? "Register" : "Sign In",
                            icon: nil,
                            style: .primary,
                            action: handleSubmit
                        )
                        .disabled(isLoading)
                        
                        // Toggle Register/Login
                        Button(action: { isRegistering.toggle(); errorMessage = nil }) {
                            Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Register")
                                .font(PremiumTheme.Typography.bodySM)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.xxl)
                }
            }
        }
    }
    
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

#Preview {
    ContentView()
        .environmentObject(FirebaseService.shared)
}
