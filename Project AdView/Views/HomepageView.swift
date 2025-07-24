import SwiftUI
import Didomi

//MARK: Homepage view
struct HomepageView: View {
    @EnvironmentObject var debugSettings: DebugSettings
    @State private var showConsentOnAppear = true
    @State private var homepageWebAdKey = UUID()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 32) {
                    WebAdView(adUnitId: "div-gpt-ad-mobile_1", initialHeight: 320, minHeight: 320, maxHeight: 320)
                        .showAdLabel(true, text: "predefined size annonce")
                        .id(UUID())
                        .id(homepageWebAdKey)
                        .frame(maxWidth: .infinity, alignment: .top)
                    Text("Articles")
                        .font(.title2)
                        .bold()

                    VStack(spacing: 16) {
                        NavigationLink(destination: Article1View()) {
                            Text("Article 1")
                                .frame(maxWidth: .infinity)
                                .frame(width: 320, height: 320, alignment: .center)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        NavigationLink(destination: Article2View()) {
                            Text("Article 2")
                                .frame(maxWidth: .infinity)
                                .frame(width: 320, height: 320, alignment: .center)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        }
                        WebAdView(adUnitId: "div-gpt-ad-mobile_2")
                            .showAdLabel(true)
                            .id(UUID())
                            .frame(maxWidth: .infinity, alignment: .top)
                            .padding(.vertical, 8)

                        NavigationLink(destination: Article3View()) {
                            Text("Article 3")
                                .frame(maxWidth: .infinity)
                                .frame(width: 320, height: 320, alignment: .center)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
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
                    .padding(.bottom, 4)
                }
                .padding()
            }
            .lazyLoadAd(true) // Apply lazy loading to the ScrollView itself
            .navigationTitle("Demo Homepage")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { debugSettings.isDebugEnabled.toggle() }) {
                        Image(systemName: debugSettings.isDebugEnabled ? "ladybug.fill" : "ladybug")
                            .foregroundColor(debugSettings.isDebugEnabled ? .red : .primary)
                            .accessibilityLabel("Toggle Debug Mode")
                    }
                }
            }
            .onAppear {
                homepageWebAdKey = UUID() //
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
                WebAdView(adUnitId: "div-gpt-ad-mobile_1")
                    .showAdLabel(true, text: "Custom annonce text", font: .caption.bold())
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
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
        .lazyLoadAd() // Apply lazy loading to the ScrollView
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
                WebAdView(adUnitId: "div-gpt-ad-mobile_1")
                    .showAdLabel(true)
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.vertical, 8)
                // Filler text before ad
                Text("""
                Continuation of Article 2. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                Pellentesque habitant morbi tristique senectus et netus et
                """)
                    .padding()
                // Ad unit WebView in the middle
                WebAdView(adUnitId: "div-gpt-ad-mobile_2")
                    .showAdLabel(true)
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
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
        .lazyLoadAd(true) // Apply lazy loading to the ScrollView
    }
}

struct Article3View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Article 3")
                    .font(.largeTitle)
                    .bold()
                // Ad unit WebView in the top (mobile_1)
                WebAdView(adUnitId: "div-gpt-ad-mobile_1")
                    .showAdLabel(true)
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.vertical, 8)
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 8)
                // Filler text before first ad
                Text("""
                Introduction to Article 3. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. 
                Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor.
                """)
                    .padding()
                // First ad unit WebView (mobile_2)
                WebAdView(adUnitId: "div-gpt-ad-mobile_2")
                    .showAdLabel(true)
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.vertical, 8)
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 8)
                // More filler text
                Text("""
                Section 2 of Article 3. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat. Praesent dapibus, neque id cursus faucibus, tortor neque egestas augue, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.
                Phasellus ultrices nulla quis nibh. Quisque a lectus. Donec consectetuer ligula vulputate sem tristique cursus. Nam nulla quam, gravida non, commodo a, sodales sit amet, nisi. Pellentesque fermentum dolor. Aliquam quam lectus, facilisis auctor, ultrices ut, elementum vulputate, nunc.
                """)
                    .padding()
                // Second ad unit WebView (mobile_3)
                WebAdView(adUnitId: "div-gpt-ad-mobile_3")
                    .showAdLabel(true)
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.vertical, 8)
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 8)
                // More filler text
                Text("""
                Section 3 of Article 3. Cras mattis consectetur purus sit amet fermentum. Etiam porta sem malesuada magna mollis euismod. Nullam id dolor id nibh ultricies vehicula ut id elit. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam at risus et justo dignissim congue. Donec congue lacinia dui, a porttitor lectus condimentum laoreet. Nunc eu ullamcorper orci. Quisque eget odio ac lectus vestibulum faucibus eget in metus. In pellentesque faucibus vestibulum. Nulla at nulla justo, eget luctus tortor. Nulla facilisi. Duis aliquet egestas purus in blandit.
                """)
                    .padding()
                // Third ad unit WebView (mobile_4)
                WebAdView(adUnitId: "div-gpt-ad-mobile_4")
                    .showAdLabel(true)
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.vertical, 8)
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 8)
                // More filler text
                Text("""
                Section 4 of Article 3. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Nullam quis risus eget urna mollis ornare vel eu leo. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Etiam porta sem malesuada magna mollis euismod. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.
                """)
                    .padding()
                // Fourth ad unit WebView (mobile_5)
                WebAdView(adUnitId: "div-gpt-ad-mobile_5")
                    .showAdLabel(true)
                    .id(UUID())
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.vertical, 8)
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 8)
                // Final filler text
                Text("""
                Conclusion of Article 3. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Donec ullamcorper nulla non metus auctor fringilla. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla.
                """)
                    .padding()
                Spacer()
            }
            .navigationTitle("Article 3")
            .padding()
        }
        .lazyLoadAd(true) // Apply lazy loading to the ScrollView
    }
}
