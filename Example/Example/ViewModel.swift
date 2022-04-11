import Combine
import Foundation
import SwiftUI

// MARK: - ViewModel

final class ViewModel: ObservableObject {

  // MARK: Lifecycle

  init() {}

  // MARK: Internal

  @Published var items: [Response.Item] = []

  func fetchImageList(page: Int) {

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self = self else { return }
      Just([Response.Item]())
        .eraseToAnyPublisher()
        .sink(receiveValue: { [weak self] items in
          guard let self = self else { return }
          self.items = items
        })
        .store(in: &self.cancelables)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
      guard let self = self else { return }

      Just([Response.Item]())
        .eraseToAnyPublisher()
        .sink(receiveValue: { [weak self] items in
          guard let self = self else { return }
          self.items = items
        })
        .store(in: &self.cancelables)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in

      guard let self = self else { return }

      self.requestImageList(page)
        .sink(receiveValue: { [weak self] items in
          guard let self = self else { return }
          self.items = items
        })
        .store(in: &self.cancelables)
    }


  }

  // MARK: Private

  private var cancelables: Set<AnyCancellable> = []

  private lazy var backgroundQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 5
    return queue
  }()

  private var requestImageList: (Int) -> AnyPublisher<[Response.Item], Never> {
    { page in
      let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=30")

      return URLSession.shared
        .dataTaskPublisher(for: url!)
        .map(\.data)
        .decode(type: [Response.Item].self, decoder: JSONDecoder())
        .catch { error -> Just<[Response.Item]> in
          print(error.localizedDescription)
          return .init([])
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
  }
}

// MARK: - Response

enum Response {
  struct Item: Decodable, Identifiable {
    let id: String
    let downloadURL: String

    private enum CodingKeys: String, CodingKey {
      case id
      case downloadURL = "download_url"
    }
  }
}
