import Foundation

class AlbumPresenter {
    weak var viewController: AlbumViewControllerInput?
}

protocol AlbumPresenterInput : class {
    func presentImage(image: UIImage)
}

extension AlbumPresenter: AlbumPresenterInput {
    func presentImage(image: UIImage) {
        viewController?.displayImage(image)
    }
}