import UIKit

class AlbumSelectorViewController: UITableViewController {
    var eventHandler: AlbumSelectorEventHandler?
    
    private struct Header {
        static let Height = CGFloat(40)
        static let FontSize = CGFloat(18)
        static let Font = SnapImagePickerTheme.font?.fontWithSize(FontSize)
        static let Indentation = CGFloat(8)
    }
    
    private struct Cell {
        static let FontSize = CGFloat(15)
        static let Font = SnapImagePickerTheme.font?.fontWithSize(FontSize)
    }
    
    private var collections: [(title: String, albums: [Album])]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        eventHandler?.viewWillAppear()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupTitleButton()
    }
    
    private func setupTitleButton() {
        let button = UIButton()
        button.titleLabel?.font = SnapImagePickerTheme.font
        button.setTitle(L10n.GeneralCollectionName.string, forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.setTitleColor(UIColor.init(red: 0xB8/0xFF, green: 0xB8/0xFF, blue: 0xB8/0xFF, alpha: 1), forState: .Highlighted)
        button.addTarget(self, action: #selector(titleButtonPressed), forControlEvents: .TouchUpInside)
        if let mainImage = UIImage(named: "open_downwards_arrow", inBundle: NSBundle(forClass: SnapImagePickerViewController.self), compatibleWithTraitCollection: nil),
            let mainCgImage = mainImage.CGImage,
            let highlightedImage = UIImage(named: "open_downwards_arrow_highlighted", inBundle: NSBundle(forClass: SnapImagePickerViewController.self), compatibleWithTraitCollection: nil),
            let highlightedCgImage = highlightedImage.CGImage,
            let navBarHeight = navigationController?.navigationBar.frame.height {
            let scale = mainImage.size.height / navBarHeight * 2
            let scaledMainImage = UIImage(CGImage: mainCgImage, scale: scale, orientation: .Down)
            let scaledHighlightedImage = UIImage(CGImage: highlightedCgImage, scale: scale, orientation: .Down)
            
            button.setImage(scaledMainImage, forState: .Normal)
            button.setImage(scaledHighlightedImage, forState: .Highlighted)
            button.frame = CGRect(x: 0, y: 0, width: scaledMainImage.size.width, height: scaledMainImage.size.height)
        }
        navigationController?.navigationBar.topItem?.titleView = button
    }
    
    @IBAction func titleButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return collections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections?[section].albums.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Album Cell", forIndexPath: indexPath)
        
        if let albumCell = cell as? AlbumCell {
            albumCell.album = collections?[indexPath.section].albums[indexPath.row]
            albumCell.displayFont = Cell.Font
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let collections = collections
           where indexPath.section < collections.count && indexPath.row < collections.count {
            eventHandler?.albumClicked(collections[indexPath.section].albums[indexPath.row].type, inNavigationController: self.navigationController)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : Header.Height
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if section > 0 {
            view.frame = CGRectMake(0, 0, tableView.frame.width, Header.Height)
            view.backgroundColor = UIColor.whiteColor()
        
            let label = UILabel()
            label.frame = CGRectMake(Header.Indentation, 0, tableView.frame.width, Header.Height)
            label.font = Header.Font
            if collections?[section].title == AlbumType.CollectionNames.General {
                label.text = L10n.GeneralCollectionName.string
            } else if collections?[section].title == AlbumType.CollectionNames.UserDefined {
                label.text = L10n.UserDefinedAlbumsCollectionName.string
            } else if collections?[section].title == AlbumType.CollectionNames.SmartAlbums {
                label.text = L10n.SmartAlbumsCollectionName.string
            } else {
                print("Fetched collection with invalid name!")
                label.text = nil
            }
            view.addSubview(label)
        } else {
            view.frame = CGRectMake(0, 0, 0, 0)
        }
        return view
    }
}

extension AlbumSelectorViewController: AlbumSelectorViewControllerProtocol {
    func display(collections: [(title: String, albums: [Album])]) {
        self.collections = collections
    }
}

