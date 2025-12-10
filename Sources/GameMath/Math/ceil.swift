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
public func ceil<T: FloatingPoint>(_ x: T) -> T {
    return x.rounded(.up)
}

// MARK: - Native

@inlinable
public func ceil(_ x: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.ceilf(x)
    #elseif canImport(Glibc)
    return Glibc.ceilf(x)
    #elseif canImport(Bionic)
    return Bionic.ceilf(x)
    #elseif canImport(Musl)
    return Musl.ceilf(x)
    #elseif canImport(WASILibc)
    return WASILibc.ceilf(x)
    #else
    return x.rounded(.up)
    #endif
}

@inlinable
public func ceil(_ x: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.ceil(x)
    #elseif canImport(Glibc)
    return Glibc.ceil(x)
    #elseif canImport(Bionic)
    return Bionic.ceil(x)
    #elseif canImport(Musl)
    return Musl.ceil(x)
    #elseif canImport(WASILibc)
    return WASILibc.ceil(x)
    #else
    return x.rounded(.up)
    #endif
}
