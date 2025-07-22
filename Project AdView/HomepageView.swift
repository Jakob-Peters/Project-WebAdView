import SwiftUI

struct HomepageView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Ad unit placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 320, height: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(Text("Ad Unit Placeholder").foregroundColor(.gray))
                    .padding(.top, 32)

                Text("Articles")
                    .font(.title2)
                    .bold()

                VStack(spacing: 16) {
                    NavigationLink(destination: ArticleView(articleNumber: 1)) {
                        Text("Article 1")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    NavigationLink(destination: ArticleView(articleNumber: 2)) {
                        Text("Article 2")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                    NavigationLink(destination: ArticleView(articleNumber: 3)) {
                        Text("Article 3")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Demo Homepage")
        }
    }
}

struct ArticleView: View {
    let articleNumber: Int
    var body: some View {
        VStack(spacing: 24) {
            Text("Article \(articleNumber)")
                .font(.largeTitle)
                .bold()
            Text("Filler text for Article \(articleNumber). Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                .padding()
            Spacer()
        }
        .navigationTitle("Article \(articleNumber)")
        .padding()
    }
}
