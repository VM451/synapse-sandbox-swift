# Hot Reloading & Differential DOM/CSS Patching

This guide details how to use `DOMPatcher` and `SandboxEngine` to dynamically update styles, elements, and JavaScript scripts without losing running application state or triggering a full page reload.

---

## ⚡ Why Differential Patching?

When an AI Agent or developer makes a modification to a running web app:
* **Full Reload (`location.reload()`)**: Destroys in-memory form state, canvas animations, and WebGL buffers, introducing a 100-300ms flash.
* **Differential Patching (`DOMPatcher`)**: Updates only the targeted DOM node or style tag in **< 2 milliseconds**, preserving application runtime state completely.

---

## 🎨 1. Dynamic CSS Stylesheet Patching

`DOMPatcher.generateCSSPatchScript()` injects or replaces dynamic styles inside a dedicated `<style id="sandbox-dynamic-styles">` tag in the `<head>`:

```swift
import SynapseSandbox

// Apply new CSS theme on the fly
let cssDelta = """
:root {
    --accent-color: #FF2D55;
    --card-bg: #2C2C2E;
}
body {
    background-color: #000000;
    color: #FFFFFF;
}
.card {
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 8px 30px rgba(0,0,0,0.5);
}
"""

let resultJSON = try await engine.applyCSSPatch(cssDelta)
print("CSS Patch Result: \(resultJSON)")
```

---

## 🧩 2. Subtree DOM Patching

Replace specific elements or subtrees using CSS selectors:

### OuterHTML Replacement (Replaces the node and its attributes)
```swift
let updatedCardHTML = """
<div id="analytics-card" class="card updated">
    <h2>Real-Time Metrics</h2>
    <p>Live throughput: <strong>1.4 GB/s</strong></p>
</div>
"""

let patchResponse = try await engine.applyDOMPatch(
    selector: "#analytics-card",
    html: updatedCardHTML,
    mode: .outerHTML
)
```

### InnerHTML Replacement (Replaces only the contents inside the node)
```swift
let updatedInnerContent = """
<span class="badge success">Active</span>
<span>Last ping: 2ms ago</span>
"""

let innerResponse = try await engine.applyDOMPatch(
    selector: "#status-container",
    html: updatedInnerContent,
    mode: .innerHTML
)
```

---

## ⚡ 3. Differential JS Patching with Performance Timing

Execute arbitrary JS snippets and receive execution durations in milliseconds:

```swift
let jsSnippet = """
const chart = window.myActiveChart;
if (chart) {
    chart.data.datasets[0].data = [65, 59, 80, 81, 56, 55, 40];
    chart.update();
    return 'Chart updated successfully';
}
return 'Chart instance not found';
"""

let jsResult = try await engine.applyJSPatch(jsSnippet)
print("JS Execution Report: \(jsResult)")
// Output contains durationMs and serialized return value
```

---

## 🔄 4. Live Workspace Hot Reload

To replace the entire workspace while triggering a clean lifecycle reload:

```swift
var updatedWorkspace = engine.getWorkspace()
updatedWorkspace.upsertFile(SandboxFile(path: "index.html", text: newHTMLContent))

// Triggers lifecycle reload state and notifies all observers
await engine.updateWorkspace(updatedWorkspace)
```
