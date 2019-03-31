import WebKit

class WebViewController : UIViewController {
    
    @IBOutlet weak var rootView: UIView!
    private var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    public var url: URL!
    public var mimeType: MimeType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconClose"),
                                                 style: .plain, target: self, action: #selector(userClickDone))
        
        self.navigationItem.leftBarButtonItem = closeBarButtonItem
        
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem:.action, target: self, action: #selector(userClickShare))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem
        
        // Create WKWebView in code, because IB cannot add a WKWebView directly
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        rootView.addSubview(webView)
        
        // Auto layout the webview
        rootView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[webView]-0-|",
                                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                           metrics: nil,
                                                                           views: ["webView": webView]))
        rootView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webView]-0-|",
                                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                           metrics: nil,
                                                                           views: ["webView": webView]))
        
        let webViewKeyPathsToObserve = ["title", "estimatedProgress"]
        for keyPath in webViewKeyPathsToObserve {
            webView.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
        
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    @objc func userClickDone() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func userClickShare() {
        
        let linkToShare : [Any] = [url]
        
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceView = self.webView
            popoverController.sourceRect = CGRect(x: self.webView.bounds.midX, y: self.webView.bounds.midY, width: 0, height: 0)
        }
        self.present(activityController, animated: true, completion: nil)
    }
}

extension WebViewController : WKNavigationDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
            
            case "title":
                if let title = change?[NSKeyValueChangeKey.newKey] as? String {
                    self.navigationItem.title = title
                }
                return
            case "estimatedProgress":
                progressView.isHidden = webView.estimatedProgress == 1
                progressView.progress = Float(webView.estimatedProgress)
                return
            default:
                return
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
}
