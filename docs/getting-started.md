# Getting Started with SynapseSandbox

This guide walks you through installing **SynapseSandbox** via Swift Package Manager and rendering your first sandboxed mini web application in a native SwiftUI interface in under 5 minutes.

---

## 📋 System Requirements

| Requirement | Specification |
| :--- | :--- |
| **Swift Toolchain** | Swift 6.0+ (Xcode 16.0+ or Command Line Tools) |
| **Concurrency Mode** | Swift 6 Strict Concurrency (`-swift-version 6`) |
| **iOS / iPadOS** | iOS 27.0+ / iPadOS 27.0+ |
| **macOS** | macOS 27.0+ (Apple Silicon recommended) |
| **visionOS** | visionOS 27.0+ |
| **watchOS** | watchOS 27.0+ (State & CloudKit trigger only) |
| **tvOS** | tvOS 27.0+ (Full engine supported) |
| **External Dependencies** | **Zero** (100% native Apple SDKs) |

---

## 📦 Installation via Swift Package Manager (SPM)

### Option 1: Using `Package.swift`

Add `synapse-sandbox-swift` to your dependencies list:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyNativeAIApp",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
        .visionOS("27.0")
    ],
    dependencies: [
        .package(url: "https://github.com/VM451/synapse-sandbox-swift.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyNativeAIApp",
            dependencies: [
                .product(name: "SynapseSandbox", package: "synapse-sandbox-swift")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
```

### Option 2: Using Xcode UI
1. Open your project in Xcode.
2. Navigate to **File > Add Package Dependencies...**
3. Paste the repository URL: `https://github.com/VM451/synapse-sandbox-swift.git`
4. Select **Exact Version** or **Up to Next Major** `1.0.0`.
5. Add `SynapseSandbox` to your application target.

---

## 🚀 5-Minute Quickstart

### 1. Create a Workspace
A `SandboxWorkspace` holds your virtual files (HTML, CSS, JavaScript, WebAssembly, assets) completely in memory:

```swift
import SwiftUI
import SynapseSandbox

struct MySandboxedView: View {
    // 1. Create an in-memory workspace with standard starter template
    @State private var workspace = SandboxWorkspace.defaultTemplate(name: "My First AI Sandbox")

    var body: some View {
        VStack {
            // 2. Embed the multi-platform sandbox view
            SynapseSandboxView(
                workspace: workspace,
                configuration: .default
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
```

### 2. Loading Custom HTML, CSS & JavaScript
You can create a workspace from individual files or a dictionary map:

```swift
import SynapseSandbox

func createCustomWorkspace() -> SandboxWorkspace {
    let htmlContent = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <div class="container">
            <h1 id="heading">Hello from SynapseSandbox</h1>
            <p>Executed locally with zero server requirements.</p>
            <button onclick="pingNativeHost()">Click Me</button>
        </div>
        <script src="app.js"></script>
    </body>
    </html>
    """

    let cssContent = """
    body {
        margin: 0;
        font-family: -apple-system, sans-serif;
        background: #000;
        color: #fff;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
    }
    .container {
        text-align: center;
        background: #1c1c1e;
        padding: 32px;
        border-radius: 16px;
    }
    button {
        background: #007AFF;
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        font-size: 16px;
        cursor: pointer;
    }
    """

    let jsContent = """
    function pingNativeHost() {
        console.log("Button clicked inside sandbox!");
        if (window.SwiftSandboxBridge) {
            window.SwiftSandboxBridge.postMessage({
                id: crypto.randomUUID(),
                type: 'CUSTOM_MESSAGE',
                name: 'UserAction',
                payload: 'Button was tapped'
            });
        }
    }
    """

    return SandboxWorkspace(
        name: "Custom Application",
        files: [
            SandboxFile(path: "index.html", text: htmlContent),
            SandboxFile(path: "style.css", text: cssContent),
            SandboxFile(path: "app.js", text: jsContent)
        ],
        entryPointPath: "index.html"
    )
}
```

### 3. Choosing a Security Configuration Preset

SynapseSandbox comes with predefined configurations tailored for different security needs:

```swift
// Default Configuration (Offline, WebAssembly enabled, WebGPU enabled, 256MB RAM cap)
let defaultConfig = SandboxConfiguration.default

// High-Security Configuration (Zero network, WebGPU disabled, 128MB RAM cap, strict CSP)
let secureConfig = SandboxConfiguration.secure

// Developer Configuration (Safari Web Inspector enabled, live developer overlay visible)
let devConfig = SandboxConfiguration.developer
```

---

## 🎯 Next Steps

Now that your first sandbox is up and running, explore the specialized guides:
* [Connect Local LLMs & Apple Intelligence](guides/ai-agent-llm-integration.md)
* [Expose Swift Tools to JavaScript via RPC](guides/tool-calling-rpc.md)
* [Set up Cross-Device Private CloudKit Sync](guides/cloudkit-sync-crdt.md)
* [Explore the Architecture Overview](architecture/overview.md)
