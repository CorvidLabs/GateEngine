/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Array {
    @_transparent
    init(minimumCapacity: Int) {
        self = []
        self.reserveCapacity(minimumCapacity)
    }
}

public extension ContiguousArray {
    @_transparent
    init(minimumCapacity: Int) {
        self = []
        self.reserveCapacity(minimumCapacity)
    }
}

public extension Set {
    @_transparent
    init(minimumCapacity: Int) {
        self = []
        self.reserveCapacity(minimumCapacity)
    }
}

#if canImport(OrderedCollections)
public import OrderedCollections

public extension OrderedSet {
    @_transparent
    init(minimumCapacity: Int) {
        self = []
        self.reserveCapacity(minimumCapacity)
    }
}

#endif
