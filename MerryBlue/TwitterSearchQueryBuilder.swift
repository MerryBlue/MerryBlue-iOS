class TwitterSearchQueryBuilder {

    enum Operator: String {
        case FilterImage = "filter:image"
    }

    var text = ""
    var isFilterImage = false
    var list: MBTwitterList!

    init(text: String) {
        self.text = text
    }

    func filterImage(isFilterImage: Bool = true) {
        self.isFilterImage = isFilterImage
    }

    func setList(list: MBTwitterList) {
        self.list = list
    }

    func build() -> String {
        let q = self.text
        var suffixList = [String]()
        if self.isFilterImage {
            suffixList.append(Operator.FilterImage.rawValue)
        }
        if let l = self.list {
            suffixList.append(l.fullName)
        }
        let suffix = suffixList.joinWithSeparator(" ")
        return q + " " + suffix
    }

}
