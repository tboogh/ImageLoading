import Combine
import Foundation
import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
typealias OSImage = UIImage
#elseif os(macOS)
typealias OSImage = NSImage
#endif


class ImageLoader: ObservableObject {
    
    @Published var image: OSImage? = nil
    var cancellable: AnyCancellable?
    
    var url: String = "" {
        didSet {
            cancel()
            loadImage(url: url)
        }
    }
    
    func cancel(){
        cancellable?.cancel()
        cancellable = nil
        image = nil
    }
    
    private func loadImage(url: String) {
        let cachedData = ImageCache.shared.cache[url]
        if cachedData != nil {
            image = OSImage(data: cachedData!)
            return
        }
        
        cancellable = URLSession(configuration: .default)
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
                self.cancellable = nil
            } receiveValue: { [weak self] result in
                ImageCache.shared.cache[url] = result
                guard let self = self else { return }
                self.image = OSImage(data: result)
            }
    }
}
