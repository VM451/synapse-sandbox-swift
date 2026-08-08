# Agentic Bridge & AI Integration

The `AgenticBridge` subsystem provides first-class interoperability between Apple's on-device Foundation Models (Apple Intelligence, Local LLMs, CoreML Transformers, MLX) and the live sandbox execution environment.

---

## 🧠 Why an Agentic Bridge?

Standard LLMs face two major bottlenecks when interacting with web environments:
1. **Context Window Saturation**: A full HTML page can contain tens of thousands of tokens of non-semantic code (`<script>`, `<svg>`, inline CSS, tracking tags, boilerplate whitespace).
2. **Fragile Code Application**: Instructing an LLM to regenerate an entire 1,000-line HTML file for a 1-line style fix introduces latency, high token costs, and high risk of regression.

`AgenticBridge` solves both problems via **Token-Pruned Semantic DOM Extraction** and **Differential Code Patching**.

---

## 🔍 Semantic DOM Extraction Pipeline

The `SemanticDOMExtractor` extracts a compact semantic representation of the DOM tree:

```
+-----------------------------------------------------------------------------+
|                          Full Raw WebKit DOM Tree                           |
|        (20,000 - 50,000 Tokens: Scripts, Styles, Inline SVGs, etc.)         |
+-----------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------+
|                     SemanticDOMExtractor JavaScript Core                    |
|                                                                             |
|  - Drops <script>, <style>, <svg>, <noscript>, <iframe> tags                |
|  - Retains tags, IDs, class names, ARIA labels, roles, input values         |
|  - Depth-bounded recursion (configurable maxDepth, default 8-10)            |
+-----------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------+
|                         Semantic Markdown Formatter                         |
|                   (500 - 1,500 Tokens: 95% Token Savings)                   |
+-----------------------------------------------------------------------------+
```

### Raw HTML vs. Semantic Markdown Example

#### Raw HTML (Overwhelming for LLM context):
```html
<div class="header-container flex flex-row items-center justify-between p-4 bg-white border-b">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="..."/></svg>
    <h1 id="main-title" class="text-xl font-bold text-gray-900">User Dashboard</h1>
    <button id="export-btn" role="button" aria-label="Export Data" class="btn btn-primary" onclick="doExport()">
        <span>Export</span>
    </button>
</div>
```

#### Extracted Semantic Markdown:
```markdown
<[div] .header-container.flex.flex-row.items-center.justify-between.p-4.bg-white.border-b>
  <[h1] #main-title .text-xl.font-bold.text-gray-900>
    - "User Dashboard"
  <[button] #export-btn role="button" aria-label="Export Data">
    - "Export"
```

---

## 🛠 Native Tool Calling RPC Protocol

`AgenticBridge` integrates with `ToolRegistryActor` to expose native Swift functions to both the JavaScript application and LLM agent function-calling pipelines.

### Tool Registration & JSON Schema Generation
Each tool conforms to `SandboxAgentTool`:

```swift
public protocol SandboxAgentTool: Sendable {
    var name: String { get }
    var description: String { get }
    var parametersSchemaJSON: String { get }
    func execute(argumentsJSON: String) async throws -> String
}
```

The bridge converts registered tools into `FoundationModelToolDefinition` structs containing JSON Schema parameters suitable for direct injection into Apple Intelligence / LLM system prompts:

```swift
public struct FoundationModelToolDefinition: Sendable, Codable, Equatable {
    public let name: String
    public let description: String
    public let parametersSchemaJSON: String
}
```

### Bidirectional Dispatch Sequence

```
Web JS / LLM                        SandboxEngine                     ToolRegistryActor
     |                                    |                                   |
     |--- window.SwiftSandboxBridge ----->|                                   |
     |    (type: 'TOOL_CALL')             |                                   |
     |                                    |--- executeAndReplyToolCall() ---->|
     |                                    |                                   |--- tool.execute()
     |                                    |<-- JSON Result / Error -----------|
     |<-- window.__handleAgentResponse -- |
     |
```

---

## ⚡ Differential Agent Code Patching

When an AI agent decides to modify the running interface, `AgenticBridge.applyAgentCodePatch(jsDelta:cssDelta:)` executes the changes surgically:
1. Injects dynamic CSS rules into a dedicated style element (`#sandbox-dynamic-styles`).
2. Evaluates the JavaScript delta inside an isolated closure with error capturing.
3. Measures precise execution time in milliseconds and returns an `AgentPatchResult`.

```swift
public struct AgentPatchResult: Sendable, Equatable {
    public let isSuccess: Bool
    public let executionTimeMs: Double
    public let rawOutput: String
    public let errorDescription: String?
}
```
