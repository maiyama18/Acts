import Foundation

public extension FileManager {
    func subDirectoriesOfDirectory(at: URL, includingPropertiesForKeys: [URLResourceKey]? = nil, options: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        let contents = try contentsOfDirectory(at: at, includingPropertiesForKeys: includingPropertiesForKeys, options: options)
        return contents.filter {
            directoryExists(atPath: $0.path)
        }
    }

    func directoryExists(atPath: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
