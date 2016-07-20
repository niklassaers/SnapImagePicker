// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum L10n {
  /// image
  case ImageLabelText
  /// images
  case SeveralImagesLabelText
  /// Cameraroll
  case GeneralCollectionName
  /// Albums
  case UserDefinedAlbumsCollectionName
  /// Smart Albums
  case SmartAlbumsCollectionName
  /// All Photos
  case AllPhotosAlbumName
  /// Favorites
  case FavoritesAlbumName
  /// Select
  case SelectButtonLabelText
}

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .ImageLabelText:
        return L10n.tr("imageLabelText")
      case .SeveralImagesLabelText:
        return L10n.tr("severalImagesLabelText")
      case .GeneralCollectionName:
        return L10n.tr("generalCollectionName")
      case .UserDefinedAlbumsCollectionName:
        return L10n.tr("userDefinedAlbumsCollectionName")
      case .SmartAlbumsCollectionName:
        return L10n.tr("smartAlbumsCollectionName")
      case .AllPhotosAlbumName:
        return L10n.tr("allPhotosAlbumName")
      case .FavoritesAlbumName:
        return L10n.tr("favoritesAlbumName")
      case .SelectButtonLabelText:
        return L10n.tr("selectButtonLabelText")
    }
  }

  private static func tr(key: String, _ args: CVarArgType...) -> String {
    let format = NSLocalizedString(key, bundle: NSBundle(forClass: SnapImagePicker.self), comment: "")
    return String(format: format, locale: NSLocale.currentLocale(), arguments: args)
  }
}

func tr(key: L10n) -> String {
  return key.string
}

