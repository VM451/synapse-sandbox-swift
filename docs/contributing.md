# Contributing & Development Guide

Thank you for contributing to **SynapseSandbox**! This document provides development guidelines, concurrency requirements, and testing standards.

---

## 🛠 Local Development Setup

### Clone Repository
```bash
git clone https://github.com/VM451/synapse-sandbox-swift.git
cd synapse-sandbox-swift
```

### Running Tests via Swift CLI
```bash
swift test
```

---

## 🔒 Code Standards & Concurrency Invariants

All contributions must adhere to the following standards:

1. **Swift 6 Strict Concurrency**: All files must build with `-swift-version 6` and Complete Strict Concurrency checking enabled.
2. **Zero Third-Party Dependencies**: No external SPM dependencies, CocoaPods, or binary frameworks may be introduced. Rely solely on Apple Native Frameworks.
3. **Actor Isolation**: All mutable state across engine and sync layers must be encapsulated in actors.
4. **Swift Testing**: All new features must be covered by modern Swift Testing (`@Test`, `#expect`, `#require`) test suites.

---

## 📋 Pull Request Checklist

Before submitting a Pull Request:
* [ ] `swift test` passes with zero errors.
* [ ] Code adheres to Swift 6 strict concurrency with zero warnings.
* [ ] Public APIs include comprehensive docstrings.
* [ ] Related documentation in `/docs` is updated.
