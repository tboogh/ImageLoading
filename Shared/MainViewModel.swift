//
//  ImageViewModel.swift
//  NasaImages
//
//  Created by Tobias Boogh on 2021-04-27.
//
import Combine
import Foundation

class MainViewModel: ObservableObject {
    let api = NasaApi()
    var cancellables = Set<AnyCancellable>()
    @Published var photos: [ApiPhoto] = []
    
    func fetchImages() {
        api.getImages()
            .receive(on: DispatchQueue.main).sink { completion in
            switch(completion){
            case .finished:
                break
//                print("done")
            case .failure(_):
                break
//                print("failed: \(error)")
            }
        } receiveValue: { [weak self] photo in
//            print(photo.photos.count)
            guard let self = self else { return }
            self.photos = photo.photos
        }.store(in: &cancellables)

    }
}
