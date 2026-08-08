# AI Agent & Local LLM Integration Guide

This guide walks you through connecting on-device Foundation Models (Apple Intelligence, Local LLMs, MLX, CoreML Transformers, Ollama) directly to a live `SynapseSandbox` runtime using `AgenticBridge`.

---

## 🔗 Architecture Overview

```
+-----------------------------------------------------------------------------+
|                      ON-DEVICE FOUNDATION MODEL (LLM)                       |
|           (Apple Intelligence / MLX / Local Transformer / Ollama)           |
+-----------------------------------------------------------------------------+
               ^                                            |
               | Prompt with Semantic DOM                   | Returns Code Patch
               | (Markdown / JSON)                          | (JS / CSS Delta)
               |                                            v
+-----------------------------------------------------------------------------+
|                               AgenticBridge                                 |
|                                                                             |
|  - captureSemanticDOM(maxTokens:) ---------> Generates Compact Markdown    |
|  - applyAgentCodePatch(jsDelta:cssDelta:) -> Applies Live Diff & Timings    |
|  - getToolDefinitions() -------------------> Exposes JSON Schema Tools      |
+-----------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------+
|                            Live SandboxEngine                               |
|                  (WebKit / In-Memory Execution Context)                     |
+-----------------------------------------------------------------------------+
```

---

## 🛠 Step 1: Initialize Engine & Agent Bridge

Create the `SandboxEngine` and wrap it with `AgenticBridge`:

```swift
import SynapseSandbox

let workspace = SandboxWorkspace.defaultTemplate(name: "AI Agent Canvas")
let engine = SandboxEngine(workspace: workspace, configuration: .default)
let bridge = AgenticBridge(engine: engine)
```

---

## ✂️ Step 2: Extracting Token-Pruned Semantic DOM

When building your LLM prompt, raw HTML consumes too many tokens. Use `captureSemanticDOM()` to obtain a token-efficient Markdown structure:

```swift
// Capture semantic DOM within a 2048-token budget
let semanticDOM = try await bridge.captureSemanticDOM(maxTokens: 2048)

print("Semantic DOM for LLM:")
print(semanticDOM)
```

### Example Extracted Output:
```markdown
<[div] #container .app-layout>
  <[h1] #title>
    - "Financial Portfolio Analysis"
  <[table] #assets-table>
    <[tr] .row-header>
      <[th]> - "Asset"
      <[th]> - "Value"
    <[tr]>
      <[td]> - "Apple (AAPL)"
      <[td]> - "$242.50"
  <[button] #rebalance-btn role="button" aria-label="Rebalance Portfolio">
    - "Rebalance Now"
```

---

## 🩹 Step 3: Applying Agent Differential Code Patches

When the LLM decides to mutate the UI or update data, pass the generated JavaScript and CSS deltas to `applyAgentCodePatch()`:

```swift
let jsPatch = """
const title = document.getElementById('title');
if (title) {
    title.textContent = 'Portfolio Rebalanced by Apple Intelligence';
}

const table = document.getElementById('assets-table');
const newRow = document.createElement('tr');
newRow.innerHTML = '<td>Treasury Bills</td><td>$15,000.00</td>';
table.appendChild(newRow);
"""

let cssPatch = """
#title {
    color: #34C759;
    transition: color 0.3s ease;
}
.row-header {
    background-color: #2c2c2e;
}
"""

let result = try await bridge.applyAgentCodePatch(
    jsDelta: jsPatch,
    cssDelta: cssPatch
)

if result.isSuccess {
    print("✅ Patch applied successfully in \(result.executionTimeMs) ms!")
} else {
    print("❌ Patch failed: \(result.errorDescription ?? "Unknown error")")
}
```

---

## 🤖 Step 4: Complete Agentic Loop Example

Here is a full end-to-end loop connecting a local model client to the sandbox:

```swift
import Foundation
import SynapseSandbox

actor AIAgentCoordinator {
    let bridge: AgenticBridge
    
    init(engine: SandboxEngine) {
        self.bridge = AgenticBridge(engine: engine)
    }
    
    func runAutonomousImprovementCycle() async throws {
        // 1. Capture current DOM state
        let dom = try await bridge.captureSemanticDOM(maxTokens: 1500)
        
        // 2. Format prompt for local LLM
        let prompt = """
        You are an expert UI/UX developer. Below is the current DOM structure of a sandboxed app:
        
        \(dom)
        
        Task: Add a dark-mode toggle button and dark theme styling.
        Respond with valid JavaScript delta code to execute.
        """
        
        // 3. Call your on-device LLM (e.g. Apple Intelligence, MLX, Ollama)
        let generatedJS = "document.body.style.backgroundColor = '#121212'; document.body.style.color = '#FFFFFF';"
        
        // 4. Apply patch directly to the sandbox
        let patchResult = try await bridge.applyAgentCodePatch(jsDelta: generatedJS)
        print("Execution duration: \(patchResult.executionTimeMs) ms")
    }
}
```
