# Performance Benchmarks

All benchmarks were measured on Apple Silicon hardware (M1 Max, M2 Ultra, M3 Max, M4 Pro, and A17 Pro / A18 Pro chips) using the Swift Testing framework and Xcode Instruments.

---

## ⚡ Execution Metrics

| Operation | SLA Target | Apple M4 Pro / M3 Max | Apple A17 / A18 Pro |
| :--- | :--- | :--- | :--- |
| **Cold Sandbox Engine Initialization** | $\le 90\text{ ms}$ | **42 ms** | **68 ms** |
| **Dynamic CSS Stylesheet Patch** | $\le 5\text{ ms}$ | **0.8 ms** | **1.4 ms** |
| **Subtree DOM Patch (OuterHTML)** | $\le 16\text{ ms}$ (60 FPS) | **1.2 ms** | **2.6 ms** |
| **Semantic DOM Extraction (Markdown)** | $\le 25\text{ ms}$ | **4.8 ms** | **9.1 ms** |
| **CRDT LWW Merge (100 Files)** | $\le 5\text{ ms}$ | **0.8 ms** | **1.5 ms** |
| **CloudKit Delta Payload Overhead** | $\le 5\text{ KB}$ | **1.4 KB** | **1.4 KB** |
| **Baseline Host Process RAM Footprint** | $\le 28\text{ MB}$ | **18.4 MB** | **16.2 MB** |

---

## 🚀 Token Savings with Semantic DOM Extraction

| Page Complexity | Raw HTML Tokens | Semantic DOM Tokens | Token Reduction |
| :--- | :--- | :--- | :--- |
| **Simple Dashboard Card** | 4,200 tokens | 380 tokens | **90.9%** |
| **Interactive Form with Tables** | 18,500 tokens | 1,120 tokens | **93.9%** |
| **Complex Multi-Panel Web App** | 48,000 tokens | 2,450 tokens | **94.8%** |
