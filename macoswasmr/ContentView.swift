import SwiftUI
import WebKit
import Combine
import Telegraph

// This is the model for the WebView (below)
class WebViewModel: ObservableObject {
  @Published var link: String
  @Published var didFinishLoading: Bool = false
  @Published var pageTitle: String
  
  init (link: String) {
    self.link = link
    self.pageTitle = ""
  }
}

public class InsertHeadersHandler: HTTPRequestHandler {
  public func respond(to request: HTTPRequest, nextHandler: HTTPRequest.Handler) throws -> HTTPResponse? {
    
    //  Let the other handlers create a response
    let response = try nextHandler(request)
    
    // Add our own bit of magic
    response?.headers["Cross-Origin-Embedder-Policy"] = "require-corp"
    response?.headers["Cross-Origin-Opener-Policy"] = "same-origin"
    response?.headers["Cross-Origin-Resource-Policy"] = "cross-origin"
    
    debugPrint("WEBR: \(response?.headers)")
    return response
    
  }
}

// I so hate boilerplate code in macOS apps
//
// This is the actual WebView that does the work where we'll load up the index.html for the REPL
// We'll use it in the SwiftUI view (below)
struct SwiftUIWebView: NSViewRepresentable {
  
  public typealias NSViewType = WKWebView
  @ObservedObject var viewModel: WebViewModel

  private let webView: WKWebView = WKWebView()
  
  public func makeNSView(context: NSViewRepresentableContext<SwiftUIWebView>) -> WKWebView {
    
//    telegraph.serveDirectory(Bundle.main.url(forAuxiliaryExecutable: "Resources")!)
    
    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator as? WKUIDelegate
    webView.load(URLRequest(url: URL(string: viewModel.link)!, cachePolicy: .reloadIgnoringLocalCacheData))
    return webView
  }
  
  public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<SwiftUIWebView>) { }
  
  public func makeCoordinator() -> Coordinator {
    return Coordinator(viewModel)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate {
    private var viewModel: WebViewModel
    
    init(_ viewModel: WebViewModel) {
      //Initialise the WebViewModel
      self.viewModel = viewModel
    }
    
    public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) { }
    
    public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) { }
    
    //After the webpage is loaded, assign the data in WebViewModel class
    public func webView(_ web: WKWebView, didFinish: WKNavigation!) {
      self.viewModel.pageTitle = web.title!
      if let url = web.url {
        self.viewModel.link = url.absoluteString
      }
      self.viewModel.didFinishLoading = true
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      decisionHandler(.allow)
    }
    
  }
  
}

// FINALLY
//
// This is what SwitfUI will put into the window
struct WebRWebView: View {
  @ObservedObject var model: WebViewModel
  
  init(mesgURL: String) {
    //Assign the url to the model and initialise the model
    self.model = WebViewModel(link: mesgURL)
  }
  
  var body: some View {
    //Create the WebView with the model
    SwiftUIWebView(viewModel: model)
  }
}


// We put up a Text view above the WebView
// to sort of prove it's running in an app for screenshots.
struct ContentView: View {
  
  private let telegraph = Server()
  
  var body: some View {
    VStack {
      Text("Local webR inside a macOS app and a custom WebView")
        .padding()
      WebRWebView(mesgURL: "http://localhost:9082/webr-demo.html")
//      WebRWebView(mesgURL: "http://localhost:9082/index.html")
    }.onAppear {
      
      telegraph.serveBundle(.main)
      telegraph.httpConfig.requestHandlers.insert(InsertHeadersHandler(), at: 0)
      telegraph.concurrency = 4
      
      do {
        try telegraph.start(port: 9082)
      } catch let error {
        print("Error starting server: \(error.localizedDescription)")
      }

    }
  }
  
}

