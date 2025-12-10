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
public func cos<T: BinaryFloatingPoint>(_ x: T) -> T {
    switch x {
    #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    case let x as Float16:
        return T(_cos(Float32(x)))
    #endif
    case let x as Float32:
        return T(_cos(x))
    case let x as Float64:
        return T(_cos(x))
    default:
        return T(_cos(Float64(x)))
    }
}

// MARK: - Native

internal func _cos(_ x: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.cosf(x)
    #elseif canImport(Glibc)
    return Glibc.cosf(x)
    #elseif canImport(Bionic)
    return Bionic.cosf(x)
    #elseif canImport(Musl)
    return Musl.cosf(x)
    #elseif canImport(WASILibc)
    return WASILibc.cosf(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

internal func _cos(_ x: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.cos(x)
    #elseif canImport(Glibc)
    return Glibc.cos(x)
    #elseif canImport(Bionic)
    return Bionic.cos(x)
    #elseif canImport(Musl)
    return Musl.cos(x)
    #elseif canImport(WASILibc)
    return WASILibc.cos(x)
    #else
    fatalError("Unsupported platform.")
    #endif
}

public func cos(_ x: Float32) -> Float32 {
    return _cos(x)
}

public func cos(_ x: Float64) -> Float64 {
    return _cos(x)
}
