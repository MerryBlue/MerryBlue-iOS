import TwitterKit

extension TWTRUser {
    func screenNameWithAt() -> String {
        return "@\(self.screenName)"
    }
}
