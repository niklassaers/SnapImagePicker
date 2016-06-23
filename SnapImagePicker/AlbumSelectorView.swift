import UIKit

class AlbumSelectorView: UITableView {
    var albums: [PhotoAlbum]? {
        didSet {
            reloadData()
        }
    }
}

extension AlbumSelectorView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = dequeueReusableCellWithIdentifier("Album Preview Cell", forIndexPath: indexPath)
        
        if let albums = albums,
           let albumCell = cell as? AlbumSelectorViewCell
           where indexPath.row < albums.count {
            albumCell.album = albums[indexPath.row]
        }
        
        return cell
    }
}

class AlbumSelectorViewCell: UITableViewCell {
    @IBOutlet weak var albumPreviewImageView: UIImageView?
    @IBOutlet weak var albumNameLabel: UILabel? {
        didSet {
            if let font = SnapImagePicker.Theme.font {
                albumNameLabel?.font = font.fontWithSize(15)
            }
        }
    }
    @IBOutlet weak var albumSizeLabel: UILabel? {
        didSet {
            if let font = SnapImagePicker.Theme.font {
                albumSizeLabel?.font = font.fontWithSize(12)
                albumSizeLabel?.textColor = UIColor.grayColor()
            }
        }
    }
    
    var album: PhotoAlbum? {
        didSet {
            if let album = album {
                albumNameLabel?.text = album.title
                albumPreviewImageView?.image = album.image
                albumSizeLabel?.text = formatAlbumSize(album.size)
            }
        }
    }
    
    private func formatAlbumSize(size: Int) -> String {
        let suffix = size == 1 ? "image" : "images"
        
        return String(size) + " " + suffix
    }
}