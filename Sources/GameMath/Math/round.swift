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
public func round<T: FloatingPoint>(_ x: T) -> T {
    return x.rounded(.toNearestOrAwayFromZero)
}

// MARK: - Native

@_transparent
@inlinable
public func round(_ x: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.roundf(x)
    #elseif canImport(Glibc)
    return Glibc.roundf(x)
    #elseif canImport(Bionic)
    return Bionic.roundf(x)
    #elseif canImport(Musl)
    return Musl.roundf(x)
    #elseif canImport(WASILibc)
    return WASILibc.roundf(x)
    #else
    return x.rounded(.toNearestOrAwayFromZero)
    #endif
}

@_transparent
@inlinable
public func round(_ x: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.round(x)
    #elseif canImport(Glibc)
    return Glibc.round(x)
    #elseif canImport(Bionic)
    return Bionic.round(x)
    #elseif canImport(Musl)
    return Musl.round(x)
    #elseif canImport(WASILibc)
    return WASILibc.round(x)
    #else
    return x.rounded(.toNearestOrAwayFromZero)
    #endif
}
