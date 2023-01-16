import Capacitor
import Foundation

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SharingPlugin)
public class SharingPlugin: CAPPlugin {
    private let implementation = Sharing()


    @objc func share(_ call: CAPPluginCall) {
        var image: UIImage? = nil

        if let imageBase64 = call.getString("imageBase64") {
            image = UIImage(data: base64StringToData(imageBase64)!)
        }

        var url: URL? = nil
        if let urlStr = call.getString("url") {
            url = URL(string: urlStr)
        }

        DispatchQueue.main.async {
            self.implementation.share(text: call.getString("text"), url: url, image: image, sender: self.bridge?.viewController?.view)
        }
        call.resolve()
    }

    @objc func shareToInstagramStories(_ call: CAPPluginCall) {
        guard let facebookAppId = call.getString("facebookAppId") else {
            call.reject("Must provide a facebookAppId")
            return
        }
        var backgroundImage: UIImage? = nil
        if let backgroundImageBase64 = call.getString("backgroundImageBase64") {
            backgroundImage = UIImage(data: base64StringToData( backgroundImageBase64)!)
        }
        let backgroundTopColor = call.getString("backgroundTopColor")
        let backgroundBottomColor = call.getString("backgroundBottomColor")

        var stickerImage: UIImage? = nil
        if let stickerImageBase64 = call.getString("stickerImageBase64") {
            stickerImage = UIImage(data:base64StringToData(stickerImageBase64)!)
        }
        DispatchQueue.main.async {
            self.implementation.shareToInstagramStories(facebookAppId, backgroundImage: backgroundImage, backgroundTopColor: backgroundTopColor, backgroundBottomColor: backgroundBottomColor, stickerImage: stickerImage)
            call.resolve()
            
        }
    }

    @objc func canShareToInstagramStories(_ call: CAPPluginCall) {
        guard let facebookAppId = call.getString("facebookAppId") else {
            call.reject("Must provide a facebookAppId")
            return
        }
        DispatchQueue.main.async {
            let value = self.implementation.canShareToInstagramStories(facebookAppId)
            call.resolve([
                "value": value
            ])
        }
    }
    
    @objc private func base64StringToData(_ str: String) -> Data? {
        if str.contains("data:image") {
            guard let url = URL(string: str) else { return nil }
            return try? Data(contentsOf: url)
        }else {
            return Data(base64Encoded: str, options: .ignoreUnknownCharacters)
        }
    }
}
