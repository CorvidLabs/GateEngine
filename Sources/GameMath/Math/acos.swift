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
public func acos<T: BinaryFloatingPoint>(_ x: T) -> T {
    switch x {
    #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    case let x as Float16:
        return T(_acos(Float32(x)))
    #endif
    case let x as Float32:
        return T(_acos(x))
    case let x as Float64:
        return T(_acos(x))
    default:
        return T(_acos(Float64(x)))
    }
}

// MARK: - Native

@usableFromInline
@_transparent
internal func _acos(_ x: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.acosf(x)
    #elseif canImport(Glibc)
    return Glibc.acosf(x)
    #elseif canImport(Bionic)
    return Bionic.acosf(x)
    #elseif canImport(Musl)
    return Musl.acosf(x)
    #elseif canImport(WASILibc)
    return WASILibc.acosf(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@usableFromInline
@_transparent
internal func _acos(_ x: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.acos(x)
    #elseif canImport(Glibc)
    return Glibc.acos(x)
    #elseif canImport(Bionic)
    return Bionic.acos(x)
    #elseif canImport(Musl)
    return Musl.acos(x)
    #elseif canImport(WASILibc)
    return WASILibc.acos(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@_transparent
@inlinable
public func acos(_ x: Float32) -> Float32 {
    return _acos(x)
}

@_transparent
@inlinable
public func acos(_ x: Float64) -> Float64 {
    return _acos(x)
}
