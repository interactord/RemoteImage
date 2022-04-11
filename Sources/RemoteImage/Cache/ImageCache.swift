import Foundation
import UIKit

// MARK: - ImageCache

public protocol ImageCache {
  subscript(_: URL) -> CacheStore? { get set }
}

// MARK: - MemoryCache

public struct MemoryCache: ImageCache {

  // MARK: Public

  public static let shared = MemoryCache()

  public subscript(_ Key: URL) -> CacheStore? {
    get { cache.object(forKey: Key as NSURL) as? CacheStore }
    set {
      guard let value = newValue else { return cache.removeObject(forKey: Key as NSURL) }
      cache.setObject(value as AnyObject, forKey: Key as NSURL)
    }
  }

  // MARK: Private

  private enum Const {
    enum Limit {
      static let count = 100
      static let memory = 1024 * 1024 * 100
    }
  }

  private let cache: NSCache<NSURL, AnyObject> = {
    let cache = NSCache<NSURL, AnyObject>()
    cache.countLimit = Const.Limit.count
    cache.totalCostLimit = Const.Limit.memory
    return cache
  }()

}
