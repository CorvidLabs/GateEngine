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
public func sin<T: BinaryFloatingPoint>(_ x: T) -> T {
    switch x {
    #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    case let x as Float16:
        return T(_sin(Float32(x)))
    #endif
    case let x as Float32:
        return T(_sin(x))
    case let x as Float64:
        return T(_sin(x))
    default:
        return T(_sin(Float64(x)))
    }
}

// MARK: - Native

@usableFromInline
internal func _sin(_ x: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.sinf(x)
    #elseif canImport(Glibc)
    return Glibc.sinf(x)
    #elseif canImport(Bionic)
    return Bionic.sinf(x)
    #elseif canImport(Musl)
    return Musl.sinf(x)
    #elseif canImport(WASILibc)
    return WASILibc.sinf(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@usableFromInline
internal func _sin(_ x: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.sin(x)
    #elseif canImport(Glibc)
    return Glibc.sin(x)
    #elseif canImport(Bionic)
    return Bionic.sin(x)
    #elseif canImport(Musl)
    return Musl.sin(x)
    #elseif canImport(WASILibc)
    return WASILibc.sin(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@inlinable
public func sin(_ x: Float32) -> Float32 {
    return _sin(x)
}

@inlinable
public func sin(_ x: Float64) -> Float64 {
    return _sin(x)
}
