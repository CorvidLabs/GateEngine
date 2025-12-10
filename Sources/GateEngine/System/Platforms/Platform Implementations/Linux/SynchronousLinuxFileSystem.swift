/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux) && GATEENGINE_PLATFORM_HAS_FILESYSTEM && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
import Foundation

public struct SynchronousLinuxFileSystem: SynchronousFileSystem {
    let homeDir: String = String(cString: getenv("HOME") ?? getpwuid(getuid()).pointee.pw_dir)

    public func pathForSearchPath(
        _ searchPath: FileSystemSearchPath,
        in domain: FileSystemSearchPathDomain = .currentUser
    ) throws -> String {
        switch searchPath {
        case .persistent:
            switch domain {
            case .currentUser:
                return URL(fileURLWithPath: homeDir)
                    .appendingPathComponent(".config")
                    .appendingPathComponent("." + Game.unsafeShared.identifier)
                    .path
            case .shared:
                return URL(fileURLWithPath: "/var/lib")
                    .appendingPathComponent(Game.unsafeShared.identifier)
                    .path
            }
        case .cache:
            switch domain {
            case .currentUser:
                return URL(fileURLWithPath: homeDir)
                    .appendingPathComponent(".cache")
                    .appendingPathComponent(Game.unsafeShared.identifier)
                    .path
            case .shared:
                return URL(fileURLWithPath: "/var/cache")
                    .appendingPathComponent(Game.unsafeShared.identifier)
                    .path
            }
        case .temporary:
            return URL(fileURLWithPath: "/tmp")
                .appendingPathComponent(Game.unsafeShared.identifier)
                .path
        }
    }
}
#endif
