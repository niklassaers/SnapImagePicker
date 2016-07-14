@testable import SnapImagePicker
import UIKit

class SnapImagePickerEventHandlerSpy: SnapImagePickerEventHandlerProtocol {
    var viewWillAppearWithCellSizeCount = 0
    var viewWillAppearWithCellSize: CGFloat?
    
    var albumImageClickedCount = 0
    var albumImageClickedAtIndex: Int?
    
    var albumTitleClickedCount = 0
    
    var selectButtonPressedCount = 0
    var selectButtonPressedWithImage: UIImage?
    var selectButtonPressedWithOptions: ImageOptions?
    
    var numberOfSectionsForNumberOfColumnsCount = 0
    
    var numberOfItemsInSectionCount = 0
    var numberOfItemsInSection: Int?
    
    var presentCellCount = 0
    var presentCellAtIndex: Int?
    
    func viewWillAppearWithCellSize(cellSize: CGFloat) {
        viewWillAppearWithCellSizeCount += 1
        viewWillAppearWithCellSize = cellSize
    }
    
    func albumImageClicked(index: Int) -> Bool {
        albumImageClickedCount += 1
        albumImageClickedAtIndex = index
        
        return false
    }
    
    func albumTitleClicked(destinationViewController: UIViewController) {
        albumTitleClickedCount += 1
    }
    
    func selectButtonPressed(image: UIImage, withImageOptions: ImageOptions) {
        selectButtonPressedCount += 1
        selectButtonPressedWithImage = image
        selectButtonPressedWithOptions = withImageOptions
    }
    
    func numberOfSectionsForNumberOfColumns(columns: Int) -> Int {
        numberOfSectionsForNumberOfColumnsCount += 1
        
        return 0
    }
    
    func numberOfItemsInSection(section: Int, withColumns: Int) -> Int {
        numberOfItemsInSectionCount += 1
        numberOfItemsInSection = section
        
        return 0
    }
    
    func presentCell(cell: ImageCell, atIndex: Int) -> ImageCell {
        presentCellCount += 1
        presentCellAtIndex = atIndex
        
        return ImageCell()
    }
}
