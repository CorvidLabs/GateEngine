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

// MARK: - Integers

@inlinable
internal func _pow_recursive<T: FixedWidthInteger, E: FixedWidthInteger>(_ base: T, _ exponent: E) -> T {
    if exponent == 0 {
        return 1
    }
    let half_power: T = _pow_recursive(base, exponent / 2)
    if exponent % 2 == 0 {
        return half_power * half_power
    }
    return base * half_power * half_power
}

@inlinable
public func pow<T: FixedWidthInteger, E: FixedWidthInteger & SignedInteger>(_ base: T, _ exponent: E) -> T {
    if exponent < 0 {
        return 1 / _pow_recursive(base, -exponent)
    }
    return _pow_recursive(base, exponent)
}

@inlinable
public func pow<T: FixedWidthInteger, E: FixedWidthInteger & UnsignedInteger>(_ base: T, _ exponent: E) -> T {
    return _pow_recursive(base, exponent)
}


// MARK: - Floats

@inlinable
internal func _pow_recursive<T: FloatingPoint, E: FixedWidthInteger>(_ base: T, _ exponent: E) -> T {
    if exponent == 0 {
        return 1
    }
    let half_power: T = _pow_recursive(base, exponent / 2)
    if exponent % 2 == 0 {
        return half_power * half_power
    }
    return base * half_power * half_power
}

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func pow<T: FloatingPoint, E: FixedWidthInteger & SignedInteger>(_ base: T, _ exponent: E) -> T {
    if exponent < 0 {
        return 1 / _pow_recursive(base, -exponent)
    }
    return _pow_recursive(base, exponent)
}

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func pow<T: FloatingPoint, E: FixedWidthInteger & UnsignedInteger>(_ base: T, _ exponent: E) -> T {
    return _pow_recursive(base, exponent)
}


// MARK: - Native

@_transparent
@inlinable
public func pow(_ base: Float32, _ exponent: Float32) -> Float32 {
    #if canImport(Darwin)
    return Darwin.powf(base, exponent)
    #elseif canImport(Glibc)
    return Glibc.powf(base, exponent)
    #elseif canImport(Bionic)
    return Bionic.powf(base, exponent)
    #elseif canImport(Musl)
    return Musl.powf(base, exponent)
    #elseif canImport(WASILibc)
    return WASILibc.powf(base, exponent)
    #else
    // Fallback using integer exponent if available
    fatalError("Unsupported platform.")
    #endif
}

@_transparent
@inlinable
public func pow(_ base: Float64, _ exponent: Float64) -> Float64 {
    #if canImport(Darwin)
    return Darwin.pow(base, exponent)
    #elseif canImport(Glibc)
    return Glibc.pow(base, exponent)
    #elseif canImport(Bionic)
    return Bionic.pow(base, exponent)
    #elseif canImport(Musl)
    return Musl.pow(base, exponent)
    #elseif canImport(WASILibc)
    return WASILibc.pow(base, exponent)
    #else
    fatalError("Unsupported platform.")
    #endif
}
