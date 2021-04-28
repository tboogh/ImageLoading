import Foundation

class ImageCache {
    let cache = Cache<String, Data>()
    
    static let shared = ImageCache()
}
