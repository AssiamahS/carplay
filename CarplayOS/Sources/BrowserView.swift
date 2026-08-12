import SwiftUI
import WebKit

struct BrowserView: View {
    @State private var model = BrowserModel()
    @State private var addressText = ""
    @FocusState private var addressFocused: Bool

    private let quickLinks: [(String, String)] = [
        ("Google", "https://www.google.com"),
        ("YouTube", "https://m.youtube.com"),
        ("Maps", "https://maps.google.com"),
        ("Onn backend", "http://192.168.50.2"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                addressBar
                if model.currentURL == nil {
                    startPage
                } else {
                    WebContainer(model: model)
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("SlyBrowser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button { model.goBack() } label: { Image(systemName: "chevron.left") }
                        .disabled(!model.canGoBack)
                    Button { model.goForward() } label: { Image(systemName: "chevron.right") }
                        .disabled(!model.canGoForward)
                    Spacer()
                    Button { model.reload() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
        }
    }

    private var addressBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search or enter address", text: $addressText)
                .keyboardType(.webSearch)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($addressFocused)
                .onSubmit { submit() }
            if !addressText.isEmpty {
                Button {
                    addressText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: Capsule())
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var startPage: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                ForEach(quickLinks, id: \.1) { name, url in
                    Button {
                        addressText = url
                        submit()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: name == "Onn backend" ? "car.side" : "globe")
                                .font(.title2)
                            Text(name).font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func submit() {
        addressFocused = false
        model.load(addressText)
    }
}

@Observable
@MainActor
final class BrowserModel {
    var currentURL: URL?
    var canGoBack = false
    var canGoForward = false

    let webView: WKWebView

    init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
    }

    func load(_ input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let urlString: String
        if trimmed.contains("://") {
            urlString = trimmed
        } else if trimmed.contains(".") && !trimmed.contains(" ") {
            urlString = "https://\(trimmed)"
        } else {
            let q = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
            urlString = "https://www.google.com/search?q=\(q)"
        }
        guard let url = URL(string: urlString) else { return }
        currentURL = url
        webView.load(URLRequest(url: url))
    }

    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func reload() { webView.reload() }

    func syncNavState() {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }
}

struct WebContainer: UIViewRepresentable {
    let model: BrowserModel

    func makeCoordinator() -> Coordinator { Coordinator(model: model) }

    func makeUIView(context: Context) -> WKWebView {
        model.webView.navigationDelegate = context.coordinator
        return model.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        let model: BrowserModel
        init(model: BrowserModel) { self.model = model }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            model.syncNavState()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            model.syncNavState()
        }
    }
}
