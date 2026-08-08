# Runtime Engine & Virtual Filesystem

The core execution environment in **SynapseSandbox** is powered by `SandboxEngine` in conjunction with `SandboxURLSchemeHandler` and `SandboxScriptBridge`. This document explains how virtual files are routed, how JavaScript is evaluated, and how events are streamed.

---

## 📂 The In-Memory Virtual Filesystem

### Structure of `SandboxWorkspace`
A `SandboxWorkspace` represents a self-contained web project stored entirely in memory. It contains:
* An array of `SandboxFile` items.
* An `entryPointPath` (defaults to `"index.html"`).
* Metadata key-value pairs.
* Timestamps (`createdAt`, `lastModified`).

```swift
public struct SandboxWorkspace: Identifiable, Sendable, Codable, Hashable, Equatable {
    public let id: UUID
    public var name: String
    public var files: [SandboxFile]
    public var entryPointPath: String
    public var metadata: [String: String]
    public var createdAt: Date
    public var lastModified: Date
}
```

### File Resolution and Normalization
When a URL request is made to `sandbox://app/src/components/chart.js`, the path is normalized:
1. Strip leading slashes (`"/src/components/chart.js"` $\rightarrow$ `"src/components/chart.js"`).
2. Look up the file in the workspace's `files` array.
3. Automatically determine the MIME type via `SandboxFile.inferMimeType(from:)` or the explicit file metadata.
4. Compute or verify the SHA-256 checksum.

---

## 🌐 Custom URL Scheme Handler (`sandbox://`)

Traditional web views accessing local disk files via `file://` face several security challenges:
* File path traversal attacks (`../../etc/passwd` or accessing host app documents).
* Inability to enforce fine-grained CORS per virtual project.
* Temporary file cleanup failures leaving residual unencrypted data on flash storage.

`SandboxURLSchemeHandler` solves this by handling the custom scheme `sandbox`:

```
Web View Request: GET sandbox://app/index.html
                 |
                 v
      SandboxURLSchemeHandler
                 |
  +--------------+--------------+
  |                             |
  v                             v
File exists in memory       File not found
  |                             |
  v                             v
HTTP 200 OK + MIME Headers   HTTP 404 Not Found
Data streamed to WebKit      Error response
```

### MIME Type Mapping
`SandboxFile` automatically maps common extensions to appropriate MIME types:
* `.html`, `.htm` $\rightarrow$ `text/html; charset=utf-8`
* `.css` $\rightarrow$ `text/css; charset=utf-8`
* `.js`, `.mjs` $\rightarrow$ `application/javascript; charset=utf-8`
* `.json` $\rightarrow$ `application/json; charset=utf-8`
* `.wasm` $\rightarrow$ `application/wasm`
* `.svg`, `.png`, `.jpg`, `.webp` $\rightarrow$ Appropriate image format
* `.woff2`, `.woff`, `.ttf` $\rightarrow$ Font format

---

## ⚡ The `SandboxEngine` Actor

`SandboxEngine` is the thread-safe coordinator for a single running sandbox instance:

```swift
public actor SandboxEngine {
    private var workspace: SandboxWorkspace
    nonisolated public let configuration: SandboxConfiguration
    nonisolated public let eventStream: AsyncStream<SandboxEvent>
    
    // Core capabilities:
    public func evaluateScript(_ script: String) async throws -> String
    public func applyCSSPatch(_ css: String) async throws -> String
    public func applyDOMPatch(selector: String, html: String, mode: DOMPatcher.PatchMode) async throws -> String
    public func applyJSPatch(_ jsCode: String) async throws -> String
    public func registerTool(_ tool: any SandboxAgentTool)
    public func handleIncomingJSON(_ jsonString: String) async
}
```

### JavaScript Evaluation Pipeline
When the UI layer (macOS `NSViewRepresentable` or iOS `UIViewRepresentable`) creates the `WKWebView`, it binds a JS evaluator closure to the `SandboxEngine`:

```swift
await engine.bindEvaluator { script in
    guard let webView = webView else { throw SandboxError.engineDeallocated }
    let result = try await webView.evaluateJavaScript(script)
    return String(describing: result ?? "")
}
```

This decoupling allows:
* The host UI layer to stay lightweight and platform-specific.
* The `SandboxEngine` to remain pure Swift actor code that can be tested in isolation or manipulated by background tasks.

---

## 📡 Event Streaming & IPC Bridge

When the web application boots, `SandboxScriptBridge.generateBootstrapScript()` injects a client-side bridge object:

```javascript
window.SwiftSandboxBridge = {
    postMessage: function(msg) {
        window.webkit.messageHandlers.SwiftSandboxBridge.postMessage(msg);
    }
};
```

It also overrides `console.log`, `console.warn`, `console.error`, and `window.onerror` to capture runtime diagnostic logs and stream them to the native host as `SandboxEvent` entries:

```swift
for await event in engine.eventStream {
    switch event {
    case .consoleLog(let level, let message, let timestamp):
        print("[\(level)] \(message)")
    case .uncaughtError(let message, let stack):
        print("JS Exception: \(message)")
    case .toolCall(let id, let toolName, let args):
        print("Tool invoked: \(toolName)")
    case .domMutation(let summary, let selector, _):
        print("DOM Changed at \(selector ?? "*")")
    case .lifecycle(let state):
        print("Sandbox state: \(state)")
    case .customMessage(let name, let payload):
        print("Message '\(name)': \(payload)")
    }
}
```
