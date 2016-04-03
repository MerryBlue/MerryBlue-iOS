import SlideMenuControllerSwift

class StoryBoardService {

    static let sharedInstance = StoryBoardService()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)


    func mainViewController() -> UIViewController {
        let mainView = storyboard.instantiateViewControllerWithIdentifier("main")
        let leftMenuView = storyboard.instantiateViewControllerWithIdentifier("menu")
        return SlideMenuController(mainViewController: mainView, leftMenuViewController: leftMenuView)
    }

    func signInViewController() -> UIViewController {
        return storyboard.instantiateViewControllerWithIdentifier("login")
    }

    func userNavView() -> UIViewController {
        return MBNavigationController(rootViewController: UserTimelineViewController())
    }

}
