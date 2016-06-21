import UIKit

class AlbumSelectorView: UITableView {
    var albums: [PhotoAlbum]?
}

extension AlbumSelectorView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albums = albums {
            return albums.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let albums = albums,
           let cell = dequeueReusableCellWithIdentifier("Album Preview Cell", forIndexPath: indexPath) as? AlbumSelectorViewCell
           where indexPath.row < albums.count {
            cell.albumNameLabel?.text = albums[indexPath.row].title
            cell.albumSizeLabel?.text = String(albums[indexPath.row].size)
            cell.albumPreviewImageView?.image = albums[indexPath.row].image
            
            return cell
        }
        
        return UITableViewCell()
    }
}

class AlbumSelectorViewCell: UITableViewCell {
    @IBOutlet weak var albumNameLabel: UILabel?
    @IBOutlet weak var albumPreviewImageView: UIImageView?
    @IBOutlet weak var albumSizeLabel: UILabel?
}