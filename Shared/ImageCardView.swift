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
    
//    @ObservedObject var imageLoader = ImageLoader()
    @State var display: Bool = false
    var body: some View {
        VStack{
            AsyncImage(display: display, url: photo.url)
                .frame(height:300)
                .padding(5)
            Text("\(photo.rover.name) \(photo.id)")
                .foregroundColor(.accentColor)
                .frame(height:50, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .bottom)
        }
        .background(Color.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            display = true
        })
        .onDisappear(perform: {
            display = false
//            imageLoader.cancel()
        })
    }
}

struct ImageCardView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCardView(photo: .createMock())
            .previewLayout(.fixed(width: 320, height: 400))
    }
}
