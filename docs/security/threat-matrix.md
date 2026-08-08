# Security & Threat Matrix

This document provides a comprehensive security assessment and threat modeling matrix for **SynapseSandbox**.

---

## 🛡 Attack Vectors & Defense Mitigations

| Attack Vector | Threat Level | Mitigation Strategy | Technical Enforcement |
| :--- | :---: | :--- | :--- |
| **Local File Traversal** | **Critical** | In-Memory Virtual Scheme | Requests routed via `sandbox://app/`. `file://` scheme is disabled. WebKit process has no filesystem handles. |
| **Data Exfiltration (SSRF)** | **High** | Content Security Policy | `connect-src 'none'` blocks `fetch()`, `XMLHttpRequest`, and `WebSocket` by default. |
| **Memory Exhaustion (DoS)** | **High** | Watchdog Engine | Background polling verifies RAM consumption against 256MB threshold. Violations trigger graceful termination. |
| **Arbitrary Native Code Injection** | **Critical** | Strong IPC Serialization | Swift reflection/selectors are not exposed. Messages are parsed via strictly typed JSON models. |
| **DOM Redirection / Phishing** | **Medium** | Scheme Whitelisting | Navigation outside `sandbox:`, `data:`, `blob:` is rejected. |
| **WebAssembly Memory Escape** | **Medium** | Wasm Sandbox Boundary | WASM runs within WebKit's isolated linear memory buffer with hardware bounds checking. |

---

## 🔒 Content Security Policy (CSP) Directives

```http
default-src 'self' sandbox: data: blob: 'unsafe-inline' 'unsafe-eval';
connect-src 'none';
img-src 'self' sandbox: data: blob:;
frame-src 'self' sandbox:;
```

---

## 🏢 Enterprise Compliance Checklist

* ✅ **GDPR & HIPAA Friendly**: Zero data sent to third-party tracking or cloud services.
* ✅ **No Third-Party SDKs**: 100% native Apple SDKs (`WebKit`, `CloudKit`, `CryptoKit`, `SwiftUI`, `Foundation`).
* ✅ **Strict Concurrency**: Compliant with Swift 6 thread safety standards.
