import Foundation

@objc public class Sharing: NSObject {
    @objc public func share(text: String?, url: URL?, image: UIImage?, sender: UIView?) {

        let activityItems = [ text as Any, image as Any,url as Any,].compactMap ({ $0 })

        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let sender = sender {
            activityViewController.popoverPresentationController?.sourceView = sender
        }
            UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)

    }

    @objc public func shareToFacebookStories(_ facebookAppId: String, backgroundImage: UIImage?, backgroundTopColor: String?, backgroundBottomColor: String?, stickerImage: UIImage?) {
        var pasteboardItems: [String: Any] = [:]

        if let backgroundImageData = backgroundImage?.pngData() {
            pasteboardItems["com.facebook.sharedSticker.backgroundImage"] = backgroundImageData
        }

        if let stickerImageData = stickerImage?.pngData() {
            pasteboardItems["com.facebook.sharedSticker.stickerImage"] = stickerImageData
        }

        if let backgroundTopColor = backgroundTopColor {
            pasteboardItems["com.facebook.sharedSticker.backgroundTopColor"] = backgroundTopColor
        }

        if let backgroundBottomColor = backgroundBottomColor {
            pasteboardItems["com.facebook.sharedSticker.backgroundBottomColor"] = backgroundBottomColor
        }

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5),
        ]
        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
        UIApplication.shared.open(getFacebookStoriesUrl(facebookAppId), options: [:], completionHandler: nil)
    }


    @objc public func shareToInstagramStories(_ facebookAppId: String, backgroundImage: UIImage?, backgroundTopColor: String?, backgroundBottomColor: String?, stickerImage: UIImage?) {
        var pasteboardItems: [String: Any] = [:]

        if let backgroundImageData = backgroundImage?.pngData() {
            pasteboardItems["com.instagram.sharedSticker.backgroundImage"] = backgroundImageData
        }

        if let stickerImageData = stickerImage?.pngData() {
            pasteboardItems["com.instagram.sharedSticker.stickerImage"] = stickerImageData
        }

        if let backgroundTopColor = backgroundTopColor {
            pasteboardItems["com.instagram.sharedSticker.backgroundTopColor"] = backgroundTopColor
        }

        if let backgroundBottomColor = backgroundBottomColor {
            pasteboardItems["com.instagram.sharedSticker.backgroundBottomColor"] = backgroundBottomColor
        }

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5),
        ]
        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
        UIApplication.shared.open(getInstagramStoriesUrl(facebookAppId), options: [:], completionHandler: nil)
    }

    @objc public func canShareToFacebookStories(_ facebookAppId: String) -> Bool {
        return UIApplication.shared.canOpenURL(getFacebookStoriesUrl(facebookAppId))
    }

    @objc private func getInstagramStoriesUrl(_ facebookAppId: String) -> URL {
        return URL(string: "facebook-stories://share?source_application=\(facebookAppId)")!
    }

    @objc public func canShareToInstagramStories(_ facebookAppId: String) -> Bool {
        return UIApplication.shared.canOpenURL(getInstagramStoriesUrl(facebookAppId))
    }

    @objc private func getInstagramStoriesUrl(_ facebookAppId: String) -> URL {
        return URL(string: "instagram-stories://share?source_application=\(facebookAppId)")!
    }
}
