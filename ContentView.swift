//
//  ContentView.swift
//  Codex Videre
//
//  Created by joshua johnson on 15/9/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showingScanner = false
    @State private var scannedCode = ""
    @State private var codeType = ""
    @State private var torchOn = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 70))
                
                Text("CODEX VIDERE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Digital Code Scanner")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                if !scannedCode.isEmpty {
                    VStack(spacing: 8) {
                        Text(codeType)
                            .font(.headline)
                        
                        Text(scannedCode)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                    .padding()
                }
                
                Button("Scan Code") {
                    showingScanner = true
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .sheet(isPresented: $showingScanner) {
                ZStack {
                    CameraView(
                        scannedCode: $scannedCode,
                        codeType: $codeType,
                        torchOn: $torchOn
                    )
                    .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button {
                                torchOn.toggle()
                            } label: {
                                Image(systemName: torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
