import UIKit
class AlertManager {
    static let sharedInstantce = AlertManager()

    func listNotFound() -> UIAlertController {
        let ac = UIAlertController(
            title: "リストが見つかりませんでした",
            message: "このアカウントはリストを作成, フォローしていません",
            preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return ac
    }

    func listMemberLimit() -> UIAlertController {
        let ac = UIAlertController(
            title: "メンバー数制限",
            message: "メンバー数が多すぎます(\(MBTwitterList.memberNumActiveMaxLimit)人まで), このリストは TimelineView のみ使えます",
            preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return ac
    }

    func listSyncDisable() -> UIAlertController {
        let ac = UIAlertController(
            title: "リスト編集中",
            message: "編集状態を完了してからリストの更新を行ってください",
            preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return ac
    }

    func disableTabSpecialTab() -> UIAlertController {
        let ac = UIAlertController(
            title: "特別なリスト",
            message: "このリストでは Timeline タブは使えません",
            preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return ac
    }

    func disableOpenApp() -> UIAlertController {
        let ac = UIAlertController(
            title: "アプリ起動エラー",
            message: "なんらかの理由で Safari や Twitter が開けません",
            preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return ac
    }

}
