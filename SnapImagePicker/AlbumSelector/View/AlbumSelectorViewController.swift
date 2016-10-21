import UIKit

class AlbumSelectorViewController: UITableViewController {
    var eventHandler: AlbumSelectorEventHandler?
    
    fileprivate struct Header {
        static let Height = CGFloat(40)
        static let FontSize = CGFloat(18)
        static let Font = SnapImagePickerTheme.font?.withSize(FontSize)
        static let Indentation = CGFloat(8)
    }
    
    fileprivate struct Cell {
        static let FontSize = CGFloat(15)
        static let Font = SnapImagePickerTheme.font?.withSize(FontSize)
    }
    
    fileprivate var collections: [(title: String, albums: [Album])]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventHandler?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTitleButton()
    }
    
    fileprivate func setupTitleButton() {
        let button = UIButton()
        button.titleLabel?.font = SnapImagePickerTheme.font
        button.setTitle(L10n.generalCollectionName.string, for: UIControlState())
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.setTitleColor(UIColor.init(red: 0xB8/0xFF, green: 0xB8/0xFF, blue: 0xB8/0xFF, alpha: 1), for: .highlighted)
        button.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
        if let image = UIImage(named: "icon_s_arrow_up_gray", in: Bundle(for: SnapImagePickerViewController.self), compatibleWith: nil),
            let cgImage = image.cgImage {
            let rotatedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .down)
            let highlightedImage = rotatedImage.setAlpha(0.3)
            if let mainCgImage = rotatedImage.cgImage,
               let highlightedCgImage = highlightedImage.cgImage,
               let navBarHeight = navigationController?.navigationBar.frame.height {
                let scale = image.findRoundedScale(image.size.height / (navBarHeight / 5))
                let scaledMainImage = UIImage(cgImage: mainCgImage, scale: scale, orientation: .up)
                let scaledHighlightedImage = UIImage(cgImage: highlightedCgImage, scale: scale * 2, orientation: .up)
                
                button.setImage(scaledMainImage, for: UIControlState())
                button.setImage(scaledHighlightedImage, for: .highlighted)
                button.frame = CGRect(x: 0, y: 0, width: scaledMainImage.size.width, height: scaledMainImage.size.height)
                
                button.rightAlignImage(scaledMainImage)
            }
        }
        navigationController?.navigationBar.topItem?.titleView = button
    }
    
    @IBAction func titleButtonPressed(_ sender: UIButton) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return collections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections?[section].albums.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Album Cell", for: indexPath)
        
        if let albumCell = cell as? AlbumCell {
            albumCell.album = collections?[(indexPath as NSIndexPath).section].albums[(indexPath as NSIndexPath).row]
            albumCell.displayFont = Cell.Font
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let collections = collections
           , (indexPath as NSIndexPath).section < collections.count && (indexPath as NSIndexPath).row < collections.count {
            eventHandler?.albumClicked(collections[(indexPath as NSIndexPath).section].albums[(indexPath as NSIndexPath).row].type, inNavigationController: self.navigationController)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : Header.Height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if section > 0 {
            view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: Header.Height)
            view.backgroundColor = UIColor.white
        
            let label = UILabel()
            label.frame = CGRect(x: Header.Indentation, y: 0, width: tableView.frame.width, height: Header.Height)
            label.font = Header.Font
            if collections?[section].title == AlbumType.CollectionNames.General {
                label.text = L10n.generalCollectionName.string
            } else if collections?[section].title == AlbumType.CollectionNames.UserDefined {
                label.text = L10n.userDefinedAlbumsCollectionName.string
            } else if collections?[section].title == AlbumType.CollectionNames.SmartAlbums {
                label.text = L10n.smartAlbumsCollectionName.string
            } else {
                print("Fetched collection with invalid name!")
                label.text = nil
            }
            view.addSubview(label)
        } else {
            view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        return view
    }
}

extension AlbumSelectorViewController: AlbumSelectorViewControllerProtocol {
    func display(_ collections: [(title: String, albums: [Album])]) {
        self.collections = collections
    }
}

