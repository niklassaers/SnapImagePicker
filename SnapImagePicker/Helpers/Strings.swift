// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum L10n {
  /// image
  case imageLabelText
  /// images
  case severalImagesLabelText
  /// Cameraroll
  case generalCollectionName
  /// Albums
  case userDefinedAlbumsCollectionName
  /// Smart Albums
  case smartAlbumsCollectionName
  /// All Photos
  case allPhotosAlbumName
  /// Favorites
  case favoritesAlbumName
  /// Select
  case selectButtonLabelText
}

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .imageLabelText:
        return L10n.tr("imageLabelText")
      case .severalImagesLabelText:
        return L10n.tr("severalImagesLabelText")
      case .generalCollectionName:
        return L10n.tr("generalCollectionName")
      case .userDefinedAlbumsCollectionName:
        return L10n.tr("userDefinedAlbumsCollectionName")
      case .smartAlbumsCollectionName:
        return L10n.tr("smartAlbumsCollectionName")
      case .allPhotosAlbumName:
        return L10n.tr("allPhotosAlbumName")
      case .favoritesAlbumName:
        return L10n.tr("favoritesAlbumName")
      case .selectButtonLabelText:
        return L10n.tr("selectButtonLabelText")
    }
  }

  fileprivate static func tr(_ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, bundle: Bundle(for: SnapImagePickerViewController.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

func tr(_ key: L10n) -> String {
  return key.string
}

