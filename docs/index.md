# SynapseSandbox Documentation

Welcome to the comprehensive documentation for **SynapseSandbox** (Project Hyperion) — an enterprise-grade, privacy-first Swift framework designed for Apple platforms (iOS, iPadOS, macOS, visionOS, tvOS, and watchOS) to safely render, execute, and inspect local mini web applications with zero external server dependencies.

---

## 📚 Documentation Structure

Our documentation follows the [Diátaxis framework](https://diataxis.fr/) to provide clear separation between learning, problem-solving, architectural understanding, and reference material.

```
docs/
├── getting-started.md              # 5-minute quickstart, SPM installation, requirements
├── architecture/                   # Conceptual & system design deep dives
│   ├── overview.md                 # System topology & runtime process model
│   ├── runtime-engine.md           # SandboxEngine, URLSchemeHandler & virtual filesystem
│   ├── agentic-bridge.md           # Semantic DOM, token pruning & tool calling RPC
│   ├── cloudkit-sync.md            # CloudKit private sync & CRDT merge mechanics
│   └── security-model.md           # Zero-trust perimeter, CSP & memory watchdog
├── guides/                         # Task-oriented, step-by-step how-to guides
│   ├── swiftui-integration.md      # Embedding SynapseSandboxView & state management
│   ├── ai-agent-llm-integration.md # Apple Intelligence, MLX & Foundation Model interop
│   ├── tool-calling-rpc.md         # Exposing Swift tools to JavaScript & LLMs
│   ├── hot-reloading-patching.md   # Live differential DOM/CSS patching
│   ├── cloudkit-sync-crdt.md       # Multi-device iCloud sync setup & conflict handling
│   ├── webassembly-compute.md      # Running isolated WebAssembly (.wasm) workloads
│   └── platform-specific-ux.md     # visionOS Spatial Canvas & macOS Safari Web Inspector
├── api-reference/                  # Exhaustive Swift 6 API signatures & types
│   ├── core.md                     # SandboxWorkspace, SandboxFile, SandboxConfiguration, etc.
│   ├── engine.md                   # SandboxEngine, DOMPatcher, SandboxCSPBuilder, etc.
│   ├── agentic-bridge.md           # AgenticBridge, SemanticDOMExtractor, ToolRegistryActor
│   ├── sync.md                     # CloudKitSyncEngine, WorkspaceCRDT, SyncOfflineQueue
│   └── ui.md                       # SynapseSandboxView, SandboxViewController, etc.
├── security/                       # Security analysis & threat modeling
│   └── threat-matrix.md            # Attack vectors, mitigations & defense-in-depth
├── benchmarks.md                   # Apple Silicon latency, memory & throughput metrics
├── troubleshooting.md              # Diagnostics, common pitfalls & debugging workflows
└── contributing.md                 # Development setup, Swift 6 concurrency & test suite
```

---

## 🧭 Navigation Matrix

### 🚀 Getting Started
* [Quickstart Guide](getting-started.md) — Install via Swift Package Manager and render your first sandboxed view in 5 minutes.

### 🏛 Architecture & Design
* [Architecture Overview](architecture/overview.md) — System boundaries, IPC pipelines, and framework topologies.
* [Runtime Engine](architecture/runtime-engine.md) — Actor-isolated WebKit execution and custom scheme serving.
* [Agentic Bridge](architecture/agentic-bridge.md) — Token-pruned DOM extraction and LLM tool calling mechanics.
* [CloudKit Sync](architecture/cloudkit-sync.md) — Private database CRDT delta sync without custom backend servers.
* [Security Model](architecture/security-model.md) — Process isolation, Content Security Policy, and memory watchdogs.

### 🛠 How-To Guides
* [SwiftUI Integration](guides/swiftui-integration.md) — Declarative view composition, controller patterns, and styling.
* [AI Agent & LLM Integration](guides/ai-agent-llm-integration.md) — Connecting Apple Intelligence, MLX, and Local LLMs.
* [Native Tool Calling Protocol](guides/tool-calling-rpc.md) — Bi-directional Swift ↔ JavaScript tool invocation.
* [Hot Reloading & DOM Patching](guides/hot-reloading-patching.md) — Sub-millisecond differential visual updates.
* [Private CloudKit Sync](guides/cloudkit-sync-crdt.md) — Cross-device synchronization with CRDT Last-Write-Wins.
* [WebAssembly Isolated Compute](guides/webassembly-compute.md) — High-performance computational routines in WASM.
* [Platform-Specific UX](guides/platform-specific-ux.md) — visionOS volumetric glass UI and macOS Safari Web Inspector.

### 📖 API Reference
* [Core Module](api-reference/core.md) — Domain models, configurations, errors, and event streams.
* [Engine Module](api-reference/engine.md) — Runtime actors, script bridges, and DOM patchers.
* [Agentic Bridge Module](api-reference/agentic-bridge.md) — LLM integration, token pruners, and tool registry.
* [Sync Module](api-reference/sync.md) — CloudKit sync engines, CRDT algorithms, and offline queues.
* [UI Module](api-reference/ui.md) — SwiftUI components, view controllers, and developer overlays.

### 🔒 Security, Quality & Operations
* [Threat Matrix & Security](security/threat-matrix.md) — Threat modeling, attack surfaces, and mitigations.
* [Performance Benchmarks](benchmarks.md) — Latency targets and hardware execution metrics.
* [Troubleshooting & FAQ](troubleshooting.md) — Error resolutions, debugging tips, and Safari Inspector workflows.
* [Contributing Guide](contributing.md) — Coding conventions, Swift 6 concurrency, and testing protocols.
