import Capacitor
import Foundation
import UIKit
import Photos
import ObjectiveC

@objc(Sharing)
public class Sharing: NSObject {
  private var documentInteractionController: UIDocumentInteractionController?
  
  @objc public func canSaveToPhotoLibrary(_ call: CAPPluginCall, plugin: SharingPlugin? = nil) {
    DispatchQueue.main.async {
      let status: PHAuthorizationStatus
      if #available(iOS 14, *) {
        status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      } else {
        status = PHPhotoLibrary.authorizationStatus()
      }
      
      let hasPermission = (status == .authorized || status == .limited)
      call.resolve(["value": hasPermission])
    }
  }
  
  @objc public func requestPhotoLibraryPermissions(_ call: CAPPluginCall, plugin: SharingPlugin? = nil) {
    // Set up notification to handle app becoming active again after permission dialog
    NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      NotificationCenter.default.removeObserver(self as Any, name: UIApplication.didBecomeActiveNotification, object: nil)
      
      // Check the permission status after returning to the app
      DispatchQueue.main.async {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
          status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
          status = PHPhotoLibrary.authorizationStatus()
        }
        
        let hasPermission = (status == .authorized || status == .limited)
        call.resolve(["value": hasPermission])
      }
    }
    
    // Request permissions
    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        // This callback may not be called if the user leaves the permission dialog without making a choice
        if status != .notDetermined {
          DispatchQueue.main.async {
            let hasPermission = (status == .authorized || status == .limited)
            call.resolve(["value": hasPermission])
          }
        }
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        // This callback may not be called if the user leaves the permission dialog without making a choice
        if status != .notDetermined {
          DispatchQueue.main.async {
            let hasPermission = (status == .authorized)
            call.resolve(["value": hasPermission])
          }
        }
      }
    }
  }
  
  @objc public func share(_ call: CAPPluginCall, plugin: SharingPlugin) {
    var image: UIImage? = nil

    if let backgroundImageBase64 = call.getString("backgroundImageBase64") {
      image = UIImage(data: base64StringToData(backgroundImageBase64)!)
    }

    var url: URL? = nil
    if let urlStr = call.getString("url") {
      url = URL(string: urlStr)
    }

    let text = call.getString("text")

    DispatchQueue.main.async {
      let activityItems = [text as Any, image as Any, url as Any].compactMap({
        $0
      })

      let actionController = UIActivityViewController(
        activityItems: activityItems, applicationActivities: nil)
      if let sender = plugin.bridge?.viewController?.view {
        actionController.popoverPresentationController?.sourceView = sender
      }

      actionController.completionWithItemsHandler = {
        (activityType, completed, _ returnedItems, activityError) in
        if activityError != nil {
          call.reject("Error sharing item", nil, activityError)
          return
        }

        call.resolve([
          "status": completed ? "success" : "cancelled",
          "target": activityType?.rawValue ?? "",
        ])
      }
      
      if plugin.bridge?.viewController?.presentedViewController != nil {
        call.reject("Can't share while sharing is in progress")
        return
      }
      
      plugin.setCenteredPopover(actionController)
      plugin.bridge?.viewController?.present(actionController, animated: true, completion: nil)
    }
    call.resolve()
  }

  @objc public func canShareTo(_ call: CAPPluginCall, plugin: SharingPlugin? = nil) {
    guard let shareTo = call.getString("shareTo") else {
      call.reject("Must provide a shareTo")
      return
    }

    if let handler = createHandler(for: shareTo) {
      handler.call = call
      handler.plugin = plugin
      handler.checkAvailability { isAvailable, error in
        if let error = error {
          call.reject(error)
        } else {
          call.resolve(["value": isAvailable])
        }
      }
    } else {
      call.reject("Unsupported target")
    }
  }

  @objc public func shareTo(_ call: CAPPluginCall, plugin: SharingPlugin? = nil) {
    guard let shareTo = call.getString("shareTo") else {
      call.reject("Must provide a shareTo")
      return
    }

    if let handler = createHandler(for: shareTo) {
      handler.call = call
      handler.plugin = plugin
      handler.share { success, error in
        if let error = error {
          call.reject(error)
        } else {
          call.resolve(["value": success])
        }
      }
    } else {
      call.reject("Unsupported target")
    }
  }
  
  @objc public func shareToInstagramStories(_ call: CAPPluginCall, plugin: SharingPlugin? = nil) {
    // Instead of creating a new call, modify the existing one
    call.options["shareTo"] = "instagramStories"
    
    // Call the main implementation with the modified call
    shareTo(call, plugin: plugin)
  }
  
  @objc public func canShareToInstagramStories(_ call: CAPPluginCall, plugin: SharingPlugin? = nil) {
    // Instead of creating a new call, modify the existing one
    call.options["shareTo"] = "instagramStories"
    
    // Call the main implementation with the modified call
    canShareTo(call, plugin: plugin)
  }

  private func createHandler(for target: String) -> ShareTargetHandler? {
    switch target {
    case "instagramStories":
      return MetaHandler(platform: "instagram", placement: "stories")
    case "facebookStories":
      return MetaHandler(platform: "facebook", placement: "stories")
    case "instagramFeed":
      return InstagramFeedHandler()
    case "native":
      return NativeHandler()
    default:
      return nil
    }
  }
}

