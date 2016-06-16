import UIKit

class AlbumSelectorViewController: UITableViewController {
    weak var delegate: SnapImagePickerDelegate?
    var interactor: AlbumSelectorInteractorInput?
    private var albums: [PhotoAlbum]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        print("View did load")
        if let interactor = interactor {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                interactor.fetchAlbums()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albums = albums where section == 0 {
            return albums.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("Album Cell", forIndexPath: indexPath) as? AlbumCell,
            let albums = albums {
            let album = albums[indexPath.row]
            cell.nameLabel?.text = album.title
            cell.sizeLabel?.text = String(album.size) + " photos"
            cell.firstImageView?.image = album.image
            
            return cell
        }
        
        return UITableViewCell()
    }
}

protocol AlbumSelectorViewControllerInput : class {
    func displayAlbum(album: PhotoAlbum)
}

extension AlbumSelectorViewController: AlbumSelectorViewControllerInput {
    func displayAlbum(album: PhotoAlbum) {
        if let currentAlbums = self.albums {
            if !currentAlbums.contains(album) {
                self.albums?.append(album) 
            }
        } else {
            self.albums = [album]
        }
    }
}

//extension AlbumSelectorViewController {
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//            case "Show Album":
//                if let cell = sender as? AlbumCell,
//                   let vc = segue.destinationViewController as? ImageSelectorViewController {
//                    if let image = cell.firstImageView?.image {
//                        vc.selectedImage = image
//                        vc.title = cell.nameLabel?.text
//                        vc.delegate = delegate
//                    }
//                }
//            default: break
//            }
//        }
//    }
//}
