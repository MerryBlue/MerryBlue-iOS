class TwitterSearchQueryBuilder {

    enum Operator: String {
        case FilterImage = "filter:images"
        case ExcludeRT = "exclude:retweets"
        case List = "list:"
    }

    var text = ""
    var isFilterImage = false
    var isExcludeRT = false
    var list: MBTwitterList!

    init(text: String) {
        self.text = text
    }

    func filterImage(_ isFilterImage: Bool = true) {
        self.isFilterImage = isFilterImage
    }

    func excludeRT(_ isExcludeRT: Bool = true) {
        self.isExcludeRT = isExcludeRT
    }

    func setList(_ list: MBTwitterList) {
        self.list = list
    }

    func build() -> String {
        let q = self.text
        var suffixList = [String]()
        if self.isFilterImage {
            suffixList.append(Operator.FilterImage.rawValue)
        }
        if self.isExcludeRT {
            suffixList.append(Operator.ExcludeRT.rawValue)
        }
        if let l = self.list {
            suffixList.append(Operator.List.rawValue + l.fullName)
        }
        let suffix = suffixList.joined(separator: " ")
        return q + " " + suffix
    }

}
