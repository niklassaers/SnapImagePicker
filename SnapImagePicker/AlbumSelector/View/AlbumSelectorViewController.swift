import UIKit

class AlbumSelectorViewController: UITableViewController {
    var eventHandler: AlbumSelectorEventHandler?
    
    private struct Header {
        static let Height = CGFloat(40)
        static let FontSize = CGFloat(18)
        static let Font = SnapImagePicker.Theme.font?.fontWithSize(FontSize)
        static let Indentation = CGFloat(8)
    }
    
    private struct Cell {
        static let FontSize = CGFloat(15)
        static let Font = SnapImagePicker.Theme.font?.fontWithSize(FontSize)
    }
    
    private var collections: [(title: String, albums: [Album])]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        title = L10n.GeneralCollectionName.string
        eventHandler?.viewWillAppear()
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
            eventHandler?.albumClicked(collections[indexPath.section].albums[indexPath.row].type)
            navigationController?.popViewControllerAnimated(true)
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

