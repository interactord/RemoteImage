import Foundation
import SwiftUI

// MARK: - RemoteImage

public struct RemoteImage<Content: View> {

  // MARK: Lifecycle

  public init<I: View, P: View>(
    url: String,
    type: CacheStore.ContentType,
    @ViewBuilder content: @escaping (Image) -> I,
    @ViewBuilder placeholer: @escaping () -> P) where Content == _ConditionalContent<I, P> {
      self.init(url: url, type: type) { phase in
        if let image = phase.image {
          content(image)
        } else {
          placeholer()
        }
      }
  }

  let url: String

  // MARK: Private

  @StateObject private var loader: ImageLoader = .init()

  let type: CacheStore.ContentType
  let content: (ImageLoader.RemoteImagePhase) -> Content


  init(
    url: String,
    type: CacheStore.ContentType,
    @ViewBuilder content: @escaping (ImageLoader.RemoteImagePhase) -> Content) {
      self.url = url
      self.type = type
      self.content = content
    }
}

// MARK: View

extension RemoteImage: View {

  // MARK: Public

  public var body: some View {
    content(loader.phase)
      .onAppear {
        guard let url = URL(string: url) else { return }
        loader.load(url: url, type: type)
      }
  }
}
