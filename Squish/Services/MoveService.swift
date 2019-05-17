import Foundation

class MoveService {

    let temporaryLocation: URL
    let destinationLocation: URL

    public static func call(temporary: URL, destination: URL) {
        MoveService(temporary: temporary, destination: destination).perform()
    }

    private init(temporary: URL, destination: URL) {
        self.temporaryLocation = temporary
        self.destinationLocation = destination
    }

    private func perform() {
        do {
            try FileManager.default.moveItem(at: temporaryLocation, to: destinationLocation)
        } catch {
            print(error)
        }
    }
}
