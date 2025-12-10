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
public func tan<T: BinaryFloatingPoint>(_ x: T) -> T {
    switch x {
    #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    case let x as Float16:
        return T(_tan(Float32(x)))
    #endif
    case let x as Float32:
        return T(_tan(x))
    case let x as Float64:
        return T(_tan(x))
    default:
        return T(_tan(Float64(x)))
    }
}

// MARK: - Native

@usableFromInline
@_transparent
internal func _tan(_ x: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.tanf(x)
    #elseif canImport(Glibc)
    return Glibc.tanf(x)
    #elseif canImport(Bionic)
    return Bionic.tanf(x)
    #elseif canImport(Musl)
    return Musl.tanf(x)
    #elseif canImport(WASILibc)
    return WASILibc.tanf(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@usableFromInline
@_transparent
internal func _tan(_ x: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.tan(x)
    #elseif canImport(Glibc)
    return Glibc.tan(x)
    #elseif canImport(Bionic)
    return Bionic.tan(x)
    #elseif canImport(Musl)
    return Musl.tan(x)
    #elseif canImport(WASILibc)
    return WASILibc.tan(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

@_transparent
@inlinable
public func tan(_ x: Float32) -> Float32 {
    return _tan(x)
}

@_transparent
@inlinable
public func tan(_ x: Float64) -> Float64 {
    return _tan(x)
}
