# Troubleshooting & FAQ

This guide answers common questions and helps resolve issues encountered when developing with **SynapseSandbox**.

---

## 🔍 Common Issues & Solutions

### 1. `SandboxError.entryPointMissing`
* **Cause**: The workspace does not contain a file matching `workspace.entryPointPath` (usually `"index.html"`).
* **Fix**: Ensure your `files` array contains a file with path `"index.html"` or update `entryPointPath` accordingly:
  ```swift
  workspace.entryPointPath = "main.html"
  ```

---

### 2. `SandboxError.cspViolation` or External Scripts Failing to Load
* **Cause**: By default, `allowNetworkAccess` is `false`, and CSP blocks remote scripts/fetch requests.
* **Fix**: If network requests are required for your use case, enable network access in `SandboxConfiguration`:
  ```swift
  let config = SandboxConfiguration(allowNetworkAccess: true)
  ```

---

### 3. Safari Web Inspector Not Showing Pages
* **Cause**: Inspectability might be disabled or developer mode is off.
* **Fix**: Ensure `isInspectable` is set to `true`:
  ```swift
  let config = SandboxConfiguration(isInspectable: true)
  ```
  On macOS, open **Safari > Settings > Advanced > Show features for web developers**.

---

### 4. CloudKit Permission / Zone Errors
* **Cause**: iCloud capability is not checked in Xcode or the user is not signed into iCloud on the device.
* **Fix**: 
  1. Verify the iCloud entitlement in your Xcode project.
  2. Verify that `setupZone()` is called before syncing.
  3. Ensure the test device or simulator is signed into an Apple Account.

---

### 5. `SandboxError.memoryLimitExceeded`
* **Cause**: The JavaScript or WebAssembly application allocated more RAM than allowed by `maxMemoryMB`.
* **Fix**: If your application legitimately requires more memory, raise the threshold:
  ```swift
  let config = SandboxConfiguration(maxMemoryMB: 512)
  ```

---

## ❓ Frequently Asked Questions (FAQ)

#### Q: Can I run Node.js or npm packages inside SynapseSandbox?
**A:** SynapseSandbox uses Apple's native WebKit engine. Client-side libraries (React, Vue, Svelte, Tailwind, Three.js, Chart.js, WASM) run seamlessly. Server-side Node.js C++ addons are not supported.

#### Q: Does SynapseSandbox write files to the user's disk?
**A:** No. All workspace files, HTML, and assets are served directly from RAM using `SandboxURLSchemeHandler` (`sandbox://app/`).
