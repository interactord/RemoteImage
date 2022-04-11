import Foundation
import UIKit

// MARK: - CacheStore

public struct CacheStore {

  // MARK: Public

  public enum ContentType {
    case original
    case fullWidth
    case thumbnail

    static var thumbnailScale: CGFloat { 0.5 }
  }

  // MARK: Internal

  struct Content {
    let origin: UIImage
    let fullWidth: UIImage
    let thumbnail: UIImage

    func getImage(type: ContentType) -> UIImage {
      switch type {
      case .original: return origin
      case .fullWidth: return fullWidth
      case .thumbnail: return thumbnail
      }
    }
  }

  let key: URL
  let content: Content
}

extension UIImage {
  func makeStore(url: URL) -> CacheStore {
    let origin = decodedImage()
    return .init(
      key: url,
      content: .init(
        origin: origin,
        fullWidth: origin.resizingBySreenWidth(),
        thumbnail: origin.resizing(scale: CacheStore.ContentType.thumbnailScale)))
  }
}
