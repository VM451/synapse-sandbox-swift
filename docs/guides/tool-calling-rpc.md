# Native Tool Calling Protocol & JSON Schema RPC

This guide demonstrates how to register native Swift tools with **SynapseSandbox** and expose them bi-directionally to both the sandboxed JavaScript application and on-device AI Agents.

---

## 🛠 What is Native Tool Calling?

Native Tool Calling enables your sandbox web applications to securely trigger native Swift capabilities (e.g. CoreLocation, CoreMotion, Camera/Photos, Local Database queries, Hardware Diagnostics) without breaking the sandbox perimeter.

```
+------------------------------------+               +-------------------------------------+
|        SANDBOX JAVASCRIPT          |               |          NATIVE SWIFT HOST          |
|                                    |  TOOL_CALL    |                                     |
| window.SwiftSandboxBridge          |-------------->| SandboxEngine                       |
|   .postMessage({ toolName: ... })  | (JSON payload)|   .executeAndReplyToolCall()        |
|                                    |               |             |                       |
|                                    |               |             v                       |
|                                    |               | ToolRegistryActor                   |
|                                    |               |   -> SandboxAgentTool.execute()     |
|                                    |               |             |                       |
|                                    |  REPLY JSON   |             v                       |
| window.__handleAgentResponse(id,..) |<--------------| Native Swift Tool Result (Async)    |
+------------------------------------+               +-------------------------------------+
```

---

## 📝 Step 1: Defining a Native Tool

### Using `ClosureAgentTool`
The quickest way to define a tool is using `ClosureAgentTool`:

```swift
import Foundation
import SynapseSandbox

let batteryDiagnosticsTool = ClosureAgentTool(
    name: "GetDeviceBatteryInfo",
    description: "Returns the current battery level and low power mode status of the host Apple device.",
    parametersSchemaJSON: """
    {
        "type": "object",
        "properties": {
            "includeThermalState": { "type": "boolean" }
        }
    }
    """
) { argumentsJSON in
    // Parse arguments and perform native Swift logic
    let batteryLevel = 0.88
    let isLowPower = false
    
    return """
    {
        "batteryLevel": \(batteryLevel),
        "lowPowerMode": \(isLowPower),
        "chip": "Apple M4 Pro"
    }
    """
}
```

### Implementing `SandboxAgentTool` Protocol
For complex tools requiring state management:

```swift
import Foundation
import SynapseSandbox

public struct SecureVaultQueryTool: SandboxAgentTool {
    public let name = "QuerySecureDatabase"
    public let description = "Executes a parameterized read-only query against local SQLite cache."
    public let parametersSchemaJSON = """
    {
        "type": "object",
        "properties": {
            "query": { "type": "string" },
            "limit": { "type": "integer" }
        },
        "required": ["query"]
    }
    """
    
    public init() {}
    
    public func execute(argumentsJSON: String) async throws -> String {
        guard let data = argumentsJSON.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let query = dict["query"] as? String else {
            throw SandboxError.toolExecutionFailed(toolName: name, reason: "Invalid JSON arguments")
        }
        
        // Execute native query logic
        let results = [
            ["id": 101, "title": "Quarterly Report", "status": "approved"],
            ["id": 102, "title": "System Audit", "status": "in_review"]
        ]
        
        let responseData = try JSONSerialization.data(withJSONObject: results)
        return String(data: responseData, encoding: .utf8) ?? "[]"
    }
}
```

---

## 🔌 Step 2: Registering Tools with the Bridge / Engine

Register your tools with `AgenticBridge` or directly on `SandboxEngine`:

```swift
let engine = SandboxEngine(workspace: workspace)
let bridge = AgenticBridge(engine: engine)

// Register tools
await bridge.registerTool(batteryDiagnosticsTool)
await bridge.registerTool(SecureVaultQueryTool())
```

---

## 💻 Step 3: Invoking Tools from JavaScript

In your sandbox web code, invoke tools via `window.SwiftSandboxBridge`:

```javascript
// Function to invoke native tool with callback
function invokeNativeTool(toolName, args, callback) {
    const requestId = crypto.randomUUID ? crypto.randomUUID() : 'req-' + Date.now();
    
    // Register temporary response listener
    window.__agentCallbacks = window.__agentCallbacks || {};
    window.__agentCallbacks[requestId] = callback;
    
    window.SwiftSandboxBridge.postMessage({
        id: requestId,
        type: 'TOOL_CALL',
        payload: {
            toolName: toolName,
            arguments: args
        },
        timestamp: Date.now()
    });
}

// Global response dispatcher automatically called by SynapseSandbox
window.__handleAgentResponse = function(requestId, resultJSON, error) {
    if (window.__agentCallbacks && window.__agentCallbacks[requestId]) {
        window.__agentCallbacks[requestId](resultJSON, error);
        delete window.__agentCallbacks[requestId];
    }
};

// Example usage:
invokeNativeTool('GetDeviceBatteryInfo', { includeThermalState: true }, function(result, error) {
    if (error) {
        console.error("Tool failed:", error);
    } else {
        console.log("Device Battery:", result.batteryLevel);
        document.getElementById('battery-label').textContent = Math.round(result.batteryLevel * 100) + '%';
    }
});
```

---

## 🤖 Step 4: Exporting Function Schemas for LLM Tool Ingestion

When passing tool definitions to Apple Intelligence or Foundation Models:

```swift
let toolDefinitions = await bridge.getToolDefinitions()

for tool in toolDefinitions {
    print("Tool: \(tool.name)")
    print("Description: \(tool.description)")
    print("Schema: \(tool.parametersSchemaJSON)")
}
```
