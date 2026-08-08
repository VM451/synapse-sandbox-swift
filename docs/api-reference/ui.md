# UI Module API Reference

The `UI` module provides SwiftUI components, view controllers, developer overlays, and platform bridges for iOS, iPadOS, macOS, visionOS, and tvOS.

---

## 🗂 Types & Views

### `SynapseSandboxView` (and `SandboxView`)
Declarative SwiftUI view that embeds a sandboxed mini web application with automatic platform adaptations.

```swift
public struct SynapseSandboxView: View {
    public init(workspace: SandboxWorkspace, configuration: SandboxConfiguration = .default)
    public var body: some View { get }
}

public typealias SandboxView = SynapseSandboxView
```

---

### `SandboxViewController`
`@MainActor` observable controller managing UI state, loading progress, event buffer absorption, and WebKit binding.

```swift
@MainActor
public final class SandboxViewController: ObservableObject {
    @Published public private(set) var isLoading: Bool
    @Published public private(set) var isReady: Bool
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var logs: [SandboxEvent]
    
    public let workspace: SandboxWorkspace
    public let configuration: SandboxConfiguration
    public let engine: SandboxEngine
    
    #if canImport(WebKit)
    public var webView: WKWebView?
    #endif
    
    public init(workspace: SandboxWorkspace, configuration: SandboxConfiguration = .default)
    public func bootstrap() async
    public func clearLogs()
}
```

---

### `SandboxDeveloperOverlay`
SwiftUI developer inspection drawer displaying real-time console logs, uncaught JavaScript errors, and lifecycle status.

```swift
public struct SandboxDeveloperOverlay: View {
    public init(controller: SandboxViewController)
    public var body: some View { get }
}
```

---

### `NativeSandboxRepresentable`
Platform bridge connecting SwiftUI to WebKit across iOS/visionOS (`UIViewRepresentable`) and macOS (`NSViewRepresentable`).

```swift
#if os(iOS) || os(visionOS)
public struct NativeSandboxRepresentable: UIViewRepresentable {
    public init(controller: SandboxViewController)
}
#elseif os(macOS)
public struct NativeSandboxRepresentable: NSViewRepresentable {
    public init(controller: SandboxViewController)
}
#endif
```
