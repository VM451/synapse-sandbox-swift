# SwiftSandboxKit (Project Hyperion)

> **Cross-Platform Embedded Web Sandbox & AI Agent Framework for Apple Platforms**  
> Pure Swift 6.0+ with Strict Concurrency. Zero 3rd-Party Dependencies. Built on native Apple Frameworks (WebKit, CloudKit, SwiftUI, Combine, CryptoKit).

---

## Key Architectural Pillars

- **Local-First & Offline Architecture**: Zero external server dependencies. All web assets (HTML5, JS, CSS, WebAssembly, WebGPU) and state run directly on the local Apple device.
- **First-Class AI Agentic Integration**: Native Swift protocols exposing DOM AST manipulation, token-pruned semantic Markdown snapshots, real-time console streaming, and bidirectional tool calling directly to local AI agents (Apple Foundation Models, Local LLMs, On-Device Transformers).
- **CloudKit Private Sync Engine**: Out-of-the-box CRDT-based cross-device synchronization (Last-Write-Wins and text delta merging) utilizing the user's private iCloud database.
- **Platform-Native Spatial & Desktop UX**: Native SwiftUI primitives with deep platform adaptations (spatial windows & 3D volumetric attachments in visionOS, desktop multi-windowing & Safari Web Inspector in macOS, fluid gestures in iOS).
- **Zero-Trust Security Perimeter**: Custom URL scheme (`sandbox://app/`), strict Content Security Policy (CSP) enforcement, memory watchdog limit (256MB), and isolated context bridges.

---

## Platform Compatibility

| Platform | Minimum OS Version | Recommended | Features Supported |
| :--- | :--- | :--- | :--- |
| **iOS / iPadOS** | iOS 18.0+ | iOS 18.2+ | Full Engine, WebAssembly, CloudKit Sync, Agent Bridge |
| **macOS** | macOS 15.0 (Sequoia)+ | macOS 15.2+ | Multi-Instance Sandboxing, WebGPU, Safari Web Inspector, CLI Tools |
| **visionOS** | visionOS 2.0+ | visionOS 2.2+ | Spatial Canvas UI, Glass Background, Hover Effects |
| **watchOS** | watchOS 11.0+ | watchOS 11.0+ | Lightweight State Viewer & CloudKit Trigger (No WebKit Rendering) |
| **tvOS** | tvOS 18.0+ | tvOS 18.2+ | Full Sandbox Engine & Native View |

---

## Architecture Topology

```
[ Native Swift Application Layer ]
            |
            v
+--------------------------------------------------------------------------+
|                            SwiftSandboxKit Core                          |
|                                                                          |
|  +----------------------+  IPC RPC  +---------------------------------+  |
|  |    SandboxManager    |<--------->|          AgenticBridge          |  |
|  |   (SandboxEngine)    |           |    (Foundation Model Interop)   |  |
|  +----------------------+           +---------------------------------+  |
|             |                                       |                    |
|             v                                       v                    |
|  +----------------------+               +-----------------------------+  |
|  |   WebKit Environment |               |    CloudKitSyncEngine       |  |
|  | (Custom Scheme/WASM) |               |   (Private CKDatabase Engine)|  |
|  +----------------------+               +-----------------------------+  |
+--------------------------------------------------------------------------+
```

---

## Installation via Swift Package Manager

Add `SwiftSandboxKit` to your `Package.swift` manifest:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v18), .macOS(.v15), .visionOS(.v2)],
    dependencies: [
        .package(path: "../SwiftSandboxKit")
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: ["SwiftSandboxKit"]
        )
    ]
)
```

---

## Quick Start Guide

### 1. Declarative SwiftUI Sandbox

```swift
import SwiftUI
import SwiftSandboxKit

struct MiniAppRunnerView: View {
    @State private var workspace = SandboxWorkspace(
        name: "Interactive AI Chart",
        files: [
            SandboxFile(
                path: "index.html",
                text: """
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body { font-family: -apple-system; padding: 24px; background: #f0f0f5; }
                        h1 { color: #007AFF; }
                    </style>
                </head>
                <body>
                    <h1 id="title">Hello from SwiftSandboxKit!</h1>
                    <button onclick="notifySwift()">Call Native Swift Tool</button>
                    <script>
                        function notifySwift() {
                            window.SwiftSandboxBridge.postMessage({
                                id: crypto.randomUUID(),
                                type: 'TOOL_CALL',
                                payload: { toolName: 'UserActionLogger', arguments: { action: 'button_click' } },
                                timestamp: Date.now()
                            });
                        }
                    </script>
                </body>
                </html>
                """
            )
        ]
    )
    
    var body: some View {
        SandboxView(workspace: workspace, configuration: .default)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

---

### 2. Apple AI Agent Interoperability & Semantic DOM Extraction

```swift
import SwiftSandboxKit

// 1. Initialize Engine & Agent Bridge
let engine = SandboxEngine(workspace: workspace)
let bridge = AgenticBridge(engine: engine)

// 2. Register native tools callable from JavaScript or Local LLM
await bridge.registerTool(
    ClosureAgentTool(
        name: "Calculator",
        description: "Evaluates mathematical expressions safely",
        parametersSchemaJSON: "{\"type\":\"object\",\"properties\":{\"expression\":{\"type\":\"string\"}}}"
    ) { argumentsJSON in
        return "{\"result\": 42}"
    }
)

// 3. Extract token-pruned semantic Markdown DOM for Foundation Model Context Windows
let semanticMarkdown = try await bridge.captureSemanticDOM(maxTokens: 4096)
print(semanticMarkdown)
// Output:
// <[div] #container>
//   <[h1]>
//     - "Hello from SwiftSandboxKit!"
//   <[button]>
//     - "Call Native Swift Tool"

// 4. Apply live differential code patches generated by the AI model
let patchResult = try await bridge.applyAgentCodePatch(
    jsDelta: "document.getElementById('title').textContent = 'AI Patched Title!';",
    cssDelta: "h1 { color: #34C759; }"
)
print("Patch executed in \(patchResult.executionTimeMs) ms, success: \(patchResult.isSuccess)")
```

---

### 3. Private CloudKit CRDT Synchronization

```swift
import SwiftSandboxKit

let syncEngine = CloudKitSyncEngine(containerIdentifier: "iCloud.com.example.myapp")

// Initialize private record zone
try await syncEngine.setupZone()

// Upload delta updates with automatic CRDT conflict resolution
try await syncEngine.syncWorkspace(workspace)

// Fetch latest remote changes
if let remoteWorkspace = try await syncEngine.fetchLatestWorkspace(id: workspace.id) {
    print("Fetched synchronized workspace: \(remoteWorkspace.name)")
}
```

---

## Security Perimeter & Threat Model

1. **In-Memory Scheme Sandboxing (`sandbox://app/`)**: WebKit is strictly forbidden from accessing local filesystem `file://` URIs.
2. **Strict Content Security Policy (CSP)**: Default CSP blocks unauthorized external HTTP/HTTPS connections and frame nesting.
3. **Memory Watchdog**: Enforces a 256MB maximum memory threshold to prevent WebKit runaway crashes.
4. **Swift 6 Strict Concurrency**: Every actor and struct guarantees complete thread isolation with zero data races.

---

## License

MIT License. Copyright (c) 2026. Project Hyperion.
