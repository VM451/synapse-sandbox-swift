# Sync Module API Reference

The `Sync` module manages private CloudKit database operations, CRDT Last-Write-Wins element set merging, large asset chunking, and offline queueing.

---

## 🗂 Types & Actors

### `CloudKitSyncEngine`
Actor coordinating delta synchronization across Apple devices using the user's private iCloud database.

```swift
public actor CloudKitSyncEngine {
    public init(containerIdentifier: String = "iCloud.com.synapsesandbox.sandbox")
    
    /// Initializes custom record zone layout in private database.
    public func setupZone() async throws
    
    /// Uploads delta updates of a Sandbox Workspace with CRDT resolution.
    public func syncWorkspace(_ workspace: SandboxWorkspace) async throws
    
    /// Fetches incremental workspace updates from CloudKit.
    public func fetchLatestWorkspace(id: UUID) async throws -> SandboxWorkspace?
    
    /// Returns cached in-memory workspace snapshot if available.
    public func getCachedWorkspace(id: UUID) -> SandboxWorkspace?
}
```

---

### `WorkspaceCRDT`
Conflict-Free Replicated Data Type engine implementing Last-Write-Wins (LWW) and text-delta resolution.

```swift
public enum WorkspaceCRDT: Sendable {
    public struct MergeResult: Sendable, Equatable {
        public let mergedWorkspace: SandboxWorkspace
        public let filesAdded: [String]
        public let filesUpdated: [String]
        public let filesPreserved: [String]
        public let conflictsResolved: Int
        
        public init(
            mergedWorkspace: SandboxWorkspace,
            filesAdded: [String],
            filesUpdated: [String],
            filesPreserved: [String],
            conflictsResolved: Int
        )
    }
    
    public static func merge(local: SandboxWorkspace, remote: SandboxWorkspace) -> MergeResult
}
```

---

### `SyncOfflineQueue`
Thread-safe actor for persisting pending operations when network connectivity is lost.

```swift
public actor SyncOfflineQueue {
    public init()
    public func enqueue(workspace: SandboxWorkspace)
    public func dequeueAll() -> [SandboxWorkspace]
    public var pendingCount: Int { get }
}
```

---

### `AssetChunkManager`
Subsystem for chunking large binary assets into payloads compatible with CloudKit records.

```swift
public enum AssetChunkManager: Sendable {
    public static func chunkData(_ data: Data, maxChunkSize: Int = 1_048_576) -> [Data]
    public static func assembleChunks(_ chunks: [Data]) -> Data
}
```
