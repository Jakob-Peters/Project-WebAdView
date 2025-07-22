import SwiftUI
import Didomi

//MARK: Homepage view
struct HomepageView: View {
    @State private var showConsentOnAppear = true

    @State private var homepageWebAdKey = UUID()
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Ad unit WebView
                WebAdView()
                    .id(homepageWebAdKey)
                    .frame(width: 320, height: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 32)

                Text("Articles")
                    .font(.title2)
                    .bold()

                VStack(spacing: 16) {
                    NavigationLink(destination: Article1View()) {
                        Text("Article 1")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    NavigationLink(destination: Article2View()) {
                        Text("Article 2")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                    NavigationLink(destination: Article3View()) {
                        Text("Article 3")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                Spacer()
                Button(action: {
                    Didomi.shared.showPreferences()
                }) {
                    Text("Change Consent Preferences")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.bottom, 16)
            }
            .padding()
            .navigationTitle("Demo Homepage")
            .onAppear {
                if showConsentOnAppear {
                    Didomi.shared.showNotice()
                    showConsentOnAppear = false
                }
                homepageWebAdKey = UUID() // Only update if you want to force reload
            }
        }
        .background(DidomiWrapper()) // Ensures Didomi has a valid UIViewController for UI
    }
}


//MARK: Article views
struct Article1View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Article 1")
                    .font(.largeTitle)
                    .bold()
                // Ad unit WebView in the top
                WebAdView()
                    .id(UUID())
                    .frame(width: 320, height: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                // Filler text blocks
                Text("Filler text for Article 1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                    .padding()
                Text("More filler text. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.")
                    .padding()
                Text("Even more filler text. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.")
                    .padding()
            }
            .navigationTitle("Article 1")
            .padding()
        }
    }
}

struct Article2View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Article 2")
                    .font(.largeTitle)
                    .bold()
                // Ad unit WebView in the top
                WebAdView()
                    .id(UUID())
                    .frame(width: 320, height: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                // Filler text before ad
                Text("""
                Continuation of Article 2. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                Pellentesque habitant morbi tristique senectus et netus et
                """)
                    .padding()
                // Ad unit WebView in the middle
                WebAdView()
                    .id(UUID())
                    .frame(width: 300, height: 250)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                // More filler text
                Text("""
                Continuation of Article 2. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                Pellentesque habitant morbi tristique senectus et netus et
                """)
                    .padding()
                Spacer()
            }
            .navigationTitle("Article 2")
            .padding()
        }
    }
}

struct Article3View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Article 3")
                    .font(.largeTitle)
                    .bold()
                // Ad unit WebView in the top
                WebAdView()
                    .id(UUID())
                    .frame(width: 320, height: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                // Filler text before first ad
                Text("""
                Continuation of Article 2. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                Pellentesque habitant morbi tristique senectus et netus et
                """)
                    .padding()
                // First ad unit WebView
                WebAdView()
                    .id(UUID())
                    .frame(width: 320, height: 160)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                // More filler text
                Text("""
                Continuation of Article 2. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                Pellentesque habitant morbi tristique senectus et netus et
                """)
                    .padding()
                // Second ad unit WebView
                WebAdView()
                    .id(UUID())
                    .frame(width: 320, height: 160)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                // Final filler text
                Text("""
                Continuation of Article 2. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                Pellentesque habitant morbi tristique senectus et netus et
                """)
                    .padding()
                Spacer()
            }
            .navigationTitle("Article 3")
            .padding()
        }
    }
}
