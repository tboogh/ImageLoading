//
//  Cache.swift
//  NasaImages
//
//  Created by Tobias Boogh on 2021-04-27.
//

import Foundation

public final class Cache<Key: Hashable, Value> {
    
    private let cache : NSCache<WrappedKey, Entry>
    
    init() {
        let cache = NSCache<WrappedKey, Entry>()
        self.cache = cache
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        cache.setObject(entry, forKey: WrappedKey(key))
    }
    
    func value(forKey key: Key) -> Value? {
        let entry = cache.object(forKey: WrappedKey(key))
        return entry?.value
    }
    
    func removeValue(forKey key: Key){
        cache.removeObject(forKey: WrappedKey(key))
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

private extension Cache {
    
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
}

private extension Cache {
    
    final class Entry: NSObject {
        let value: Value
        
        init(value: Value) {
            self.value = value
        }
    }
}

public extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}
