/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public import WinSDK
import struct Foundation.Data

public struct D3DMessage: Swift.Error, CustomStringConvertible, Sendable {
    public typealias RawValue = WinSDK.D3D12_MESSAGE

    /// The message text, copied out of the transient `D3D12_MESSAGE` buffer at creation time.
    ///
    /// `RawValue` (`D3D12_MESSAGE`) contains a raw pointer that is only valid for the duration of
    /// the call that produced it, so it is never stored directly. Copying the description eagerly
    /// keeps `D3DMessage` genuinely safe to conform to `Sendable`.
    public let description: String

    public let sevarity: D3DMessageSeverity

    // Not `@inlinable`: unlike the other trivial inits in this file, this one calls into
    // Foundation's `String(bytes:encoding:)` / `String.Encoding`, which are not themselves
    // `@usableFromInline`. `-disable-access-control` (set for this target) only relaxes
    // access-level *diagnostics*; it does not make a non-`@usableFromInline` symbol eligible to
    // be referenced from an `@inlinable` body, so this must stay a regular internal function.
    internal init(_ rawValue: RawValue) {
        let buffer: UnsafeRawBufferPointer = UnsafeRawBufferPointer(start: rawValue.pDescription, count: Int(rawValue.DescriptionByteLength))
        self.description = String(bytes: buffer, encoding: .utf8) ?? String(bytes: buffer, encoding: .ascii) ?? String(cString: rawValue.pDescription)
        self.sevarity = D3DMessageSeverity(rawValue: rawValue.Severity)
    }
}
