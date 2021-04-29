//
//  NasaApi.swift
//  NasaImages
//
//  Created by Tobias Boogh on 2021-04-27.
//
import Combine
import Foundation

struct ApiPhotos: Codable {
    let photos: [ApiPhoto]
}

struct ApiPhoto: Identifiable, Codable {
    internal init(id: Int, sol: Int, earthDate: String, camera: Camera, imgSrc: String, rover: Rover) {
        self.id = id
        self.sol = sol
        self.earthDate = earthDate
        self.camera = camera
        self.imgSrc = imgSrc
        self.rover = rover
        self.url = imgSrc.replacingOccurrences(of: "http:", with: "https:")
    }
    
    let id: Int
    let sol: Int
    let earthDate: String
    let camera: Camera
    let imgSrc: String
    let rover: Rover
    let url: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sol = try values.decode(Int.self, forKey: .sol)
        earthDate = try values.decode(String.self, forKey: .earthDate)
        camera = try values.decode(Camera.self, forKey: .camera)
        imgSrc = try values.decode(String.self, forKey: .imgSrc)
        rover = try values.decode(Rover.self, forKey: .rover)
        url = imgSrc.replacingOccurrences(of: "http:", with: "https:")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sol
        case earthDate = "earth_date"
        case camera
        case imgSrc = "img_src"
        case rover
    }
}

struct Camera: Identifiable, Codable {
    let id: Int
    let name: String
    let roverId: Int
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roverId = "rover_id"
        case fullName = "full_name"
    }
}

struct Rover: Identifiable, Codable {
    let id: Int
    let name: String
    let landingDate: String
    let launchDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case landingDate = "landing_date"
        case launchDate = "launch_date"
        case status
    }
}

class NasaApi {
    private let url = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1000&api_key=vkkSWglgmg5YdrieWS3s3sdTmN1gEwfedrwmgzBU"
    
    func getImages() -> AnyPublisher<ApiPhotos, Error> {
        let urlSession = URLSession.init(configuration: .default)
        let publisher = urlSession.dataTaskPublisher(for: URL(string: url)!)
            .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                        httpResponse.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                        }
                    return element.data
                    }
                .decode(type: ApiPhotos.self, decoder: JSONDecoder())
        return publisher.eraseToAnyPublisher()
    }
}
