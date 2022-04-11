import Combine
import Foundation
import UIKit
import SwiftUI

// MARK: - ImageLoader

public final class ImageLoader: ObservableObject {

  // MARK: Lifecycle

  public init() {
  }

  deinit {
    cancel()
  }

  // MARK: Internal

  @Published var image: UIImage?
  @Published var phase: RemoteImagePhase = .empty

  private(set) var isLoading = false

  func load(url: URL, type: CacheStore.ContentType) {
    guard !isLoading else { return }

    if let store = cache?[url] {
      image = store.content.getImage(type: type)
      return
    }

    cancellable = URLSession.shared.dataTaskPublisher(for: url)
      .map { UIImage(data: $0.data) }
      .replaceError(with: .none)
      .handleEvents(
        receiveSubscription: { [weak self] _ in self?.onStart() },
        receiveOutput: { [weak self] image in self?.cache(url: url, image: image) },
        receiveCompletion: { [weak self] _ in self?.onFinish() },
        receiveCancel: { [weak self] in self?.onFinish() })
      .subscribe(on: Self.imageProcessingQueue)
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] _ in
        guard let self = self else { return }
        guard let store = self.cache?[url] else { return }
        self.image = store.content.getImage(type: type)
      })
  }

  func cancel() {
    cancellable?.cancel()
  }

  func onStart() {
    isLoading = true
  }

  func onFinish() {
    isLoading = false
  }

  // MARK: Private

  private static let imageProcessingQueue = DispatchQueue(label: "io.interactord.remoteImage.imageCache")

  private var cache: ImageCache?
  private var cancellable: AnyCancellable?

  private func cache(url: URL, image: UIImage?) {
    image.map {
      cache?[url] = $0.makeStore(url: url)
    }

    if let image = image {
      DispatchQueue.main.async { [weak self] in
        self?.phase = .success(Image(uiImage: image))
      }
    }
  }
}

// MARK: UIKit Support

extension ImageLoader {
  public func fetch(url: String, type: CacheStore.ContentType) -> AnyPublisher<UIImage?, Never> {
    guard let url = URL(string: url) else {
      return Just(.none)
        .eraseToAnyPublisher()
    }
    if let store = cache?[url] {
      return Just(store.content.getImage(type: type))
        .eraseToAnyPublisher()
    }

    return URLSession
      .shared
      .dataTaskPublisher(for: url)
      .map(\.data)
      .map(UIImage.init(data:))
      .catch { _ in Just(.none) }
      .handleEvents(receiveOutput: { [weak self] image in
        guard let self = self else { return }
        self.cache?[url] = image?.makeStore(url: url)
      })
      .map { [weak self] image in
        guard let self = self else { return image }
        guard let store = self.cache?[url] else { return image }
        return store.content.getImage(type: type)
      }
      .subscribe(on: Self.imageProcessingQueue)
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }

  public enum RemoteImagePhase {
    case empty
    case success(Image)
    case failure(Error)

    var isEmpty: Bool {
      guard case .empty = self else { return false }
      return true
    }

    var image: Image? {
      guard case let .success(image) = self else { return .none }
      return image
    }

    var error: Error? {
      guard case let .failure(error) = self else { return .none }
      return error
    }
  }

}
