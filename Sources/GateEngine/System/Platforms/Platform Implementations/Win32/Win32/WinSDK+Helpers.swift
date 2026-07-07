/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
public import WinSDK

@_transparent
@_specialize(where T == UInt64)
@_specialize(where T == Int64)
internal func LOWORD<T: FixedWidthInteger>(_ w: T) -> WORD {
    return WORD((DWORD_PTR(w) >> 0) & 0xffff)
}

@_transparent
@_specialize(where T == UInt64)
@_specialize(where T == Int64)
internal func HIWORD<T: FixedWidthInteger>(_ w: T) -> WORD {
    return WORD((DWORD_PTR(w) >> 16) & 0xffff)
}

@_transparent
internal func GET_X_LPARAM(_ lParam: LPARAM) -> SHORT {
    return SHORT(bitPattern: LOWORD(lParam))
}

@_transparent
internal func GET_Y_LPARAM(_ lParam: LPARAM) -> SHORT {
    return SHORT(bitPattern: HIWORD(lParam))
}

@_transparent
internal func GET_WHEEL_DELTA_WPARAM(_ wParam: WPARAM) -> SHORT {
    return SHORT(bitPattern: HIWORD(wParam))
}

@_transparent
internal func GET_XBUTTON_WPARAM(_ wParam: WPARAM) -> INT {
    return INT(SHORT(bitPattern: HIWORD(wParam)))
}

@_transparent
internal func positionFrom(_ lparam: LPARAM) -> Position2 {
    let x: SHORT = GET_X_LPARAM(lparam)
    let y: SHORT = GET_Y_LPARAM(lparam)
    return Position2(Float(x), Float(y))
}

@_transparent
internal var QS_INPUT: DWORD {
    return DWORD(QS_MOUSE) | DWORD(QS_KEY) | DWORD(QS_RAWINPUT) | DWORD(QS_TOUCH)
        | DWORD(QS_POINTER)
}

@_transparent
internal var QS_ALLINPUT: DWORD {
    return QS_INPUT | DWORD(QS_POSTMESSAGE) | DWORD(QS_TIMER) | DWORD(QS_PAINT) | DWORD(QS_HOTKEY)
        | DWORD(QS_SENDMESSAGE)
}

func getFILETIMEoffset() -> WinSDK.LARGE_INTEGER {
    var s: SYSTEMTIME = WinSDK.SYSTEMTIME()
    var f: FILETIME = WinSDK.FILETIME()
    var t: LARGE_INTEGER = WinSDK.LARGE_INTEGER()

    s.wYear = 1970
    s.wMonth = 1
    s.wDay = 1
    s.wHour = 0
    s.wMinute = 0
    s.wSecond = 0
    s.wMilliseconds = 0
    WinSDK.SystemTimeToFileTime(&s, &f)
    t.QuadPart = WinSDK.LONGLONG(f.dwHighDateTime)
    t.QuadPart <<= 32
    t.QuadPart |= Int64(f.dwLowDateTime)
    return t
}

/// Lazily-initialized monotonic clock state backing the `clock_gettime` shim below.
///
/// `clock_gettime` is only ever driven synchronously from GateEngine's single timing
/// hot path (`InternalPlatformProtocol.systemTime()`), which the engine always calls
/// from one thread at a time, so there is no concurrent first-call race in practice.
/// Grouping the mutable fields into one holder -- instead of scattering
/// `nonisolated(unsafe)` across four separate globals -- keeps the unsafety contained
/// and documented in a single place.
private final class Win32ClockState {
    var offset: WinSDK.LARGE_INTEGER = WinSDK.LARGE_INTEGER()
    var frequencyToMicroseconds: Double = 0
    var initialized: Bool = false
    var usePerformanceCounter: Bool = false
}
nonisolated(unsafe) private let clockState: Win32ClockState = Win32ClockState()

internal struct timespec {
    var tv_sec: Double = 0
    var tv_nsec: Double = 0
}
let CLOCK_MONOTONIC_RAW = 1
internal func clock_gettime(_ X: Int, _ tv: inout timespec) -> Int {
    var t: WinSDK.LARGE_INTEGER = LARGE_INTEGER()
    var f: WinSDK.FILETIME = FILETIME()
    var microseconds: Double = 0

    if !clockState.initialized {
        var performanceFrequency: WinSDK.LARGE_INTEGER = WinSDK.LARGE_INTEGER()
        clockState.initialized = true
        clockState.usePerformanceCounter = WinSDK.QueryPerformanceFrequency(&performanceFrequency)
        if clockState.usePerformanceCounter {
            WinSDK.QueryPerformanceCounter(&clockState.offset)
            clockState.frequencyToMicroseconds = Double(performanceFrequency.QuadPart) / 1_000_000
        } else {
            clockState.offset = getFILETIMEoffset()
            clockState.frequencyToMicroseconds = 10
        }
    }
    if clockState.usePerformanceCounter {
        WinSDK.QueryPerformanceCounter(&t)
    } else {
        WinSDK.GetSystemTimeAsFileTime(&f)
        t.QuadPart = LONGLONG(f.dwHighDateTime)
        t.QuadPart <<= 32
        t.QuadPart |= Int64(f.dwLowDateTime)
    }

    t.QuadPart -= clockState.offset.QuadPart
    microseconds = Double(t.QuadPart) / clockState.frequencyToMicroseconds
    t.QuadPart = LONGLONG(microseconds)
    tv.tv_sec = Double(t.QuadPart) / 1_000_000
    tv.tv_nsec = Double(t.QuadPart).truncatingRemainder(dividingBy: 1_000_000)
    return 0
}

extension String {
    @inlinable
    init(windowsUTF8 lpcstr: LPCSTR) {
        self = withUnsafePointer(to: lpcstr) {
            return $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                return String(cString: $0)
            }
        }
    }

    @inlinable
    var windowsUTF8: [CHAR] {
        return self.withCString(encodedAs: UTF8.self) {
            return $0.withMemoryRebound(to: CHAR.self, capacity: self.utf8.count + 1) {
                return Array(UnsafeBufferPointer(start: $0, count: self.utf8.count + 1))
            }
        }
    }

    @inlinable
    init(windowsUTF16 lpcwstr: LPCWSTR) {
        self.init(decodingCString: lpcwstr, as: UTF16.self)
    }

    @inlinable
    var windowsUTF16: [WCHAR] {
        return self.withCString(encodedAs: UTF16.self) {
            return $0.withMemoryRebound(to: WCHAR.self, capacity: self.utf16.count + 1) {
                return Array(UnsafeBufferPointer(start: $0, count: self.utf16.count + 1))
            }
        }
    }
}

#endif
