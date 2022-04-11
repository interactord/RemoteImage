import RemoteImage
import SwiftUI

// MARK: - ContentView

struct ContentView: View {

  // MARK: Internal

  var body: some View {
    ScrollView {
      VStack {
        Button(action: {
          viewModel.fetchImageList(page: 2)
        }) {
          Text("Reload")
        }

        ForEach(viewModel.items) { item in
          RemoteImage(
            url: item.downloadURL,
            type: .thumbnail,
            content: {
              $0.resizable().aspectRatio(contentMode: .fit)
            }, placeholer: {
              Text("Loading...")
                .background(Color.red)
            })
        }
      }
    }
    .onAppear {
      viewModel.fetchImageList(page: 1)
    }
  }

  // MARK: Private

  @StateObject private var viewModel = ViewModel()
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
