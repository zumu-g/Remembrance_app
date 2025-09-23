//
//  FullScreenPhotoView.swift
//  Remembrance
//
//  Created by Stuart Grant on 8/7/2025.
//

import SwiftUI

struct FullScreenPhotoView: View {
    let image: UIImage
    let dayNumber: Int
    let date: Date?
    let note: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showingControls = true
    @State private var showingInfo = false
    
    private let maxScale: CGFloat = 4.0
    private let minScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Main photo
            GeometryReader { geometry in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = lastScale * value
                                scale = max(minScale, min(maxScale, newScale))
                            }
                            .onEnded { _ in
                                lastScale = scale
                                if scale < minScale * 1.1 {
                                    withAnimation(.spring(response: 0.4)) {
                                        scale = minScale
                                        lastScale = minScale
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                            }
                            .simultaneously(with:
                                DragGesture()
                                    .onChanged { value in
                                        let maxOffsetX = max(0, (geometry.size.width * scale - geometry.size.width) / 2)
                                        let maxOffsetY = max(0, (geometry.size.height * scale - geometry.size.height) / 2)
                                        
                                        let newOffsetX = lastOffset.width + value.translation.width
                                        let newOffsetY = lastOffset.height + value.translation.height
                                        
                                        offset = CGSize(
                                            width: max(-maxOffsetX, min(maxOffsetX, newOffsetX)),
                                            height: max(-maxOffsetY, min(maxOffsetY, newOffsetY))
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.4)) {
                            if scale > minScale * 1.1 {
                                scale = minScale
                                lastScale = minScale
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingControls.toggle()
                        }
                    }
            }
            
            // Controls overlay
            if showingControls {
                VStack {
                    // Top controls
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                showingInfo.toggle()
                            }
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Bottom info panel
                    if showingInfo {
                        photoInfoPanel
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .statusBarHidden()
        .navigationBarHidden(true)
        .onAppear {
            // Hide controls after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if showingControls {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingControls = false
                    }
                }
            }
        }
    }
    
    private var photoInfoPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Day \(dayNumber) of 365")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let date = date {
                        Text(date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Zoom: \(Int(scale * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    if scale > minScale * 1.1 {
                        Text("Double tap to reset")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Text("Double tap to zoom")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            if !note.isEmpty {
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memory Note")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(note)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        )
        .padding()
    }
}

// MARK: - Helper View for Daily Photo View Integration

extension DailyPhotoView {
    var fullScreenPhotoView: some View {
        FullScreenPhotoView(
            image: photoViewModel.currentPhotoImage ?? UIImage(),
            dayNumber: photoViewModel.currentDayNumber,
            date: photoViewModel.currentPhotoDate,
            note: photoViewModel.currentPhotoNote
        )
    }
}

#Preview {
    FullScreenPhotoView(
        image: UIImage(systemName: "heart.fill") ?? UIImage(),
        dayNumber: 125,
        date: Date(),
        note: "This is a beautiful memory of mom in the garden. She loved spending time with her flowers."
    )
}