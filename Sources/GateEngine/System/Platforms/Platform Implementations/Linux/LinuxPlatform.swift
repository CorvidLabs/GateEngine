/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)
import Foundation
import LinuxSupport

public final class LinuxPlatform: PlatformProtocol, InternalPlatformProtocol, @unchecked Sendable {
    #if GATEENGINE_PLATFORM_HAS_FILESYSTEM
    #if GATEENGINE_PLATFORM_HAS_AsynchronousFileSystem
    public static let fileSystem: LinuxFileSystem = LinuxFileSystem()
    #endif
    #if GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
    public static let synchronousFileSystem: SynchronousLinuxFileSystem = SynchronousLinuxFileSystem()
    #endif
    #endif
    let staticResourceLocations: [URL] = LinuxPlatform.getStaticSearchPaths()

    func setCursorStyle(_ style: Mouse.Style) {
        // Linux/X11 cursor styles not yet implemented
    }

    public var supportsMultipleWindows: Bool {
        return true
    }

    public func locateResource(from path: String) async -> String? {
        if path.hasPrefix("/"), await fileSystem.itemExists(at: path) {
            return path
        }
        let searchPaths =
            await Game.shared.delegate.resolvedCustomResourceLocations() + staticResourceLocations
        for searchPath in searchPaths {
            let file = searchPath.appendingPathComponent(path)
            if await fileSystem.itemExists(at: file.path) {
                return file.path
            }
        }

        return nil
    }

    public func loadResource(from path: String) async throws(GateEngineError) -> Data {
        if let resolvedPath = await locateResource(from: path) {
            do {
                return try await fileSystem.read(from: resolvedPath)
            } catch {
                Log.error("Failed to load resource \"\(resolvedPath)\".", error)
                throw GateEngineError.failedToLoad(resource: resolvedPath, "\(error)")
            }
        }

        throw GateEngineError.failedToLocate(resource: path, nil)
    }

    @MainActor
    public func font(named name: String) -> Font {
        Log.infoOnce("Current platform does not support system fonts. Using default font.")
        return .default
    }

    #if GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
    public func synchronousLocateResource(from path: String) -> String? {
        if path.hasPrefix("/"), synchronousFileSystem.itemExists(at: path) {
            return path
        }
        let searchPaths = Game.unsafeShared.delegate.resolvedCustomResourceLocations() + staticResourceLocations
        for searchPath in searchPaths {
            let file = searchPath.appendingPathComponent(path)
            if synchronousFileSystem.itemExists(at: file.path) {
                return file.path
            }
        }

        return nil
    }

    public func synchronousLoadResource(from path: String) throws(GateEngineError) -> Data {
        if let resolvedPath = synchronousLocateResource(from: path) {
            do {
                return try synchronousFileSystem.read(from: resolvedPath)
            } catch {
                Log.error("Failed to load resource \"\(resolvedPath)\".", error)
                throw GateEngineError.failedToLoad(resource: resolvedPath, "\(error)")
            }
        }

        throw GateEngineError.failedToLocate(resource: path, nil)
    }
    #endif
}

extension LinuxPlatform {
    @MainActor func main() {
        var done = false
        Task(priority: .high) { @MainActor in
            await Game.shared.didFinishLaunching()
            done = true
        }
        while done == false {
            RunLoop.main.run(until: Date())
        }

        let window: Window? = Game.shared.windowManager.mainWindow
        mainLoop: while true {

            let eventMask: Int =
                (StructureNotifyMask | EnterWindowMask | LeaveWindowMask | PointerMotionMask
                    | ButtonPressMask | ButtonReleaseMask | KeyPressMask | KeyReleaseMask)
            for window: Window in Game.shared.windowManager.windows {
                let x11Window: X11Window = window.windowBacking as! X11Window
                var event: XEvent = XEvent()
                while XCheckWindowEvent(x11Window.xDisplay, x11Window.xWindow, eventMask, &event)
                    == 1
                {
                    x11Window.processEvent(event)
                }
                x11Window.draw()
            }

            if Game.shared.windowManager.windows.isEmpty {
                break
            }

            var time: Date? = nil
            repeat {
                // Execute Foundation.RunLoop once and determine the next time the timer
                // fires.  At this point handle all Foundation.RunLoop timers, sources and
                // Dispatch.DispatchQueue.main tasks
                time = RunLoop.main.limitDate(forMode: .default)

                // If Foundation.RunLoop doesn't contain any timers or the timers should
                // not be running right now, we interrupt the current loop or otherwise
                // continue to the next iteration.
            } while (time?.timeIntervalSinceNow ?? -1) <= 0
        }

        Game.shared.willTerminate()
        exit(EXIT_SUCCESS)
    }
}

#endif
