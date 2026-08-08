# Engine Module API Reference

The `Engine` module manages the runtime lifecycle, JavaScript context evaluation, custom URL scheme handling, Content Security Policy construction, and differential DOM/CSS patching.

---

## 🗂 Types & Actors

### `SandboxEngine`
The primary thread-safe actor managing a running sandbox instance.

```swift
public actor SandboxEngine {
    nonisolated public let configuration: SandboxConfiguration
    nonisolated public let eventStream: AsyncStream<SandboxEvent>
    
    public init(workspace: SandboxWorkspace, configuration: SandboxConfiguration = .default)
    
    // Workspace Management
    public func getWorkspace() -> SandboxWorkspace
    public func updateWorkspace(_ newWorkspace: SandboxWorkspace)
    public func updateFile(_ file: SandboxFile)
    
    // Evaluator Binding
    public func bindEvaluator(_ evaluator: @escaping @MainActor @Sendable (String) async throws -> String)
    public func unbindEvaluator()
    
    // Tool Registration & Query
    public func registerTool(_ tool: any SandboxAgentTool)
    public func removeTool(named name: String)
    public func getRegisteredToolNames() -> [String]
    public func getTool(named name: String) -> (any SandboxAgentTool)?
    
    // Script Evaluation & Patching
    public func evaluateScript(_ script: String) async throws -> String
    public func dispatchFunctionCall(name: String, args: [String]) async throws -> String
    public func applyCSSPatch(_ css: String) async throws -> String
    public func applyDOMPatch(selector: String, html: String, mode: DOMPatcher.PatchMode = .outerHTML) async throws -> String
    public func applyJSPatch(_ jsCode: String) async throws -> String
    
    // Incoming Message Processing
    public func handleIncomingJSON(_ jsonString: String) async
    public func emitEvent(_ event: SandboxEvent)
}
```

---

### `DOMPatcher`
Utility subsystem for generating high-performance JavaScript diff patches.

```swift
public enum DOMPatcher: Sendable {
    public enum PatchMode: Sendable {
        case innerHTML
        case outerHTML
    }
    
    public static func generateCSSPatchScript(css: String, styleTagID: String = "sandbox-dynamic-styles") -> String
    public static func generateSubtreePatchScript(selector: String, newHTML: String, mode: PatchMode = .outerHTML) -> String
    public static func generateJSPatchScript(jsCode: String) -> String
}
```

---

### `SandboxURLSchemeHandler`
`WKURLSchemeHandler` implementation serving virtual files from memory under `sandbox://app/`.

```swift
#if canImport(WebKit)
import WebKit

public final class SandboxURLSchemeHandler: NSObject, WKURLSchemeHandler, @unchecked Sendable {
    public static let scheme = "sandbox"
    
    public init(workspaceProvider: @escaping @Sendable () -> SandboxWorkspace)
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask)
    public func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask)
}
#endif
```

---

### `SandboxCSPBuilder`
Generates RFC-compliant Content Security Policy headers based on `SandboxConfiguration`.

```swift
public enum SandboxCSPBuilder: Sendable {
    public static func buildPolicy(for configuration: SandboxConfiguration) -> String
}
```

---

### `SandboxScriptBridge`
Generates the JavaScript bootstrap and console interception script injected into WebKit at document start.

```swift
public enum SandboxScriptBridge: Sendable {
    public static let handlerName = "SwiftSandboxBridge"
    public static func generateBootstrapScript() -> String
}
```
