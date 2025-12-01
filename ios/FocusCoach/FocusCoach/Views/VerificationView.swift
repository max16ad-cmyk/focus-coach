//
//  VerificationView.swift
//  FocusCoach
//
//  Verification View - Photo Upload & AI Verification
//

import SwiftUI
import PhotosUI

struct VerificationView: View {
    let task: Task
    let onVerified: (Bool) -> Void
    let onCancel: () -> Void
    
    @State private var selectedImage: UIImage?
    @State private var isVerifying = false
    @State private var verificationResult: VerificationResult?
    @State private var showImagePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: PremiumTheme.Spacing.xxl) {
                // Header
                VStack(spacing: PremiumTheme.Spacing.md) {
                    Text("📸")
                        .font(.system(size: 64))
                    
                    Text("Nachweis hochladen")
                        .font(PremiumTheme.Typography.headlineMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    Text(task.title)
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                    
                    if let proofDescription = task.proofDescription, !proofDescription.isEmpty {
                        Text(proofDescription)
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, PremiumTheme.Spacing.xxl)
                
                // Image Preview or Upload Button
                if let image = selectedImage {
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(16)
                            .padding()
                            .glassmorphism()
                        
                        if verificationResult == nil {
                            Button("Nachweis prüfen") {
                                verifyImage()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(isVerifying)
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.xl)
                } else {
                    Button(action: { showImagePicker = true }) {
                        VStack(spacing: PremiumTheme.Spacing.md) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            
                            Text("Foto auswählen")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(PremiumTheme.Spacing.xxl)
                        .glassmorphism()
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.xl)
                }
                
                // Verification Result
                if let result = verificationResult {
                    VStack(spacing: PremiumTheme.Spacing.md) {
                        if result.accepted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.green)
                            
                            Text("Nachweis akzeptiert!")
                                .font(PremiumTheme.Typography.headlineMD)
                                .foregroundColor(.green)
                            
                            Text(result.coachMessage)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Bestätigen") {
                                onVerified(true)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.red)
                            
                            Text("Nachweis abgelehnt")
                                .font(PremiumTheme.Typography.headlineMD)
                                .foregroundColor(.red)
                            
                            Text(result.reason)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text(result.coachMessage)
                                .font(PremiumTheme.Typography.bodySM)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: PremiumTheme.Spacing.md) {
                                Button("Abbrechen") {
                                    onCancel()
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                
                                Button("Neues Foto") {
                                    selectedImage = nil
                                    verificationResult = nil
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                    }
                    .padding(PremiumTheme.Spacing.xl)
                    .glassmorphism()
                    .padding(.horizontal, PremiumTheme.Spacing.xl)
                }
                
                if isVerifying {
                    ProgressView("KI prüft Nachweis...")
                        .padding()
                }
                
                // Cancel Button
                if verificationResult == nil {
                    Button("Abbrechen") {
                        onCancel()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal, PremiumTheme.Spacing.xl)
                    .padding(.bottom, PremiumTheme.Spacing.xxl)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func verifyImage() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        isVerifying = true
        
        _Concurrency.Task {
            do {
                let result = try await GeminiService.shared.verifyProof(
                    taskTitle: task.title,
                    taskCategory: task.category?.rawValue ?? "",
                    proofDescription: task.proofDescription ?? "",
                    imageData: imageData
                )
                
                await MainActor.run {
                    verificationResult = result
                    isVerifying = false
                }
            } catch {
                await MainActor.run {
                    verificationResult = VerificationResult(
                        accepted: false,
                        confidence: 0,
                        reason: "Fehler bei der Verifikation: \(error.localizedDescription)",
                        detectedElements: [],
                        coachMessage: "Bitte versuche es erneut."
                    )
                    isVerifying = false
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

