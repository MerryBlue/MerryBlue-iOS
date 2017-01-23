struct IdentifilerKey {
    static let homeCell = "home-cell:"
    static let listCell = "list-cell:"
}

class IdentifilerService {
    static let sharedInstance = IdentifilerService()

    func homeCellID(_ userID: String) -> String {
        return IdentifilerKey.homeCell + userID
    }

    func listCellID(_ listID: String) -> String {
        return IdentifilerKey.listCell + listID
    }

}
