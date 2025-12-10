/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if HTML5
import WebAudio

@MainActor
internal final class WABufferReference: AudioBufferBackend {
    unowned let audioBuffer: AudioBuffer
    var buffer: WebAudio.AudioBuffer! = nil

    nonisolated var duration: Double {
        return MainActor.assumeIsolated { buffer.duration }
    }

    required nonisolated init(path: String, context: AudioContext, audioBuffer: AudioBuffer) {
        self.audioBuffer = audioBuffer
        Task { @MainActor in
            await self.loadAudio(path: path, context: context)
        }
    }

    private func loadAudio(path: String, context: AudioContext) async {
        let platform: WASIPlatform = Game.shared.platform
        let ctx = (context.reference as! WAContextReference).ctx

        do {
            self.buffer = try await ctx.decodeAudioData(
                audioData: try await platform.loadResourceAsArrayBuffer(from: path)
            )
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
