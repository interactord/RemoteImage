import SwiftUI

// MARK: - ImageCacheKey

struct ImageCacheKey: EnvironmentKey {
  static let defaultValue: ImageCache = MemoryCache.shared
}

extension EnvironmentValues {
  var imageCache: ImageCache {
    get { self[ImageCacheKey.self] }
    set { self[ImageCacheKey.self] = newValue }
  }
}
