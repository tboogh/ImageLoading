//
//  ImageCardView.swift
//  NasaImages
//
//  Created by Tobias Boogh on 2021-04-27.
//
import Combine
import SwiftUI

struct ImageCardView: View {
    let photo: ApiPhoto
    
    @ObservedObject var imageLoader = ImageLoader()
    var body: some View {
        VStack{
            if imageLoader.image == nil {
                EmptyView()
                    .frame(height:300)
                    .padding(5)
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height:300)
                    .padding(5)
            }
            Text("\(photo.rover.name) \(photo.id)")
                .foregroundColor(.accentColor)
                .frame(height:50, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .bottom)
        }
        .background(Color.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            imageLoader.url = photo.url
        })
        .onDisappear(perform: {
            imageLoader.cancel()
        })
    }
    
    var image: Image {
        #if os(iOS) || os(watchOS) || os(tvOS)
        return Image(uiImage: imageLoader.image!)
        #elseif os(macOS)
        return Image(nsImage: imageLoader.image!)
            
        #endif
    }
}

struct ImageCardView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCardView(photo: .createMock())
            .previewLayout(.fixed(width: 320, height: 400))
    }
}
