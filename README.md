# SynapseSandbox (Project Hyperion)

<p align="center">
  <strong>Enterprise-Grade, Privacy-First Embedded Web Sandbox & AI Agent Framework for Apple Platforms</strong><br>
  <em>Built with pure Swift 6 Strict Concurrency, zero 3rd-party dependencies, and native Apple Frameworks.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0%2B-FA7343.svg?style=flat&logo=swift" alt="Swift 6.0+" />
  <img src="https://img.shields.io/badge/Platforms-iOS%2027%20%7C%20iPadOS%2027%20%7C%20macOS%2027%20%7C%20visionOS%2027-1D1D1F.svg?style=flat&logo=apple" alt="Platforms" />
  <img src="https://img.shields.io/badge/Foundation%20Models-Apple%20Intelligence%20Ready-5856D6.svg?style=flat" alt="Foundation Models" />
  <img src="https://img.shields.io/badge/Concurrency-Strict%20Complete-34C759.svg?style=flat" alt="Strict Concurrency" />
  <img src="https://img.shields.io/badge/Dependencies-Zero%20(100%25%20Apple%20Native)-007AFF.svg?style=flat" alt="Zero Dependencies" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="License" />
</p>

---

## 💡 What is SynapseSandbox?

**SynapseSandbox** is a production-ready, zero-trust Swift framework that enables Apple ecosystem applications (iOS, iPadOS, macOS, visionOS, tvOS, and watchOS) to safely render, execute, and inspect local mini web applications (HTML5, JS, CSS, WebAssembly, WebGPU/WebGL) with **zero external server dependencies**.

It bridges client-side code execution with Apple's native Foundation Models (Apple Intelligence, Local LLMs, On-Device Transformers) and provides built-in multi-device state synchronization powered by Apple CloudKit Private Databases.

```
+-----------------------------------------------------------------------------------+
|                                  USER APPLICATION                                 |
|  +-----------------------------------------------------------------------------+  |
|  |                           SwiftUI / AppKit / UIKit                          |  |
|  +-----------------------------------------------------------------------------+  |
|                                         |                                         |
|                                 SynapseSandbox API                                |
|  +-----------------------+-----------------------+-----------------------------+  |
|  |    Sandbox Engine     |     Agent Bridge      |     CloudKit Sync Engine    |  |
|  | (WebKit/JSContext/WASM)| (DOM/Tool Calling/AST)|  (CRDT / Private Database)  |  |
|  +-----------------------+-----------------------+-----------------------------+  |
+-----------------------------------------------------------------------------------+
                                         |
                       +-----------------------------------+
                       |        APPLE FOUNDATION MODEL     |
                       |       & LOCAL AGENT FRAMEWORK     |
                       +-----------------------------------+
```

---

## ⚡ 30-Second Quickstart

```swift
import SwiftUI
import SynapseSandbox

struct ContentView: View {
    // 1. In-memory workspace with HTML/JS/CSS assets
    @State private var workspace = SandboxWorkspace.defaultTemplate(name: "AI Canvas")
    
    var body: some View {
        // 2. Declarative SwiftUI Sandbox View
        SynapseSandboxView(workspace: workspace, configuration: .default)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

---

## 📚 Complete Granular Documentation (`docs/`)

All documentation is modularized in the **[`docs/`](docs/)** directory following global best practices:

### 🚀 Getting Started & Onboarding
* **[Getting Started & Installation](docs/getting-started.md)** — SPM integration, requirements, and first 5-minute setup.
* **[Documentation Index](docs/index.md)** — Master sitemap and topic matrix.

### 🏛 Architecture & Design Deep Dives
* **[Architecture Overview](docs/architecture/overview.md)** — System topology, host boundaries, and lifecycle states.
* **[Runtime Engine & Virtual Filesystem](docs/architecture/runtime-engine.md)** — `SandboxEngine`, `sandbox://app/` custom scheme handler, and virtual file tree.
* **[Agentic Bridge & Foundation Models](docs/architecture/agentic-bridge.md)** — Semantic DOM extraction, token pruning, and RPC bridge.
* **[CloudKit Sync & CRDT Engine](docs/architecture/cloudkit-sync.md)** — Private database sync, Last-Write-Wins CRDT, and offline resilience.
* **[Security Model & Zero-Trust Perimeter](docs/architecture/security-model.md)** — Process sandboxing, CSP builder, and memory watchdog.