func base64StringToData(_ str: String) -> Data? {
  if str.contains("data:image") {
    guard let url = URL(string: str) else { return nil }
    return try? Data(contentsOf: url)
  } else {
    return Data(base64Encoded: str, options: .ignoreUnknownCharacters)
  }
}

class ShareTargetHandler: NSObject {
  public var call: CAPPluginCall?
  public var plugin: SharingPlugin?

  override init() {}

  func checkAvailability(completion: @escaping (Bool, String?) -> Void) {}
  func share(completion: @escaping (Bool, String?) -> Void) {}
}

class MetaHandler: ShareTargetHandler {
  private let platform: String  // facebook or instagram
  private let placement: String  // stories or feed

  init(platform: String, placement: String) {
    self.platform = platform
    self.placement = placement
  }

  override func checkAvailability(completion: @escaping (Bool, String?) -> Void) {
    DispatchQueue.main.async {
      guard let facebookAppId = self.call?.getString("facebookAppId") else {
        completion(false, "Must provide a facebookAppId")
        return
      }

      let value = UIApplication.shared.canOpenURL(self.getShareUrl(facebookAppId))

      completion(value, nil)
    }
  }

  override func share(completion: @escaping (Bool, String?) -> Void) {
    DispatchQueue.main.async {
        guard let facebookAppId = self.call?.getString("facebookAppId") else {
            completion(false, "Must provide a facebookAppId")
            return
        }
        
        guard let call = self.call else {
            completion(false, "Must provide a call")
            return
        }

        let shareUrl = self.getShareUrl(facebookAppId)

        var backgroundImage: UIImage? = nil
        if let backgroundImageBase64 = call.getString("backgroundImageBase64") {
            backgroundImage = UIImage(data: base64StringToData(backgroundImageBase64)!)
        }
        
        let backgroundTopColor = call.getString("backgroundTopColor")
        let backgroundBottomColor = call.getString("backgroundBottomColor")

        var stickerImage: UIImage? = nil
        if let stickerImageBase64 = call.getString("stickerImageBase64") {
            stickerImage = UIImage(data: base64StringToData(stickerImageBase64)!)
        }

        var pasteboardItems: [String: Any] = [:]

        if let backgroundImageData = backgroundImage?.pngData() {
            pasteboardItems["com.\(self.platform).sharedSticker.backgroundImage"] = backgroundImageData
        }

        if let stickerImageData = stickerImage?.pngData() {
            pasteboardItems["com.\(self.platform).sharedSticker.stickerImage"] = stickerImageData
        }

        if let backgroundTopColor = backgroundTopColor {
            pasteboardItems["com.\(self.platform).sharedSticker.backgroundTopColor"] = backgroundTopColor
        }

        if let backgroundBottomColor = backgroundBottomColor {
            pasteboardItems["com.\(self.platform).sharedSticker.backgroundBottomColor"] = backgroundBottomColor
        }

        if self.platform == "facebook" {
            pasteboardItems["com.facebook.sharedSticker.appID"] = facebookAppId
        }

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5)
        ]
        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
        UIApplication.shared.open(
            shareUrl, options: [:], completionHandler: nil)

