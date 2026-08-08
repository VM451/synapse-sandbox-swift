# WebAssembly (.wasm) & Isolated Compute Guide

This guide demonstrates how to load, configure, and execute isolated WebAssembly (`.wasm`) modules inside **SynapseSandbox**.

---

## 🚀 Why WebAssembly in SynapseSandbox?

WebAssembly enables near-native computational performance inside the sandbox:
* Image and video processing filters (e.g. OpenCV / Canvas filters).
* Local SQLite engines compiled to WASM (e.g. sql.js).
* Cryptographic routines, tokenizers, and physics engines.
* Zero access to the host filesystem or system calls.

---

## 📦 Step 1: Loading a `.wasm` Binary File

Load the raw `.wasm` binary into a `SandboxFile` and add it to your `SandboxWorkspace`:

```swift
import Foundation
import SynapseSandbox

func createWasmWorkspace(wasmBinaryURL: URL) throws -> SandboxWorkspace {
    let wasmData = try Data(contentsOf: wasmBinaryURL)
    
    let wasmFile = SandboxFile(
        path: "compute.wasm",
        data: wasmData,
        mimeType: "application/wasm"
    )
    
    let htmlContent = """
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"></head>
    <body>
        <h1>WebAssembly Runner</h1>
        <div id="output">Loading module...</div>
        <script>
            async function initWasm() {
                try {
                    const response = await fetch('sandbox://app/compute.wasm');
                    const bytes = await response.arrayBuffer();
                    const { instance } = await WebAssembly.instantiate(bytes);
                    
                    // Call exported WASM function (e.g. add(a, b))
                    const sum = instance.exports.add(40, 2);
                    document.getElementById('output').textContent = 'Result from WASM: ' + sum;
                } catch (e) {
                    document.getElementById('output').textContent = 'WASM Error: ' + e.message;
                }
            }
            initWasm();
        </script>
    </body>
    </html>
    """
    
    let htmlFile = SandboxFile(path: "index.html", text: htmlContent)
    
    return SandboxWorkspace(
        name: "WASM Compute Engine",
        files: [htmlFile, wasmFile]
    )
}
```

---

## 🔒 Step 2: Configuring Content Security Policy for WASM

WebAssembly compilation in browser engines requires the `wasm-unsafe-eval` or `'unsafe-eval'` CSP directive. `SandboxConfiguration` automatically configures this when `enableWebAssembly` is `true`:

```swift
let config = SandboxConfiguration(
    allowNetworkAccess: false,      // Prevent WASM from exfiltrating data
    enableWebAssembly: true,       // Injects wasm-unsafe-eval
    maxMemoryMB: 256
)
```

---

## 📊 Step 3: Verifying Execution & Benchmarks

Once loaded, the WebAssembly module runs on Apple Silicon with native execution speed, benefiting from hardware acceleration.
