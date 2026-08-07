import Foundation
#if canImport(CloudKit)
import CloudKit
#endif

/// Sync Engine handling delta synchronization across Apple devices using Private CloudKit Database and CRDT resolution.
public actor CloudKitSyncEngine {
    #if canImport(CloudKit)
    private let container: CKContainer
    private let database: CKDatabase
    private let zoneID: CKRecordZone.ID
    #endif
    
    private let offlineQueue = SyncOfflineQueue()
    private var changeToken: Any? // CKServerChangeToken on platforms with CloudKit
    private var cachedWorkspaces: [UUID: SandboxWorkspace] = [:]
    
    public init(containerIdentifier: String = "iCloud.com.swiftsandboxkit.sandbox") {
        #if canImport(CloudKit)
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = container.privateCloudDatabase
        self.zoneID = CKRecordZone.ID(zoneName: "SwiftSandboxZone", ownerName: CKCurrentUserDefaultName)
        #endif
    }
    
    // MARK: - Zone Setup
    
    /// Initializes CloudKit custom zone layout in private database.
    public func setupZone() async throws {
        #if canImport(CloudKit)
        let zone = CKRecordZone(zoneID: zoneID)
        _ = try await database.save(zone)
        #endif
    }
    
    // MARK: - Sync Workspace
    
    /// Uploads delta updates of a Sandbox Workspace to CloudKit private database with CRDT resolution.
    public func syncWorkspace(_ workspace: SandboxWorkspace) async throws {
        #if canImport(CloudKit)
        let recordID = CKRecord.ID(recordName: workspace.id.uuidString, zoneID: zoneID)
        
        // Fetch existing record if any to merge
        var recordToSave: CKRecord
        do {
            let existingRecord = try await database.record(for: recordID)
            recordToSave = existingRecord
            
            // If remote record has file payload, perform CRDT merge
            if let existingPayload = existingRecord["filePayload"] as? Data,
               let remoteFiles = try? JSONDecoder().decode([SandboxFile].self, from: existingPayload) {
                let remoteWorkspace = SandboxWorkspace(
                    id: workspace.id,
                    name: (existingRecord["name"] as? String) ?? workspace.name,
                    files: remoteFiles,
                    entryPointPath: (existingRecord["entryPoint"] as? String) ?? workspace.entryPointPath,
                    lastModified: (existingRecord["lastModified"] as? Date) ?? Date.distantPast
                )
                let mergeResult = WorkspaceCRDT.merge(local: workspace, remote: remoteWorkspace)
                cachedWorkspaces[workspace.id] = mergeResult.mergedWorkspace
            } else {
                cachedWorkspaces[workspace.id] = workspace
            }
        } catch {
            recordToSave = CKRecord(recordType: "SandboxWorkspaceRecord", recordID: recordID)
            cachedWorkspaces[workspace.id] = workspace
        }
        
        let targetWorkspace = cachedWorkspaces[workspace.id] ?? workspace
        recordToSave["name"] = targetWorkspace.name as CKRecordValue
        recordToSave["lastModified"] = targetWorkspace.lastModified as CKRecordValue
        recordToSave["entryPoint"] = targetWorkspace.entryPointPath as CKRecordValue
        
        let fileData = try JSONEncoder().encode(targetWorkspace.files)
        recordToSave["filePayload"] = fileData as CKRecordValue
        
        _ = try await database.save(recordToSave)
        #else
        cachedWorkspaces[workspace.id] = workspace
        #endif
    }
    
    // MARK: - Fetch Updates
    
    /// Fetches incremental workspace updates from CloudKit.
    public func fetchLatestWorkspace(id: UUID) async throws -> SandboxWorkspace? {
        #if canImport(CloudKit)
        let recordID = CKRecord.ID(recordName: id.uuidString, zoneID: zoneID)
        let record = try await database.record(for: recordID)
        guard let name = record["name"] as? String,
              let entryPoint = record["entryPoint"] as? String,
              let lastModified = record["lastModified"] as? Date,
              let filePayload = record["filePayload"] as? Data else {
            return nil
        }
        let files = try JSONDecoder().decode([SandboxFile].self, from: filePayload)
        let workspace = SandboxWorkspace(
            id: id,
            name: name,
            files: files,
            entryPointPath: entryPoint,
            lastModified: lastModified
        )
        cachedWorkspaces[id] = workspace
        return workspace
        #else
        return cachedWorkspaces[id]
        #endif
    }
    
    public func getCachedWorkspace(id: UUID) -> SandboxWorkspace? {
        cachedWorkspaces[id]
    }
}