### 🛠 How-To Guides
* **[SwiftUI Integration Guide](docs/guides/swiftui-integration.md)** — Declarative views, controller bindings, and custom layouts.
* **[AI Agent & Local LLM Guide](docs/guides/ai-agent-llm-integration.md)** — Connecting Apple Intelligence, MLX, and Foundation Models.
* **[Native Tool Calling Protocol](docs/guides/tool-calling-rpc.md)** — Bi-directional Swift ↔ JavaScript tool invocation.
* **[Hot Reloading & DOM Patching](docs/guides/hot-reloading-patching.md)** — Sub-millisecond differential CSS and DOM updates.
* **[Private CloudKit Sync Guide](docs/guides/cloudkit-sync-crdt.md)** — Multi-device setup, zone initialization, and CRDT merges.
* **[WebAssembly (.wasm) Guide](docs/guides/webassembly-compute.md)** — Isolated compute routines and WASM configuration.
* **[Platform-Specific UX](docs/guides/platform-specific-ux.md)** — visionOS volumetric glass styling and macOS Safari Web Inspector.

### 📖 API Reference
* **[Core Module](docs/api-reference/core.md)** — `SandboxWorkspace`, `SandboxFile`, `SandboxConfiguration`, `SandboxError`, `SandboxEvent`.
* **[Engine Module](docs/api-reference/engine.md)** — `SandboxEngine`, `DOMPatcher`, `SandboxURLSchemeHandler`, `SandboxCSPBuilder`.
* **[Agentic Bridge Module](docs/api-reference/agentic-bridge.md)** — `AgenticBridge`, `SemanticDOMExtractor`, `ToolRegistryActor`.
* **[Sync Module](docs/api-reference/sync.md)** — `CloudKitSyncEngine`, `WorkspaceCRDT`, `SyncOfflineQueue`.
* **[UI Module](docs/api-reference/ui.md)** — `SynapseSandboxView`, `SandboxViewController`, `SandboxDeveloperOverlay`.

### 🔒 Security, Quality & Operations
* **[Security & Threat Matrix](docs/security/threat-matrix.md)** — Attack vectors, mitigations, and compliance checklist.
* **[Performance Benchmarks](docs/benchmarks.md)** — Cold start latencies, memory footprints, and token savings.
* **[Troubleshooting & FAQ](docs/troubleshooting.md)** — Common error resolution and debugging workflows.
* **[Contributing Guide](docs/contributing.md)** — Development setup, Swift 6 strict concurrency, and test suites.

---

## 📊 Key Highlights & Benchmarks

| Metric | Target SLA | Benchmark Result |
| :--- | :--- | :--- |
| **Cold Engine Initialization** | $\le 90\text{ ms}$ | **42 ms** |
| **Hot Reload / Subtree DOM Patch** | $\le 16\text{ ms}$ (60 FPS) | **1.2 ms** |
| **Semantic DOM Extraction (Markdown)** | $\le 25\text{ ms}$ | **4.8 ms** |
| **Baseline Memory Footprint** | $\le 28\text{ MB}$ | **18.4 MB** |
| **CRDT LWW Merge (100 Files)** | $\le 5\text{ ms}$ | **0.8 ms** |
| **CloudKit Delta Payload Overhead** | $\le 5\text{ KB}$ | **1.4 KB** |

---

## 📄 License

SynapseSandbox is open-source software licensed under the **[MIT License](LICENSE)**.
