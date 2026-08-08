# Agentic Bridge API Reference

The `AgenticBridge` module provides semantic DOM extraction, token pruning, JSON Schema reflection, and differential code patching for Apple Foundation Models.

---

## 🗂 Types & Actors

### `AgenticBridge`
Coordinates between `SandboxEngine` and Foundation Models.

```swift
public final class AgenticBridge: @unchecked Sendable {
    public init(engine: SandboxEngine)
    
    // Semantic DOM Extraction
    public func captureSemanticDOM(maxTokens: Int = 4096) async throws -> String
    public func captureSemanticJSON(maxTokens: Int = 4096) async throws -> String
    
    // Agent Differential Patching
    public func applyAgentCodePatch(jsDelta: String, cssDelta: String? = nil) async throws -> AgentPatchResult
    
    // Tool Management & Schema Reflection
    public func registerTool(_ tool: any SandboxAgentTool) async
    public func executeTool(name: String, argumentsJSON: String) async throws -> String
    public func getToolDefinitions() async -> [FoundationModelToolDefinition]
}
```

---

### `SemanticDOMExtractor`
Subsystem that strips non-semantic elements and formats the DOM tree into token-optimized Markdown.

```swift
public enum SemanticDOMExtractor: Sendable {
    public static func extractionScript(maxDepth: Int = 10) -> String
    public static func jsonToSemanticMarkdown(_ jsonString: String) -> String
    public static func pruneToTokenBudget(_ content: String, maxTokens: Int = 4096) -> String
}
```

---

### `ToolRegistryActor`
Actor managing tool registration, JSON schema generation, and execution dispatch.

```swift
public actor ToolRegistryActor {
    public init()
    public func register(_ tool: any SandboxAgentTool)
    public func unregister(name: String)
    public func execute(toolName: String, argumentsJSON: String) async throws -> String
    public func exportFoundationModelToolDefinitions() -> [FoundationModelToolDefinition]
}
```

---

### `FoundationModelToolDefinition`
Standardized tool schema definition ready for injection into Foundation Model prompt contexts.

```swift
public struct FoundationModelToolDefinition: Sendable, Codable, Equatable {
    public let name: String
    public let description: String
    public let parametersSchemaJSON: String
    
    public init(name: String, description: String, parametersSchemaJSON: String)
}
```

---

### `AgentPatchResult`
Execution feedback returned after applying a differential code patch.

```swift
public struct AgentPatchResult: Sendable, Equatable {
    public let isSuccess: Bool
    public let executionTimeMs: Double
    public let rawOutput: String
    public let errorDescription: String?
    
    public init(isSuccess: Bool, executionTimeMs: Double, rawOutput: String, errorDescription: String? = nil)
}
```
