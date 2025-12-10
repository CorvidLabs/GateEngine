/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#endif

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func floor<T: FloatingPoint>(_ x: T) -> T {
    return x.rounded(.down)
}

// MARK: - Native

@inlinable
public func floor(_ x: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.floorf(x)
    #elseif canImport(Glibc)
    return Glibc.floorf(x)
    #elseif canImport(Bionic)
    return Bionic.floorf(x)
    #elseif canImport(Musl)
    return Musl.floorf(x)
    #elseif canImport(WASILibc)
    return WASILibc.floorf(x)
    #else
    return x.rounded(.down)
    #endif
}

@inlinable
public func floor(_ x: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.floor(x)
    #elseif canImport(Glibc)
    return Glibc.floor(x)
    #elseif canImport(Bionic)
    return Bionic.floor(x)
    #elseif canImport(Musl)
    return Musl.floor(x)
    #elseif canImport(WASILibc)
    return WASILibc.floor(x)
    #else
    return x.rounded(.down)
    #endif
}
