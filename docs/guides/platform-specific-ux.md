# Platform-Specific UX: visionOS Spatial Canvas & macOS Web Inspector

**SynapseSandbox** is built to adapt seamlessly to the unique capabilities of each Apple platform.

---

## 👓 1. visionOS Spatial Canvas & Volumetric Glass

On visionOS 27+, 2D web views can feel out of place unless integrated with native spatial depth and glass materials.

### Automatic Glass & Hover Modifiers
When compiled for visionOS, `SynapseSandboxView` automatically invokes:
```swift
#if os(visionOS)
.glassBackgroundEffect()
.hoverEffect()
#endif
```

### Custom Volumetric Window Configuration
Embed a sandbox in an immersive spatial window:

```swift
#if os(visionOS)
import SwiftUI
import SynapseSandbox

@main
struct SpatialSandboxApp: App {
    var body: some Scene {
        WindowGroup(id: "SpatialCanvas") {
            SynapseSandboxView(
                workspace: SandboxWorkspace.defaultTemplate(name: "Spatial Visualizer")
            )
            .frame(depth: 50)
            .glassBackgroundEffect(displayMode: .always)
        }
        .windowStyle(.volumetric)
    }
}
#endif
```

---

## 🖥 2. macOS Multi-Windowing & Safari Web Inspector

On macOS 27+, developers expect desktop-class debugging tools, multi-instance sandboxes, and context menus.

### Enabling Safari Web Inspector
Set `isInspectable: true` in your configuration:

```swift
let config = SandboxConfiguration(
    developerModeEnabled: true,
    isInspectable: true
)
```

1. Run your macOS application in Xcode.
2. Open **Safari** on your Mac.
3. Navigate to **Develop > [Your Mac Name] > [Your Application Target]**.
4. Select the `sandbox://app/index.html` page to open full Safari Developer Tools (DOM Tree, Console, Network, Performance Timeline).

### macOS AppKit Integration
On macOS, `NativeSandboxRepresentable` bridges into `NSViewRepresentable` and disables default opaque drawing backgrounds (`webView.setValue(false, forKey: "drawsBackground")`), allowing your SwiftUI backgrounds and materials to shine through.
