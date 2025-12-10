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
public func atan2<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> T {
    switch lhs {
    #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    case is Float16:
        return T(_atan2(Float32(lhs), Float32(rhs)))
    #endif
    case is Float32:
        return T(_atan2(Float32(lhs), Float32(rhs)))
    case is Float64:
        return T(_atan2(Float64(lhs), Float64(rhs)))
    default:
        return T(_atan2(Float64(lhs), Float64(rhs)))
    }
}

// MARK: - Native

@usableFromInline
@_transparent
internal func _atan2(_ lhs: Float32, _ rhs: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.atan2f(lhs, rhs)
    #elseif canImport(Glibc)
    return Glibc.atan2f(lhs, rhs)
    #elseif canImport(Bionic)
    return Bionic.atan2f(lhs, rhs)
    #elseif canImport(Musl)
    return Musl.atan2f(lhs, rhs)
    #elseif canImport(WASILibc)
    return WASILibc.atan2f(lhs, rhs)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@usableFromInline
@_transparent
internal func _atan2(_ lhs: Float64, _ rhs: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.atan2(lhs, rhs)
    #elseif canImport(Glibc)
    return Glibc.atan2(lhs, rhs)
    #elseif canImport(Bionic)
    return Bionic.atan2(lhs, rhs)
    #elseif canImport(Musl)
    return Musl.atan2(lhs, rhs)
    #elseif canImport(WASILibc)
    return WASILibc.atan2(lhs, rhs)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@_transparent
@inlinable
public func atan2(_ lhs: Float32, _ rhs: Float32) -> Float32 {
    return _atan2(lhs, rhs)
}

@_transparent
@inlinable
public func atan2(_ lhs: Float64, _ rhs: Float64) -> Float64 {
    return _atan2(lhs, rhs)
}
