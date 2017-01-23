import SlideMenuControllerSwift

class StoryBoardService {

    static let sharedInstance = StoryBoardService()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)


    func mainViewController() -> UIViewController {
        let mainView = storyboard.instantiateViewController(withIdentifier: "main")
        let leftMenuView = storyboard.instantiateViewController(withIdentifier: "menu")
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false
        return SlideMenuController(mainViewController: mainView, leftMenuViewController: leftMenuView)
    }

    func signInViewController() -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: "login")
    }

    func userView() -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: "user-view")
    }

    func showTweetView() -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: "show-tweet")
    }

    func navHomeViewController() -> UINavigationController {
        return (storyboard.instantiateViewController(withIdentifier: "home-nav") as? UINavigationController)!
    }

    func photoViewController() -> PhotoViewController {
        return (storyboard.instantiateViewController(withIdentifier: "photo-view") as? PhotoViewController)!
    }
}
