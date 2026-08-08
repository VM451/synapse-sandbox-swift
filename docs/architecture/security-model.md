# Security Model & Zero-Trust Perimeter

**SynapseSandbox** operates under a **Zero-Trust Security Perimeter** designed to ensure that untrusted HTML, CSS, JavaScript, and WebAssembly can never compromise the host Apple device, access local files, or leak private data.

---

## 🔒 The 4 Layers of Defense-in-Depth

```
+-----------------------------------------------------------------------------------+
| LAYER 1: IN-MEMORY SCHEME SANDBOXING (sandbox://app/ vs file://)                   |
| - Virtual filesystem served strictly via WKURLSchemeHandler in memory             |
| - WebKit is denied access to host device file paths, Documents, or Temp dirs     |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
| LAYER 2: CONTENT SECURITY POLICY (CSP) INJECTION                                  |
| - Injected at document start before any user scripts execute                      |
| - Default: 'self' sandbox: data: blob: 'unsafe-inline' 'unsafe-eval'              |
| - External network requests (fetch, XMLHttpRequest, WebSocket) blocked by default |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
| LAYER 3: ENGINE MEMORY WATCHDOG                                                   |
| - Host process monitors WebKit process memory footprint                          |
| - Default limit: 256MB (configurable)                                             |
| - Immediate graceful termination & event emission upon threshold breach           |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
| LAYER 4: SANITIZED IPC BRIDGE & RPC ISOLATION                                     |
| - Strict JSON validation on incoming window.SwiftSandboxBridge messages           |
| - Arbitrary Swift reflection / selector invocation blocked                        |
| - Native tools require explicit registration via SandboxAgentTool protocol       |
+-----------------------------------------------------------------------------------+
```

---

## 🛡 Layer 1: In-Memory URL Scheme Isolation

Traditional web view implementations load HTML bundles by writing files to `NSTemporaryDirectory()` and pointing the web view at `file:///tmp/app/index.html`. This creates critical vulnerabilities:
* **Local File Traversal**: JavaScript can fetch `file:///etc/passwd` or traverse directories to read private app databases.
* **Persistent Leaks**: Crashes can leave unencrypted HTML/JS files in local storage.

SynapseSandbox eliminates `file://` entirely. All requests are routed through `sandbox://app/`. If a script attempts to read outside the virtual workspace, the scheme handler immediately returns HTTP 404.

---

## 🛑 Layer 2: Content Security Policy (`SandboxCSPBuilder`)

Every HTML document rendered within the sandbox is protected by a dynamically generated Content Security Policy.

### Default Policy (`SandboxConfiguration.default`)
```http
Content-Security-Policy: default-src 'self' sandbox: data: blob: 'unsafe-inline' 'unsafe-eval'; connect-src 'none'; img-src 'self' sandbox: data: blob:;
```
* **Script Execution**: Allows in-memory scripts and eval for template rendering.
* **Network Access**: Fully disabled (`connect-src 'none'`). Fetch and XHR calls to outside servers fail immediately.
* **Frames**: Nested iframes are restricted to `sandbox:` origins.

### High-Security Preset (`SandboxConfiguration.secure`)
```http
Content-Security-Policy: default-src 'self' sandbox:; script-src 'self' sandbox:; connect-src 'none'; img-src 'self' sandbox: data:;
```
* Disables `'unsafe-eval'` and inline script evaluation.
* Eliminates remote data URLs for scripts.

---

## ⏱ Layer 3: Memory Watchdog

To prevent runaway JavaScript loops, memory leaks, or malicious WebAssembly allocation bombs, `SandboxConfiguration` enforces a strict memory watchdog:

* **Default Limit**: 256 MB.
* **Monitoring Interval**: 5 seconds.
* If memory usage crosses the limit, the engine triggers `SandboxError.memoryLimitExceeded(usedMB:limitMB:)`, suspends evaluation, and emits a diagnostic event to the UI and host application.

---

## 🔌 Layer 4: Sanitized IPC Bridge

The bridge between WebKit and Swift runs through `WKScriptMessageHandler` with strict type checking:

1. Only structured JSON payloads conforming to `type: "TOOL_CALL"`, `"CONSOLE"`, `"DOM_MUTATION"`, `"CUSTOM_MESSAGE"`, or `"UNCAUGHT_ERROR"` are processed.
2. Tool execution is restricted to instances explicitly registered with `SandboxEngine.registerTool()`.
3. Tool arguments are passed as raw JSON strings and validated against JSON Schemas, preventing native code injection.
