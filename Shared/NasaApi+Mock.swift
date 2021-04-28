extension ApiPhoto {
    static func createMock() -> ApiPhoto {
        ApiPhoto(id: 0, sol: 0, earthDate: "1985/10/21", camera: .createMock(), imgSrc: "https://mars.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/01000/opgs/edr/fcam/FLB_486265257EDR_F0481570FHAZ00323M_.JPG", rover: .createMock())
    }
}

extension Rover {
    static func createMock() -> Rover {
        Rover(id: 1, name: "Rover", landingDate: "1985/10/21", launchDate: "1984/12/23", status: "Active")
    }
}

extension Camera {
    static func createMock() -> Camera {
        Camera(id: 0, name: "Pentax", roverId: 1, fullName: "Good camera")
    }
}
