import Foundation
import UIKit

extension UIImage {
  func decodedImage() -> UIImage {
    guard let cgImage = cgImage else { return self }
    let size = CGSize(width: cgImage.width, height: cgImage.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(
      data: .none,
      width: Int(size.width),
      height: Int(size.height),
      bitsPerComponent: 8,
      bytesPerRow: cgImage.bytesPerRow,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    context?.draw(cgImage, in: .init(origin: .zero, size: size))
    guard let decodedImage = context?.makeImage() else { return self }
    return UIImage(cgImage: decodedImage)
  }

  func resizing(scale: CGFloat) -> UIImage {
    guard let cgImage = cgImage else { return self }
    let scale = scale.clamped(range: 0.0 ... 1.0)
    let newSize = CGSize(
      width: CGFloat(cgImage.width) * scale,
      height: CGFloat(cgImage.height) * scale)
    return resizing(newSize: newSize) ?? self
  }

  func resizing(newSize: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(newSize, false, .zero)
    defer { UIGraphicsEndImageContext() }

    draw(in: .init(origin: .zero, size: newSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }

  func resizingBySreenWidth() -> UIImage {
    guard let cgImage = cgImage else { return self }
    let fullWidth = UIScreen.main.bounds.width
    let ratio = fullWidth / CGFloat(cgImage.width)
    let newSize = CGSize(
      width: fullWidth,
      height: CGFloat(cgImage.height) * ratio)

    return resizing(newSize: newSize) ?? self
  }
}

extension Comparable {
  fileprivate func clamped(range: ClosedRange<Self>) -> Self {
    min(max(self, range.lowerBound), range.upperBound)
  }
}
