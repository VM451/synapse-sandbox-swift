# Core Module API Reference

The `Core` module contains domain models, configuration presets, error types, event streams, and tool calling definitions.

---

## 🗂 Types & Protocols

### `SandboxWorkspace`
Represents the in-memory file tree and snapshot state of a sandboxed web application.

```swift
public struct SandboxWorkspace: Identifiable, Sendable, Codable, Hashable, Equatable {
    public let id: UUID
    public var name: String
    public var files: [SandboxFile]
    public var entryPointPath: String
    public var metadata: [String: String]
    public var createdAt: Date
    public var lastModified: Date
    
    public var totalSizeInBytes: Int { get }
    public var entryPointFile: SandboxFile? { get }
    
    public init(
        id: UUID = UUID(),
        name: String,
        files: [SandboxFile] = [],
        entryPointPath: String = "index.html",
        metadata: [String: String] = [:],
        createdAt: Date = Date(),
        lastModified: Date = Date()
    )
    
    public init(name: String, fileMap: [String: String], entryPointPath: String = "index.html")
    public init(name: String, binaryFiles: [String: Data], entryPointPath: String = "index.html")
    
    public func exportFileMap() -> [String: String]
    public func file(at path: String) -> SandboxFile?
    public mutating func upsertFile(_ file: SandboxFile)
    public mutating func removeFile(at path: String) -> SandboxFile?
    public static func defaultTemplate(name: String = "Interactive Sandbox") -> SandboxWorkspace
}
```

---

### `SandboxFile`
Represents a virtual file stored inside a workspace.

```swift
public struct SandboxFile: Identifiable, Sendable, Codable, Hashable, Equatable {
    public var id: String { get }
    public let path: String
    public var content: FileContent
    public var mimeType: String
    public var checksum: String
    public var sizeInBytes: Int { get }
    public var lastModified: Date
    
    public enum FileContent: Sendable, Codable, Hashable, Equatable {
        case text(String)
        case binary(Data)
        public var byteLength: Int { get }
        public var rawData: Data { get }
        public var utf8Text: String? { get }
    }
    
    public init(path: String, content: FileContent, mimeType: String? = nil, lastModified: Date = Date())
    public init(path: String, text: String, mimeType: String? = nil, lastModified: Date = Date())
    public init(path: String, data: Data, mimeType: String? = nil, lastModified: Date = Date())
    
    public static func computeChecksum(for data: Data) -> String
    public static func inferMimeType(from path: String) -> String
    public mutating func updateContent(_ newContent: FileContent)
}
```

---

### `SandboxConfiguration`
Parameters governing security, rendering, memory watchdog limits, and developer tools.

```swift
public struct SandboxConfiguration: Sendable, Equatable {
    public var allowNetworkAccess: Bool
    public var enableWebAssembly: Bool
    public var enableWebGPU: Bool
    public var cornerRadius: CGFloat
    public var maxMemoryMB: Int
    public var customCSP: String?
    public var developerModeEnabled: Bool
    public var allowedSchemes: [String]
    public var isInspectable: Bool
    public var watchdogCheckIntervalSeconds: TimeInterval
    
    public init(
        allowNetworkAccess: Bool = false,
        enableWebAssembly: Bool = true,
        enableWebGPU: Bool = true,
        cornerRadius: CGFloat = 12.0,
        maxMemoryMB: Int = 256,
        customCSP: String? = nil,
        developerModeEnabled: Bool = false,
        allowedSchemes: [String] = ["sandbox", "data", "blob"],
        isInspectable: Bool = true,
        watchdogCheckIntervalSeconds: TimeInterval = 5.0
    )
    
    public static let `default`: SandboxConfiguration
    public static let secure: SandboxConfiguration
    public static let developer: SandboxConfiguration
}
```

---

### `SandboxError`
Exhaustive error cases emitted during engine evaluation, IPC communication, or CloudKit synchronization.

```swift
public enum SandboxError: Error, Sendable, CustomStringConvertible, Equatable {
    case serializationFailed(String)
    case executionFailed(String)
    case toolNotFound(String)
    case toolExecutionFailed(toolName: String, reason: String)
    case securityViolation(String)
    case cspViolation(String)
    case fileNotFound(String)
    case entryPointMissing(String)
    case invalidScheme(String)
    case memoryLimitExceeded(usedMB: Int, limitMB: Int)
    case engineDeallocated
    case timeout(String)
    case cloudKitSyncError(String)
    case crdtConflict(String)
}
```

---

### `SandboxEvent`
Events streamed from the JavaScript sandbox to the Swift host via `SandboxEngine.eventStream`.

```swift
public enum SandboxEvent: Sendable, Codable, Equatable {
    case consoleLog(level: LogLevel, message: String, timestamp: Date)
    case uncaughtError(message: String, stackTrace: String?)
    case domMutation(summary: String, targetSelector: String?, timestamp: Date)
    case customMessage(name: String, payload: String)
    case toolCall(id: String, toolName: String, argumentsJSON: String)
    case lifecycle(LifecycleState)
    
    public var summary: String { get }
    
    public enum LogLevel: String, Codable, Sendable, Equatable, Comparable {
        case debug, info, warning, error
    }
    
    public enum LifecycleState: String, Codable, Sendable, Equatable {
        case initializing, ready, reloading, terminated, error
    }
}
```

---

### `SandboxAgentTool` & `ClosureAgentTool`
Protocols and implementations for exposing native Swift functionality as callable tools.

```swift
public protocol SandboxAgentTool: Sendable {
    var name: String { get }
    var description: String { get }
    var parametersSchemaJSON: String { get }
    func execute(argumentsJSON: String) async throws -> String
}

public struct ClosureAgentTool: SandboxAgentTool {
    public let name: String
    public let description: String
    public let parametersSchemaJSON: String
    
    public init(
        name: String,
        description: String,
        parametersSchemaJSON: String = "{}",
        handler: @escaping @Sendable (String) async throws -> String
    )
    
    public func execute(argumentsJSON: String) async throws -> String
}
```