        completion(true, nil)
    }
  }

  private func getShareUrl(_ facebookAppId: String) -> URL {
    return URL(string: "\(platform)-\(placement)://share?source_application=\(facebookAppId)")!
  }
}

// Static property to hold values across notification events
private var pendingShareInfo: [String: Any] = [:]

class InstagramFeedHandler: ShareTargetHandler {
  override func checkAvailability(completion: @escaping (Bool, String?) -> Void) {
    DispatchQueue.main.async {
      // Check if Instagram is installed
      let instagramURL = URL(string: "instagram://app")!
      let isInstagramAvailable = UIApplication.shared.canOpenURL(instagramURL)
      completion(isInstagramAvailable, isInstagramAvailable ? nil : "Instagram app not installed")
    }
  }
  
  override func share(completion: @escaping (Bool, String?) -> Void) {
    guard let call = self.call else {
      completion(false, "Must provide a call")
      return
    }
  
    guard let backgroundImageBase64 = call.getString("backgroundImageBase64"),
          let imageData = base64StringToData(backgroundImageBase64),
          let image = UIImage(data: imageData) else {
      completion(false, "Invalid image data")
      return
    }
    
    // Check if Instagram is available
    if !UIApplication.shared.canOpenURL(URL(string: "instagram://app")!) {
      completion(false, "Instagram app not installed")
      return
    }
    
    // Check if photo library permissions are already granted
    let status: PHAuthorizationStatus
    if #available(iOS 14, *) {
      status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    } else {
      status = PHPhotoLibrary.authorizationStatus()
    }
    
    let hasPermission = (status == .authorized || status == .limited)
    
    if hasPermission {
      // If permission is already granted, save and share directly
      saveAndShareToInstagram(image: image, completion: completion)
    } else {
      // We need to inform the user that permissions are required
      completion(false, "Photo library permission required to share to Instagram Feed")
    }
  }
  
  // A new function that handles saving to photo library and sharing to Instagram
  func saveAndShareToInstagram(image: UIImage, completion: @escaping (Bool, String?) -> Void) {
    // Save the image to the photo library
    saveImageToPhotoLibrary(image) { success, localIdentifier in
      if success, let localIdentifier = localIdentifier {
        // Open Instagram with the local identifier of the saved image
        self.openInstagramWithLocalIdentifier(localIdentifier, completion: completion)
      } else {
        completion(false, "Failed to save image to photo library")
      }
    }
  }
  
  // Static helper function to check photo library permissions
  static func checkPhotoLibraryPermissions() -> Bool {
    let status: PHAuthorizationStatus
    if #available(iOS 14, *) {
      status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    } else {
      status = PHPhotoLibrary.authorizationStatus()
    }
    
    return (status == .authorized || status == .limited)
  }
  
  private func saveImageToPhotoLibrary(_ image: UIImage, completion: @escaping (Bool, String?) -> Void) {
    var localIdentifier: String?
    
    PHPhotoLibrary.shared().performChanges({
      // Request to save the image
      let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
      localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
    }) { success, error in
      DispatchQueue.main.async {
        if success {
          completion(true, localIdentifier)
        } else {
          print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
          completion(false, nil)
        }
      }
    }
  }
  
  private func openInstagramWithLocalIdentifier(_ localIdentifier: String, completion: @escaping (Bool, String?) -> Void) {
    // URL encode the local identifier
    guard let encodedIdentifier = localIdentifier.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      completion(false, "Failed to encode local identifier")
      return
    }
    
    // Create the Instagram URL with the local identifier
    let instagramURL = URL(string: "instagram://library?LocalIdentifier=\(encodedIdentifier)")!
    
    // Open Instagram
    UIApplication.shared.open(instagramURL, options: [:]) { success in
      if success {
        // Successfully opened Instagram
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          completion(true, nil)
        }
      } else {
        completion(false, "Failed to open Instagram")
      }
    }
  }
}

class NativeHandler: ShareTargetHandler {
  override func checkAvailability(completion: @escaping (Bool, String?) -> Void) {
    completion(true, nil)  // Always available
  }
  
  override func share(completion: @escaping (Bool, String?) -> Void) {
    completion(true, nil)
  }
}
