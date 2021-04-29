import Combine
import Foundation
import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
typealias OSImage = UIImage
#elseif os(macOS)
typealias OSImage = NSImage
#endif

class ImageLoading {
    static let instance = ImageLoading()
    
    let images = PassthroughSubject<(key: String, image: OSImage), Never>()
    
    var cancellables = [String: AnyCancellable]()
    
    func cancel(url: String) {
//        print("cancel: \(url)")
        guard let cancellable = cancellables[url] else {
            return
        }
        cancellable.cancel()
        cancellables.removeValue(forKey: url)
    }
    
    func loadImage(url: String) {
//        print("load: \(url)")
        let cachedData = ImageCache.shared.cache[url]
        if cachedData != nil {
            let image = OSImage(data: cachedData!)
            if image != nil {
                images.send((url, image!))
                return
            }
        }
        
        let cancellable = URLSession(configuration: .default)
            .dataTaskPublisher(for: URL(string: url)!)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.cancellables.removeValue(forKey: url)
            } receiveValue: { [weak self] result in
                ImageCache.shared.cache[url] = result
                guard let self = self else { return }
                let image = OSImage(data: result)
                if image != nil {
                    self.images.send((url, image!))
                    return
                }
            }
        cancellables[url] = cancellable
    }
}
