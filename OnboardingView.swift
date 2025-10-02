import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var showingPhotoPicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var mainPhoto: UIImage?
    @State private var galleryPhotos: [UIImage] = []
    @State private var userName: String = ""
    @State private var lovedOneName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject var photoStore: PhotoStore

    let totalPages = 5

    var body: some View {
        ZStack {
            Color(red: 51/255, green: 90/255, blue: 76/255)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isTextFieldFocused = false
                }

            VStack {
                progressBar

                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    purposePage.tag(1)
                    setupPage.tag(2)
                    photoImportPage.tag(3)
                    completionPage.tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.none, value: currentPage)

                navigationButtons
            }
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedItems,
            maxSelectionCount: 100,
            matching: .images
        )
        .onChange(of: selectedItems) { items in
            Task {
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            galleryPhotos.append(image)
                        }
                    }
                }
                selectedItems = []
            }
        }
    }

    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)

                Rectangle()
                    .fill(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .frame(width: geometry.size.width * CGFloat(currentPage + 1) / CGFloat(totalPages), height: 4)
                    .animation(.spring(), value: currentPage)
            }
        }
        .frame(height: 4)
        .padding(.horizontal)
        .padding(.top, 60)
    }

    var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

            VStack(spacing: 15) {
                Text("Welcome to Remembrance")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("A beautiful space to honor and remember someone special")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
            Spacer()
        }
    }

    var purposePage: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 25) {
                Text("How Remembrance Works")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "photo", title: "Daily Photo", description: "Each day, see a special photo from your collection")
                    FeatureRow(icon: "quote.bubble", title: "Inspiring Quotes", description: "365 unique quotes about love, hope, and memories")
                    FeatureRow(icon: "calendar", title: "Memory Timeline", description: "Look back at previous daily memories")
                    FeatureRow(icon: "bell", title: "Gentle Reminders", description: "Optional daily notifications at your chosen time")
                }
                .padding(.horizontal, 30)
            }

            VStack(spacing: 10) {
                Text("7-Day Free Trial")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

                Text("Then $2.99/month or $19.99/year")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)

            Spacer()
        }
    }

    var setupPage: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Let's Personalize")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)

            VStack(spacing: 25) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your first name (optional)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))

                    TextField("Your name", text: $userName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .focused($isTextFieldFocused)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Who are you remembering?")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))

                    TextField("Their name or relationship (e.g., Mom, Dad)", text: $lovedOneName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
            }
            .padding(.horizontal, 40)

            Text("This helps personalize your experience")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .italic()

            Spacer()
            Spacer()
        }
        .onAppear {
            // Faster keyboard appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }

    var photoImportPage: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Add Memorial Photos")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("Start with a few favorite photos\nYou can always add more later")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                // Main portrait button
                Button(action: {
                    // This would open a single photo picker for main portrait
                }) {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 120, height: 120)

                            if mainPhoto != nil {
                                Image(uiImage: mainPhoto!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else {
                                Image(systemName: "person.crop.rectangle.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                        Text("Main Portrait")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                // Gallery photos button
                Button(action: {
                    showingPhotoPicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 24))

                        VStack(alignment: .leading) {
                            Text("Add Photos to Gallery")
                                .font(.system(size: 16, weight: .medium))

                            if !galleryPhotos.isEmpty {
                                Text("\(galleryPhotos.count) photos selected")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)

                // Skip option
                Button(action: {
                    currentPage = 4
                }) {
                    Text("I'll add photos later")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .underline()
                }
                .padding(.top, 10)
            }

            Spacer()
        }
    }

    var completionPage: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("You're All Set!")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.white)

            VStack(spacing: 15) {
                Text("Your 7-day free trial has begun")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

                Text("Take a moment each day to remember and celebrate the beautiful memories you shared")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 12) {
                Button(action: {
                    completeOnboarding()
                }) {
                    Text("Start Remembering")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 51/255, green: 90/255, blue: 76/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)

                Text("Cancel anytime in Settings")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
            Spacer()
        }
    }

    var navigationButtons: some View {
        HStack {
            if currentPage > 0 && currentPage < totalPages - 1 {
                Button(action: {
                    currentPage -= 1
                    isTextFieldFocused = false
                }) {
                    Text("Back")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
            } else {
                Spacer()
                    .frame(width: 80)
            }

            Spacer()

            if currentPage < totalPages - 1 {
                Button(action: {
                    isTextFieldFocused = false
                    currentPage += 1
                }) {
                    Text("Next")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color(red: 179/255, green: 154/255, blue: 76/255))
                        .cornerRadius(25)
                }
            } else {
                Spacer()
                    .frame(width: 80)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
    }

    private func completeOnboarding() {
        // Save user preferences
        if !userName.isEmpty {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
        if !lovedOneName.isEmpty {
            UserDefaults.standard.set(lovedOneName, forKey: "lovedOneName")
        }

        // Add photos to photoStore
        var allPhotos: [UIImage] = []
        if let mainPhoto = mainPhoto {
            allPhotos.append(mainPhoto)
        }
        if !galleryPhotos.isEmpty {
            allPhotos.append(contentsOf: galleryPhotos)
        }
        if !allPhotos.isEmpty {
            photoStore.addImages(allPhotos)
        }

        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Start trial
        if UserDefaults.standard.object(forKey: "trialStartDate") == nil {
            UserDefaults.standard.set(Date(), forKey: "trialStartDate")
        }

        // Dismiss onboarding
        isPresented = false
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(PhotoStore())
}