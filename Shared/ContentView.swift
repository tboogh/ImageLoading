//
//  ContentView.swift
//  Shared
//
//  Created by Tobias Boogh on 2021-04-27.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(viewModel.photos) { photo in
                    ImageCardView(photo: photo)
                        .frame(width:320)
                }
            }
        }
//        List(viewModel.photos) { photo in
//            ImageCardView(photo: photo)
//                .frame(width:320)
//        }
            .onAppear{
                viewModel.fetchImages()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
