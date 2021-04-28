import Combine
import Foundation
import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
typealias OSImage = UIImage
#elseif os(macOS)
typealias OSImage = NSImage
#endif

protocol Initializable {
    init()
}

struct AsyncImage: View {
    
    @State private var image: OSImage?
    var display: Bool
    let url: String
    
    init(display: Bool, url: String) {
        self.display = display
        self.url = url
        if (display) {
            ImageLoading.instance.loadImage(url: url)
        } else {
            ImageLoading.instance.cancel(url: url)
        }
    }
    
    var body: some View {
        Group {
            if image == nil {
                EmptyView()
                    .onAppear{
                        print("dude?!")
                    }
            } else {
                #if os(iOS) || os(watchOS) || os(tvOS)
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                #elseif os(macOS)
                Image(nsImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                #endif
            }
        }
        .onReceive(ImageLoading.instance.images) { result in
            print("recieve")
            if (result.key == url){
                image = result.image
            }
        }
    }
}

class ImageLoading {
    static let instance = ImageLoading()
    
    let images = PassthroughSubject<(key: String, image: OSImage), Never>()
    
    var cancellables = [String: AnyCancellable]()
    
    func cancel(url: String) {
        print("cancel: \(url)")
        guard let cancellable = cancellables[url] else {
            return
        }
        cancellable.cancel()
        cancellables.removeValue(forKey: url)
    }
    
    func loadImage(url: String) {
        print("load: \(url)")
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
