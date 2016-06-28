import UIKit

class AlbumSelectorViewController: UITableViewController {
    var eventHandler: AlbumSelectorEventHandler?
    
    private struct Header {
        static let Height = CGFloat(40)
        static let FontSize = CGFloat(18)
        static let Font = SnapImagePickerConnector.Theme.font?.fontWithSize(FontSize)
        static let Indentation = CGFloat(8)
    }
    
    private struct Cell {
        static let FontSize = CGFloat(15)
        static let Font = SnapImagePickerConnector.Theme.font?.fontWithSize(FontSize)
    }
    
    private var collectionTitles = [String]()
    private var collections = [[Album]]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        eventHandler?.viewWillAppear()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return collections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < collections.count {
            return collections[section].count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < collectionTitles.count {
            return collectionTitles[section]
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Album Cell", forIndexPath: indexPath)
        
        if let albumCell = cell as? AlbumCell {
            albumCell.album = collections[indexPath.section][indexPath.row]
            albumCell.displayFont = Cell.Font
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section < collections.count && indexPath.row < collections.count {
            eventHandler?.albumSelected(collections[indexPath.section][indexPath.row].title)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Header.Height
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.frame = CGRectMake(0, 0, tableView.frame.width, Header.Height)
        view.backgroundColor = UIColor.whiteColor()
        
        let label = UILabel()
        label.frame = CGRectMake(Header.Indentation, 0, tableView.frame.width, Header.Height)
        label.font = Header.Font
        label.text = collectionTitles[section]
        view.addSubview(label)
        
        return view
    }
}

extension AlbumSelectorViewController: AlbumSelectorViewControllerProtocol {
    func display(collections: [String: [Album]]) {
        collectionTitles = [String]()
        self.collections = [[Album]]()
        for (title, collection) in collections {
            collectionTitles.append(title)
            self.collections.append(collection)
        }
    }
}

