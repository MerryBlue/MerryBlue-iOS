class TwitterSearchQueryBuilder {

    enum Operator: String {
        case FilterImage = "filter:image"
    }

    var text = ""
    var isFilterImage = false

    init(text: String) {
        self.text = text
    }

    func filterImage(isFilterImage: Bool = true) {
        self.isFilterImage = isFilterImage
    }

    func build() -> String {
        let q = self.text
        var operators = [Operator]()
        if self.isFilterImage {
            operators.append(.FilterImage)
        }
        let suffix = (operators.map { (op: Operator) -> String in
            return op.rawValue
        }).joinWithSeparator(" ")
        return q + " " + suffix
    }

}