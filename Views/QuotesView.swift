import SwiftUI

struct QuotesView: View {
    @StateObject private var quoteViewModel = QuoteViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var selectedQuote: Quote?
    @State private var showingAddQuote = false
    @State private var searchText = ""
    
    var filteredQuotes: [Quote] {
        if searchText.isEmpty {
            return quoteViewModel.allQuotes
        }
        return quoteViewModel.allQuotes.filter { quote in
            quote.text?.localizedCaseInsensitiveContains(searchText) == true ||
            quote.author?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Add gradient background
                settingsViewModel.getGradientBackground()
                    .ignoresSafeArea()
                
                VStack {
                    if quoteViewModel.isLoading {
                        loadingView
                    } else if filteredQuotes.isEmpty {
                        emptyStateView
                    } else {
                        quotesListView
                    }
                }
            }
            .navigationTitle("Daily Quotes")
            .searchable(text: $searchText, prompt: "Search quotes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddQuote = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(settingsViewModel.getThemeColor(for: .accent))
                    }
                }
            }
        }
        .onAppear {
            Task {
                await quoteViewModel.refreshQuotes()
            }
        }
        .sheet(isPresented: $showingAddQuote) {
            AddQuoteView(quoteViewModel: quoteViewModel)
        }
        .sheet(item: $selectedQuote) { quote in
            QuoteDetailView(quote: quote, quoteViewModel: quoteViewModel)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: settingsViewModel.getThemeColor(for: .accent)))
            
            Text("Loading quotes...")
                .font(.headline)
                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
        }
    }
    
    private var quotesListView: some View {
        List {
            ForEach(filteredQuotes, id: \.id) { quote in
                QuoteRowView(quote: quote, settingsViewModel: settingsViewModel)
                    .onTapGesture {
                        selectedQuote = quote
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.bubble")
                .font(.system(size: 60))
                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
            
            Text(searchText.isEmpty ? "No quotes available" : "No quotes found")
                .font(.title2)
                .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
            
            Text(searchText.isEmpty ? "Quotes are being loaded" : "Try adjusting your search")
                .font(.body)
                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct QuoteRowView: View {
    let quote: Quote
    let settingsViewModel: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Day \(quote.dayNumber)")
                    .font(.caption)
                    .foregroundColor(settingsViewModel.getThemeColor(for: .accent))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(settingsViewModel.getThemeColor(for: .accent).opacity(0.1))
                    )
                
                Spacer()
                
                if quote.isCustom {
                    Text("Custom")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange.opacity(0.1))
                        )
                }
            }
            
            Text(quote.text ?? "")
                .font(.body)
                .italic()
                .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
            
            HStack {
                Spacer()
                Text("— \(quote.author ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
            }
        }
        .padding(.vertical, 8)
    }
}

struct QuoteDetailView: View {
    let quote: Quote
    let quoteViewModel: QuoteViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Day \(quote.dayNumber) of 365")
                                .font(.headline)
                                .foregroundColor(settingsViewModel.getThemeColor(for: .accent))
                            
                            Spacer()
                            
                            if quote.isCustom {
                                Text("Custom Quote")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                        }
                        
                        VStack(spacing: 16) {
                            Text(quote.text ?? "")
                                .font(.title3)
                                .italic()
                                .multilineTextAlignment(.center)
                                .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                                .lineLimit(nil)
                            
                            Text("— \(quote.author ?? "Unknown")")
                                .font(.body)
                                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(settingsViewModel.getThemeColor(for: .accent).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(settingsViewModel.getThemeColor(for: .accent).opacity(0.3), lineWidth: 1)
                                )
                        )
                        .shadow(color: settingsViewModel.getThemeColor(for: .accent).opacity(0.1), radius: 8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddQuoteView: View {
    let quoteViewModel: QuoteViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    @State private var quoteText = ""
    @State private var author = ""
    @State private var dayNumber = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Day Number")
                        .font(.headline)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                    
                    TextField("1-365", text: $dayNumber)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quote Text")
                        .font(.headline)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                    
                    TextEditor(text: $quoteText)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Author")
                        .font(.headline)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                    
                    TextField("Author name (optional)", text: $author)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: addQuote) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "plus.circle.fill")
                        }
                        Text(isLoading ? "Adding..." : "Add Quote")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(settingsViewModel.getThemeColor(for: .accent))
                    .cornerRadius(12)
                }
                .disabled(isLoading || quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || dayNumber.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addQuote() {
        guard let dayNum = Int32(dayNumber), dayNum >= 1 && dayNum <= 365 else {
            errorMessage = "Please enter a valid day number between 1 and 365"
            showingError = true
            return
        }
        
        let trimmedText = quoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            errorMessage = "Please enter quote text"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            let success = await quoteViewModel.addCustomQuote(
                text: trimmedText,
                author: author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : author.trimmingCharacters(in: .whitespacesAndNewlines),
                dayNumber: dayNum
            )
            
            await MainActor.run {
                isLoading = false
                if success {
                    dismiss()
                } else {
                    errorMessage = "Failed to add quote. Please try again."
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    QuotesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}