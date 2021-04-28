import Foundation
import SwiftUI
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
            image = nil
        }
    }
    
    var body: some View {
        VStack {
            if image == nil {
                EmptyView()
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
