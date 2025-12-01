//
//  SynthWaveView.swift
//  FocusCoach
//
//  Synth Wave Animation für Voice Input
//

import SwiftUI

struct SynthWaveView: View {
    @Binding var isListening: Bool
    @Binding var audioLevel: CGFloat // 0.0 - 1.0 (echtes Audio-Level vom Mikrofon)
    
    @State private var phase: CGFloat = 0
    @State private var smoothedLevel: CGFloat = 0.0
    
    // Threshold: Nur animieren wenn Audio-Level über diesem Wert liegt
    private let audioThreshold: CGFloat = 0.01
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let radius = size / 2 - 10 // Etwas kleiner als Container
            
            ZStack {
                // Mikrofon Icon in der Mitte
                Image(systemName: "mic.fill")
                    .font(.system(size: size * 0.3, weight: .semibold))
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .position(x: centerX, y: centerY)
                
                // Wellen-Animation NUR wenn Audio-Level vorhanden
                if isListening && smoothedLevel > audioThreshold {
                    // Multiple konzentrische Kreise
                    ForEach(0..<3, id: \.self) { index in
                        CircleWaveShape(
                            phase: phase + CGFloat(index) * 0.5,
                            radius: radius,
                            amplitude: calculateAmplitude(for: index),
                            centerX: centerX,
                            centerY: centerY
                        )
                        .stroke(
                            PremiumTheme.Colors.pendingBlue.opacity(0.8 - Double(index) * 0.2),
                            lineWidth: calculateLineWidth(for: index)
                        )
                    }
                }
            }
        }
        .onChange(of: isListening) { listening in
            if !listening {
                // Reset wenn nicht mehr zuhört
                smoothedLevel = 0.0
                phase = 0
            }
        }
        .onChange(of: audioLevel) { level in
            // NUR animieren wenn Level über Threshold
            if level > audioThreshold {
                // Smooth das Audio-Level
                withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
                    smoothedLevel = level
                }
                
                // Starte Animation nur wenn noch nicht aktiv
                if phase == 0 {
                    startAnimation()
                }
            } else {
                // Level zu niedrig - stoppe Animation
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    smoothedLevel = 0.0
                }
                phase = 0
            }
        }
    }
    
    private func calculateAmplitude(for index: Int) -> CGFloat {
        // Amplitude basierend auf Audio-Level
        let baseAmplitude: CGFloat = 2.0
        let levelMultiplier = smoothedLevel * 15.0 // Stärkere Reaktion
        return baseAmplitude + levelMultiplier + CGFloat(index) * 1.5
    }
    
    private func calculateLineWidth(for index: Int) -> CGFloat {
        let baseWidth: CGFloat = 2.0
        let levelWidth = smoothedLevel * 2.0
        return baseWidth + levelWidth + CGFloat(index) * 0.5
    }
    
    private func startAnimation() {
        // Animation-Geschwindigkeit basierend auf Audio-Level
        let speed = 0.5 + (smoothedLevel * 0.5) // 0.5x bis 1.0x
        
        withAnimation(.linear(duration: 2.0 / speed).repeatForever(autoreverses: false)) {
            phase = .pi * 2
        }
    }
}

// Neue Shape für kreisförmige Wellen
struct CircleWaveShape: Shape {
    var phase: CGFloat
    var radius: CGFloat
    var amplitude: CGFloat
    var centerX: CGFloat
    var centerY: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let points = 64 // Anzahl der Punkte für glatten Kreis
        let angleStep = (2 * .pi) / CGFloat(points)
        
        for i in 0..<points {
            let angle = CGFloat(i) * angleStep + phase
            let waveOffset = sin(angle * 3.0) * amplitude // 3 Wellen um den Kreis
            let currentRadius = radius + waveOffset
            let x = centerX + cos(angle) * currentRadius
            let y = centerY + sin(angle) * currentRadius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            let y = midHeight + sin(phase + relativeX * frequency * width) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

