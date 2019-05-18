import Foundation

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

extension Array where Element: Equatable {
    mutating func move(from oldIndex: Int, to newIndex: Int) {
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}
