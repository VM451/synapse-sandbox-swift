# SwiftUI Integration Guide

This guide demonstrates how to embed, style, and interact with `SynapseSandboxView` (and its convenience alias `SandboxView`) in modern SwiftUI applications across iOS, iPadOS, macOS, visionOS, and tvOS.

---

## 📱 Basic Embedding

Embed a sandbox view anywhere in your SwiftUI view hierarchy:

```swift
import SwiftUI
import SynapseSandbox

struct SimpleSandboxScreen: View {
    @State private var workspace = SandboxWorkspace.defaultTemplate(name: "AI Dashboard")
    
    var body: some View {
        SynapseSandboxView(
            workspace: workspace,
            configuration: .default
        )
        .frame(minWidth: 400, minHeight: 300)
    }
}
```

---

## ⚙️ Customizing the Sandbox Configuration

You can customize styling tokens, security boundaries, and developer tools using `SandboxConfiguration`:

```swift
import SwiftUI
import SynapseSandbox

struct CustomConfiguredSandbox: View {
    @State private var workspace: SandboxWorkspace
    
    private var config: SandboxConfiguration {
        SandboxConfiguration(
            allowNetworkAccess: false,      // Zero-trust offline isolation
            enableWebAssembly: true,       // Enable .wasm binary execution
            enableWebGPU: true,            // Enable Metal/WebGPU acceleration
            cornerRadius: 16.0,            // Native SwiftUI clipping radius
            maxMemoryMB: 128,              // Watchdog RAM limit
            developerModeEnabled: true,    // Show live developer overlay
            isInspectable: true            // Safari Web Inspector support
        )
    }
    
    init() {
        _workspace = State(initialValue: SandboxWorkspace.defaultTemplate(name: "Custom Studio"))
    }
    
    var body: some View {
        SynapseSandboxView(workspace: workspace, configuration: config)
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}
```

---

## 🕹 Accessing the `SandboxViewController`

When you need direct programmatic control over loading states, event logs, and the underlying `SandboxEngine`, you can instantiate and observe `SandboxViewController`:

```swift
import SwiftUI
import SynapseSandbox

struct AdvancedSandboxControllerView: View {
    @StateObject private var controller: SandboxViewController
    
    init(workspace: SandboxWorkspace) {
        _controller = StateObject(
            wrappedValue: SandboxViewController(
                workspace: workspace,
                configuration: .developer
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text(controller.workspace.name)
                    .font(.headline)
                
                Spacer()
                
                if controller.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Live")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            // Native WebKit Representable
            #if os(iOS) || os(visionOS)
            NativeSandboxRepresentable(controller: controller)
            #elseif os(macOS)
            NativeSandboxRepresentable(controller: controller)
            #endif
            
            // Event Log Drawer
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(controller.logs.indices, id: \.self) { idx in
                        Text(controller.logs[idx].summary)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
            }
            .frame(height: 120)
            .background(Color.black.opacity(0.8))
        }
        .task {
            await controller.bootstrap()
        }
    }
}
```

---

## 👓 visionOS Spatial Styling

On visionOS 27+, `SynapseSandboxView` automatically applies `.glassBackgroundEffect()` and `.hoverEffect()`. You can enhance the spatial presentation using native window modifiers:

```swift
#if os(visionOS)
import SwiftUI
import SynapseSandbox

struct SpatialCanvasWindow: View {
    @State private var workspace = SandboxWorkspace.defaultTemplate(name: "Spatial 3D Chart")
    
    var body: some View {
        SynapseSandboxView(workspace: workspace)
            .glassBackgroundEffect()
            .hoverEffect()
            .frame(width: 800, height: 600)
    }
}
#endif
```

---

## 🪟 macOS Multi-Window & Context Menus

On macOS, you can bind multiple sandboxes into native windows or split views:

```swift
#if os(macOS)
import SwiftUI
import SynapseSandbox

struct MacDeveloperSplitView: View {
    @State private var leftWorkspace = SandboxWorkspace.defaultTemplate(name: "Editor")
    @State private var rightWorkspace = SandboxWorkspace.defaultTemplate(name: "Preview")
    
    var body: some View {
        HSplitView {
            SynapseSandboxView(workspace: leftWorkspace)
                .frame(minWidth: 300)
            
            SynapseSandboxView(workspace: rightWorkspace)
                .frame(minWidth: 300)
        }
    }
}
#endif
```
