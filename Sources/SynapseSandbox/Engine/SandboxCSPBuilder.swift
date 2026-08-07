import Foundation

/// Generates strict Content Security Policy (CSP) directives tailored to the sandbox runtime isolation model.
public enum SandboxCSPBuilder: Sendable {
    
    /// Builds the standard CSP directive header based on configuration.
    public static func buildPolicy(configuration: SandboxConfiguration) -> String {
        if let custom = configuration.customCSP {
            return custom
        }
        
        var connectSrc = "'self' sandbox: data: blob:"
        var imgSrc = "'self' sandbox: data: blob:"
        if configuration.allowNetworkAccess {
            connectSrc += " https: wss:"
            imgSrc += " https:"
        }
        
        var scriptSrc = "'self' sandbox: 'unsafe-inline' 'unsafe-eval' blob:"
        if configuration.enableWebAssembly {
            scriptSrc += " 'wasm-unsafe-eval'"
        }
        
        let directives = [
            "default-src 'self' sandbox: data: blob: 'unsafe-inline' 'unsafe-eval'",
            "script-src \(scriptSrc)",
            "style-src 'self' sandbox: data: blob: 'unsafe-inline'",
            "img-src \(imgSrc)",
            "connect-src \(connectSrc)",
            "font-src 'self' sandbox: data: blob:",
            "media-src 'self' sandbox: data: blob:",
            "object-src 'none'",
            "frame-src 'none'",
            "base-uri 'self' sandbox:",
            "form-action 'none'"
        ]
        
        return directives.joined(separator: "; ")
    }
    
    /// Injects a `<meta http-equiv="Content-Security-Policy">` tag into the `<head>` of an HTML document if not present.
    public static func injectCSP(into html: String, configuration: SandboxConfiguration) -> String {
        let policy = buildPolicy(configuration: configuration)
        let metaTag = "<meta http-equiv=\"Content-Security-Policy\" content=\"\(policy)\">"
        
        // If already contains Content-Security-Policy meta tag, do not double inject
        if html.lowercased().contains("http-equiv=\"content-security-policy\"") ||
            html.lowercased().contains("http-equiv='content-security-policy'") {
            return html
        }
        
        if let headRange = html.range(of: "<head>", options: .caseInsensitive) {
            var mutated = html
            mutated.insert(contentsOf: "\n    " + metaTag, at: headRange.upperBound)
            return mutated
        } else if let htmlRange = html.range(of: "<html>", options: .caseInsensitive) {
            var mutated = html
            mutated.insert(contentsOf: "\n<head>\n    \(metaTag)\n</head>", at: htmlRange.upperBound)
            return mutated
        } else {
            return "<head>\n    \(metaTag)\n</head>\n" + html
        }
    }
}
