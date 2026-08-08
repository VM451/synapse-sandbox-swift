# CloudKit Sync & CRDT Engine

**SynapseSandbox** features a built-in cross-device synchronization engine powered by Apple CloudKit Private Databases. It requires **zero custom servers, zero backend infrastructure, and zero third-party database dependencies**.

---

## ☁️ Zero-Backend Architecture

By using the user's personal iCloud account, the framework guarantees:
1. **Privacy-First**: Neither the app developer nor any intermediary server can inspect the user's sandboxed files or workspace states.
2. **Zero Maintenance**: Automatic handling of authentication, tokens, network retry, and power management through Apple's native CloudKit daemon.
3. **Cross-Platform Sync**: Workspaces created on macOS immediately sync to iPadOS, iOS, and Apple Vision Pro.

```
+-----------------------------------------------------------------------------+
|                            USER'S APPLE DEVICES                             |
|                                                                             |
|   +------------------+    +------------------+    +---------------------+   |
|   |   Mac Studio     |    |    iPad Pro      |    |  Apple Vision Pro   |   |
|   | (macOS 27.0+)    |    | (iPadOS 27.0+)   |    |  (visionOS 27.0+)   |   |
|   +------------------+    +------------------+    +---------------------+   |
|            |                       |                         |              |
|            +-----------------------+-------------------------+              |
|                                    |                                        |
|                         CloudKit Private Zone                               |
|                     ("SwiftSandboxZone" in Private DB)                      |
|                                    v                                        |
|   +---------------------------------------------------------------------+   |
|   |                       Apple iCloud Private Database                 |   |
|   |                    (Encrypted At Rest & In Transit)                 |   |
|   +---------------------------------------------------------------------+   |
+-----------------------------------------------------------------------------+
```

---

## 🔀 Conflict-Free Replicated Data Types (CRDT)

When multiple devices edit the same workspace offline or concurrently, naive overwrites cause data loss. `WorkspaceCRDT` implements a deterministic **Last-Write-Wins (LWW) Element Set** algorithm to resolve conflicting file versions and metadata.

### The Merge Algorithm
Given a `local` workspace and a `remote` workspace:

1. **Exact Checksum Match**: If `localFile.checksum == remoteFile.checksum`, the file is marked as preserved with zero disk/memory recomputation.
2. **Conflict Resolution on Collision**: If two files have the same relative path but different checksums:
   * The file with the newer `lastModified` timestamp wins.
   * `conflictsResolved` counter is incremented.
   * The winning file is added to `filesUpdated` or `filesPreserved`.
3. **Disjoint Additions**: Files that exist on only one replica are automatically integrated into the merged set.
4. **Metadata Merging**: Workspace metadata dictionaries are merged; collisions resolve to the newer workspace's metadata.
5. **Deterministic Sorting**: Merged files are sorted alphabetically by path for consistent hashing across devices.

```swift
public struct MergeResult: Sendable, Equatable {
    public let mergedWorkspace: SandboxWorkspace
    public let filesAdded: [String]
    public let filesUpdated: [String]
    public let filesPreserved: [String]
    public let conflictsResolved: Int
}
```

---

## 📦 Large Asset Handling with `AssetChunkManager`

CloudKit records have payload size limits. For workspaces containing large binary assets (WebAssembly binaries, high-res images, SQLite databases):
* `AssetChunkManager` partitions payloads exceeding 1MB into chunks or maps them to `CKAsset` instances stored in Apple's cloud storage.
* On download, chunks are reassembled and checksum-verified using SHA-256 before being restored to the in-memory `SandboxWorkspace`.

---

## 📶 Offline Resilience & `SyncOfflineQueue`

When network connectivity is unavailable:
1. Workspace modifications are serialized into `SyncOfflineQueue`.
2. The queue persists pending operations locally in encrypted storage.
3. Upon reconnection, operations are drained and synced to CloudKit in sequential batches with exponential backoff retry.
