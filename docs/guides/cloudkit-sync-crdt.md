# Private CloudKit Sync & CRDT Guide

This guide walks through configuring multi-device state synchronization with **CloudKitSyncEngine** and **WorkspaceCRDT**.

---

## 🛠 Step 1: Xcode CloudKit Entitlements Setup

1. Open your project in Xcode.
2. Select your main application target $\rightarrow$ **Signing & Capabilities**.
3. Click **+ Capability** and add **iCloud**.
4. Check **CloudKit**.
5. Click **+** under **Containers** and create or select a container identifier (e.g. `iCloud.com.mycompany.myapp`).

---

## ☁️ Step 2: Initializing the Sync Engine

Create an instance of `CloudKitSyncEngine`:

```swift
import SynapseSandbox

let syncEngine = CloudKitSyncEngine(containerIdentifier: "iCloud.com.mycompany.myapp")

// Setup the custom record zone in the user's private database (idempotent)
try await syncEngine.setupZone()
```

---

## 🔄 Step 3: Synchronizing a Workspace

Push your local workspace state to CloudKit:

```swift
let workspace = SandboxWorkspace.defaultTemplate(name: "Shared Project")

// Sync workspace (fetches remote version, resolves CRDT merge, and saves)
try await syncEngine.syncWorkspace(workspace)
print("Workspace synced to iCloud!")
```

---

## 📥 Step 4: Fetching Remote Updates

Fetch the latest workspace updates for a given workspace UUID:

```swift
if let remoteWorkspace = try await syncEngine.fetchLatestWorkspace(id: workspace.id) {
    print("Fetched workspace '\(remoteWorkspace.name)' with \(remoteWorkspace.files.count) files.")
    
    // Load into running engine
    await engine.updateWorkspace(remoteWorkspace)
}
```

---

## 🔀 Step 5: Manual CRDT Merge Inspection

You can test or inspect CRDT merges directly using `WorkspaceCRDT.merge(local:remote:)`:

```swift
import SynapseSandbox

let localWorkspace = SandboxWorkspace(
    name: "Project A",
    fileMap: ["index.html": "<h1>Local Title</h1>", "style.css": "body { color: red; }"]
)

let remoteWorkspace = SandboxWorkspace(
    name: "Project A - Remote",
    fileMap: ["index.html": "<h1>Remote Title</h1>", "app.js": "console.log('remote');"]
)

let mergeResult = WorkspaceCRDT.merge(local: localWorkspace, remote: remoteWorkspace)

print("Merged Files Count: \(mergeResult.mergedWorkspace.files.count)")
print("Files Added: \(mergeResult.filesAdded)")
print("Files Preserved: \(mergeResult.filesPreserved)")
print("Conflicts Resolved: \(mergeResult.conflictsResolved)")
```

---

## 📶 Step 6: Handling Offline Scenarios

`CloudKitSyncEngine` automatically coordinates with `SyncOfflineQueue`:
* When offline, writes are queued in memory and local storage.
* As soon as network connectivity is re-established, the pending queue is drained automatically.
