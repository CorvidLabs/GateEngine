/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if HTML5
import WebAudio

internal final class WABufferReference: AudioBufferBackend, @unchecked Sendable {
    unowned let audioBuffer: AudioBuffer
    nonisolated(unsafe) var buffer: WebAudio.AudioBuffer! = nil

    @inlinable
    var duration: Double {
        return buffer.duration
    }

    required init(path: String, context: AudioContext, audioBuffer: AudioBuffer) {
        self.audioBuffer = audioBuffer
        Task { @MainActor in
            await self.loadAudio(path: path, context: context)
        }
    }

    @MainActor
    private func loadAudio(path: String, context: AudioContext) async {
        let platform: WASIPlatform = Game.shared.platform
        let ctx = (context.reference as! WAContextReference).ctx

        do {
            let arrayBuffer = try await platform.loadResourceAsArrayBuffer(from: path)
            // Use nonisolated(unsafe) to allow passing the ArrayBuffer to decodeAudioData
            // This is safe because we're on the MainActor and WASI runs single-threaded
            nonisolated(unsafe) let unsafeArrayBuffer = arrayBuffer
            self.buffer = try await ctx.decodeAudioData(audioData: unsafeArrayBuffer)
            self.audioBuffer.state = .ready
        } catch {
            #if DEBUG
            Log.warn("Resource \"\(path)\" failed ->", error)
            #endif
            self.audioBuffer.state = .failed(
                error: GateEngineError.failedToDecode("\(error)")
            )
        }
    }
}

#endif
